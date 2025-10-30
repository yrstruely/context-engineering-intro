# Keeping MSW and Pact Stubs in Sync

## 🎯 The Challenge

You want to use MSW for rich Cucumber test data, but you need to ensure the response structure matches your Pact contracts.

**Goal:** MSW returns rich data, but the **structure** must match Pact contracts exactly.

---

## ✅ Solution: Automated Sync Strategies

### Strategy 1: Generate MSW Handlers from Pact Contracts (Recommended)

**Concept:** Use Pact contract files as the source of truth to generate MSW handlers.

### Strategy 2: Shared Type Definitions

**Concept:** Define TypeScript types that both Pact and MSW must follow.

### Strategy 3: Validation Tests

**Concept:** Automated tests that verify MSW responses match Pact structure.

---

## 🏆 Strategy 1: Generate MSW from Pact (Best)

### How It Works

```
1. Run Pact tests → Generate contracts
2. Read contract JSON files
3. Generate MSW handlers with correct structure
4. Populate with rich test data
```

### Implementation

#### Step 1: Create Contract-to-MSW Generator

```typescript
// scripts/generate-msw-from-pact.ts
import fs from 'fs'
import path from 'path'
import { http, HttpResponse } from 'msw'

interface PactContract {
  interactions: Array<{
    description: string
    request: {
      method: string
      path: string
    }
    response: {
      status: number
      body: any
    }
    providerState?: string
  }>
}

// Data generators for different types
const generators = {
  string: (example: string) => example,
  integer: (example: number) => example,
  decimal: (example: number) => example,
  boolean: (example: boolean) => example,
  iso8601DateTime: () => new Date().toISOString(),
  
  // Generate multiple items for arrays
  array: (template: any, count: number = 5) => {
    return Array.from({ length: count }, (_, i) => 
      enrichTemplate(template, i)
    )
  }
}

function enrichTemplate(template: any, index: number = 0): any {
  if (Array.isArray(template)) {
    return template.map((item, i) => enrichTemplate(item, i))
  }
  
  if (typeof template === 'object' && template !== null) {
    const enriched: any = {}
    
    for (const [key, value] of Object.entries(template)) {
      if (typeof value === 'object' && value !== null) {
        // Handle Pact matchers
        if ('pact:matcher:type' in value) {
          enriched[key] = enrichPactMatcher(value, index)
        } else if ('contents' in value && 'min' in value) {
          // eachLike matcher
          enriched[key] = generators.array(
            enrichTemplate(value.contents, 0),
            5 // Generate 5 items by default
          )
        } else {
          enriched[key] = enrichTemplate(value, index)
        }
      } else {
        enriched[key] = value
      }
    }
    
    return enriched
  }
  
  return template
}

function enrichPactMatcher(matcher: any, index: number): any {
  const type = matcher['pact:matcher:type']
  const value = matcher.value
  
  switch (type) {
    case 'type':
      return enrichTemplate(value, index)
    case 'regex':
      return value // Use example value
    case 'integer':
      return typeof value === 'number' ? value + index : value
    case 'decimal':
      return value
    case 'boolean':
      return value
    default:
      return value
  }
}

function generateHandlers(contract: PactContract): string {
  const handlers = contract.interactions.map(interaction => {
    const { method, path } = interaction.request
    const { status, body } = interaction.response
    
    // Enrich the body with more data
    const enrichedBody = enrichTemplate(body)
    
    // Generate rich data variants
    const variants = {
      default: enrichedBody,
      empty: replaceArraysWithEmpty(body),
      many: replaceArraysWithMany(body, 20),
    }
    
    return `
  // ${interaction.description}
  http.${method.toLowerCase()}('${path}', ({ request }) => {
    const url = new URL(request.url)
    const scenario = url.searchParams.get('scenario')
    
    // Handle different scenarios
    if (scenario === 'empty') {
      return HttpResponse.json(${JSON.stringify(variants.empty, null, 2)}, {
        status: ${status}
      })
    }
    
    if (scenario === 'many') {
      return HttpResponse.json(${JSON.stringify(variants.many, null, 2)}, {
        status: ${status}
      })
    }
    
    // Default: enriched response
    return HttpResponse.json(${JSON.stringify(variants.default, null, 2)}, {
      status: ${status}
    })
  }),`
  }).join('\n')
  
  return `
// Generated from Pact contracts - DO NOT EDIT MANUALLY
// To regenerate: npm run generate:msw

