## 🏗️ The BDD-First Workflow

### Phase 1: Define Requirements & Features

```gherkin
# Start here: What does the user need?
Feature: User Management
  As an admin
  I want to view all users
  So I can manage system access

  Scenario: View users list
    Given there are 5 active users in the system
    And there are 2 inactive users
    When I navigate to the users page
    Then I should see 5 active user cards
    And I should see 2 inactive user cards
    And I should see a total count of 7 users
```

**Output:** Clear requirements and acceptance criteria

---

### Phase 2: Create Rich MSW Mocks

Based on Cucumber scenarios, create MSW handlers with the data you need:

```typescript
// test/e2e/mocks/handlers.ts
import { http, HttpResponse } from 'msw'

export const handlers = [
  http.get('/api/users', ({ request }) => {
    const url = new URL(request.url)
    const scenario = url.searchParams.get('scenario')
    
    // Scenario from Cucumber: "5 active, 2 inactive"
    if (scenario === 'mixed-status') {
      return HttpResponse.json({
        success: true,
        data: [
          // 5 active users
          { id: 'USR-001', name: 'John Doe', email: 'john@example.com', role: 'admin', active: true },
          { id: 'USR-002', name: 'Jane Smith', email: 'jane@example.com', role: 'user', active: true },
          { id: 'USR-003', name: 'Bob Johnson', email: 'bob@example.com', role: 'user', active: true },
          { id: 'USR-004', name: 'Alice Williams', email: 'alice@example.com', role: 'viewer', active: true },
          { id: 'USR-005', name: 'Charlie Brown', email: 'charlie@example.com', role: 'user', active: true },
          // 2 inactive users
          { id: 'USR-006', name: 'David Lee', email: 'david@example.com', role: 'user', active: false },
          { id: 'USR-007', name: 'Emma Davis', email: 'emma@example.com', role: 'viewer', active: false },
        ]
      })
    }
    
    // Default scenario
    return HttpResponse.json({
      success: true,
      data: [
        { id: 'USR-001', name: 'John Doe', email: 'john@example.com', role: 'admin', active: true },
      ]
    })
  }),
]
```

**Output:** Rich, scenario-specific mock data

---

### Phase 3: Implement Frontend (TDD with MSW)

Run Cucumber tests with MSW, implement frontend:

```typescript
// pages/users.vue
<script setup lang="ts">
const { data: users } = await useFetch('/api/users')

const activeUsers = computed(() => 
  users.value?.data.filter(u => u.active) || []
)

const inactiveUsers = computed(() => 
  users.value?.data.filter(u => !u.active) || []
)
</script>

<template>
  <div>
    <h1>Users ({{ users?.data.length || 0 }} total)</h1>
    
    <section>
      <h2>Active Users ({{ activeUsers.length }})</h2>
      <UserCard 
        v-for="user in activeUsers" 
        :key="user.id" 
        :user="user"
        data-testid="user-card"
        data-status="active"
      />
    </section>
    
    <section>
      <h2>Inactive Users ({{ inactiveUsers.length }})</h2>
      <UserCard 
        v-for="user in inactiveUsers" 
        :key="user.id" 
        :user="user"
        data-testid="user-card"
        data-status="inactive"
      />
    </section>
  </div>
</template>
```

**Cucumber passes → Frontend done!**

---

### Phase 4: Generate Pact Contract from MSW

Now that you know what the API should look like, generate Pact contracts:

```typescript
// scripts/generate-pact-from-msw.ts
import fs from 'fs'
import path from 'path'
import { handlers } from '../test/e2e/mocks/handlers'

/**
 * Generate Pact consumer tests from MSW handlers
 * This ensures your contracts match what your frontend actually needs
 */

interface MSWHandler {
  info: {
    method: string
    path: string
  }
}

function generatePactTest(handler: any): string {
  // Extract method and path from MSW handler
  const method = extractMethod(handler)
  const path = extractPath(handler)
  
  // Call the handler to get example response
  const mockRequest = new Request(`http://localhost:3000${path}`)
  const response = await handler(mockRequest)
  const exampleBody = await response.json()
  
  // Convert to Pact matchers
  const pactBody = convertToPactMatchers(exampleBody)
  
  return `
  describe('${method} ${path}', () => {
    it('returns expected response structure', async () => {
      await provider
        .given('${generateProviderState(path, exampleBody)}')
        .uponReceiving('a request for ${path}')
        .withRequest({
          method: '${method}',
          path: '${path}',
          headers: {
            Accept: 'application/json',
          },
        })
        .willRespondWith({
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: ${JSON.stringify(pactBody, null, 2)},
        })
        .executeTest(async (mockServer) => {
          const response = await fetch(\`\${mockServer.url}${path}\`)
          const data = await response.json()
          
          expect(response.status).toBe(200)
          expect(data.success).toBe(true)
          ${generateAssertions(exampleBody)}
        });
    });
  });`
}

