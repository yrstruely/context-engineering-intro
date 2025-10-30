# Migration Guide: Pact Frontend Mocks → MSW Rich Mocks + Generated Pact Contracts

**Project**: IP Hub Frontend
**Migration Type**: Replace Pact stub server with MSW for frontend mocks, generate Pact contracts from MSW
**Version**: 1.0
**Date**: 2025-10-30
**Status**: Ready for Implementation

---

## Executive Summary

### Current State
- Pact contracts define API structure AND serve as frontend mocks via `pact-stub-service`
- Limited test data scenarios (one example per endpoint)
- Frontend development depends on Pact stub server running on port 4000
- BDD E2E tests use Pact-stubbed APIs

### Future State
- **MSW** provides rich, scenario-specific mock data for frontend development
- **Pact contracts** generated FROM MSW handlers (single source of truth)
- Environment-based data scenarios (no test-specific query parameters in production APIs)
- Clean separation: MSW for local dev, real APIs for DEV/UAT/STG/PRD

### Benefits
✅ Rich test data for comprehensive BDD scenarios
✅ MSW handlers define what frontend actually needs
✅ Pact contracts auto-generated to match frontend requirements
✅ Reduced maintenance (one source of truth)
✅ Production-like API structure in mocks

---

## Migration Phases Overview

```
Phase 1: Setup MSW Infrastructure (1-2 hours)
├── Install MSW dependencies
├── Create MSW server setup for Node.js
└── Configure environment-based mock data

Phase 2: Create MSW Handlers (3-4 hours)
├── Convert existing Pact contracts to MSW handlers
├── Enrich with scenario-specific data
└── Organize by API domain

Phase 3: Pact Generation Script (2-3 hours)
├── Create script to generate Pact contracts from MSW
├── Add validation to ensure MSW/Pact sync
└── Integrate into AI agent workflow

Phase 4: Update Tests & Configuration (2-3 hours)
├── Update Cucumber step definitions
├── Replace Pact stub server with MSW server
├── Update package.json scripts
└── Update nuxt.config.ts

Phase 5: Update AI Context Documents (1-2 hours)
├── Update BDD frontend agent context
├── Create MSW-specific workflow documents
└── Update TDD green agent context

Phase 6: Validation & Cleanup (1 hour)
├── Run all test suites
├── Remove Pact stub server dependencies
└── Update README
```

**Total Estimated Time**: 10-15 hours

---

## Phase 1: Setup MSW Infrastructure

### 1.1 Install Dependencies

```bash
npm install --save-dev msw@latest
```

**Note**: Remove `@pact-foundation/pact-node` later (used for `pact-stub-service`)

### 1.2 Create MSW Server Setup for Node.js

**File**: `test/msw/server.ts`

```typescript
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

/**
 * MSW server for Node.js environment (tests, local dev)
 * Intercepts HTTP requests and returns mock responses
 */
export const server = setupServer(...handlers)

/**
 * Start MSW server
 * Call this before running tests or starting dev server
 */
export const startMockServer = () => {
  server.listen({
    onUnhandledRequest: 'warn', // Warn about unmocked requests
  })
  console.log('🔶 MSW Server started - API requests will be mocked')
}

/**
 * Stop MSW server
 * Call this after tests complete
 */
export const stopMockServer = () => {
  server.close()
  console.log('🔶 MSW Server stopped')
}

/**
 * Reset handlers between tests
 * Clears any runtime request handlers
 */
export const resetMockServer = () => {
  server.resetHandlers()
}
```

### 1.3 Create MSW Handler Index

**File**: `test/msw/handlers/index.ts`

```typescript
import { http } from 'msw'
import { healthHandlers } from './health'
import { usersHandlers } from './users'
import { collaboratorsHandlers } from './collaborators'
import { ipAssetsHandlers } from './ip-assets'
import { dashboardHandlers } from './dashboard'
import { patentsHandlers } from './patents'

/**
 * All MSW request handlers
 * Each handler intercepts HTTP requests and returns mock responses
 */
export const handlers = [
  ...healthHandlers,
  ...usersHandlers,
  ...collaboratorsHandlers,
  ...ipAssetsHandlers,
  ...dashboardHandlers,
  ...patentsHandlers,
]
```

### 1.4 Create Environment Configuration

**File**: `test/msw/config.ts`

```typescript
/**
 * MSW Configuration
 * Determines which environment's mock data to use
 */

export type Environment = 'test' | 'development' | 'ci'

export const MSW_CONFIG = {
  environment: (process.env.MSW_ENV || 'development') as Environment,
  baseUrl: process.env.API_BASE_URL || 'http://localhost:3000',
  delay: process.env.MSW_DELAY ? parseInt(process.env.MSW_DELAY) : 0, // Response delay in ms
}

/**
 * Get environment-specific data
 * Returns different datasets based on environment
 */
export const getEnvironmentData = <T>(data: Record<Environment, T>): T => {
  return data[MSW_CONFIG.environment] || data.development
}
```

---

## Phase 2: Create MSW Handlers

### 2.1 Create Handler Structure

Create one handler file per API domain. Use existing Pact contracts as reference.

**File**: `test/msw/handlers/users.ts`

```typescript
import { http, HttpResponse, delay } from 'msw'
import { MSW_CONFIG, getEnvironmentData } from '../config'

/**
 * Mock data for users endpoint
 * Different data per environment
 */
const usersData = getEnvironmentData({
  // Test environment: Minimal data for specific test scenarios
  test: [
    { id: 1, name: 'Test User', email: 'test@example.com' },
  ],

  // Development environment: Rich, varied data for UI development
  development: [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
    { id: 3, name: 'Bob Johnson', email: 'bob@example.com' },
    { id: 4, name: 'Alice Williams', email: 'alice@example.com' },
    { id: 5, name: 'Charlie Brown', email: 'charlie@example.com' },
  ],

  // CI environment: Deterministic data for CI/CD pipelines
  ci: [
    { id: 1, name: 'CI User', email: 'ci@example.com' },
  ],
})

const currentUserData = getEnvironmentData({
  test: {
    id: 'USER-001',
    name: 'Alice',
    email: 'alice@example.com',
    role: 'Patent Applicant',
    verified: true,
    createdAt: '2024-01-01T00:00:00.000Z',
    lastLogin: '2024-01-20T10:30:00.000Z',
  },
  development: {
    id: 'USER-001',
    name: 'Alice',
    email: 'alice@example.com',
    role: 'Patent Applicant',
    verified: true,
    createdAt: '2024-01-01T00:00:00.000Z',
    lastLogin: '2024-01-20T10:30:00.000Z',
  },
  ci: {
    id: 'USER-001',
    name: 'Alice',
    email: 'alice@example.com',
    role: 'Patent Applicant',
    verified: true,
    createdAt: '2024-01-01T00:00:00.000Z',
    lastLogin: '2024-01-20T10:30:00.000Z',
  },
})

export const usersHandlers = [
  // GET /api/users - Returns all users
  http.get('/api/users', async () => {
    await delay(MSW_CONFIG.delay)

    return HttpResponse.json({
      success: true,
      data: usersData,
    })
  }),

  // GET /api/users/current - Returns authenticated user
  http.get('/api/users/current', async () => {
    await delay(MSW_CONFIG.delay)

    return HttpResponse.json({
      success: true,
      data: currentUserData,
    })
  }),
]
```

