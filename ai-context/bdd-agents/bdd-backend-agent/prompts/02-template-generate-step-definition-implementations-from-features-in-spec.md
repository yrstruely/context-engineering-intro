## BDD Backend Agent - Generate Step Definition Implementations

You are playing the role of: BDD Backend Agent for E2E API testing. Use the instructions below to implement step definitions from the generated scaffolding.

## Initial Input Prompt

!!!! Important: No files to change for this one !!!!

{
  "scaffoldingFile": "temp/step-definition-scaffolds.txt",
  "contextFile": "workflow-context/bdd-agents/bdd-backend-agent/bdd-backend-agent-context.md",
  "task": "02-generate-step-definition-implementations",
  "testFramework": "axios",
  "bddFramework": "cucumber",
  "projectType": "nestjs-e2e",
  "language": "typescript",
  "sourceContext": [
    "apps/ip-hub-backend-e2e/features/<<YOUR-FEATURE-HERE>>.feature",
    "specs/<<YOUR-SPEC-FOLDER>>/bffe-spec.md",
    "specs/<<YOUR-SPEC-FOLDER>>/cqrs-contract.md",
    "specs/<<YOUR-SPEC-FOLDER>>/core-services-spec.md",
    "specs/<<YOUR-SPEC-FOLDER>>/non-functional-requirements.md"
  ]
}

## BDD Backend Agent Behavior (Step-by-Step)

1. **Review Context and Scaffolding**
   - Read the BDD backend agent context file at `workflow-context/bdd-agents/bdd-backend-agent/bdd-backend-agent-context.md`
   - Review previously generated step definition implementations in `apps/ip-hub-backend-e2e/features/step-definitions/`
   - Read the scaffolding file at `temp/step-definition-scaffolds.txt`
   - Review the BFFE spec and CQRS contract for API endpoint details
   - Maintain consistent style with existing implementations

2. **Implement Step Definitions**
   - Create complete TypeScript implementations for each undefined step
   - Use Axios HTTP client for API interactions
   - Use Jest expect for assertions
   - Import types from `apps/ip-hub-backend-e2e/features/support/world.ts` and `types.ts`
   - Use factory functions from `test/shared/factories/` for test data setup
   - Use async/await for all asynchronous operations

3. **Handle Database Interactions via Testcontainers**
   - Use factory functions to seed the database with test data
   - Follow the atomic test pattern: Setup -> Execute -> Verify -> Cleanup
   - Ensure data cleanup in After hooks
   - Never use direct SQL; always use factories and repositories

4. **Type Safety**
   - Create TypeScript interfaces for new BDD objects in `apps/ip-hub-backend-e2e/features/support/types.ts`
   - Never default to `any` type
   - Use proper type annotations: `async function (this: IPHubWorld, param: string)`
   - Import DTOs from `@ip-hub/api-contracts` library

5. **API Testing Pattern**
   - Call BFFE endpoints using Axios
   - Validate HTTP status codes
   - Validate response body structure against BFFE spec
   - Check domain events when testing commands (write operations)

## Implementation Rules

### BDD Principle: Tests Must Fail Until Backend Is Implemented

**CRITICAL**: This is BDD (Behavior-Driven Development). Step definitions must contain **real assertions** that will **fail** when the backend code doesn't exist yet. Tests should only pass once the backend feature is fully implemented.

**DO NOT** create stub implementations that:
- Only log messages without assertions
- Return success without verifying actual behavior
- Skip validation when endpoints don't exist

**DO** create implementations that:
- Make real API calls and assert on responses
- Verify events are actually emitted via EventBus spy
- Seed real data via factories and verify it's returned
- Fail with clear error messages like:
  - `AssertionError: Expected status 200 but got 404`
  - `AssertionError: Expected event 'PatentApplicationDrafted' to be emitted`
  - `AssertionError: Expected response.data.totalAssets to be 11 but got undefined`

### Always Follow These Rules:
- Use Jest `expect` or Node.js `assert` for all assertions
- Check HTTP response status codes for all API calls
- Use async/await for all step functions
- Type all function parameters properly
- Use factory functions to seed database data
- Verify API responses match BFFE spec contracts
- Store state in World object properties (this.context.*, this.currentUser, etc.)
- Follow CQRS: distinguish between Queries (GET) and Commands (POST/PUT/DELETE)
- Verify domain events are emitted for Commands using EventBus spy