function convertToPactMatchers(obj: any): any {
  if (Array.isArray(obj)) {
    if (obj.length === 0) return []
    
    return {
      'pact:matcher:type': 'type',
      'min': 1,
      'contents': convertToPactMatchers(obj[0])
    }
  }
  
  if (typeof obj === 'object' && obj !== null) {
    const result: any = {}
    
    for (const [key, value] of Object.entries(obj)) {
      result[key] = convertToPactMatchers(value)
    }
    
    return result
  }
  
  // Primitives
  if (typeof obj === 'string') {
    // Check if it's a date
    if (obj.match(/^\d{4}-\d{2}-\d{2}T/)) {
      return {
        'pact:matcher:type': 'regex',
        'regex': '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}',
        'value': obj
      }
    }
    // Check if it's an email
    if (obj.match(/@/)) {
      return {
        'pact:matcher:type': 'regex',
        'regex': '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
        'value': obj
      }
    }
    return { 'pact:matcher:type': 'type', 'value': obj }
  }
  
  if (typeof obj === 'number') {
    return { 'pact:matcher:type': Number.isInteger(obj) ? 'integer' : 'decimal', 'value': obj }
  }
  
  if (typeof obj === 'boolean') {
    return { 'pact:matcher:type': 'type', 'value': obj }
  }
  
  return obj
}

function generateProviderState(path: string, body: any): string {
  // Infer provider state from response
  if (body.data && Array.isArray(body.data)) {
    if (body.data.length === 0) {
      return `no ${path.split('/').pop()} exist`
    }
    return `${path.split('/').pop()} exist in the system`
  }
  
  return `data exists for ${path}`
}

function generateAssertions(body: any): string {
  const assertions: string[] = []
  
  if (body.data && Array.isArray(body.data) && body.data.length > 0) {
    const firstItem = body.data[0]
    for (const key of Object.keys(firstItem)) {
      assertions.push(`expect(data.data[0]).toHaveProperty('${key}')`)
    }
  }
  
  return assertions.join('\n          ')
}

// Generate tests for all handlers
async function main() {
  const tests = []
  
  for (const handler of handlers) {
    const test = await generatePactTest(handler)
    tests.push(test)
  }
  
  const output = `
import { describe, it, expect } from 'vitest'
import { MatchersV3 } from '@pact-foundation/pact'
import { createProvider, createApiUrl } from '../pact-setup'

const { eachLike, string, integer, decimal, boolean, regex, iso8601DateTimeWithMillis } = MatchersV3
const iso8601DateTime = iso8601DateTimeWithMillis

const provider = createProvider()

describe('Generated Pact Tests from MSW', () => {
${tests.join('\n\n')}
})
`
  
  fs.writeFileSync(
    path.join(process.cwd(), 'test/pact/generated/from-msw.pact.spec.ts'),
    output
  )
  
  console.log('✅ Generated Pact tests from MSW handlers')
}

main()
```

**Output:** Pact contracts that match your frontend needs

---

### Phase 5: Share Contracts with Backend Team

```bash
# Generate contracts
npm run test:pact

# Publish to broker
npm run pact:publish

# Backend team verifies
# (in Nest.js repo)
npm run pact:verify
```

**Output:** Backend implements APIs that match frontend expectations

---

## 🔄 Complete BDD-First Workflow

### Weekly Sprint Flow

```
Monday:
├── 1. Product defines requirements
├── 2. Write Cucumber features
└── 3. Review and refine scenarios

Tuesday-Wednesday:
├── 4. Create MSW handlers for scenarios
├── 5. Run Cucumber (Red)
├── 6. Implement frontend features
├── 7. Cucumber tests pass (Green)
└── 8. Refactor

Thursday:
├── 9. Generate Pact contracts from MSW
├── 10. Review contracts
├── 11. Publish to Pact Broker
└── 12. Share with backend team