### 2.2 Migration Pattern for Each Existing Pact Contract

For each file in `test/pact/apis/`:

1. **Read the Pact contract** to understand API structure
2. **Create corresponding MSW handler** in `test/msw/handlers/`
3. **Enrich with environment-specific data**
4. **Add realistic variations** (empty states, error states, edge cases)

**Example Conversion**:

```typescript
// OLD: test/pact/apis/core-resources.pact.spec.ts
await provider
  .given('users exist in the system')
  .withRequest({ method: 'GET', path: '/api/users' })
  .willRespondWith({
    status: 200,
    body: {
      success: boolean(true),
      data: eachLike({
        id: integer(1),
        name: string('John Doe'),
        email: regex('john@example.com', '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$'),
      }),
    },
  })

// NEW: test/msw/handlers/users.ts
http.get('/api/users', async () => {
  return HttpResponse.json({
    success: true,
    data: [
      { id: 1, name: 'John Doe', email: 'john@example.com' },
      { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
      // ... more rich data
    ],
  })
})
```

### 2.3 Create All Required Handlers

Based on your existing Pact contracts, create these handler files:

- `test/msw/handlers/health.ts` - Health check endpoint
- `test/msw/handlers/users.ts` - User management
- `test/msw/handlers/collaborators.ts` - Collaborators
- `test/msw/handlers/ip-assets.ts` - IP Assets with filtering
- `test/msw/handlers/dashboard.ts` - Dashboard data
- `test/msw/handlers/patents.ts` - Patent-specific endpoints

**Template for each handler file**:

```typescript
import { http, HttpResponse, delay } from 'msw'
import { MSW_CONFIG, getEnvironmentData } from '../config'

// Define mock data with environment variations
const mockData = getEnvironmentData({
  test: { /* minimal test data */ },
  development: { /* rich development data */ },
  ci: { /* deterministic CI data */ },
})

export const [domain]Handlers = [
  http.get('/api/[endpoint]', async () => {
    await delay(MSW_CONFIG.delay)
    return HttpResponse.json({ success: true, data: mockData })
  }),

  // ... more handlers for this domain
]
```

---

## Phase 3: Pact Generation Script

### 3.1 Create Pact Generation Script

**File**: `scripts/generate-pact-from-msw.ts`

```typescript
import fs from 'fs'
import path from 'path'
import { handlers } from '../test/msw/handlers'
import type { HttpHandler } from 'msw'

/**
 * Generate Pact consumer contracts from MSW handlers
 * This ensures Pact contracts match what the frontend actually needs
 */

interface PactInteraction {
  description: string
  request: {
    method: string
    path: string
    query?: Record<string, string>
  }
  response: {
    status: number
    headers?: Record<string, string>
    body: any
  }
  providerState?: string
}

interface PactContract {
  consumer: { name: string }
  provider: { name: string }
  interactions: PactInteraction[]
  metadata: {
    pactSpecification: { version: string }
  }
}

/**
 * Extract request info from MSW handler
 */
function extractRequestInfo(handler: any): { method: string; path: string } | null {
  try {
    const info = handler.info
    if (info && info.method && info.path) {
      return {
        method: info.method,
        path: typeof info.path === 'string' ? info.path : info.path.source,
      }
    }
  } catch (error) {
    console.warn('Could not extract request info from handler:', error)
  }
  return null
}

/**
 * Call MSW handler to get example response
 */
async function getHandlerResponse(handler: any, requestInfo: { method: string; path: string }): Promise<any> {
  try {
    // Create mock Request object
    const url = `http://localhost:3000${requestInfo.path}`
    const request = new Request(url, { method: requestInfo.method })

    // Call the handler
    const response = await handler.resolver(
      { request, params: {}, cookies: {} },
      {} // response utilities
    )

    if (response && typeof response.json === 'function') {
      return await response.json()
    }
  } catch (error) {
    console.warn(`Could not execute handler for ${requestInfo.method} ${requestInfo.path}:`, error)
  }
  return null
}

/**
 * Convert MSW handler to Pact interaction
 */
async function convertToPactInteraction(handler: any): Promise<PactInteraction | null> {
  const requestInfo = extractRequestInfo(handler)
  if (!requestInfo) return null

  const responseBody = await getHandlerResponse(handler, requestInfo)
  if (!responseBody) return null

  const interaction: PactInteraction = {
    description: `${requestInfo.method} ${requestInfo.path}`,
    request: {
      method: requestInfo.method,
      path: requestInfo.path,
    },
    response: {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
      body: convertToPactMatchers(responseBody),
    },
    providerState: generateProviderState(requestInfo.path, responseBody),
  }

  return interaction
}

/**
 * Convert response body to Pact matchers
 * This generates flexible matchers instead of hardcoded values
 */
function convertToPactMatchers(obj: any): any {
  if (Array.isArray(obj)) {
    if (obj.length === 0) return []

    return {
      'pact:matcher:type': 'eachLike',
      'min': 1,
      'value': convertToPactMatchers(obj[0]),
    }
  }

  if (typeof obj === 'object' && obj !== null) {
    const result: any = {}

    for (const [key, value] of Object.entries(obj)) {
      result[key] = convertToPactMatchers(value)
    }

    return result
  }

  // Primitives with type matchers
  if (typeof obj === 'string') {
    // Email pattern
    if (obj.match(/@/)) {
      return {
        'pact:matcher:type': 'regex',
        'regex': '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
        'value': obj,
      }
    }
    // ISO date pattern
    if (obj.match(/^\d{4}-\d{2}-\d{2}T/)) {
      return {
        'pact:matcher:type': 'regex',
        'regex': '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}',
        'value': obj,
      }
    }
    return { 'pact:matcher:type': 'type', 'value': obj }
  }

  if (typeof obj === 'number') {
    return {
      'pact:matcher:type': Number.isInteger(obj) ? 'integer' : 'decimal',
      'value': obj,
    }
  }

  if (typeof obj === 'boolean') {
    return { 'pact:matcher:type': 'type', 'value': obj }
  }

  return obj
}

/**
 * Generate provider state from endpoint and response
 */
function generateProviderState(path: string, body: any): string {
  const resource = path.split('/').filter(Boolean).pop() || 'resource'

  if (body.data) {
    if (Array.isArray(body.data)) {
      if (body.data.length === 0) {
        return `no ${resource} exist`
      }
      return `${resource} exist in the system`
    }
    return `${resource} data is available`
  }

  return `data exists for ${path}`
}

/**
 * Main execution
 */
