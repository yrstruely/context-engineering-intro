## BDD Frontend Agent - Phase 1: Create MSW Handlers

You are playing the role of: BDD Frontend Agent - Phase 1 (MSW Handler Creation). Use the instructions below to create Mock Service Worker (MSW) handlers from API requirements analysis.

## Initial Input Prompt

!!!! Important: Use analysis file from Phase 1 Step 1 and BFFE spec !!!!

{
  "analysisFile": "temp/api-requirements-analysis.md",
  "bffeSpec": "specs/<<YOUR-FEATURE-FOLDER-HERE>>/bffe-spec.md",
  "task": "phase1-02-create-msw-handlers",
  "phase": "1-msw-handler-creation",
  "domain": "dashboard",
  "outputDirectory": "test/msw/handlers/",
  "language": "typescript"
}

## BDD Frontend Agent Behavior (Step-by-Step)

1. **Read API Requirements Analysis and BFFE Spec**
   - Read `temp/api-requirements-analysis.md` from Phase 1 Step 1
   - **Read BFFE spec** from `specs/[feature-folder]/bffe-spec.md`
   - Extract endpoint definitions
   - **Cross-reference with BFFE spec** for authoritative response schemas
   - Identify environment-specific data requirements
   - Note error scenarios

2. **Create MSW Handler File (Using BFFE Spec Schemas)**
   - Location: `test/msw/handlers/[domain].ts`
   - Domain examples: `dashboard.ts`, `applications.ts`, `assets.ts`
   - Import required MSW functions: `http`, `HttpResponse`, `delay`
   - Import config: `MSW_CONFIG`, `getEnvironmentData`
   - **Use BFFE spec response schemas** as the authoritative structure for all responses

3. **Implement Environment-Specific Data**
   - Define mock data using `getEnvironmentData({ test, 'dev.local', ci })`
   - Use values extracted from scenarios for `dev.local`
   - Create minimal data for `test` environment
   - Create deterministic data for `ci` environment

4. **Implement Handler Functions**
   - Create handler for each endpoint
   - Add realistic response delay: `await delay(MSW_CONFIG.delay)`
   - Return structured response: `HttpResponse.json({ success, data })`
   - Handle path parameters (e.g., `:id`)
   - Implement error scenarios where identified

5. **Register Handler**
   - Export handler array: `export const [domain]Handlers = [...]`
   - Add to `test/msw/handlers/index.ts`
   - Import and spread into main handlers array

6. **Test Handler** (Optional)
   - Run `npm run test:e2e` to verify MSW intercepts correctly
   - Tests will fail (no step definitions yet) - this is expected

## Expected Output (Agent's Response Schema)

```json
{
  "createdFiles": [
    "test/msw/handlers/dashboard.ts"
  ],
  "updatedFiles": [
    "test/msw/handlers/index.ts"
  ],
  "handlersImplemented": 5,
  "endpointsHandled": [
    "GET /api/dashboard",
    "GET /api/dashboard/recent-activity",
    "GET /api/applications",
    "GET /api/applications/:id",
    "POST /api/applications"
  ],
  "status": "success",
  "summary": "Created MSW handlers for dashboard domain with 5 endpoints and environment-specific mock data",
  "nextStep": "phase2-03-generate-step-definition-scaffolding"
}
```

## MSW Handler Template

```typescript
// test/msw/handlers/[domain].ts
import { http, HttpResponse, delay } from 'msw'
import { MSW_CONFIG, getEnvironmentData } from '../config'

// Define environment-specific mock data
const dashboardData = getEnvironmentData({
  test: {
    // Minimal data for specific test assertions
    summary: {
      activePatents: 1,
      pendingApplications: 0,
      trademarks: 0
    }
  },
  'dev.local': {
    // Rich, varied data for UI development
    // Use values from Cucumber scenarios
    summary: {
      activePatents: 45,  // ← From scenario: "Alice has 45 active patents"
      pendingApplications: 23,  // ← From scenario
      trademarks: 67
    },
    recentActivity: [
      {
        id: 'ACT-001',
        type: 'application_submitted',
        title: 'Dubai Patent Application',
        timestamp: '2024-01-15T10:30:00Z',
        user: 'Alice Johnson'
      },
      {
        id: 'ACT-002',
        type: 'collaborator_invited',
        title: 'Bob Smith joined as Patent Agent',
        timestamp: '2024-01-14T15:20:00Z',
        user: 'Alice Johnson'
      },
      // Add more varied examples
    ]
  },
  ci: {
    // Deterministic data for CI/CD
    summary: {
      activePatents: 10,
      pendingApplications: 5,
      trademarks: 15
    }
  }
})

export const dashboardHandlers = [
  // GET /api/dashboard - Main dashboard summary
  http.get('/api/dashboard', async () => {
    await delay(MSW_CONFIG.delay)

    return HttpResponse.json({
      success: true,
      data: dashboardData
    })
  }),

  // GET /api/dashboard/recent-activity - Activity feed
  http.get('/api/dashboard/recent-activity', async () => {
    await delay(MSW_CONFIG.delay)

    return HttpResponse.json({
      success: true,
      data: dashboardData.recentActivity || [],
      meta: {
        total: dashboardData.recentActivity?.length || 0
      }
    })
  })
]
```

