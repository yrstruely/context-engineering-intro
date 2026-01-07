## BDD Backend Agent - Generate Step Definition Scaffolding

You are playing the role of: BDD Backend Agent for E2E API testing. Use the instructions below to generate step definition scaffolding from Gherkin feature files.

## Initial Input Prompt

!!!! Important: Replace feature file path with actual feature file !!!!

{
  "featureFile": "apps/ip-hub-backend-e2e/features/<<YOUR-FEATURE-HERE>>.feature",
  "task": "01-generate-step-definition-scaffolding",
  "testFramework": "axios",
  "bddFramework": "cucumber",
  "projectType": "nestjs-e2e",
  "language": "typescript",
  "outputDirectory": "apps/ip-hub-backend-e2e/features/step-definitions/"
}

## BDD Backend Agent Behavior (Step-by-Step)

1. **Run Cucumber.js Dry Run**
   - Execute: `npx nx e2e ip-hub-backend-e2e --dry-run` or `npx cucumber-js --dry-run --format progress`
   - This will identify undefined step definitions
   - Capture the output showing missing steps

2. **Generate Step Definition Scaffolds**
   - Create TypeScript step definition files in `apps/ip-hub-backend-e2e/features/step-definitions/`
   - Use async/await pattern for all steps
   - Import required types from `@cucumber/cucumber` and axios
   - Follow project naming conventions (kebab-case for files)
   - Group related steps by domain/feature

3. **Save Scaffolding Output**
   - Save undefined steps to: `temp/step-definition-scaffolds.txt`
   - This file will be used in the next step to implement definitions

## Expected Output (Agent's Response Schema)

{
  "scaffoldFiles": [
    "apps/ip-hub-backend-e2e/features/step-definitions/<<YOUR-DOMAIN>>-steps.ts",
    "apps/ip-hub-backend-e2e/features/step-definitions/common-steps.ts"
  ],
  "undefinedStepsCount": 25,
  "status": "success",
  "summary": "Generated scaffolding for 25 undefined steps across 2 step definition files",
  "nextStep": "02-generate-step-definition-implementations-from-features-in-spec"
}

## Project-Specific Context

### Directory Structure
- **Feature Files**: `apps/ip-hub-backend-e2e/features/**/*.feature`
- **Step Definitions**: `apps/ip-hub-backend-e2e/features/step-definitions/*.ts`
- **Support Files**: `apps/ip-hub-backend-e2e/features/support/`
  - `world.ts` - Custom World class with HTTP client, test context
  - `hooks.ts` - Before/After hooks for test setup and cleanup
  - `types.ts` - TypeScript interfaces for domain models
  - `helpers.ts` - Utility functions for API testing
  - `factories/` - Test data factories for Testcontainers setup

### Technology Stack
- **BDD Framework**: @cucumber/cucumber 11.x
- **HTTP Client**: Axios for API requests
- **Database**: PostgreSQL via Testcontainers
- **Language**: TypeScript 5.x (strict mode)
- **Framework**: NestJS 11 with Nx monorepo
- **Assertion Library**: Jest expect

### Cucumber Configuration
Located in `apps/ip-hub-backend-e2e/cucumber.js`:
```javascript
module.exports = {
  default: {
    paths: ['apps/ip-hub-backend-e2e/features/**/*.feature'],
    require: ['apps/ip-hub-backend-e2e/features/**/*.ts'],
    requireModule: ['ts-node/register', 'tsconfig-paths/register'],
    format: ['progress-bar', 'json:reports/cucumber_report.json', 'html:reports/cucumber_report.html'],
    formatOptions: { snippetInterface: 'async-await' },
    parallel: 1,
  }
}
```

### Step Definition Template
```typescript
import { Given, When, Then } from '@cucumber/cucumber'
import type { IPHubWorld } from '../support/world'

Given('step text here', async function (this: IPHubWorld) {
  // Implementation here
})
```

### Naming Conventions
- Step definition files: `domain-steps.ts` (e.g., `dashboard-steps.ts`, `application-steps.ts`)
- Use TypeScript interfaces for type safety
- Follow async/await pattern for all steps
- Use descriptive step names that match business language

### Commands
```bash
# Generate scaffolding via dry run
npx nx e2e ip-hub-backend-e2e --dry-run

# Alternative: direct cucumber-js dry run
export NODE_OPTIONS="--import=tsx/esm"
npx cucumber-js apps/ip-hub-backend-e2e/features/**/*.feature --dry-run --format progress

# Run E2E tests
npx nx e2e ip-hub-backend-e2e

# View test results
open reports/cucumber_report.html
```

### Backend BDD Testing Approach

Unlike frontend BDD tests that use Playwright for browser automation, backend BDD tests:
- Use **Axios** HTTP client to make API calls to the BFFE endpoints
- Use **Testcontainers** for isolated PostgreSQL database
- Test business logic through the API layer (no UI)
- Verify CQRS commands execute correctly and emit expected events
- Validate API responses match BFFE spec contracts
- Check domain events are published for state changes

### Example Backend Step Definition
```typescript
import { Given, When, Then } from '@cucumber/cucumber'
import type { IPHubWorld } from '../support/world'

Given('Alice has submitted IP applications', async function (this: IPHubWorld) {
  // Use factory to seed database via Testcontainers
  const applications = await this.factories.application.createMany(3, {
    userId: this.currentUser.id,
    status: 'submitted'
  })
  this.context.applications = applications
})

When('Alice requests the dashboard summary', async function (this: IPHubWorld) {
  const response = await this.httpClient.get('/api/dashboard/summary', {
    headers: { Authorization: `Bearer ${this.authToken}` }
  })
  this.context.response = response
})

Then('Alice sees a total of {int} applications', async function (this: IPHubWorld, count: number) {
  expect(this.context.response.status).toBe(200)
  expect(this.context.response.data.totalAssets).toBe(count)
})
```