import { http, HttpResponse } from 'msw'

export const generatedHandlers = [${handlers}
]
`
}

function replaceArraysWithEmpty(obj: any): any {
  if (Array.isArray(obj)) return []
  if (typeof obj !== 'object' || obj === null) return obj
  
  const result: any = {}
  for (const [key, value] of Object.entries(obj)) {
    result[key] = replaceArraysWithEmpty(value)
  }
  return result
}

function replaceArraysWithMany(obj: any, count: number): any {
  if (Array.isArray(obj) && obj.length > 0) {
    return Array.from({ length: count }, (_, i) => 
      enrichTemplate(obj[0], i)
    )
  }
  if (typeof obj !== 'object' || obj === null) return obj
  
  const result: any = {}
  for (const [key, value] of Object.entries(obj)) {
    result[key] = replaceArraysWithMany(value, count)
  }
  return result
}

// Main execution
const pactsDir = path.join(process.cwd(), 'test/pact/pacts')
const outputFile = path.join(process.cwd(), 'test/e2e/mocks/generated-handlers.ts')

try {
  const contractFiles = fs.readdirSync(pactsDir)
    .filter(f => f.endsWith('.json'))
  
  const allHandlers: string[] = []
  
  for (const file of contractFiles) {
    const contractPath = path.join(pactsDir, file)
    const contract: PactContract = JSON.parse(
      fs.readFileSync(contractPath, 'utf-8')
    )
    
    const handlers = generateHandlers(contract)
    allHandlers.push(handlers)
  }
  
  fs.writeFileSync(outputFile, allHandlers.join('\n\n'))
  
  console.log('✅ Generated MSW handlers from Pact contracts')
  console.log(`   Output: ${outputFile}`)
} catch (error) {
  console.error('❌ Failed to generate MSW handlers:', error)
  process.exit(1)
}
```

#### Step 2: Add Script to package.json

```json
{
  "scripts": {
    "generate:msw": "ts-node scripts/generate-msw-from-pact.ts",
    "test:pact": "vitest --config vitest.pact.config.ts",
    "posttest:pact": "npm run generate:msw"
  }
}
```

#### Step 3: Use Generated + Custom Handlers

```typescript
// test/e2e/mocks/handlers.ts
import { generatedHandlers } from './generated-handlers'
import { http, HttpResponse } from 'msw'

// Custom handlers for special cases
const customHandlers = [
  // Override generated handler for specific scenario
  http.get('/api/users', ({ request }) => {
    const url = new URL(request.url)
    
    if (url.searchParams.get('scenario') === 'admin-only') {
      return HttpResponse.json({
        success: true,
        data: [
          { id: 'USR-001', name: 'Admin User', role: 'admin', active: true },
        ]
      })
    }
    
    // Fall through to generated handler
    return undefined
  }),
]

// Combine custom handlers (higher priority) with generated
export const handlers = [
  ...customHandlers,
  ...generatedHandlers,
]
```

#### Step 4: Workflow

```bash
# 1. Update Pact tests
# 2. Run Pact tests (generates contracts)
npm run test:pact

# 3. MSW handlers auto-generated (via posttest:pact)
# 4. Review generated-handlers.ts
# 5. Add custom scenarios if needed in handlers.ts
```

### Pros & Cons

✅ **Pros:**
- Single source of truth (Pact contracts)
- Automatic sync when contracts change
- Guaranteed structure match
- Generated code = less maintenance

❌ **Cons:**
- Need to write generator script
- Generated code may need customization
- Complex nested structures need careful handling

---

## 🔷 Strategy 2: Shared TypeScript Types

### How It Works

```
1. Define TypeScript types for API responses
2. Both Pact tests and MSW handlers use these types
3. TypeScript ensures structure matches
```

### Implementation

#### Step 1: Define Shared Types