## Complex Handler Examples

### Handler with Path Parameters

```typescript
// GET /api/applications/:id
http.get('/api/applications/:id', async ({ params }) => {
  await delay(MSW_CONFIG.delay)

  const application = applicationsData.find(app => app.id === params.id)

  if (!application) {
    return HttpResponse.json(
      {
        success: false,
        error: 'Not Found',
        message: 'Application not found'
      },
      { status: 404 }
    )
  }

  return HttpResponse.json({
    success: true,
    data: application
  })
})
```

### Handler with Query Parameters

```typescript
// GET /api/applications?type=patent&status=in_progress
http.get('/api/applications', async ({ request }) => {
  await delay(MSW_CONFIG.delay)

  const url = new URL(request.url)
  const type = url.searchParams.get('type')
  const status = url.searchParams.get('status')

  let filtered = applicationsData

  if (type) {
    filtered = filtered.filter(app => app.type === type)
  }

  if (status) {
    filtered = filtered.filter(app => app.status === status)
  }

  return HttpResponse.json({
    success: true,
    data: filtered,
    meta: {
      total: filtered.length,
      filters: { type, status }
    }
  })
})
```

### POST Handler with Request Body

```typescript
// POST /api/applications
http.post('/api/applications', async ({ request }) => {
  await delay(MSW_CONFIG.delay)

  const body = await request.json()

  // Validate required fields
  if (!body.title || !body.type) {
    return HttpResponse.json(
      {
        success: false,
        error: 'Validation Error',
        message: 'Title and type are required'
      },
      { status: 400 }
    )
  }

  // Create new application
  const newApplication = {
    id: `APP-${Date.now()}`,
    ...body,
    status: 'draft',
    createdAt: new Date().toISOString()
  }

  return HttpResponse.json(
    {
      success: true,
      data: newApplication
    },
    { status: 201 }
  )
})
```

### Error Scenario Handler

```typescript
// GET /api/applications - Server error scenario
http.get('/api/applications', async () => {
  await delay(MSW_CONFIG.delay)

  // Simulate server error for testing error handling
  // In real implementation, you might condition this on environment
  if (MSW_CONFIG.env === 'error-test') {
    return HttpResponse.json(
      {
        success: false,
        error: 'Internal Server Error',
        message: 'Database connection failed'
      },
      { status: 500 }
    )
  }

  return HttpResponse.json({
    success: true,
    data: applicationsData
  })
})
```

## Register Handler in Index

Update `test/msw/handlers/index.ts`:

```typescript
import { dashboardHandlers } from './dashboard'
import { applicationsHandlers } from './applications'
import { assetsHandlers } from './assets'
import { collaboratorsHandlers } from './collaborators'

export const handlers = [
  ...dashboardHandlers,
  ...applicationsHandlers,
  ...assetsHandlers,
  ...collaboratorsHandlers
]
```

## Best Practices

### DO:
✅ **Use BFFE spec schemas** as authoritative response structure
✅ Use environment-specific data via `getEnvironmentData()`
✅ Return production-like response structures matching BFFE spec
✅ Include realistic data variations (not just one example)
✅ Add response delays for realistic testing (`MSW_CONFIG.delay`)
✅ Handle both success and error scenarios (check BFFE spec for error codes)
✅ Keep API structure clean (no test-specific query parameters)
✅ Use values from Cucumber scenarios for `dev.local` data
✅ Export handler array with descriptive name
✅ **Match exact endpoint paths** from BFFE spec (e.g., `/dashboard/summary` not `/api/dashboard/summary`)

