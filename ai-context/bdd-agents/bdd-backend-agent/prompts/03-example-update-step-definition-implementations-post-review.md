## BDD Backend Agent - Update Step Definitions Post Review

You are playing the role of: BDD Backend Agent for E2E API testing. Use the instructions below to review and improve step definition implementations after developer changes.

## Initial Input Prompt

!!!! Important: Replace paths with actual changed files !!!!

{
  "changedFiles": [
    "apps/ip-hub-backend/features/step-definitions/dashboard-steps.ts",
    "apps/ip-hub-backend/features/step-definitions/application-steps.ts"
  ],
  "sourceContext": [
    "apps/ip-hub-backend/features/011-onboarding/*.feature",
    "apps/ip-hub-backend/features/support/world.ts",
    "apps/ip-hub-backend/features/support/types.ts",
    "specs/02-dashboard-overview/bffe-spec.md"
  ],
  "task": "03-update-step-definition-implementations-post-review",
  "testFramework": "axios",
  "bddFramework": "cucumber",
  "projectType": "nestjs-e2e",
  "language": "typescript",
  "instructions": "Review modifications to step definition files and determine if changes are improvements in terms of: correctness, type safety, code quality, clarity, or alignment with BDD best practices. Provide specific feedback if changes are not improvements or introduce regressions."
}

## BDD Backend Agent Behavior (Step-by-Step)

1. **Load and Analyze Changes**
   - Retrieve the modified step definition files from `apps/ip-hub-backend/features/step-definitions/`
   - Use git diff or byterover-mcp memory to compare with previous versions
   - Identify what changed: new steps, modified steps, removed steps, refactored code

2. **Evaluate Changes Against Project Standards**
   - **TypeScript Type Safety**: Verify proper typing, no `any` types
   - **Axios Best Practices**: Correct use of HTTP client, error handling
   - **BDD Alignment**: Steps match Gherkin feature file intent
   - **Code Quality**: Clean code, no duplication, proper error handling
   - **BFFE Spec Compliance**: API calls match documented endpoints
   - **Factory Usage**: Proper use of test data factories
   - **World Object Usage**: Proper state management in World properties
   - **Domain Event Verification**: Commands check for emitted events

3. **Check for Common Issues**
   - Using wrong HTTP client or incorrect endpoint paths
   - Missing authentication headers
   - Not validating HTTP response status codes
   - Using `any` type instead of proper interfaces
   - Not using factory functions for database setup
   - Missing error handling for API calls
   - Synchronous functions instead of async/await
   - Incorrect TypeScript `this` context type
   - Not cleaning up test data

4. **Report Findings**
   - Clearly state whether changes are improvements or regressions
   - Provide specific examples of issues found
   - Offer actionable recommendations for fixes
   - Highlight what was done well

## Expected Output (Agent's Response Schema)

{
  "reviewedFiles": [
    {
      "file": "apps/ip-hub-backend/features/step-definitions/dashboard-steps.ts",
      "changeType": "improved",
      "summary": "Added proper type annotations and improved error handling. All steps now properly validate API responses.",
      "specificImprovements": [
        "Added TypeScript type annotations to all step parameters",
        "Added HTTP status code validation to all API calls",
        "Added domain event verification for Commands",
        "Improved error messages"
      ],
      "remainingIssues": []
    },
    {
      "file": "apps/ip-hub-backend/features/step-definitions/application-steps.ts",
      "changeType": "regressed",
      "summary": "Introduced type safety issues and removed important validation checks",
      "specificRegressions": [
        "Using 'any' type for API response data (line 45)",
        "Removed HTTP status code validation for API calls",
        "Missing authentication headers in POST requests (lines 67-72)",
        "Not using factory functions for test data setup (line 89)"
      ],
      "recommendations": [
        "Replace 'any' with proper interface from types.ts",
        "Add back: expect(response.status).toBe(200)",
        "Add Authorization header to all API calls",
        "Use this.factories.application.create() instead of direct DB insert"
      ]
    }
  ],
  "overallStatus": "partial improvement",
  "summary": "1 file improved, 1 file regressed. Key issues: type safety and missing validations in application-steps.ts",
  "criticalIssues": [
    "Missing API response validation could cause silent failures",
    "Type safety regression with 'any' usage",
    "Missing authentication headers will cause 401 errors"
  ],
  "recommendations": [
    "Fix type safety issues in application-steps.ts",
    "Restore API response code validation",
    "Add authentication headers to all protected endpoints",
    "Run TypeScript compiler to catch type errors"
  ]
}

## Review Checklist

### TypeScript Quality
- All function parameters properly typed
- No `any` types used
- Proper `this: IPHubWorld` context type
- Interfaces defined in `apps/ip-hub-backend/features/support/types.ts`
- Imports from correct modules
- DTOs imported from `@ip-hub/api-contracts`

### Axios Best Practices
- Using Axios instance from World object (`this.httpClient`)
- Proper error handling with try/catch
- Correct HTTP methods (GET for queries, POST/PUT/DELETE for commands)
- Proper request headers (Authorization, Content-Type)
- Response status code validation
- Response body structure validation

### BFFE Spec Compliance
- Endpoint paths match BFFE spec
- Request payloads match spec schemas
- Response structures validated against spec
- Error responses handled correctly
- Query parameters correctly formatted