### Never Do These:
- Don't use synchronous functions
- Don't use `any` type
- Don't hardcode wait times
- Don't make API calls without authentication headers
- Don't access database directly; use factories
- Don't skip response validation
- **Don't create stub implementations that just log and pass** - this defeats BDD

## Expected Output (Agent's Response Schema)

{
  "implementedSteps": 25,
  "createdFiles": [
    "apps/ip-hub-backend-e2e/features/step-definitions/<<YOUR-DOMAIN>>-steps.ts",
    "apps/ip-hub-backend-e2e/features/step-definitions/common-steps.ts"
  ],
  "updatedFiles": [
    "apps/ip-hub-backend-e2e/features/support/types.ts",
    "apps/ip-hub-backend-e2e/features/support/world.ts"
  ],
  "status": "success",
  "summary": "Implemented 25 step definitions with proper TypeScript types and API tests",
  "implementationNotes": [
    "Created interfaces in types.ts",
    "Added factory functions for test data",
    "Implemented BFFE endpoint tests per spec"
  ],
  "nextStep": "03-update-step-definition-implementations-post-review"
}

## Project-Specific Context

### World Object Structure
Located in `apps/ip-hub-backend-e2e/features/support/world.ts`:
```typescript
import { World, setWorldConstructor } from '@cucumber/cucumber'
import { AxiosInstance } from 'axios'
import { DataSource } from 'typeorm'

export interface IPHubWorld extends World {
  // HTTP Client
  httpClient: AxiosInstance
  baseUrl: string

  // Authentication
  authToken: string | null
  currentUser: User | null

  // Database
  dataSource: DataSource

  // Test Context (stores scenario-specific data)
  context: {
    response?: AxiosResponse
    applications?: Application[]
    alerts?: Alert[]
    error?: Error
    [key: string]: unknown
  }

  // Factory Access
  factories: {
    user: UserFactory
    application: ApplicationFactory
    alert: AlertFactory
    ipAsset: IPAssetFactory
  }

  // Helper Methods
  authenticate(user: User): Promise<string>
  clearDatabase(): Promise<void>
  seedDatabase(seed: DatabaseSeed): Promise<void>
}
```

### Common Step Definition Patterns

#### Given Steps (Setup - Seed Database):
```typescript
Given('Alice has submitted IP applications', async function (this: IPHubWorld) {
  // Create user if not exists
  if (!this.currentUser) {
    this.currentUser = await this.factories.user.create({ name: 'Alice' })
    this.authToken = await this.authenticate(this.currentUser)
  }

  // Seed applications in database via factory
  const applications = await this.factories.application.createMany(3, {
    userId: this.currentUser.id,
    status: 'submitted'
  })

  this.context.applications = applications
})

Given('Alice has {int} patent applications', async function (this: IPHubWorld, count: number) {
  const applications = await this.factories.application.createMany(count, {
    userId: this.currentUser.id,
    type: 'patent'
  })
  this.context.applications = applications
})
```

#### When Steps (Actions - API Calls):
```typescript
When('Alice requests the dashboard summary', async function (this: IPHubWorld) {
  try {
    const response = await this.httpClient.get('/api/dashboard/summary', {
      headers: { Authorization: `Bearer ${this.authToken}` }
    })
    this.context.response = response
  } catch (error) {
    if (error.response) {
      this.context.response = error.response
    }
    this.context.error = error
  }
})

When('Alice creates a new patent application with:', async function (this: IPHubWorld, dataTable: DataTable) {
  const payload = dataTable.rowsHash()

  try {
    const response = await this.httpClient.post('/api/actions/register', {
      type: 'patent',
      payload
    }, {
      headers: { Authorization: `Bearer ${this.authToken}` }
    })
    this.context.response = response
  } catch (error) {
    this.context.response = error.response
    this.context.error = error
  }
})
```

#### Then Steps (Assertions - Validate Response):
```typescript
Then('the API returns status code {int}', async function (this: IPHubWorld, statusCode: number) {
  expect(this.context.response?.status).toBe(statusCode)
})

Then('Alice sees a total of {int} assets', async function (this: IPHubWorld, count: number) {
  expect(this.context.response?.status).toBe(200)
  expect(this.context.response?.data.totalAssets).toBe(count)
})

Then('the response contains an application with:', async function (this: IPHubWorld, dataTable: DataTable) {
  const expectedFields = dataTable.rowsHash()
  const response = this.context.response?.data

  expect(response).toBeDefined()
  for (const [key, value] of Object.entries(expectedFields)) {
    expect(response[key]).toBe(value)
  }
})

Then('a {string} domain event is emitted', async function (this: IPHubWorld, eventName: string) {
  // Check event store or event bus for emitted event
  const events = await this.getEmittedEvents()
  const matchingEvent = events.find(e => e.type === eventName)
  expect(matchingEvent).toBeDefined()
})
```

