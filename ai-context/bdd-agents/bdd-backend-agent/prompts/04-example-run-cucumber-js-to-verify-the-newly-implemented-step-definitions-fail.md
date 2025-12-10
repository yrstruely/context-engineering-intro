## BDD Backend Agent - Verify Step Definitions Fail Correctly

You are playing the role of: BDD Backend Agent for E2E API testing. Use the instructions below to verify that the newly implemented step definitions fail correctly (before the actual backend implementation exists).

## Initial Input Prompt

!!!! Important: No files to change for this one !!!!

{
  "featureFiles": "apps/ip-hub-backend/features/011-onboarding/*.feature",
  "stepDefinitionFiles": [
    "apps/ip-hub-backend/features/step-definitions/dashboard-steps.ts",
    "apps/ip-hub-backend/features/step-definitions/application-steps.ts",
    "apps/ip-hub-backend/features/step-definitions/alert-steps.ts"
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
npx nx test:e2e:local ip-hub-backend

# Or run with more verbose output
npx cucumber-js apps/ip-hub-backend/features/011-onboarding/*.feature \
  --format progress-bar \
  --format json:reports/cucumber_report.json \
  --format html:reports/cucumber_report.html

# Run with tags to focus on specific scenarios
npx cucumber-js apps/ip-hub-backend/features/011-onboarding/*.feature --tags "@dashboard"
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
    "totalScenarios": 25,
    "passed": 0,
    "failed": 25,
    "pending": 0,
    "undefined": 0
  },
  "failureAnalysis": {
    "readyForImplementation": [
      {
        "scenario": "User views dashboard after login",
        "feature": "phase1-core-dashboard.feature",
        "failureReason": "API endpoint not found (404)",
        "failingStep": "When Alice logs into the platform",
        "expectedFailure": true,
        "implementationNeeded": "GET /api/dashboard/summary endpoint"
      },
      {
        "scenario": "User views portfolio status cards",
        "feature": "phase1-core-dashboard.feature",
        "failureReason": "AssertionError: expected 0 to equal 14",
        "failingStep": "Then Alice sees a 'Total Assets' card showing 14 IP assets",
        "expectedFailure": true,
        "implementationNeeded": "GetPortfolioSummary query handler"
      }
    ],
    "stepDefinitionBugs": [
      {
        "scenario": "User dismisses alert notification",
        "feature": "phase1-core-dashboard.feature",
        "failureReason": "TypeError: Cannot read property 'id' of undefined",
        "failingStep": "When Alice dismisses a notification",
        "expectedFailure": false,
        "fix": "Check that alert is created in Given step before accessing this.context.alert.id"
      }
    ],
    "setupIssues": [
      {
        "scenario": "User filters applications by type",
        "feature": "phase1-core-dashboard.feature",
        "failureReason": "ECONNREFUSED 127.0.0.1:3000",
        "failingStep": "When Alice views the dashboard",
        "expectedFailure": false,
        "fix": "Ensure backend server is running on port 3000"
      }
    ],
    "unexpectedPasses": []
  },
  "status": "expected_failures",
  "summary": "23/25 scenarios failing as expected (ready for implementation). 2 scenarios have step definition bugs that need fixing.",
  "nextSteps": [
    "Fix step definition bug in alert-steps.ts (line 45)",
    "Ensure server is running before tests",
    "Proceed with backend implementation for 23 scenarios"
  ],
  "reportLocation": "reports/cucumber_report.html"
}

## Failure Analysis Examples

### Example 1: Expected Failure (404 - Endpoint Not Implemented)
```
Scenario: User views dashboard after login
  Given Alice is an authenticated user         # ✓ Passed - Setup works
  When Alice logs into the platform            # ✗ Failed
    Error: Request failed with status code 404
    GET /api/dashboard/summary returned 404 Not Found

  Analysis: EXPECTED FAILURE
  - Step definition is correct
  - API endpoint doesn't exist yet
  - Ready for backend implementation
```

### Example 2: Expected Failure (Assertion - Data Not Returned)
```
Scenario: User views portfolio status cards
  Given Alice has 11 active IP assets          # ✓ Passed - Database seeded
  When Alice views the dashboard               # ✓ Passed - API call made
  Then Alice sees a "Total Assets" card showing 14 IP assets  # ✗ Failed
    AssertionError: expected 0 to equal 14

  Analysis: EXPECTED FAILURE
  - Step definition is correct
  - Data was seeded, but query doesn't return it yet
  - GetPortfolioSummary query needs implementation
```

### Example 3: Step Definition Bug (TypeError)
```
Scenario: User dismisses alert notification
  Given Alice has pending notifications in the alert banner  # ✓ Passed
  When Alice dismisses a notification                        # ✗ Failed
    TypeError: Cannot read property 'id' of undefined
    at dismissAlert (alert-steps.ts:45)

  Analysis: STEP DEFINITION BUG
  - Bug in step definition code
  - this.context.alert is undefined
  - Fix: Ensure Given step sets this.context.alert correctly
```

### Example 4: Setup Issue (Connection Refused)
```
Scenario: User filters applications by type
  Given Alice has 3 patent applications        # ✗ Failed
    Error: connect ECONNREFUSED 127.0.0.1:3000

  Analysis: SETUP ISSUE
  - Server not running
  - Fix: Start backend server before running tests
```

### Example 5: Unexpected Pass (Review Required)
```
Scenario: User views empty applications section
  Given Alice has no active applications       # ✓ Passed
  When Alice views the dashboard               # ✓ Passed
  Then Alice sees an empty state message       # ✓ Passed

  Analysis: UNEXPECTED PASS
  - This should fail if endpoint not implemented
  - Either endpoint exists, or step definition is wrong
  - Review: Is assertion checking the right thing?
```

## Verification Commands

```bash
# Run all E2E tests with verbose output
npx nx test:e2e:local ip-hub-backend --verbose

# Run specific feature file
npx cucumber-js apps/ip-hub-backend/features/011-onboarding/*.feature

# Run with tags
npx cucumber-js --tags "@dashboard and not @wip"

# Run with fail-fast (stop on first failure)
npx cucumber-js --fail-fast

# Generate HTML report
npx cucumber-js --format html:reports/cucumber_report.html

# View the report
open reports/cucumber_report.html

# Check for TypeScript errors first
npx tsc --noEmit

# Check for undefined steps
npx nx test:e2e:local ip-hub-backend --dry-run
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
Error: Step implementation not found for: "Alice views the dashboard"
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