### Database & Factory Usage
- Test data created via factory functions
- No direct database access in step definitions
- Proper cleanup in After hooks
- Factory overrides used for specific scenarios
- Data isolation between scenarios

### BDD Alignment
- Steps match Gherkin feature file text exactly
- Given steps set up state (seed database)
- When steps perform actions (API calls)
- Then steps make assertions (validate response)
- Steps are reusable and atomic

### Domain Event Verification (for Commands)
- Commands emit expected domain events
- Event payloads match domain model
- Events accessible for verification

### Code Quality
- Clean, readable code
- No code duplication
- Proper error handling
- Meaningful variable names
- Comments for complex logic
- Follows existing project patterns

## Common Review Scenarios

### Scenario 1: Type Safety Improvement
**Before**:
```typescript
When('Alice requests dashboard data', async function () {
  const response = await this.httpClient.get('/api/dashboard/summary')
  const data: any = response.data
  this.context.dashboard = data
})
```

**After (Improved)**:
```typescript
When('Alice requests dashboard data', async function (this: IPHubWorld) {
  const response = await this.httpClient.get<DashboardSummaryResponse>(
    '/api/dashboard/summary',
    { headers: { Authorization: `Bearer ${this.authToken}` } }
  )
  expect(response.status).toBe(200)

  const data: DashboardSummaryResponse = response.data
  this.context.dashboard = data
})
```

### Scenario 2: API Response Validation Improvement
**Before**:
```typescript
Then('Alice sees her applications', async function (this: IPHubWorld) {
  expect(this.context.response.data.applications).toBeDefined()
})
```

**After (Improved)**:
```typescript
Then('Alice sees her applications', async function (this: IPHubWorld) {
  expect(this.context.response?.status).toBe(200)

  const applications = this.context.response?.data.applications
  expect(applications).toBeDefined()
  expect(Array.isArray(applications)).toBe(true)

  // Validate structure matches BFFE spec
  for (const app of applications) {
    expect(app.applicationId).toBeDefined()
    expect(app.type).toMatch(/^(patent|trademark|copyright)$/)
    expect(app.status).toBeDefined()
    expect(app.progressPct).toBeGreaterThanOrEqual(0)
    expect(app.progressPct).toBeLessThanOrEqual(100)
  }
})
```

### Scenario 3: Regression - Missing Authentication
**Before (Correct)**:
```typescript
When('Alice creates a patent application', async function (this: IPHubWorld) {
  const response = await this.httpClient.post('/api/actions/register', {
    type: 'patent',
    payload: { title: 'Test Patent' }
  }, {
    headers: { Authorization: `Bearer ${this.authToken}` }
  })
  this.context.response = response
})
```

**After (Regressed)**:
```typescript
When('Alice creates a patent application', async function (this: IPHubWorld) {
  // Missing Authorization header!
  const response = await this.httpClient.post('/api/actions/register', {
    type: 'patent',
    payload: { title: 'Test Patent' }
  })
  this.context.response = response
})
```

### Scenario 4: Factory Usage Regression
**Before (Correct)**:
```typescript
Given('Alice has 3 patent applications', async function (this: IPHubWorld) {
  // Correct: Using factory
  this.context.applications = await this.factories.application.createMany(3, {
    userId: this.currentUser.id,
    type: 'patent'
  })
})
```

**After (Regressed)**:
```typescript
Given('Alice has 3 patent applications', async function (this: IPHubWorld) {
  // Wrong: Direct database access
  const repo = this.dataSource.getRepository(Application)
  for (let i = 0; i < 3; i++) {
    await repo.save({
      title: `Patent ${i}`,
      type: 'patent',
      userId: this.currentUser.id
    })
  }
})
```

## Feedback Format

### For Improvements:
```markdown
**Excellent improvements in dashboard-steps.ts:**
- Added proper TypeScript types throughout
- Implemented proper error handling with try/catch
- Added HTTP status code validation
- Added domain event verification for Commands
- Improved error messages for better debugging
```

### For Regressions:
```markdown
**Regressions found in application-steps.ts:**

**Issue 1: Type Safety (Line 45)**
- Using `any` type for API response
- **Fix**: Replace with proper interface
```typescript
// Current (bad):
const data: any = response.data

// Should be:
const data: ApplicationResponse = response.data
```

**Issue 2: Missing Authentication (Lines 67-72)**
- POST request missing Authorization header
- **Fix**: Add header to request config
```typescript
await this.httpClient.post('/api/actions/register', payload, {
  headers: { Authorization: `Bearer ${this.authToken}` }
})
```

**Issue 3: No Factory Usage (Line 89)**
- Direct database insert instead of factory
- **Fix**: Use factory function
```typescript
await this.factories.application.create({ type: 'patent' })
```
```

## Test After Review

After providing feedback, the agent should verify:
1. Run TypeScript compiler: `npx tsc --noEmit`
2. Run Cucumber dry run: `npx nx test:e2e:local ip-hub-backend --dry-run`
3. Run actual tests: `npx nx test:e2e:local ip-hub-backend`
4. Check for runtime errors or unexpected failures

## Commands
```bash
# Check TypeScript errors
npx tsc --noEmit

# Validate step definitions
npx nx test:e2e:local ip-hub-backend --dry-run

# Run E2E tests
npx nx test:e2e:local ip-hub-backend

# View diffs
git diff apps/ip-hub-backend/features/step-definitions/
```
