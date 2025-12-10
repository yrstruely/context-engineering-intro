## BDD Backend Agent - Verify Step Definitions Fail Correctly

You are playing the role of: BDD Backend Agent for E2E API testing. Use the instructions below to verify that the newly implemented step definitions fail correctly (before the actual backend implementation exists).

## Initial Input Prompt

!!!! Important: No files to change for this one !!!!

{
  "featureFiles": "apps/ip-hub-backend/features/<<CURRENT-SPEC>>/*.feature",
  "stepDefinitionFiles": [
    "apps/ip-hub-backend/features/step-definitions/<<YOUR-DOMAIN>>-steps.ts"
  ],
  "task": "04-verify-step-definitions-fail-correctly",
  "testFramework": "axios",
  "bddFramework": "cucumber",
  "projectType": "nestjs-e2e",
  "language": "typescript"
}

## Purpose of This Step

In TDD/BDD workflow, after implementing step definitions but **before** implementing the actual backend functionality, we run the tests expecting them to **fail**. This confirms:

1. **Step definitions are correctly wired**: Steps are found and executed
2. **Test setup works**: Database, HTTP client, authentication setup
3. **Assertions are correct**: Tests fail for the right reasons (e.g., 404, empty data)
4. **No false positives**: Tests don't pass when they shouldn't

## BDD Backend Agent Behavior (Step-by-Step)

### Step 1: Ensure Prerequisites
```bash
# Ensure database is running (Testcontainers or Docker)
docker-compose up -d

# Ensure backend is running (for integration tests)
npx nx serve ip-hub-backend --watch=false &

# Or if using Testcontainers, ensure Docker is available
docker info
```

### Step 2: Run Cucumber Tests
```bash
# Run the E2E tests for the specific feature
npx nx e2e ip-hub-backend-e2e

# Or run with more verbose output
npx cucumber-js apps/ip-hub-backend/features/<<CURRENT-SPEC>>/*.feature \
  --format progress-bar \
  --format json:reports/cucumber_report.json \
  --format html:reports/cucumber_report.html
```

### Step 3: Analyze Failure Types

**Expected Failures (Good - Implementation Needed)**:
- `404 Not Found` - API endpoint not implemented yet
- `501 Not Implemented` - Method stub exists but not implemented
- Empty response where data expected - Query handler not implemented
- `AssertionError: expected 0 to equal 5` - Logic not implemented

**Unexpected Failures (Bad - Step Definition Issues)**:
- `TypeError` - Code error in step definition
- `Step not defined` - Missing step definition
- `401 Unauthorized` - Authentication not set up correctly
- `500 Internal Server Error` - Server-side crash
- Connection errors - Server not running or wrong URL

### Step 4: Document Results

Categorize each failing scenario:
- **Ready for Implementation**: Fails for expected reasons (404, empty data)
- **Step Definition Bug**: Fails due to code error in step definition
- **Setup Issue**: Fails due to test infrastructure problem
- **Already Passing**: Unexpected pass (review if implementation exists)

## Expected Output (Agent's Response Schema)

{
  "executionSummary": {
    "totalScenarios": 0,
    "passed": 0,
    "failed": 0,
    "pending": 0,
    "undefined": 0
  },
  "failureAnalysis": {
    "readyForImplementation": [],
    "stepDefinitionBugs": [],
    "setupIssues": [],
    "unexpectedPasses": []
  },
  "status": "expected_failures",
  "summary": "",
  "nextSteps": [],
  "reportLocation": "reports/cucumber_report.html"
}

## Failure Analysis Examples

### Example 1: Expected Failure (404 - Endpoint Not Implemented)
```
Scenario: User views data
  Given Alice is authenticated         # ✓ Passed - Setup works
  When Alice requests data             # ✗ Failed
    Error: Request failed with status code 404

  Analysis: EXPECTED FAILURE
  - Step definition is correct
  - API endpoint doesn't exist yet
  - Ready for backend implementation
```

### Example 2: Step Definition Bug (TypeError)
```
Scenario: User dismisses item
  Given Alice has items                # ✓ Passed
  When Alice dismisses an item         # ✗ Failed
    TypeError: Cannot read property 'id' of undefined

  Analysis: STEP DEFINITION BUG
  - Bug in step definition code
  - Fix: Ensure Given step sets up context correctly
```

### Example 3: Setup Issue (Connection Refused)
```
Scenario: User views data
  Given Alice has data                 # ✗ Failed
    Error: connect ECONNREFUSED 127.0.0.1:3000

  Analysis: SETUP ISSUE
  - Server not running
  - Fix: Start backend server before running tests
```

## Verification Commands

```bash
# Run all E2E tests with verbose output
npx nx e2e ip-hub-backend-e2e --verbose

# Run specific feature file
npx cucumber-js apps/ip-hub-backend/features/<<CURRENT-SPEC>>/*.feature

# Run with fail-fast (stop on first failure)
npx cucumber-js --fail-fast

# Generate HTML report
npx cucumber-js --format html:reports/cucumber_report.html

# View the report
open reports/cucumber_report.html

# Check for TypeScript errors first
npx tsc --noEmit

# Check for undefined steps
npx nx e2e ip-hub-backend-e2e --dry-run
```

## Post-Verification Checklist

Before declaring step definitions ready:

- [ ] All step definitions are found (no "undefined" steps)
- [ ] No TypeScript compilation errors
- [ ] No runtime errors in step definition code
- [ ] Failures are due to missing backend implementation, not test bugs
- [ ] Database setup/teardown works correctly
- [ ] Authentication setup works correctly
- [ ] HTTP client configuration is correct
- [ ] All scenarios have documented expected failure reasons

## Common Issues and Fixes

### Issue: Steps Not Found
```
Error: Step implementation not found for: "..."
```
**Fix**: Check step definition file is in the correct location and cucumber config includes it.

### Issue: Wrong Base URL
```
Error: connect ECONNREFUSED 127.0.0.1:3000
```
**Fix**: Set correct `BASE_URL` environment variable or configure in World constructor.

### Issue: Missing Auth Token
```
Error: Request failed with status code 401
```
**Fix**: Ensure Given step authenticates user and sets `this.authToken`.

### Issue: Testcontainer Not Starting
```
Error: Container startup failed
```
**Fix**: Ensure Docker daemon is running and has enough resources.

### Issue: Database Not Cleaned
```
Error: Duplicate key violation
```
**Fix**: Ensure After hook cleans database between scenarios.

## Red-Green-Refactor Workflow

This step completes the **Red** phase of TDD:

1. **Red** (This step): Tests fail because implementation doesn't exist
2. **Green** (Next): Implement backend to make tests pass
3. **Refactor** (Later): Clean up code while keeping tests green

After verifying failures are correct, hand off to backend developers with:
- List of failing scenarios
- Expected implementations needed (endpoints, handlers, queries)
- Test report location for tracking progress