async function main() {
  console.log('🔄 Generating Pact contracts from MSW handlers...')

  const interactions: PactInteraction[] = []

  for (const handler of handlers) {
    const interaction = await convertToPactInteraction(handler)
    if (interaction) {
      interactions.push(interaction)
      console.log(`✅ Generated interaction: ${interaction.description}`)
    }
  }

  const pactContract: PactContract = {
    consumer: { name: 'IPManagementFrontend' },
    provider: { name: 'IPManagementBackend' },
    interactions,
    metadata: {
      pactSpecification: { version: '3.0.0' },
    },
  }

  // Write to pacts directory
  const outputDir = path.join(process.cwd(), 'test/pact/pacts')
  const outputFile = path.join(outputDir, 'ip-management-frontend-ip-management-backend.json')

  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true })
  }

  fs.writeFileSync(outputFile, JSON.stringify(pactContract, null, 2))

  console.log(`\n✅ Generated Pact contract: ${outputFile}`)
  console.log(`📊 Total interactions: ${interactions.length}`)
  console.log('\n⚠️  IMPORTANT: Review the generated contract and increment package.json version')
  console.log('⚠️  REMINDER: Publish to Pact Broker after review: npm run pact:publish')
}

main().catch(console.error)
```

### 3.2 Create Validation Script

**File**: `scripts/validate-msw-pact-sync.ts`

```typescript
import fs from 'fs'
import path from 'path'
import { handlers } from '../test/msw/handlers'

/**
 * Validate that MSW handlers and Pact contracts are in sync
 * Run this before publishing contracts to catch mismatches
 */

interface ValidationResult {
  valid: boolean
  errors: string[]
  warnings: string[]
}

function validateSync(): ValidationResult {
  const result: ValidationResult = {
    valid: true,
    errors: [],
    warnings: [],
  }

  // Check 1: Pact contract file exists
  const pactFile = path.join(process.cwd(), 'test/pact/pacts/ip-management-frontend-ip-management-backend.json')
  if (!fs.existsSync(pactFile)) {
    result.errors.push('Pact contract file does not exist. Run: npm run pact:generate')
    result.valid = false
    return result
  }

  // Check 2: Load and parse Pact contract
  let pactContract
  try {
    pactContract = JSON.parse(fs.readFileSync(pactFile, 'utf-8'))
  } catch (error) {
    result.errors.push(`Failed to parse Pact contract: ${error}`)
    result.valid = false
    return result
  }

  // Check 3: Compare number of interactions
  const pactInteractionCount = pactContract.interactions?.length || 0
  const mswHandlerCount = handlers.length

  if (pactInteractionCount !== mswHandlerCount) {
    result.warnings.push(
      `Interaction count mismatch: ${mswHandlerCount} MSW handlers vs ${pactInteractionCount} Pact interactions`
    )
  }

  // Check 4: Verify each MSW handler has corresponding Pact interaction
  // (Implementation depends on how we extract handler info)

  console.log(`\n📊 Validation Summary:`)
  console.log(`   MSW Handlers: ${mswHandlerCount}`)
  console.log(`   Pact Interactions: ${pactInteractionCount}`)

  if (result.errors.length > 0) {
    console.log(`\n❌ Errors:`)
    result.errors.forEach(err => console.log(`   - ${err}`))
  }

  if (result.warnings.length > 0) {
    console.log(`\n⚠️  Warnings:`)
    result.warnings.forEach(warn => console.log(`   - ${warn}`))
  }

  if (result.valid && result.warnings.length === 0) {
    console.log(`\n✅ MSW and Pact are in sync!`)
  }

  return result
}

const result = validateSync()
process.exit(result.valid ? 0 : 1)
```

---

## Phase 4: Update Tests & Configuration

### 4.1 Update Cucumber Setup

**File**: `features/support/hooks.ts` (create if doesn't exist)

```typescript
import { Before, BeforeAll, AfterAll } from '@cucumber/cucumber'
import { startMockServer, stopMockServer, resetMockServer } from '../../test/msw/server'

// Start MSW server before all tests
BeforeAll(async function () {
  // Only start MSW in local/test environments
  if (process.env.NODE_ENV !== 'production' && !process.env.USE_REAL_API) {
    startMockServer()
  }
})

// Reset handlers between scenarios
Before(async function () {
  if (process.env.NODE_ENV !== 'production' && !process.env.USE_REAL_API) {
    resetMockServer()
  }
})

// Stop MSW server after all tests
AfterAll(async function () {
  if (process.env.NODE_ENV !== 'production' && !process.env.USE_REAL_API) {
    stopMockServer()
  }
})
```

### 4.2 Update Vitest Setup

**File**: `test/setup.ts`

Add MSW server lifecycle:

```typescript
import { beforeAll, afterEach, afterAll } from 'vitest'
import { startMockServer, resetMockServer, stopMockServer } from './msw/server'

// Start MSW server before all tests
beforeAll(() => {
  startMockServer()
})

// Reset handlers after each test
afterEach(() => {
  resetMockServer()
})

