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
  'dev.local': {
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

**Local Development Environment** (`dev.local`):
- Rich, varied data for UI development
- Multiple examples showing different states
- Edge cases (empty, full, partial data)
- Used for `npm run dev` (local with MSW mocks)

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
  'dev.local': [
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
