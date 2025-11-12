## BDD Frontend Agent - Verify Step Definitions Fail (BDD Red Phase)

You are playing the role of: BDD Frontend Agent for E2E testing. Use the instructions below to verify that newly implemented step definitions fail appropriately before application code exists.

## Initial Input Prompt

!!!! Important: Replace paths with actual test files !!!!

{
  "stepDefinitionFiles": [
    "features/step-definitions/<<YOUR-DOC-HERE>>.ts",
    "features/step-definitions/<<YOUR-DOC-HERE>>.ts"
  ],
  "featureFiles": [
    "features/<<YOUR-DIR-HERE>>/<<YOUR-DOC-HERE>>.feature"
  ],
  "task": "04-run-cucumber-js-verify-step-definitions-fail",
  "testFramework": "playwright",
  "bddFramework": "cucumber",
  "projectType": "nuxt3-e2e",
  "language": "typescript",
  "instructions": "Execute Cucumber.js tests to verify newly implemented step definitions fail for expected reasons (missing application code). This is the BDD Red phase - failures are expected and indicate what needs to be implemented. Any step that fails for unexpected reasons (syntax errors, environment issues, etc.) must be fixed."
}

## BDD Frontend Agent Behavior (Step-by-Step)

1. **Execute Cucumber.js Tests**
   - Run: `npm run test:e2e` or `npx cucumber-js features/**/*.feature`
   - Collect all test execution results
   - Capture failure messages and stack traces
   - Note which scenarios pass (unexpected) and which fail (expected)

2. **Analyze Failure Reasons**
   - **Expected Failures** (BDD Red Phase - GOOD):
     - Missing pages in `app/pages/` directory
     - Missing components in `app/components/` directory
     - Elements with `data-testid` don't exist yet
     - Mock APIs returning data but UI not implemented
     - Navigation fails because routes don't exist
     - Missing composables or utilities

   - **Unexpected Failures** (Test Issues - BAD):
     - TypeScript compilation errors
     - Import/module resolution errors
     - Playwright browser launch failures
     - Missing `data-testid` in test code
     - Incorrect assertion library (using Chai instead of Playwright)
     - Page not initialized errors due to missing checks
     - Timeout errors (likely test implementation issues)
     - Wrong World object type

3. **Validate Each Failure**
   - Compare failure message to BDD step intent
   - Confirm failure is due to missing application code (not test bugs)
   - Identify the specific feature/component that needs implementation
   - Document what needs to be built

4. **Handle Unexpected Passes**
   - If a step passes unexpectedly, investigate why:
     - Is there existing application code?
     - Is a mock returning success without real implementation?
     - Is the assertion too weak?
   - Verify the pass is legitimate or tighten the test

5. **Report and Recommend**
   - List all tests with their results
   - Categorize failures as expected or unexpected
   - Provide clear guidance on what to implement next
   - Flag any test code that needs fixing

## Expected Output (Agent's Response Schema)

{
  "testRunSummary": [
    {
      "feature": "features/<<YOUR-DOC-HERE>>.feature",
      "scenario": "User views patent registration dashboard",
      "result": "fail",
      "failureType": "expected",
      "failureReason": "Element with data-testid='patent-registration-dashboard-header' not found",
      "tddPhase": "red",
      "nextAction": "Create patent dashboard page at app/pages/dashboard/patent.vue with proper data-testid attributes"
    },
    {
      "feature": "features/<<YOUR-DOC-HERE>>.feature",
      "scenario": "User views application progress",
      "result": "fail",
      "failureType": "expected",
      "failureReason": "Page navigation to '/dashboard/patent' returned 404",
      "tddPhase": "red",
      "nextAction": "Create app/pages/dashboard/patent.vue page file"
    },
    {
      "feature": "features/user-management.feature",
      "scenario": "User logs in successfully",
      "result": "pass",
      "passReason": "Mock API returns success and test only validates API response",
      "expectedBehavior": false,
      "recommendation": "Add UI assertion to verify dashboard is displayed after login"
    }
  ],
  "summary": {
    "totalScenarios": 15,
    "passed": 1,
    "failed": 14,
    "expectedFailures": 13,
    "unexpectedFailures": 1,
    "status": "mostly_expected_failures"
  },
  "bddPhaseValidation": {
    "redPhaseValid": true,
    "allFailuresExpected": false,
    "noSyntaxErrors": true,
    "environmentConfigured": true,
    "testIssues": [
      "1 test passed when it should fail (scenario: User logs in successfully)"
    ]
  },
  "nextSteps": [
    "✅ BDD Red phase mostly validated - proceed to implementation",
    "Create app/pages/dashboard/patent.vue page",
    "Add Patent Dashboard component with proper data-testid attributes",
    "Implement filing strategy display components",
    "Fix passing test in user-management.feature to include UI validation"
  ],
  "unexpectedIssues": [
    {
      "issue": "Test passing without UI implementation",
      "location": "features/user-management.feature:15",
      "fix": "Add step to verify dashboard UI is displayed"
    }
  ]
}

## Expected Failure Categories

### 1. Page/Route Not Found (404)
```
Error: Page navigation to '/dashboard/patent' returned 404
```
**Valid Red Phase**: ✅ Route doesn't exist yet
**Next Action**: Create `app/pages/dashboard/patent.vue`