// Stop MSW server after all tests
afterAll(() => {
  stopMockServer()
})
```

### 4.3 Update package.json Scripts

```json
{
  "scripts": {
    "dev": "nuxt dev",
    "dev:nuxt": "nuxt dev",
    "test": "vitest --run",
    "test:watch": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --run --coverage",
    "test:e2e": "export NODE_OPTIONS='--import=tsx' && npx cucumber-js --import 'features/step-definitions/**/*.ts'",
    "test:e2e:dry": "export NODE_OPTIONS='--import=tsx' && npx cucumber-js --dry-run --format progress-bar",
    "test:e2e:results": "open reports/cucumber_report.html",
    "test:all": "npm run test && npm run test:coverage && npm run test:e2e",

    "pact:generate": "tsx scripts/generate-pact-from-msw.ts",
    "pact:validate": "tsx scripts/validate-msw-pact-sync.ts",
    "pact:publish": "pact-broker publish ./test/pact/pacts --consumer-app-version=$npm_package_version --broker-base-url=http://localhost:9292",
    "pact:workflow": "npm run pact:generate && npm run pact:validate",

    "storybook": "storybook dev -p 6006",
    "build-storybook": "storybook build"
  }
}
```

**Remove**:
```json
"dev:pact-stub": "pact-stub-service ./test/pact/pacts --port 4000 --cors",
```

**Note**: `dev` script no longer runs `run-p dev:nuxt dev:pact-stub`

### 4.4 Update nuxt.config.ts

Remove Pact stub server proxy configuration since MSW runs in-process:

```typescript
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: ['@nuxt/eslint', '@nuxt/test-utils', '@nuxt/ui'],

  // Runtime config for different environments
  runtimeConfig: {
    public: {
      apiBase: process.env.API_BASE_URL || 'http://localhost:3000',
      useMockApi: process.env.USE_MOCK_API !== 'false', // Default to mocks in development
    },
  },

  // Environment-specific overrides
  $production: {
    runtimeConfig: {
      public: {
        apiBase: process.env.API_BASE_URL || 'https://api.production.example.com',
        useMockApi: false,
      },
    },
  },

  $development: {
    runtimeConfig: {
      public: {
        apiBase: 'http://localhost:3000',
        useMockApi: true,
      },
    },
  },

  // For UAT/staging environments
  $test: {
    runtimeConfig: {
      public: {
        apiBase: process.env.UAT_API_URL || 'https://api.uat.example.com',
        useMockApi: false,
      },
    },
  },
})
```

**Remove**: All `nitro.routeRules` and `nitro.devProxy` configurations for `/api/**`

### 4.5 Create Environment Files

**File**: `.env.local` (local development - uses MSW)

```bash
# Local development with MSW mocks
USE_MOCK_API=true
MSW_ENV=development
MSW_DELAY=100
API_BASE_URL=http://localhost:3000
```

**File**: `.env.uat` (UAT environment - real backend)

```bash
# UAT environment with real backend
USE_MOCK_API=false
USE_REAL_API=true
API_BASE_URL=https://api.uat.example.com
```

**File**: `.env.production` (production - real backend)

```bash
# Production environment
USE_MOCK_API=false
USE_REAL_API=true
API_BASE_URL=https://api.production.example.com
```

---

## Phase 5: Update AI Context Documents

### 5.1 Documents Requiring Updates

#### 5.1.1 BDD Frontend Agent Context

**File**: `ai-context/bdd-agents/bdd-frontend-agent/bdd-test-agent-context.md`

**Changes Required**:

1. **Update Step Definition Implementation Section** (lines 500-520):

**OLD**:
```markdown
When('Alice logs in with her valid credentials', async function () {
  this.loginResponse = await this.authService.login({
    email: this.alice.email,
    password: this.alice.password
  });
});
```

**NEW**:
```markdown
When('Alice logs in with her valid credentials', async function () {
  // MSW automatically intercepts this request and returns mock data
  this.loginResponse = await this.authService.login({
    email: this.alice.email,
    password: this.alice.password
  });
});
```

2. **Add MSW Setup Section** after line 665:

```markdown
### MSW Mock Server Setup

The project uses MSW (Mock Service Worker) for API mocking during BDD tests:

**Setup** (in hooks or world.ts):
```typescript
import { startMockServer, resetMockServer } from '../test/msw/server'

Before(async function() {
  // MSW automatically intercepts HTTP requests
  // No additional setup needed in step definitions
})
```

**Making API Requests**:
- Use standard `fetch()`, `axios`, or `page.request.get()`
- MSW intercepts requests automatically
- Returns environment-specific mock data

**Data Scenarios**:
- Controlled via MSW_ENV environment variable
- `development`: Rich data for UI testing
- `test`: Minimal data for specific scenarios
- `ci`: Deterministic data for CI/CD

**No Query Parameters Needed**:
- MSW handlers return production-like responses
- Scenario variations handled via environment config
- Keep API structure clean and production-ready
```

3. **Update World Object Section** (lines 927-960):

**Remove**:
```typescript
this.authService = {
  login: async (credentials) => {
    throw new Error('AuthService.login not implemented');
  }
};
```

**Replace with**:
```typescript
// No need to stub services - MSW handles API mocking
// Services can call real fetch/axios and MSW intercepts
```

#### 5.1.2 TDD Green Agent Context

**File**: `ai-context/frontend-agents/tdd-green-implement-frontend-to-pass-tests/01-template-implement-frontend-to-pass-tests.md`

**Changes Required**:

1. **Update Data Fetching Pattern Section** (line 506):

**OLD**:
```typescript
export const useSomethingData = async (params?: Record<string, any>) => {
  const { data, pending, error, refresh } = await useFetch('/api/endpoint', {
    query: params,
    default: () => ({
      // Default structure
    })
  })
```

**NEW**:
```typescript
export const useSomethingData = async (params?: Record<string, any>) => {
  // In local dev: MSW intercepts and returns mock data
  // In other environments: Real API is called
  const config = useRuntimeConfig()

  const { data, pending, error, refresh } = await useFetch('/api/endpoint', {
    query: params,
    baseURL: config.public.apiBase,
    default: () => ({
      // Default structure
    })
  })
```

2. **Add MSW Context Section** after line 220:

```markdown
### MSW Mock Server Context

**Local Development**:
- MSW runs in-process (no separate server)
- Intercepts all `/api/**` requests automatically
- Returns rich, environment-specific mock data
- Configured via `MSW_ENV` environment variable

**Unit/Integration Tests**:
- MSW started in `test/setup.ts`
- Automatically intercepts `useFetch()` and `fetch()` calls
- No need to mock at component level

**E2E Tests**:
- MSW started in Cucumber hooks
- Playwright requests intercepted via MSW Node.js adapter
- Consistent mock data across test types

**When MSW is NOT used**:
- UAT environment (`USE_REAL_API=true`)
- Staging environment (`USE_REAL_API=true`)
- Production environment (`USE_REAL_API=true`)
```

#### 5.1.3 Create New MSW Workflow Document

**File**: `ai-context/frontend-agents/msw-workflow/msw-handler-creation-guide.md`

**Content**:

```markdown
# MSW Handler Creation Guide for Frontend AI Agents

## When to Create/Update MSW Handlers

Create or update MSW handlers when:
1. Adding new API endpoints to the frontend
2. Adding new fields to existing API responses
3. Creating new BDD scenarios requiring specific data
4. Frontend needs richer mock data for testing

## MSW Handler Creation Process

### Step 1: Analyze API Requirements

**Input**: Feature requirements, BDD scenarios, or component tests

**Actions**:
1. Identify API endpoints needed
2. Determine response structure from tests/requirements
3. Identify data variations needed (success, error, edge cases)
4. Plan environment-specific data sets

### Step 2: Create/Update Handler File

**Location**: `test/msw/handlers/[domain].ts`

**Template**:
```typescript
import { http, HttpResponse, delay } from 'msw'
import { MSW_CONFIG, getEnvironmentData } from '../config'

// Define environment-specific mock data
const mockData = getEnvironmentData({
  test: {
    // Minimal data for specific test assertions
  },
  development: {
    // Rich, varied data for UI development
  },
  ci: {
    // Deterministic data for CI/CD
  },
})

export const [domain]Handlers = [
  http.get('/api/[endpoint]', async () => {
    await delay(MSW_CONFIG.delay)

    return HttpResponse.json({
      success: true,
      data: mockData,
    })
  }),
]
```

### Step 3: Register Handler

Add to `test/msw/handlers/index.ts`:

```typescript
import { [domain]Handlers } from './[domain]'

export const handlers = [
  // ... existing handlers
  ...[domain]Handlers,
]
```

### Step 4: Test Handler

Run tests to verify:
```bash
npm run test           # Unit tests
npm run test:e2e       # BDD E2E tests
```

### Step 5: Generate Pact Contracts

After verifying MSW handlers work:

```bash
npm run pact:generate  # Generate Pact contracts from MSW
npm run pact:validate  # Validate MSW and Pact are in sync
```

**IMPORTANT**: Inform the developer that:
1. Package version may need incrementing
2. Pact contracts need publishing to broker

### Step 6: Update Handler Index

Ensure handler is exported in `test/msw/handlers/index.ts`

## Best Practices

### DO:
✅ Use environment-specific data via `getEnvironmentData()`
✅ Return production-like response structures
✅ Include realistic data variations (not just one example)
✅ Add response delays for realistic testing (`MSW_CONFIG.delay`)
✅ Handle both success and error scenarios
✅ Keep API structure clean (no test-specific query parameters)

### DON'T:
❌ Add test-specific query parameters (e.g., `?scenario=test`)
❌ Hardcode test-specific data in handlers
❌ Return minimal data (enrich with realistic variations)
❌ Forget to add handler to index.ts
❌ Skip Pact generation after MSW changes

## Environment Data Guidelines

**Test Environment** (`test`):
- Minimal data to satisfy specific test assertions
- Predictable, simple datasets
- Used for unit/integration tests

**Development Environment** (`development`):
- Rich, varied data for UI development
- Multiple examples showing different states
- Edge cases (empty, full, partial data)
- Used for `npm run dev`

**CI Environment** (`ci`):
- Deterministic, reproducible data
- Consistent across runs
- Used in CI/CD pipelines

## Error Handling

To mock error responses:

```typescript
http.get('/api/endpoint', async () => {
  // Return error response based on environment or condition
  return HttpResponse.json(
    {
      success: false,
      error: 'Not Found',
      message: 'Resource not found',
    },
    { status: 404 }
  )
})
```

## Complete Example

```typescript
// test/msw/handlers/applications.ts
import { http, HttpResponse, delay } from 'msw'
import { MSW_CONFIG, getEnvironmentData } from '../config'

const applicationsData = getEnvironmentData({
  test: [
    {
      id: 'APP-001',
      name: 'Test Application',
      status: 'in_progress',
      jurisdiction: 'Dubai/UAE',
    },
  ],
  development: [
    {
      id: 'APP-001',
      name: 'Dubai Patent Application',
      status: 'in_progress',
      jurisdiction: 'Dubai/UAE',
      filingDate: '2024-01-15',
      completionPercentage: 45,
    },
    {
      id: 'APP-002',
      name: 'PCT Application',
      status: 'submitted',
      jurisdiction: 'PCT',
      filingDate: '2024-02-01',
      completionPercentage: 100,
    },
    {
      id: 'APP-003',
      name: 'EPO Application',
      status: 'not_started',
      jurisdiction: 'EPO',
      completionPercentage: 0,
    },
  ],
  ci: [
    {
      id: 'APP-CI-001',
      name: 'CI Application',
      status: 'in_progress',
      jurisdiction: 'Dubai/UAE',
    },
  ],
})

export const applicationsHandlers = [
  // GET all applications
  http.get('/api/applications', async () => {
    await delay(MSW_CONFIG.delay)

    return HttpResponse.json({
      success: true,
      data: applicationsData,
      meta: {
        total: applicationsData.length,
      },
    })
  }),

  // GET single application
  http.get('/api/applications/:id', async ({ params }) => {
    await delay(MSW_CONFIG.delay)

    const application = applicationsData.find(app => app.id === params.id)

    if (!application) {
      return HttpResponse.json(
        {
          success: false,
          error: 'Not Found',
        },
        { status: 404 }
      )
    }

    return HttpResponse.json({
      success: true,
      data: application,
    })
  }),
]
```

## Integration with AI Agent Workflow

When implementing new features:

1. **RED Phase**: Write failing tests
2. **Create MSW Handlers**: Provide mock data for tests
3. **GREEN Phase**: Implement frontend code
4. **Run Tests**: Verify all pass
5. **Generate Pact**: Run `npm run pact:generate`
6. **Validate**: Run `npm run pact:validate`
7. **Inform Developer**: Suggest version increment and Pact Broker publish

This ensures frontend development is not blocked while maintaining contract-driven development with the backend.
```

#### 5.1.4 Update Cucumber Context Document

**File**: `ai-context/bdd-agents/cucumber-context-doc.md`

**Add Section** after Playwright setup:

```markdown
### MSW Mock Server Integration

Cucumber tests use MSW for API mocking:

**Setup** (in `features/support/hooks.ts`):
```typescript
import { Before, BeforeAll, AfterAll } from '@cucumber/cucumber'
import { startMockServer, stopMockServer, resetMockServer } from '../../test/msw/server'

BeforeAll(async function () {
  if (!process.env.USE_REAL_API) {
    startMockServer()
  }
})

Before(async function () {
  if (!process.env.USE_REAL_API) {
    resetMockServer()
  }
})

AfterAll(async function () {
  if (!process.env.USE_REAL_API) {
    stopMockServer()
  }
})
```

**In Step Definitions**:
- Use standard HTTP requests (`page.request.get()`, `fetch()`)
- MSW intercepts automatically
- No need to manually stub APIs

**Environment Control**:
- Local dev: MSW provides mocks
- UAT/STG/PRD: `USE_REAL_API=true` disables MSW
```

### 5.2 New AI Agent Prompts

Create prompts for common MSW tasks:

#### **File**: `ai-context/frontend-agents/msw-workflow/prompts/01-template-create-msw-handler.md`

```markdown
# Create MSW Handler Prompt Template

You are creating a new MSW handler for the IP Hub Frontend. Follow the MSW Handler Creation Guide.

## Input

```json
{
  "endpoint": "/api/[resource]",
  "method": "GET|POST|PUT|DELETE",
  "description": "Brief description of what this endpoint does",
  "responseStructure": {
    "success": true,
    "data": {
      // Expected response shape
    }
  },
  "environments": {
    "test": "Description of test data needs",
    "development": "Description of development data needs",
    "ci": "Description of CI data needs"
  },
  "errorScenarios": [
    {
      "status": 404,
      "condition": "When resource not found",
      "response": {}
    }
  ]
}
```

## Tasks

1. Create handler file in `test/msw/handlers/[domain].ts`
2. Define environment-specific mock data
3. Implement success and error scenarios
4. Register in `test/msw/handlers/index.ts`
5. Test with `npm run test`
6. Generate Pact with `npm run pact:generate`
7. Validate with `npm run pact:validate`
8. **Report to Developer**:
   - Changes made
   - Tests passing
   - Suggest: Increment package version
   - Suggest: Publish to Pact Broker with `npm run pact:publish`

## Output

- Handler file path
- Test results
- Pact generation results
- Version increment recommendation
```

---

## Phase 6: Validation & Cleanup

### 6.1 Pre-Migration Checklist

Before starting migration:

- [ ] Commit all current changes to git
- [ ] Create migration branch: `git checkout -b migration/pact-to-msw`
- [ ] Backup `test/pact/` directory
- [ ] Document current Pact contracts for reference
- [ ] Ensure all tests currently pass

### 6.2 Migration Execution Checklist

Execute phases in order:

- [ ] **Phase 1**: Install MSW and create infrastructure
  - [ ] Install msw package
  - [ ] Create `test/msw/server.ts`
  - [ ] Create `test/msw/config.ts`
  - [ ] Create `test/msw/handlers/index.ts`
  - [ ] Test MSW server starts/stops

- [ ] **Phase 2**: Create MSW handlers
  - [ ] Health check handler
  - [ ] Users handlers
  - [ ] Collaborators handlers
  - [ ] IP Assets handlers
  - [ ] Dashboard handlers
  - [ ] Patents handlers
  - [ ] Test each handler with curl/Postman

- [ ] **Phase 3**: Create Pact generation
  - [ ] Create `scripts/generate-pact-from-msw.ts`
  - [ ] Create `scripts/validate-msw-pact-sync.ts`
  - [ ] Run generation script and verify output
  - [ ] Compare generated Pact to original

- [ ] **Phase 4**: Update tests & configuration
  - [ ] Update `test/setup.ts`
  - [ ] Create `features/support/hooks.ts`
  - [ ] Update `package.json` scripts
  - [ ] Update `nuxt.config.ts`
  - [ ] Create environment files (.env.*)

- [ ] **Phase 5**: Update AI context documents
  - [ ] Update BDD frontend agent context
  - [ ] Update TDD green agent context
  - [ ] Create MSW workflow guide
  - [ ] Update Cucumber context doc
  - [ ] Create MSW handler creation prompts

- [ ] **Phase 6**: Validation & cleanup
  - [ ] Run all unit tests: `npm run test`
  - [ ] Run all E2E tests: `npm run test:e2e`
  - [ ] Generate Pact: `npm run pact:generate`
  - [ ] Validate sync: `npm run pact:validate`
  - [ ] Remove old Pact test files
  - [ ] Update README.md

### 6.3 Post-Migration Testing

Run comprehensive test suite:

```bash
# 1. Unit and integration tests
npm run test:coverage

# 2. E2E BDD tests
npm run test:e2e

# 3. Generate and validate Pact
npm run pact:workflow

# 4. Check for errors
# All tests should pass
```

### 6.4 Cleanup Tasks

After successful migration:

**Remove files**:
```bash
# Remove old Pact test files
rm -rf test/pact/apis/

# Keep only:
# - test/pact/pacts/ (generated contracts)
# - test/pact/pact-setup.ts (if still needed for broker publish)
```

**Remove dependencies**:
```bash
npm uninstall @pact-foundation/pact-node
npm uninstall npm-run-all  # If only used for running pact-stub
```

**Remove from package.json**:
- `"test:pact"` script (no longer needed)
- `vitest.pact.config.ts` file

**Update README.md**:

**OLD**:
```markdown
## Development Server

### Start with Pact Stub Server (Recommended)

```bash
npm run dev
```

This runs:
- Nuxt dev server on `http://localhost:3000`
- Pact stub server on `http://localhost:4000`
```

**NEW**:
```markdown
## Development Server

### Start Development Server

```bash
npm run dev
```

This starts the Nuxt dev server on `http://localhost:3000` with MSW providing mock API responses.

**API Mocking**:
- **Local Dev**: MSW intercepts `/api/**` requests automatically
- **UAT/Production**: Real backend APIs used (set `USE_REAL_API=true`)

**Mock Data Control**:
Set `MSW_ENV` to control mock data:
- `development` (default): Rich data for UI development
- `test`: Minimal data for testing
- `ci`: Deterministic data for CI/CD

### Testing

#### Generate Pact Contracts

After creating or updating MSW handlers:

```bash
npm run pact:generate     # Generate contracts from MSW
npm run pact:validate     # Validate MSW and Pact are in sync
npm run pact:publish      # Publish to Pact Broker
```

**Important**: Increment `version` in `package.json` before publishing contracts.
```

### 6.5 Version Control

Commit strategy:

```bash
# Commit Phase 1
git add test/msw/
git commit -m "feat: Add MSW infrastructure and configuration"

# Commit Phase 2
git add test/msw/handlers/
git commit -m "feat: Create MSW handlers from Pact contracts"

# Commit Phase 3
git add scripts/
git commit -m "feat: Add Pact generation and validation scripts"

# Commit Phase 4
git add test/setup.ts features/support/hooks.ts package.json nuxt.config.ts .env.*
git commit -m "feat: Update test configuration to use MSW"

# Commit Phase 5
git add ai-context/
git commit -m "docs: Update AI context for MSW workflow"

# Commit Phase 6
git add README.md
git rm -r test/pact/apis/
git commit -m "chore: Remove Pact stub dependencies and update docs"
```

---

## Migration Decision Points

### Decision 1: MSW Server Architecture

**Question**: Should MSW run as Node.js server or integrated into Nuxt?

**Recommendation**: **Node.js server mode** (setupServer from 'msw/node')

**Rationale**:
- ✅ Works with Playwright E2E tests (`page.request.get()`)
- ✅ Consistent with current Pact stub server approach
- ✅ No Nuxt server modifications needed
- ✅ Clear separation of concerns
- ✅ Easy to disable in production environments

**Implementation**: Use `msw/node` package with `setupServer()`

### Decision 2: Data Scenario Management

**Question**: How to handle different test scenarios?

**Recommendation**: **Environment-based via MSW_ENV**

**Rationale**:
- ✅ Production-like API structure (no query parameters)
- ✅ Clean separation of concerns
- ✅ Easy to extend (add new environments)
- ✅ Aligns with deployment environments
- ❌ Less flexible than query parameters (acceptable trade-off)

**Implementation**:
```typescript
const data = getEnvironmentData({
  test: { /* minimal */ },
  development: { /* rich */ },
  ci: { /* deterministic */ },
})
```

### Decision 3: Pact Generation Timing

**Question**: When should Pact contracts be generated?

**Recommendation**: **Manual with validation**

**Rationale**:
- ✅ Developer controls when contracts change
- ✅ Version increment is intentional
- ✅ Pact Broker publish is deliberate
- ✅ Prevents accidental contract breaking changes
- ✅ AI agent can suggest but not auto-publish

**Implementation**:
```bash
# Manual workflow
npm run pact:generate    # Developer runs after MSW changes
npm run pact:validate    # Verify sync
# Developer reviews, increments version
npm run pact:publish     # Publishes to broker
```

### Decision 4: AI Agent Integration

**Question**: How should AI agents interact with MSW workflow?

**Recommendation**: **AI creates handlers, suggests Pact workflow**

**Rationale**:
- ✅ AI can create/update MSW handlers safely
- ✅ AI cannot break contracts accidentally
- ✅ Human approval for version bumps
- ✅ Human approval for broker publish
- ⚠️ AI must remind developer of Pact workflow

**Implementation**:
```markdown
AI Agent Output:
- ✅ Created MSW handler
- ✅ Tests passing
- ⚠️ ACTION REQUIRED:
  1. Review changes
  2. Run: npm run pact:generate
  3. Run: npm run pact:validate
  4. If valid: Increment version in package.json
  5. Run: npm run pact:publish