### Data Table Handling
```typescript
When('Alice creates applications with:', async function (
  this: IPHubWorld,
  dataTable: DataTable
) {
  const rows = dataTable.hashes()

  for (const row of rows) {
    const response = await this.httpClient.post('/api/actions/register', {
      type: row.type,
      payload: {
        title: row.title,
        description: row.description
      }
    }, {
      headers: { Authorization: `Bearer ${this.authToken}` }
    })

    expect(response.status).toBe(201)
  }
})
```

### Factory Pattern (Testcontainers)
Located in `test/shared/factories/`:
```typescript
// application.factory.ts
import { DataSource } from 'typeorm'
import { Application } from '../../entities/application.entity'

export class ApplicationFactory {
  constructor(private dataSource: DataSource) {}

  async create(overrides: Partial<Application> = {}): Promise<Application> {
    const repo = this.dataSource.getRepository(Application)
    const application = repo.create({
      id: randomUUID(),
      title: 'Test Application',
      type: 'patent',
      status: 'draft',
      createdAt: new Date(),
      updatedAt: new Date(),
      ...overrides
    })
    return repo.save(application)
  }

  async createMany(count: number, overrides: Partial<Application> = {}): Promise<Application[]> {
    const applications: Application[] = []
    for (let i = 0; i < count; i++) {
      applications.push(await this.create({
        title: `Test Application ${i + 1}`,
        ...overrides
      }))
    }
    return applications
  }
}
```

### IP Hub Domain Context

This is an **IP (Intellectual Property) Hub** platform with:

**Asset Types**: Patents, Trademarks, Copyrights, Utility Certificates
**Application Statuses**: Draft, In Progress, Submitted, Under Review, Action Required, Approved, Rejected
**BFFE Endpoints** (from specs/<<YOUR-SPEC-FOLDER>>/bffe-spec.md):
  - `GET /dashboard/summary` - Portfolio summary and status cards
  - `GET /dashboard/alerts` - Urgent alerts and deadlines
  - `GET /dashboard/applications-in-progress` - Active applications
  - `GET /dashboard/assets-breakdown` - Asset counts by type
  - `POST /actions/register` - Create new application
  - `POST /actions/import-asset` - Import external asset
  - `GET /search` - Search assets and applications
  - `POST /alerts/{alertId}/dismiss` - Dismiss alert
  - `POST /applications/{id}/status-transition` - Change application status

**Bounded Contexts**:
  - Identity Management
  - Shared Kernel
  - Patent Application
  - Trademark Application
  - Copyright Application
  - IP Asset Management
  - Notifications
  - Workflow & Status Tracking
  - Fee Calculation & Payment
  - Document Management

**Domain Events** (verify these are emitted for Commands):
  - PatentApplicationDrafted
  - TrademarkApplicationDrafted
  - CopyrightApplicationDrafted
  - ApplicationStatusChanged
  - NotificationDismissed
  - DocumentUploaded
  - PaymentInitiated

### BFFE API Response Patterns

```typescript
// Successful response structure
interface ApiSuccessResponse<T> {
  success: true
  data: T
}

// Error response structure
interface ApiErrorResponse {
  success: false
  error: {
    code: string
    message: string
    details?: Record<string, unknown>
  }
}
```

### Best Practices

1. **Always authenticate first**: Get auth token before making API calls
2. **Use factories for setup**: Never insert data directly into database
3. **Validate status codes**: Always check HTTP response status
4. **Check response structure**: Validate against BFFE spec
5. **Verify domain events**: For Commands, check events are emitted
6. **Clean up after tests**: Use After hooks to clear test data
7. **Follow existing patterns**: Review similar steps in existing files
8. **Use TypeScript strictly**: No `any` types, proper interfaces

### Test Execution
```bash
# Run all E2E tests
npx nx e2e ip-hub-backend-e2e

# Run specific feature
npx cucumber-js apps/ip-hub-backend-e2e/features/<<YOUR-FEATURE-HERE>>.feature

# Dry run to check syntax
npx nx e2e ip-hub-backend-e2e --dry-run

# View HTML report
open reports/cucumber_report.html
```