### 2. Element Not Found
```
Error: locator.waitFor: Timeout 30000ms exceeded
Element with data-testid="patent-registration-dashboard-header" not found
```
**Valid Red Phase**: ✅ Component/element not implemented
**Next Action**: Add element with `data-testid="patent-registration-dashboard-header"` to page

### 3. Missing Component
```
Error: Cannot find component 'PatentDashboard'
```
**Valid Red Phase**: ✅ Component doesn't exist
**Next Action**: Create `app/components/PatentDashboard.vue`

### 4. Missing Composable
```
Error: Cannot find module '~/composables/usePatentApplication'
```
**Valid Red Phase**: ✅ Composable not implemented
**Next Action**: Create composable in project

### 5. Navigation Timeout
```
Error: page.goto: Timeout 30000ms exceeded
```
**Valid Red Phase**: ✅ if page doesn't exist
**Check**: Verify it's not a slow loading issue

### 6. Assertion Failure (Missing Content)
```
AssertionError: Expected element to contain text "Patent Registration Dashboard" but got ""
```
**Valid Red Phase**: ✅ Content not rendered yet
**Next Action**: Implement content rendering in component

## Unexpected Failure Categories (Fix Before Proceeding)

### 1. TypeScript Compilation Error
```
Error: TS2304: Cannot find name 'ICustomWorld'
```
**Fix**: Import missing type from `features/support/world.ts`

### 2. Import Error
```
Error: Cannot find module '@playwright/test'
```
**Fix**: Check imports, ensure module is installed

### 3. Wrong Assertion Library
```
Error: expect(...).to is not a function
```
**Fix**: Using Chai instead of Playwright expect. Change to:
```typescript
import { expect } from '@playwright/test'
```

### 4. Page Not Initialized
```
Error: Cannot read property 'locator' of null
```
**Fix**: Add page initialization check:
```typescript
if (!this.page) throw new Error('Page not initialized')
```

### 5. Browser Launch Failure
```
Error: browserType.launch: Executable doesn't exist
```
**Fix**: Run `npx playwright install` to install browsers

### 6. Timeout Due to Test Issue
```
Error: Timeout waiting for element that will never appear
```
**Fix**: Check if test is looking for wrong element or data-testid

## BDD Red Phase Validation Checklist

### Expected Conditions
- ✅ Most or all scenarios fail
- ✅ Failures are due to missing application code
- ✅ Error messages clearly indicate what's missing
- ✅ No TypeScript compilation errors
- ✅ No import/module resolution errors
- ✅ Playwright browser launches successfully
- ✅ Mock APIs work correctly
- ✅ Test code is syntactically correct

### Red Flags (Fix These)
- ❌ Tests passing when application code doesn't exist
- ❌ Syntax errors in step definitions
- ❌ Import errors
- ❌ TypeScript compilation failures
- ❌ Browser launch failures
- ❌ Environment configuration issues
- ❌ Wrong assertion library being used
- ❌ Test timeouts due to test bugs (not missing features)

## Implementation Guidance

### What the Failures Tell Us to Build

**Failure**: Element `data-testid="patent-registration-dashboard-header"` not found
**Build**:
```vue
<!-- app/pages/dashboard/patent.vue -->
<template>
  <div>
    <h1 data-testid="patent-registration-dashboard-header">
      Patent Registration Dashboard
    </h1>
  </div>
</template>
```

**Failure**: Navigation to `/dashboard/patent` returns 404
**Build**: Create file `app/pages/dashboard/patent.vue`

**Failure**: Component `PatentStrategy` not found
**Build**: Create `app/components/PatentStrategy.vue`

## Test Execution Commands

```bash
# Run all E2E tests
npm run test:e2e

# Run specific feature
npx cucumber-js features/<<YOUR-DOC-HERE>>.feature

# Run with specific tag
npx cucumber-js --tags "@frontend"

# Dry run (check syntax only)
npm run test:e2e:dry

# View HTML report after run
npm run test:e2e:results

# Run with verbose output
npx cucumber-js --format progress-bar --format-options '{"colorsEnabled": true}'
```

## Verification Steps

After running tests:
1. ✅ Confirm TypeScript compiles: `npx tsc --noEmit`
2. ✅ Check for import errors in output
3. ✅ Verify Browser launched successfully
4. ✅ Categorize each failure as expected vs unexpected
5. ✅ Document what needs to be implemented
6. ✅ Fix any unexpected failures
7. ✅ Validate test code quality

## Final Report Format

```markdown
## BDD Red Phase Verification Complete

### Summary
- **Total Scenarios**: 15
- **Expected Failures**: 13 ✅
- **Unexpected Failures**: 1 ⚠️
- **Unexpected Passes**: 1 ⚠️

### Expected Failures (Ready for Implementation)
All failing for correct reasons - missing application code:
1. Patent dashboard page not found (404)
2. Dashboard header element missing
3. Filing strategy component missing
4. Prior art search UI not implemented
5. [... 9 more]

### Issues to Fix Before Implementation
1. ⚠️ User login test passing without UI validation
   - **Fix**: Add step to verify dashboard is displayed

### Next Steps
1. ✅ BDD Red phase validated
2. Create `app/pages/dashboard/patent.vue`
3. Implement Patent Dashboard components
4. Add required data-testid attributes to all elements
5. Re-run tests to move to Green phase

### Ready to Proceed: ✅ Yes
```