```

---

## Troubleshooting Guide

### Issue 1: MSW not intercepting requests

**Symptoms**:
- Tests fail with "fetch failed" or "ECONNREFUSED"
- Requests bypass MSW and hit real network

**Solutions**:
1. Verify MSW server is started:
   ```typescript
   beforeAll(() => {
     startMockServer()
   })
   ```

2. Check handler paths match requests:
   ```typescript
   // Handler
   http.get('/api/users')  // ❌ Doesn't match http://localhost:3000/api/users

   // Should be
   http.get('http://localhost:3000/api/users')  // ✅ Full URL
   // OR
   http.get('/api/users')  // ✅ Relative path (with baseURL config)
   ```

3. Ensure handlers are registered:
   ```typescript
   // test/msw/handlers/index.ts
   export const handlers = [
     ...usersHandlers,  // Must export
   ]
   ```

### Issue 2: Pact generation produces incorrect matchers

**Symptoms**:
- Generated Pact contract doesn't match MSW response structure
- Backend verification fails

**Solutions**:
1. Check MSW handler returns proper structure:
   ```typescript
   // Must be JSON-serializable
   return HttpResponse.json({ success: true, data: [...] })
   ```

2. Verify matcher conversion logic in `generate-pact-from-msw.ts`

3. Manually review generated contract before publishing

### Issue 3: Tests pass locally but fail in CI

**Symptoms**:
- Local tests use development data
- CI needs deterministic data

**Solutions**:
1. Set `MSW_ENV=ci` in CI configuration:
   ```yaml
   # .github/workflows/test.yml
   env:
     MSW_ENV: ci
   ```

2. Ensure `ci` environment data exists in all handlers:
   ```typescript
   const data = getEnvironmentData({
     test: { /* ... */ },
     development: { /* ... */ },
     ci: { /* required! */ },
   })
   ```

### Issue 4: Environment variables not loading

**Symptoms**:
- MSW uses wrong environment
- API requests not mocked/unmocked correctly

**Solutions**:
1. Load environment variables in test setup:
   ```typescript
   // test/setup.ts
   import dotenv from 'dotenv'
   dotenv.config({ path: '.env.local' })
   ```

2. Check environment file naming:
   - `.env.local` for local dev
   - `.env.uat` for UAT
   - `.env.production` for production

3. Verify Nuxt config reads runtime config:
   ```typescript
   runtimeConfig: {
     public: {
       apiBase: process.env.API_BASE_URL || 'http://localhost:3000',
     },
   }
   ```

---

## Success Criteria

Migration is complete and successful when:

### Functional Requirements
- ✅ All unit tests pass with MSW
- ✅ All integration tests pass with MSW
- ✅ All BDD E2E tests pass with MSW
- ✅ `npm run dev` works without Pact stub server
- ✅ Pact contracts generated from MSW match structure
- ✅ Pact validation passes

### Technical Requirements
- ✅ MSW provides rich, environment-specific data
- ✅ No Pact stub server dependencies remain
- ✅ Environment variables control MSW behavior
- ✅ Production environments use real APIs (USE_REAL_API=true)
- ✅ CI/CD pipelines pass all tests

### Documentation Requirements
- ✅ README updated with MSW instructions
- ✅ AI context documents reflect MSW workflow
- ✅ Migration document exists (this file)
- ✅ MSW handler creation guide exists

### Developer Experience
- ✅ Frontend development not blocked by backend
- ✅ Easy to add new mock endpoints
- ✅ Clear process for generating Pact contracts
- ✅ AI agents can create MSW handlers safely
- ✅ Human controls contract versioning and publishing

---

## Rollback Plan

If migration fails or issues arise:

### Quick Rollback (Same Session)

```bash
# Revert to previous commit
git reset --hard HEAD~[number_of_commits]