```typescript
// types/api-responses.ts

export interface ApiResponse<T> {
  success: boolean
  data: T
  error?: string
  message?: string
}

export interface User {
  id: string
  name: string
  email: string
  role: 'admin' | 'user' | 'viewer'
  active: boolean
}

export interface Collaborator {
  id: string
  userId: string
  name: string
  email: string
  role: string
  accessLevel: string
  lastActive: string
  applications: string[]
  grantedAt: string
  grantedBy: string
}

export interface Activity {
  id: string
  user: string
  action: string
  details: string
  timestamp: string
  application: string
}

export interface IPAsset {
  id: string
  type: 'patent' | 'trademark' | 'copyright'
  title: string
  description: string
  status: string
  filingDate: string
  owner: string
  applications: Application[]
}

export interface Application {
  id: string
  jurisdiction: string
  applicationNumber: string
  status: string
  filedAt: string
}

export interface Dashboard {
  summary: {
    totalAssets: number
    activePatents: number
    pendingApplications: number
    trademarks: number
    copyrights: number
  }
  recentActivity: Activity[]
  upcomingDeadlines: Deadline[]
  analytics: {
    assetsByType: Record<string, number>
    assetsByStatus: Record<string, number>
    jurisdictionCoverage: Array<{
      jurisdiction: string
      count: number
    }>
  }
}

export interface Deadline {
  id: string
  assetId: string
  title: string
  dueDate: string
  priority: 'high' | 'medium' | 'low'
}
```

#### Step 2: Use Types in Pact Tests

```typescript
// test/pact/apis/core-resources.pact.spec.ts
import { ApiResponse, User } from '../../../types/api-responses'

describe('GET /api/users', () => {
  it('returns all users', async () => {
    await provider
      .given('users exist in the system')
      .uponReceiving('a request for all users')
      .withRequest({
        method: 'GET',
        path: '/api/users',
      })
      .willRespondWith({
        status: 200,
        body: {
          success: boolean(true),
          data: eachLike({
            id: string('USR-001'),
            name: string('John Doe'),
            email: regex('john@example.com', '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'),
            role: string('admin'),
            active: boolean(true),
          } satisfies User), // ← TypeScript validation
        } satisfies ApiResponse<User[]>,
      })
      .executeTest(async (mockServer) => {
        const response = await fetch(`${mockServer.url}/api/users`)
        const data: ApiResponse<User[]> = await response.json()
        
        expect(data.success).toBe(true)
        expect(data.data[0].id).toBeDefined()
      });
  });
});
```

#### Step 3: Use Types in MSW Handlers

```typescript
// test/e2e/mocks/handlers.ts
import { http, HttpResponse } from 'msw'
import { ApiResponse, User, Activity, Dashboard } from '../../../types/api-responses'

export const handlers = [
  http.get('/api/users', (): HttpResponse<ApiResponse<User[]>> => {
    const response: ApiResponse<User[]> = {
      success: true,
      data: [
        {
          id: 'USR-001',
          name: 'John Doe',
          email: 'john@example.com',
          role: 'admin',
          active: true,
        },
        {
          id: 'USR-002',
          name: 'Jane Smith',
          email: 'jane@example.com',
          role: 'user',
          active: true,
        },
        // More users...
      ]
    }
    
    return HttpResponse.json(response)
  }),
  
  http.get('/api/patents/activities', (): HttpResponse<ApiResponse<Activity[]>> => {
    const response: ApiResponse<Activity[]> = {
      success: true,
      data: Array.from({ length: 20 }, (_, i): Activity => ({
        id: `ACT-${String(i + 1).padStart(3, '0')}`,
        user: `User ${i + 1}`,
        action: 'Updated patent',
        details: `Modified section ${i + 1}`,
        timestamp: new Date(Date.now() - i * 3600000).toISOString(),
        application: `APP-${String((i % 3) + 1).padStart(3, '0')}`
      }))
    }
    
    return HttpResponse.json(response)
  }),
]
```

#### Step 4: Add Type Validation Test

```typescript
// test/sync/msw-pact-sync.spec.ts
import { describe, it, expect } from 'vitest'
import { handlers } from '../e2e/mocks/handlers'
import type { ApiResponse, User } from '../../types/api-responses'

describe('MSW-Pact Sync Validation', () => {
  it('MSW handlers return correctly typed responses', async () => {
    // This test will fail at compile-time if types don't match
    
    for (const handler of handlers) {
      // Extract mock response
      const mockRequest = new Request('http://localhost:3000/api/users')
      const response = await handler(mockRequest)
      
      if (response) {
        const data = await response.json()
        
        // TypeScript will validate this matches ApiResponse<User[]>
        const typedData: ApiResponse<User[]> = data
        
        expect(typedData.success).toBeDefined()
        expect(Array.isArray(typedData.data)).toBe(true)
      }
    }
  })
})
```

### Pros & Cons

