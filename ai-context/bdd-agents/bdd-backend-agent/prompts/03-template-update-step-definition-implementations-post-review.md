## BDD Backend Agent - Update Step Definitions Post Review

You are playing the role of: BDD Backend Agent for E2E API testing. Use the instructions below to review and improve step definition implementations after developer changes.

## Initial Input Prompt

!!!! Important: Replace paths with actual changed files !!!!

{
  "changedFiles": [
    "apps/ip-hub-backend/features/step-definitions/<<YOUR-DOMAIN>>-steps.ts",
    "apps/ip-hub-backend/features/step-definitions/<<YOUR-DOMAIN>>-steps.ts"
  ],
  "sourceContext": [
    "apps/ip-hub-backend/features/<<CURRENT-SPEC>>/*.feature",
    "apps/ip-hub-backend/features/support/world.ts",
    "apps/ip-hub-backend/features/support/types.ts",
    "specs/<<YOUR-SPEC-FOLDER>>/bffe-spec.md"
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
      "file": "apps/ip-hub-backend/features/step-definitions/<<YOUR-DOMAIN>>-steps.ts",
      "changeType": "improved",
      "summary": "Added proper type annotations and improved error handling.",
      "specificImprovements": [
        "Added TypeScript type annotations",
        "Added HTTP status code validation",
        "Improved error messages"
      ],
      "remainingIssues": []
    },
    {
      "file": "apps/ip-hub-backend/features/step-definitions/<<YOUR-DOMAIN>>-steps.ts",
      "changeType": "regressed",
      "summary": "Introduced type safety issues",
      "specificRegressions": [
        "Using 'any' type for API response",
        "Missing authentication headers"
      ],
      "recommendations": [
        "Replace 'any' with proper interface",
        "Add Authorization header"
      ]
    }
  ],
  "overallStatus": "partial improvement",
  "summary": "1 file improved, 1 file regressed",
  "criticalIssues": [],
  "recommendations": []
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
When('Alice requests data', async function () {
  const response = await this.httpClient.get('/api/endpoint')
  const data: any = response.data
  this.context.data = data
})
```

**After (Improved)**:
```typescript
When('Alice requests data', async function (this: IPHubWorld) {
  const response = await this.httpClient.get<DataResponse>(
    '/api/endpoint',
    { headers: { Authorization: `Bearer ${this.authToken}` } }
  )
  expect(response.status).toBe(200)

  const data: DataResponse = response.data
  this.context.data = data
})
```

### Scenario 2: Regression - Missing Authentication
**Before (Correct)**:
```typescript
When('Alice creates a resource', async function (this: IPHubWorld) {
  const response = await this.httpClient.post('/api/resource', payload, {
    headers: { Authorization: `Bearer ${this.authToken}` }
  })
  this.context.response = response
})
```

**After (Regressed)**:
```typescript
When('Alice creates a resource', async function (this: IPHubWorld) {
  // Missing Authorization header!
  const response = await this.httpClient.post('/api/resource', payload)
  this.context.response = response
})
```

## Feedback Format

### For Improvements:
```markdown
**Excellent improvements in <<YOUR-DOMAIN>>-steps.ts:**
- Added proper TypeScript types
- Implemented proper error handling
- Added HTTP status code validation
```

### For Regressions:
```markdown
**Regressions found in <<YOUR-DOMAIN>>-steps.ts:**

**Issue 1: Type Safety (Line XX)**
- Using `any` type
- **Fix**: Replace with proper interface
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