# Reinstall Pact dependencies
npm install @pact-foundation/pact-node
npm install npm-run-all

# Restore package.json scripts
git checkout HEAD -- package.json

# Restart Pact stub server
npm run dev
```

### Staged Rollback (After Merge)

1. Create rollback branch:
   ```bash
   git checkout -b rollback/msw-to-pact
   ```

2. Revert migration commits:
   ```bash
   git revert <commit-hash-range>
   ```

3. Test with Pact stub server

4. Merge rollback branch

### Partial Rollback (Keep MSW, Restore Pact Tests)

If MSW works but Pact generation has issues:

1. Keep MSW handlers and configuration
2. Restore `test/pact/apis/*.pact.spec.ts` files
3. Keep both systems running until Pact generation fixed
4. Use manual Pact contract definitions temporarily

---

## Timeline and Effort Estimation

### By Role

**Frontend Developer**:
- **Phase 1-2**: 5-6 hours (MSW setup and handlers)
- **Phase 3**: 2-3 hours (Pact generation scripts)
- **Phase 4**: 2-3 hours (Configuration updates)
- **Phase 6**: 1 hour (Validation and cleanup)
- **Total**: ~10-13 hours

**Technical Writer/AI Context Engineer**:
- **Phase 5**: 2-3 hours (AI context document updates)

**Total Project**: 12-16 hours

### By Phase

- **Phase 1** (Setup): 1-2 hours
- **Phase 2** (Handlers): 3-4 hours
- **Phase 3** (Pact Scripts): 2-3 hours
- **Phase 4** (Tests/Config): 2-3 hours
- **Phase 5** (AI Docs): 2-3 hours
- **Phase 6** (Validation): 1 hour

### Recommended Schedule

**Week 1**:
- Day 1: Phases 1-2 (Setup + Handlers)
- Day 2: Phase 3 (Pact Scripts)
- Day 3: Phase 4 (Tests/Config)

**Week 2**:
- Day 1: Phase 5 (AI Docs)
- Day 2: Phase 6 (Validation + Cleanup)
- Day 3: Buffer for issues

---

## Additional Resources

### MSW Documentation
- https://mswjs.io/docs/
- https://mswjs.io/docs/api/setup-server (Node.js)
- https://mswjs.io/docs/recipes/environment-based-mocks

### Pact Documentation
- https://docs.pact.io/
- https://docs.pact.io/implementation_guides/javascript/readme
- https://docs.pact.io/pact_broker

### Project References
- `BDD_FIRST_WORKFLOW.md` - Future state workflow
- `MSW_PACT_SYNC_GUIDE.md` - Sync strategies
- `WORKFLOW_COMPARISON.md` - Bottom-up vs Top-down comparison

---

## Questions and Clarifications

If you encounter issues during migration:

1. **Check this guide first** - Most common issues are documented in Troubleshooting
2. **Review reference documents** - BDD_FIRST_WORKFLOW.md, MSW_PACT_SYNC_GUIDE.md
3. **Test incrementally** - Don't move to next phase until current phase works
4. **Commit often** - Easy to rollback if needed
5. **Ask for help** - Document any new issues found

---

## Appendix A: File Structure After Migration

```
ip-hub-frontend/
├── test/
│   ├── msw/                          # NEW: MSW mock infrastructure
│   │   ├── server.ts                 # MSW server setup
│   │   ├── config.ts                 # Environment configuration
│   │   └── handlers/                 # MSW request handlers
│   │       ├── index.ts              # Handler registry
│   │       ├── health.ts             # Health check handlers
│   │       ├── users.ts              # User management handlers
│   │       ├── collaborators.ts      # Collaborator handlers
│   │       ├── ip-assets.ts          # IP Asset handlers
│   │       ├── dashboard.ts          # Dashboard handlers
│   │       └── patents.ts            # Patent handlers
│   │
│   ├── pact/
│   │   ├── pacts/                    # Generated Pact contracts (kept)
│   │   │   └── ip-management-frontend-ip-management-backend.json
│   │   └── pact-setup.ts             # Broker config (kept for publishing)
│   │   # REMOVED: apis/*.pact.spec.ts files
│   │
│   ├── unit/                         # Unit tests (unchanged)
│   ├── integration/                  # Integration tests (unchanged)
│   └── setup.ts                      # UPDATED: Starts MSW server
│
├── features/
│   ├── support/
│   │   └── hooks.ts                  # NEW: Cucumber hooks with MSW
│   └── step-definitions/             # UPDATED: No Pact references
│
├── scripts/
│   ├── generate-pact-from-msw.ts     # NEW: Pact generation
│   └── validate-msw-pact-sync.ts     # NEW: Validation
│
├── ai-context/
│   ├── bdd-agents/
│   │   └── bdd-frontend-agent/
│   │       └── bdd-test-agent-context.md  # UPDATED: MSW references
│   └── frontend-agents/
│       ├── tdd-green-implement-frontend-to-pass-tests/
│       │   └── 01-template-implement-frontend-to-pass-tests.md  # UPDATED
│       └── msw-workflow/             # NEW: MSW workflow guides
│           ├── msw-handler-creation-guide.md
│           └── prompts/
│               └── 01-template-create-msw-handler.md
│
├── .env.local                        # NEW: Local dev config
├── .env.uat                          # NEW: UAT config
├── .env.production                   # NEW: Production config
├── nuxt.config.ts                    # UPDATED: No Pact proxy
├── package.json                      # UPDATED: MSW scripts, no Pact stub
├── vitest.config.ts                  # UPDATED: MSW in setup
├── cucumber.cjs                      # UNCHANGED
└── README.md                         # UPDATED: MSW instructions

# REMOVED FILES:
# - test/pact/apis/*.pact.spec.ts
# - vitest.pact.config.ts
# - (optional) @pact-foundation/pact-node dependency
```

---

## Appendix B: MSW Handler Examples

### Complete Health Handler

```typescript
// test/msw/handlers/health.ts
import { http, HttpResponse } from 'msw'

export const healthHandlers = [
  http.get('/api/health', async () => {
    return HttpResponse.json({
      success: true,
      status: 'operational',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    })
  }),
]
```

### Complete IP Assets Handler with Filtering

```typescript
// test/msw/handlers/ip-assets.ts
import { http, HttpResponse, delay } from 'msw'
import { MSW_CONFIG, getEnvironmentData } from '../config'

const ipAssetsData = getEnvironmentData({
  test: [
    {
      id: 'ASSET-001',
      assetType: 'patent',
      title: 'Test Patent',
      status: 'in_progress',
      applicant: {
        name: 'Alice',
        email: 'alice@example.com',
      },
    },
  ],
  development: [
    {
      id: 'ASSET-001',
      assetType: 'patent',
      title: 'Advanced AI Processing System',
      status: 'in_progress',
      completionPercentage: 45,
      applicant: {
        name: 'Alice',
        email: 'alice@example.com',
        organization: 'Tech Innovations Ltd',
      },
      applications: [
        {
          id: 'APP-001-DUBAI',
          jurisdiction: 'Dubai/UAE',
          name: 'Dubai/UAE Primary Filing',
          status: 'in_progress',
        },
      ],
    },
    {
      id: 'ASSET-002',
      assetType: 'patent',
      title: 'Smart Healthcare Device',
      status: 'submitted',
      completionPercentage: 100,
      applicant: {
        name: 'Bob',
        email: 'bob@example.com',
        organization: 'Health Tech Inc',
      },
      applications: [],
    },
    {
      id: 'ASSET-003',
      assetType: 'trademark',
      title: 'TechVision Brand Logo',
      status: 'in_progress',
      completionPercentage: 65,
      applicant: {
        name: 'Alice',
        email: 'alice@example.com',
        organization: 'Tech Innovations Ltd',
      },
      applications: [],
    },
  ],
  ci: [
    {
      id: 'ASSET-CI-001',
      assetType: 'patent',
      title: 'CI Test Patent',
      status: 'in_progress',
      applicant: {
        name: 'CI User',
        email: 'ci@example.com',
      },
    },
  ],
})

export const ipAssetsHandlers = [
  // GET /api/ip-assets - with optional type filter
  http.get('/api/ip-assets', async ({ request }) => {
    await delay(MSW_CONFIG.delay)

    const url = new URL(request.url)
    const typeFilter = url.searchParams.get('type')

    let filteredData = ipAssetsData
    if (typeFilter) {
      filteredData = ipAssetsData.filter(asset => asset.assetType === typeFilter)
    }

    return HttpResponse.json({
      success: true,
      data: filteredData,
      meta: {
        total: filteredData.length,
        filtered: !!typeFilter,
        assetType: typeFilter || 'all',
        byType: {
          patent: ipAssetsData.filter(a => a.assetType === 'patent').length,
          trademark: ipAssetsData.filter(a => a.assetType === 'trademark').length,
          copyright: ipAssetsData.filter(a => a.assetType === 'copyright').length,
        },
      },
    })
  }),
]
```

---

## End of Migration Guide

This comprehensive guide provides all information needed to successfully migrate from Pact stub server to MSW with generated Pact contracts. Follow phases sequentially, test thoroughly, and refer to troubleshooting section for issues.

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Analyze current architecture and identify all components requiring changes", "status": "completed", "activeForm": "Analyzing current architecture"}, {"content": "Create comprehensive migration document with step-by-step instructions", "status": "completed", "activeForm": "Creating migration document"}, {"content": "Document code changes required (MSW setup, Pact generation script)", "status": "completed", "activeForm": "Documenting code changes"}, {"content": "Document package.json script updates", "status": "completed", "activeForm": "Documenting script updates"}, {"content": "Document AI context updates needed", "status": "in_progress", "activeForm": "Documenting AI context updates"}, {"content": "Document environment configuration changes", "status": "completed", "activeForm": "Documenting environment configuration"}]