Friday:
├── 13. Backend verifies contracts
├── 14. Backend implements endpoints
└── 15. Integration testing in UAT
```

---

## 📊 Tool Responsibilities in BDD-First

```
┌─────────────────────────────────────┐
│     Requirements & User Stories     │
│  "As a user, I want to..."          │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Cucumber/BDD Features           │
│  Executable specifications          │
│  Drives development                 │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     MSW Mock Handlers               │
│  Rich test data                     │
│  Scenario-specific responses        │
│  Frontend development support       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Frontend Implementation         │
│  Components, pages, logic           │
│  Tested with MSW                    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Pact Contracts                  │
│  Generated from MSW                 │
│  Documents frontend needs           │
│  Validates backend                  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     Backend Implementation          │
│  Verifies Pact contracts            │
│  Implements real endpoints          │
└─────────────────────────────────────┘
```

---

## 🎯 Key Benefits of BDD-First Approach

### 1. **Requirements Drive Everything**
✅ Features are written first
✅ Clear acceptance criteria
✅ Stakeholder alignment

### 2. **Fast Frontend Development**
✅ MSW provides immediate mock data
✅ No waiting for backend
✅ Rich scenarios for testing

### 3. **Contracts Match Reality**
✅ Pact contracts reflect actual frontend needs
✅ Not theoretical API design
✅ Backend knows exact requirements

### 4. **Reduced Rework**
✅ Frontend built against scenarios
✅ Backend implements to contract
✅ Integration "just works"

### 5. **Living Documentation**
✅ Cucumber = business requirements
✅ MSW = test scenarios
✅ Pact = API contract
✅ All in sync!

---

## 📝 Practical Example: Full Flow

### Step 1: Feature File

```gherkin
Feature: Dashboard Analytics

  Scenario: View patent portfolio summary
    Given I have 45 active patents
    And I have 23 pending patent applications
    And I have 67 registered trademarks
    When I visit the dashboard
    Then I should see "45" in the active patents card
    And I should see "23" in the pending applications card
    And I should see "67" in the trademarks card
    And I should see a total portfolio value
```

### Step 2: MSW Handler

```typescript
// test/e2e/mocks/handlers.ts
http.get('/api/dashboard', ({ request }) => {
  const url = new URL(request.url)
  const scenario = url.searchParams.get('scenario')
  
  if (scenario === 'portfolio-summary') {
    return HttpResponse.json({
      success: true,
      data: {
        summary: {
          totalAssets: 135,
          activePatents: 45,      // ← From Cucumber
          pendingApplications: 23, // ← From Cucumber
          trademarks: 67,         // ← From Cucumber
          copyrights: 0,
        },
        totalValue: {
          amount: 2500000,
          currency: 'USD',
        },
        recentActivity: [
          // Rich data for testing activity feed
          { id: 'ACT-001', type: 'filing', description: 'Patent filed', date: '2024-01-15' },
          { id: 'ACT-002', type: 'approval', description: 'Trademark approved', date: '2024-01-14' },
        ],
      }
    })
  }
  
  return HttpResponse.json({ success: true, data: { /* default */ } })
})
```

### Step 3: Cucumber Steps

```typescript
// test/e2e/steps/given.steps.ts
Given('I have {int} active patents', async function(count: number) {
  this.expectedActivePatents = count
  this.scenario = 'portfolio-summary'
  
  // MSW will return data matching this scenario
  await this.page.goto('http://localhost:3000?scenario=portfolio-summary')
})
```

### Step 4: Frontend Implementation

```vue
<!-- pages/dashboard.vue -->
<script setup lang="ts">
const { data: dashboard } = await useFetch('/api/dashboard')

const summary = computed(() => dashboard.value?.data.summary || {})
const totalValue = computed(() => dashboard.value?.data.totalValue || {})
</script>

<template>
  <div class="dashboard">
    <h1>Dashboard</h1>
    
    <div class="stats-grid">
      <StatCard 
        title="Active Patents"
        :value="summary.activePatents"
        data-testid="active-patents-card"
      />
      
      <StatCard 
        title="Pending Applications"
        :value="summary.pendingApplications"
        data-testid="pending-applications-card"
      />
      
      <StatCard 
        title="Trademarks"
        :value="summary.trademarks"
        data-testid="trademarks-card"
      />
    </div>
    
    <div class="portfolio-value">
      Total Value: {{ formatCurrency(totalValue.amount, totalValue.currency) }}
    </div>
  </div>