✅ **Pros:**
- TypeScript provides compile-time validation
- Works with existing tools
- Self-documenting API structure
- IDE autocomplete

❌ **Cons:**
- Need to maintain type definitions
- Types can drift from runtime
- Doesn't validate Pact matchers vs types

---

## 🧪 Strategy 3: Automated Validation Tests

### How It Works

```
1. Run Pact tests → Generate contracts
2. Run MSW handlers → Capture responses
3. Compare structures automatically
4. Fail if mismatch detected
```

### Implementation

```typescript
// test/sync/pact-msw-validator.spec.ts
import { describe, it, expect } from 'vitest'
import fs from 'fs'
import path from 'path'
import { handlers } from '../e2e/mocks/handlers'

interface PactInteraction {
  description: string
  request: { method: string; path: string }
  response: { status: number; body: any }
}

describe('Pact-MSW Structure Validation', () => {
  // Load Pact contracts
  const pactsDir = path.join(process.cwd(), 'test/pact/pacts')
  const contracts = fs.readdirSync(pactsDir)
    .filter(f => f.endsWith('.json'))
    .map(f => JSON.parse(fs.readFileSync(path.join(pactsDir, f), 'utf-8')))
  
  const interactions = contracts.flatMap(c => c.interactions)
  
  for (const interaction of interactions) {
    it(`MSW matches Pact structure for: ${interaction.description}`, async () => {
      const { method, path } = interaction.request
      const pactBody = interaction.response.body
      
      // Find matching MSW handler
      const mockRequest = new Request(`http://localhost:3000${path}`, {
        method: method.toUpperCase(),
      })
      
      let mswResponse: any = null
      for (const handler of handlers) {
        const response = await handler(mockRequest)
        if (response) {
          mswResponse = await response.json()
          break
        }
      }
      
      expect(mswResponse).toBeDefined()
      
      // Validate structure matches
      validateStructure(pactBody, mswResponse, path)
    })
  }
})

function validateStructure(pactBody: any, mswBody: any, path: string) {
  // Check top-level properties
  const pactKeys = Object.keys(flattenPactMatchers(pactBody))
  const mswKeys = Object.keys(mswBody)
  
  for (const key of pactKeys) {
    expect(
      mswKeys,
      `MSW response for ${path} missing key: ${key}`
    ).toContain(key)
  }
  
  // Deep validation
  validateDeep(flattenPactMatchers(pactBody), mswBody, path)
}

function flattenPactMatchers(obj: any): any {
  if (Array.isArray(obj)) {
    return obj.length > 0 ? [flattenPactMatchers(obj[0])] : []
  }
  
  if (typeof obj === 'object' && obj !== null) {
    // Handle Pact matchers
    if ('pact:matcher:type' in obj) {
      return flattenPactMatchers(obj.value)
    }
    
    if ('contents' in obj && 'min' in obj) {
      // eachLike matcher
      return [flattenPactMatchers(obj.contents)]
    }
    
    const result: any = {}
    for (const [key, value] of Object.entries(obj)) {
      result[key] = flattenPactMatchers(value)
    }
    return result
  }
  
  return obj
}

function validateDeep(pact: any, msw: any, path: string, keyPath: string = '') {
  if (Array.isArray(pact) && Array.isArray(msw)) {
    if (msw.length > 0) {
      validateDeep(pact[0], msw[0], path, `${keyPath}[0]`)
    }
    return
  }
  
  if (typeof pact === 'object' && pact !== null) {
    expect(
      typeof msw,
      `Type mismatch at ${path}${keyPath}: expected object, got ${typeof msw}`
    ).toBe('object')
    
    for (const key of Object.keys(pact)) {
      expect(
        msw,
        `MSW missing key at ${path}${keyPath}.${key}`
      ).toHaveProperty(key)
      
      validateDeep(pact[key], msw[key], path, `${keyPath}.${key}`)
    }
  }
  
  // Type validation
  const pactType = typeof pact
  const mswType = typeof msw
  
  if (pactType !== mswType && pact !== null && msw !== null) {
    throw new Error(
      `Type mismatch at ${path}${keyPath}: Pact has ${pactType}, MSW has ${mswType}`
    )
  }
}
```

### Run Validation

```json
{
  "scripts": {
    "test:sync": "vitest run test/sync/pact-msw-validator.spec.ts",
    "test:pact": "vitest --config vitest.pact.config.ts",
    "posttest:pact": "npm run test:sync"
  }
}
```

### Pros & Cons

✅ **Pros:**
- Automated validation
- Catches mismatches immediately
- No code generation needed
- Works with existing handlers

❌ **Cons:**
- Validation logic can be complex
- Runtime validation (not compile-time)
- Need to handle Pact matchers properly

---

## 🎯 Recommended Combination Approach

Use **all three strategies** together for maximum confidence:

```
1. Shared Types (Strategy 2)
   ↓ Define API structure
   