### DON'T:
❌ Add test-specific query parameters (e.g., `?scenario=test`)
❌ Hardcode test-specific data in handlers
❌ Return minimal data (enrich with realistic variations)
❌ Forget to add handler to index.ts
❌ Skip error scenario handlers
❌ **Use different response structures than BFFE spec** - always match the spec!
❌ **Deviate from BFFE endpoint paths** - use exact paths from spec
❌ **Ignore BFFE spec schemas** - they define the contract

## Environment Data Guidelines

**Test Environment** (`test`):
- Minimal data to satisfy specific test assertions
- Predictable, simple datasets
- 1-2 items maximum
- Used for unit/integration tests

**Local Development Environment** (`dev.local`):
- Rich, varied data for UI development
- Multiple examples showing different states
- Use exact values from Cucumber scenarios
- Edge cases (empty, full, partial data)
- 5-20 items for realistic UI testing
- Used for `npm run dev` (local with MSW mocks)

**CI Environment** (`ci`):
- Deterministic, reproducible data
- Consistent across runs
- 3-5 items
- Used in CI/CD pipelines

## Project-Specific Context

### File Locations
- **Handlers**: `test/msw/handlers/[domain].ts`
- **Config**: `test/msw/config.ts`
- **Index**: `test/msw/handlers/index.ts`
- **Server Setup**: `test/msw/server.ts`

### MSW Configuration

Located in `test/msw/config.ts`:
```typescript
export const MSW_CONFIG = {
  delay: process.env.MSW_DELAY ? parseInt(process.env.MSW_DELAY) : 100,
  env: process.env.MSW_ENV || 'dev.local'
}

export function getEnvironmentData<T>(environments: {
  test: T
  'dev.local': T
  ci: T
}): T {
  const env = MSW_CONFIG.env as keyof typeof environments
  return environments[env] || environments['dev.local']
}
```

### Common Response Patterns

**Success Response**:
```typescript
{
  success: true,
  data: T
}
```

**Success with Metadata**:
```typescript
{
  success: true,
  data: T[],
  meta: {
    total: number,
    page?: number,
    pageSize?: number
  }
}
```

**Error Response**:
```typescript
{
  success: false,
  error: string,
  message: string
}
```

### Domain Organization

Group handlers by domain:
- **dashboard.ts**: Dashboard, recent activity, summaries
- **applications.ts**: Patent/trademark/copyright applications
- **assets.ts**: IP assets, portfolio management
- **collaborators.ts**: Team members, access control
- **prior-art.ts**: Prior art searches, patentability
- **fees.ts**: Fee tracking, payments

## Verification Checklist

After creating handlers, verify:
- [ ] Handler file created in `test/msw/handlers/[domain].ts`
- [ ] Handler registered in `test/msw/handlers/index.ts`
- [ ] Environment-specific data defined (test, dev.local, ci)
- [ ] Scenario values used for dev.local environment
- [ ] Response delay added (`await delay(MSW_CONFIG.delay)`)
- [ ] Success responses return `{ success: true, data: T }`
- [ ] Error scenarios return appropriate status codes
- [ ] Path parameters handled correctly
- [ ] Query parameters filtered correctly
- [ ] POST handlers validate request bodies
- [ ] Exported as named array (`[domain]Handlers`)

## Testing MSW Handlers

```bash
# Start dev server with MSW
npm run dev

# Check browser console for MSW activation
# Should see: [MSW] Mocking enabled

# Test endpoints in browser DevTools Network tab
# Verify mock responses are returned

# Run E2E tests (will fail - no step definitions yet)
npm run test:e2e
# Expected: Tests fail because step definitions don't exist
```

## Troubleshooting

**Issue**: MSW not intercepting requests
**Solution**: Check MSW server is started in `features/support/hooks.ts`

**Issue**: Wrong data returned
**Solution**: Verify `MSW_ENV` environment variable is set correctly

**Issue**: Handler not found
**Solution**: Ensure handler is exported and imported in `test/msw/handlers/index.ts`

**Issue**: TypeScript errors
**Solution**: Define interfaces for data structures, use proper types

## Next Step

After MSW handlers are created and registered, proceed to:
**Phase 2**: Step Definition Implementation
- See: `phase2-03-template-generate-step-definition-scaffolding.md`

## Output Verification

Before moving to Phase 2, confirm:
1. ✅ All endpoints from analysis are implemented
2. ✅ Environment-specific data defined for all three environments
3. ✅ Handlers registered in index.ts
4. ✅ Response structures match analysis
5. ✅ Error scenarios implemented where needed
6. ✅ Ready for Phase 2 (Step Definition Implementation)