</template>
```

### Step 5: Generate Pact Contract

```bash
npm run generate:pact-from-msw
```

**Generated contract:**
```json
{
  "consumer": { "name": "IPManagementFrontend" },
  "provider": { "name": "IPManagementBackend" },
  "interactions": [
    {
      "description": "a request for dashboard data",
      "request": {
        "method": "GET",
        "path": "/api/dashboard"
      },
      "response": {
        "status": 200,
        "body": {
          "success": { "pact:matcher:type": "type", "value": true },
          "data": {
            "summary": {
              "totalAssets": { "pact:matcher:type": "integer", "value": 135 },
              "activePatents": { "pact:matcher:type": "integer", "value": 45 },
              "pendingApplications": { "pact:matcher:type": "integer", "value": 23 },
              "trademarks": { "pact:matcher:type": "integer", "value": 67 },
              "copyrights": { "pact:matcher:type": "integer", "value": 0 }
            },
            "totalValue": {
              "amount": { "pact:matcher:type": "decimal", "value": 2500000 },
              "currency": { "pact:matcher:type": "type", "value": "USD" }
            }
          }
        }
      }
    }
  ]
}
```

### Step 6: Backend Implements

```typescript
// apps/backend/src/dashboard/dashboard.controller.ts
@Get()
async getDashboard(): Promise<ApiResponse<Dashboard>> {
  // Backend implements based on Pact contract
  const summary = await this.dashboardService.getSummary()
  const totalValue = await this.dashboardService.calculateTotalValue()
  
  return {
    success: true,
    data: {
      summary,
      totalValue,
      recentActivity: await this.dashboardService.getRecentActivity(),
    }
  }
}
```

---

## 🔧 Scripts Setup

```json
{
  "scripts": {
    "// Development": "",
    "dev": "nuxt dev",
    "dev:with-msw": "nuxt dev",
    
    "// BDD Testing": "",
    "test:cucumber": "cucumber-js",
    "test:cucumber:watch": "cucumber-js --watch",
    
    "// Contract Generation": "",
    "generate:pact-from-msw": "ts-node scripts/generate-pact-from-msw.ts",
    "test:pact": "vitest --config vitest.pact.config.ts",
    
    "// Workflow": "",
    "workflow:bdd": "npm run test:cucumber",
    "workflow:contracts": "npm run generate:pact-from-msw && npm run test:pact",
    "workflow:publish": "npm run pact:publish",
    
    "// Full Flow": "",
    "workflow:full": "npm run workflow:bdd && npm run workflow:contracts && npm run workflow:publish"
  }
}
```

---

## 📚 Directory Structure

```
project/
├── features/                          # Step 1: Requirements
│   └── users.feature
│
├── test/
│   ├── e2e/
│   │   ├── mocks/
│   │   │   └── handlers.ts           # Step 2: MSW handlers
│   │   └── steps/
│   │       └── *.steps.ts            # Step 2: Cucumber steps
│   │
│   └── pact/
│       ├── generated/
│       │   └── from-msw.pact.spec.ts # Step 4: Generated contracts
│       └── pacts/                     # Step 4: Contract files
│
├── pages/                             # Step 3: Frontend
│   └── users.vue
│
└── scripts/
    └── generate-pact-from-msw.ts     # Step 4: Generator
```

---

## ✅ Advantages Over Bottom-Up

| Bottom-Up (Pact First) | Top-Down (BDD First) |
|------------------------|---------------------|
| ❌ API designed in vacuum | ✅ API matches actual needs |
| ❌ Frontend adapts to contract | ✅ Contract reflects frontend needs |
| ❌ Theoretical requirements | ✅ Concrete scenarios |
| ❌ Backend drives frontend | ✅ Requirements drive both |
| ❌ Integration surprises | ✅ Smooth integration |

---

## 🎓 Best Practices

### 1. **Start with User Stories**
- Write features from user perspective
- Define clear acceptance criteria
- Get stakeholder signoff

### 2. **Make MSW Rich**
- Cover all Cucumber scenarios
- Include edge cases
- Realistic, varied data

### 3. **Generate, Don't Write**
- Auto-generate Pact from MSW
- Contracts match actual needs
- Less manual maintenance

### 4. **Keep Contracts Updated**
- Re-generate when MSW changes
- Publish regularly
- Version appropriately

### 5. **Document Flow**
- Team understands workflow
- Clear responsibilities
- Regular sync meetings

---

**This is the way!** 🎯