2. Generate MSW from Pact (Strategy 1)
   ↓ Auto-create base handlers
   
3. Validation Tests (Strategy 3)
   ↓ Verify sync in CI
```

### Implementation

```bash
# Workflow
1. Define types in types/api-responses.ts
2. Write Pact tests using types
3. Run: npm run test:pact
4. Auto-generate MSW handlers
5. Customize handlers for rich scenarios
6. Run validation tests
7. Both pass = guaranteed sync! ✅
```

---

## 📋 Complete Example

### 1. Shared Type

```typescript
// types/api-responses.ts
export interface User {
  id: string
  name: string
  email: string
  role: 'admin' | 'user' | 'viewer'
  active: boolean
}
```

### 2. Pact Test

```typescript
// test/pact/apis/users.pact.spec.ts
it('returns users', async () => {
  await provider
    .willRespondWith({
      body: {
        success: boolean(true),
        data: eachLike({
          id: string('USR-001'),
          name: string('John'),
          email: string('john@example.com'),
          role: string('admin'),
          active: boolean(true),
        } satisfies User),
      },
    })
    // ...
});
```

### 3. Generated MSW Handler (Auto)

```typescript
// test/e2e/mocks/generated-handlers.ts (AUTO-GENERATED)
http.get('/api/users', () => {
  return HttpResponse.json({
    success: true,
    data: [
      { id: 'USR-001', name: 'John', email: 'john@example.com', role: 'admin', active: true },
      { id: 'USR-002', name: 'Jane', email: 'jane@example.com', role: 'user', active: true },
      // ... more generated
    ]
  })
})
```

### 4. Custom Handler (Manual)

```typescript
// test/e2e/mocks/handlers.ts
import { generatedHandlers } from './generated-handlers'

const customHandlers = [
  http.get('/api/users', ({ request }) => {
    const url = new URL(request.url)
    
    // Custom scenario
    if (url.searchParams.get('scenario') === 'admins-only') {
      const response: ApiResponse<User[]> = {
        success: true,
        data: [
          { id: 'USR-001', name: 'Admin', email: 'admin@example.com', role: 'admin', active: true }
        ]
      }
      return HttpResponse.json(response)
    }
  })
]

export const handlers = [...customHandlers, ...generatedHandlers]
```

### 5. Validation Test (Auto)

```typescript
// test/sync/validator.spec.ts
it('MSW matches Pact for /api/users', async () => {
  // Automatically validates structure
  validateStructure(pactContract, mswResponse)
})
```

---

## ✅ Best Practices

1. **Types first** - Define shared types
2. **Generate base** - Auto-generate MSW from Pact
3. **Customize** - Add rich scenarios manually
4. **Validate** - Run sync tests in CI
5. **Document** - Note any intentional differences

---

## 🚀 Quick Start

```bash
# 1. Install dependencies
npm install --save-dev ts-node

# 2. Create generator script
# (Copy script from Strategy 1 above)

# 3. Add npm scripts
npm pkg set scripts.generate:msw="ts-node scripts/generate-msw-from-pact.ts"
npm pkg set scripts.posttest:pact="npm run generate:msw"

# 4. Run Pact tests (auto-generates MSW)
npm run test:pact

# 5. Review generated handlers
cat test/e2e/mocks/generated-handlers.ts

# 6. Customize if needed
# Edit test/e2e/mocks/handlers.ts
```

---

## 📊 Summary

| Strategy | Sync Method | Effort | Confidence |
|----------|-------------|--------|------------|
| **Generate from Pact** | Automated | Medium | ⭐⭐⭐⭐⭐ |
| **Shared Types** | TypeScript | Low | ⭐⭐⭐⭐ |
| **Validation Tests** | Runtime checks | Medium | ⭐⭐⭐⭐⭐ |
| **All Three** | Combined | High | ⭐⭐⭐⭐⭐ |

**Recommendation:** Use all three for production confidence! ✅
