# Developer Onboarding: Workflow Context Files

This guide explains how to use the workflow context files in `workflow-context/` to implement new features using our BDD-First development methodology with AI agents (Claude Code).

## Overview

The workflow context system provides structured prompts and context documents that guide AI agents through our development workflow. These files ensure consistent, high-quality implementations following BDD (Behaviour-Driven Development), TDD (Test-Driven Development), and contract testing best practices.

```
workflow-context/
├── context_engineering_guide.md          # Meta-guide on creating AI context
├── cucumber-context-doc.md               # Cucumber/Gherkin reference
├── bdd-agents/                           # BDD-related AI agents (Test Automation Specialist)
│   ├── bdd-feature-agent/                # Generate feature files from requirements
│   ├── bdd-frontend-agent/               # Frontend BDD test implementation
│   └── bdd-backend-agent/                # Backend BDD test implementation
├── frontend-agents/                      # Frontend-specific agents (Frontend Developer)
│   ├── tdd-green-implement-frontend-to-pass-tests/
│   └── unit-integration-test-agent/
├── backend-agents/                       # Backend-specific agents (Backend Developer)
└── ai-context-design/                    # Workflow design documents
    └── fe-bdd-first-to-pact/            # BDD-First workflow documentation
```

---

## Agent Ownership by Role

The workflow context agents are designed to be used by specific team roles:

| Agent Directory    | Primary User                   | Responsibility                                                                                     |
| ------------------ | ------------------------------ | -------------------------------------------------------------------------------------------------- |
| `bdd-agents/`      | **Test Automation Specialist** | Creates feature files from requirements, implements BDD step definitions, generates Pact contracts |
| `frontend-agents/` | **Frontend Developer**         | Generates unit/integration tests, implements Vue/Nuxt components to pass tests                     |
| `backend-agents/`  | **Backend Developer**          | Implements API endpoints to satisfy Pact contracts, creates backend BDD tests                      |

### Role Workflow

```
Test Automation Specialist          Frontend Developer              Backend Developer
        │                                   │                              │
        ▼                                   │                              │
┌─────────────────┐                         │                              │
│ BDD Feature     │                         │                              │
│ Agent           │                         │                              │
│ (feature files) │                         │                              │
└────────┬────────┘                         │                              │
         │                                  │                              │
         ▼                                  │                              │
┌─────────────────┐                         │                              │
│ BDD Frontend    │                         │                              │
│ Agent Phase 1-2 │                         │                              │
│ (MSW + steps)   │                         │                              │
└────────┬────────┘                         │                              │
         │                                  │                              │
         │ ─────────handoff──────────────► │                              │
         │                                  ▼                              │
         │                         ┌─────────────────┐                     │
         │                         │ Unit/Integration│                     │
         │                         │ Test Agent      │                     │
         │                         │ (Vitest tests)  │                     │
         │                         └────────┬────────┘                     │
         │                                  │                              │
         │                                  ▼                              │
         │                         ┌─────────────────┐                     │
         │                         │ TDD Green Agent │                     │
         │                         │ (Vue/Nuxt impl) │                     │
         │                         └────────┬────────┘                     │
         │                                  │                              │
         │ ◄────────handoff────────────────┘                              │
         ▼                                                                 │
┌─────────────────┐                                                        │
│ BDD Frontend    │                                                        │
│ Agent Phase 3   │                                                        │
│ (Pact contracts)│                                                        │
└────────┬────────┘                                                        │
         │                                                                 │
         │ ─────────handoff─────────────────────────────────────────────► │
         │                                                                 ▼
         │                                                        ┌─────────────────┐
         │                                                        │ Backend Agents  │
         │                                                        │ (API impl)      │
         │                                                        └─────────────────┘
```

---

## The BDD-First Development Workflow

Our development process follows a **BDD-First** approach where requirements drive everything:

```
┌─────────────────────────────────────────────────────────────────┐
│                     BDD-First Workflow                          │
└─────────────────────────────────────────────────────────────────┘

1. Requirements & Figma Designs
        ↓
2. Feature Files (Gherkin scenarios)        ← BDD Feature Agent
        ↓
3. MSW Handlers (mock API responses)        ← BDD Frontend Agent Phase 1
        ↓
4. Step Definitions (executable tests)      ← BDD Frontend Agent Phase 2
        ↓
5. Unit/Integration Tests                   ← Unit/Integration Test Agent
        ↓
6. Frontend Implementation                  ← TDD Green Agent
        ↓
7. Pact Contracts (API contracts)          ← BDD Frontend Agent Phase 3
        ↓
8. Backend Implementation                   ← Backend Agents
```

---

## Quick Start: Implementing a New Feature

### Step 1: Generate Feature Files (BDD Feature Agent)

**When to use:** Starting a new feature from requirements/Figma designs

**Context file:** `workflow-context/bdd-agents/bdd-feature-agent/bdd-agent-context.md`

**What it does:**

- Analyzes requirements documents and Figma designs
- Generates Gherkin feature files with scenarios
- Identifies gaps in requirements
- Creates domain glossary

**How to use with Claude Code:**

```
"Use the BDD Feature Agent context to generate feature files for the
onboarding feature. Input: [paste requirements or reference Figma]"
```

**Prompt templates:**

- `prompts/01-template-generate-features-from-figma.md` - Generate from designs
- `prompts/02-template-update-features-post-review.md` - Update after review
- `prompts/03-template-generate-non-functional-requirements.md` - NFRs

**Output location:** `specs/[feature-folder]/[phase].feature`

---

### Step 2: Implement BDD Tests (BDD Frontend Agent)

**When to use:** After feature files are approved

**Context file:** `workflow-context/bdd-agents/bdd-frontend-agent/bdd-test-agent-context.md`

This agent handles a **three-phase workflow**:

#### Phase 1: Create MSW Handlers

**Purpose:** Create mock API responses based on Cucumber scenarios

**Prompt templates:**

- `prompts/phase1-01-template-analyze-scenarios-for-api-requirements.md`
- `prompts/phase1-02-template-create-msw-handlers.md`

**What it creates:**

- `test/msw/handlers/[domain].ts` - MSW handler files
- Environment-specific mock data (`dev.local`, `test`, `ci`)

**Example prompt:**

```
"Analyze the feature file at specs/01-onboarding/phase1-account-setup.feature
and create MSW handlers for the required API endpoints."
```

#### Phase 2: Implement Step Definitions

**Purpose:** Create executable Cucumber step definitions

**Prompt templates:**

- `prompts/phase2-03-template-run-cucumber-js-to-generate-step-definition-scaffolding.md`
- `prompts/phase2-04-template-generate-step-definition-implementations-from-features-in-spec.md`
- `prompts/phase2-05-template-update-step-definition-implementations-post-review.md`
- `prompts/phase2-06-template-run-cucumber-js-to-verify-the-newly-implemented-step-definitions-fail.md`

**What it creates:**

- `features/step-definitions/[domain]-steps.ts` - Step definition files
- Support files (world.ts, hooks.ts, helpers)

**Example prompt:**

```
"Generate step definition scaffolding for specs/01-onboarding/phase1-account-setup.feature
then implement the step definitions using MSW mocks."
```

#### Phase 3: Generate Pact Contracts

**Purpose:** Generate API contracts for backend team

**Prompt templates:**

- `prompts/phase3-07-template-generate-pact-contracts.md`
- `prompts/phase3-08-template-validate-pact-sync.md`

**Commands:**

```bash
npm run pact:generate    # Generate contracts from MSW
npm run pact:validate    # Validate MSW-Pact sync
npm run pact:workflow    # Generate + validate (recommended)
npm run pact:publish     # Publish to Pact Broker
```

---

### Step 3: Generate Unit/Integration Tests

**When to use:** After BDD tests are implemented, before frontend implementation

**Context file:** `workflow-context/frontend-agents/unit-integration-test-agent/unit-integration-test-agent-context.md`

**What it does:**

- Generates Vitest unit tests from BDD step definitions
- Creates integration tests for pages/routes
- Sets up test fixtures and mocks

**Prompt template:** `prompts/01-template-generate-unit-integration-tests-from-bdd-steps.md`

**Output location:**

- `test/unit/[ComponentName].test.ts`
- `test/integration/[page-name].test.ts`

**Example Claude Code prompt:**

```
Implement @workflow-context/frontend-agents/unit-integration-test-agent/prompts/01-template-generate-unit-integration-tests-from-bdd-steps.md

Use the following input:
{
  "featureFile": "specs/01-onboarding/phase1-account-setup-authentication.feature",
  "targetScope": "unit-integration",
  "sourceContext": [
    "app/components/auth/GoogleAuthButton.vue",
    "app/pages/register.vue"
  ],
  "task": "01-generate-unit-and-integration-tests-from-bdd-step-definitions",
  "testFramework": "vitest",
  "testEnvironment": "happy-dom",
  "bddFramework": "cucumber",
  "devToolsEnabled": true,
  "projectType": "nuxt4 "
}
```

This prompt will generate:

- `test/unit/GoogleAuthButton.test.ts` - Component unit tests
- `test/integration/register.test.ts` - Page integration tests

---

### Step 4: Implement Frontend (TDD Green Agent)

**When to use:** After unit/integration tests are written (Red phase complete)

**Context file:** `workflow-context/frontend-agents/tdd-green-implement-frontend-to-pass-tests/01-template-implement-frontend-to-pass-tests.md`

**What it does:**

- Analyzes failing tests
- Implements minimal code to make tests pass
- Follows Vue 3/Nuxt 4 patterns
- Ensures accessibility compliance

**How to use:**

```json
{
  "testImplementationRequest": {
    "unitTests": [
      {
        "file": "test/unit/OnboardingForm.test.ts",
        "currentStatus": "failing",
        "failureReason": "Component not found"
      }
    ],
    "integrationTests": [
      {
        "file": "test/integration/onboarding.test.ts",
        "currentStatus": "failing"
      }
    ],
    "bddTests": [
      {
        "file": "features/01-onboarding/phase1.feature",
        "currentStatus": "not_run"
      }
    ],
    "targetComponents": [
      "app/components/OnboardingForm.vue",
      "app/pages/onboarding.vue"
    ]
  }
}
```

---

## Backend Implementation (Backend Agents)

The backend agents are used by **Backend Developers** to implement NestJS API endpoints that satisfy the Pact contracts generated by the frontend team.

**Context file:** `workflow-context/backend-agents/backend-test-agent-context.md`

The backend workflow follows a **three-step TDD process**:

### Step 5: Generate Backend Unit/Integration Tests (Red Phase)

**When to use:** After receiving Pact contracts from frontend team

**Prompt template:** `prompts/01-template-backend-unit-and-integration-test-agent.md`

**What it does:**

- Analyzes BDD scenarios to identify required backend components
- Generates Jest unit tests for command/query handlers
- Generates integration tests with Testcontainers
- Creates test factories following DDD patterns

**Example Claude Code prompt:**

```
Implement @workflow-context/backend-agents/prompts/01-template-backend-unit-and-integration-test-agent.md

Use the following input:
{
  "featureFile": "apps/ip-hub-backend-e2e/features/dashboard/get-dashboard-summary.feature",
  "scenarioName": "User views dashboard summary with portfolio counts",
  "failingE2EOutput": "[paste failing E2E test output here]",
  "task": "01-generate-unit-and-integration-tests",
  "targetDomain": "dashboard",
  "existingGreenFeatures": ["user-authentication"],
  "testPriority": "unit-first"
}
```

**Output locations:**

- `apps/ip-hub-backend/src/app/{domain}/queries/{query}.handler.spec.ts` - Unit tests
- `apps/ip-hub-backend/test/integration/{feature}.integration.spec.ts` - Integration tests
- `apps/ip-hub-backend/test/shared/factories/{entity}.factory.ts` - Test factories

---

### Step 6: Implement Backend to Pass Tests (Green Phase)

**When to use:** After backend tests are generated and failing

**Prompt template:** `prompts/02-template-backend-tdd-green-implement-tests.md`

**What it does:**

- Implements NestJS handlers following CQRS pattern
- Creates domain entities, value objects, and repository interfaces
- Implements TypeORM entities and mappers
- Registers modules and controllers

**Example Claude Code prompt:**

```
Implement @workflow-context/backend-agents/prompts/02-template-backend-tdd-green-implement-tests.md

Use the following input:
{
  "featureFile": "apps/ip-hub-backend-e2e/features/dashboard/get-dashboard-summary.feature",
  "scenarioName": "User views dashboard summary with portfolio counts",
  "failingUnitTests": [
    "apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.handler.spec.ts"
  ],
  "failingIntegrationTests": [
    "apps/ip-hub-backend/test/integration/dashboard-api.integration.spec.ts"
  ],
  "task": "02-implement-backend-to-pass-tests",
  "targetDomain": "dashboard",
  "implementationOrder": ["from step 01 output"]
}
```

**Key DDD Architecture Requirements:**

The backend follows a full Domain-Driven Design pattern:

```
libs/domain/src/                    # Pure domain layer (no framework deps)
├── entities/                       # Domain entities with business logic
├── value-objects/                  # Type/status value objects
├── repositories/                   # Interface + Symbol DI token
└── events/                         # Domain events

app/{domain}/                       # Application & infrastructure
├── commands/                       # Write operations (handlers)
├── queries/                        # Read operations (handlers)
└── infrastructure/                 # ORM entities, mappers, repos

bffe/controllers/                   # API layer
└── {feature}.controller.ts         # HTTP endpoints
```

---

### Step 7: Validate Backend Green Status

**When to use:** After backend implementation to confirm all tests pass

**Prompt template:** `prompts/03-template-backend-validate-tdd-and-bdd-green-status.md`

**What it does:**

- Runs all unit tests and verifies they pass
- Runs integration tests with real database
- Runs BDD E2E tests to confirm scenarios pass
- Checks for regressions in existing features
- Validates DDD architecture compliance

**Example Claude Code prompt:**

```
Implement @workflow-context/backend-agents/prompts/03-template-backend-validate-tdd-and-bdd-green-status.md

Use the following input:
{
  "featureFile": "apps/ip-hub-backend-e2e/features/dashboard/get-dashboard-summary.feature",
  "scenarioName": "User views dashboard summary with portfolio counts",
  "implementedFromStep02": {
    "unitTests": ["get-dashboard-summary.handler.spec.ts"],
    "integrationTests": ["dashboard-api.integration.spec.ts"],
    "implementedFiles": ["get-dashboard-summary.handler.ts", "dashboard.module.ts"]
  },
  "task": "03-validate-tdd-and-bdd-green-status",
  "targetDomain": "dashboard",
  "existingGreenFeatures": ["user-authentication"]
}
```

**Backend Test Commands:**

```bash
# Unit tests
npx nx test ip-hub-backend --testPathPattern="dashboard"

# Integration tests (with Testcontainers)
npx nx test:integration ip-hub-backend --testPathPattern="dashboard"

# BDD E2E tests
npx nx test:e2e ip-hub-backend -- --name "User views dashboard summary"
npx nx test:e2e ip-hub-backend -- --tags "@dashboard"
```

---

## Key Concepts

### MSW (Mock Service Worker)

MSW provides in-process API mocking during development and testing:

- **Local dev:** MSW intercepts requests, returns mock data
- **Test environments:** Same MSW handlers used in BDD tests
- **Production:** Real APIs (MSW disabled)

**Environment control via `MSW_ENV`:**

- `dev.local` - Rich data for UI development
- `test` - Minimal data for test assertions
- `ci` - Deterministic data for CI/CD

### Pact Contract Testing

Pact contracts define API requirements between frontend and backend:

- **Generated from MSW** - No manual contract writing
- **Consumer-driven** - Frontend defines what it needs
- **Backend verification** - Backend implements to match contracts

### Context Engineering

Each agent context follows a five-layer structure:

1. **System Context** - AI role and capabilities
2. **Domain Context** - Technical knowledge (Vue, Nuxt, etc.)
3. **Task Context** - Specific objectives and success criteria
4. **Interaction Context** - Communication style and examples
5. **Response Context** - Output format and structure

---

## Command Reference

### BDD E2E Tests

```bash
npm run test:e2e              # Run all Cucumber tests
npm run test:e2e:dry          # Generate step scaffolding (dry run)
npm run test:e2e:results      # View test report
npm run test:e2e:wip          # Run work-in-progress tests only
```

### Unit/Integration Tests

```bash
npm run test                  # Run all Vitest tests
npm run test:unit             # Run unit tests only
npm run test:integration      # Run integration tests only
npm run test:coverage         # Run with coverage report
```

### Pact Contracts

```bash
npm run pact:generate         # Generate Pact from MSW handlers
npm run pact:validate         # Validate MSW-Pact sync
npm run pact:workflow         # Generate + validate
npm run pact:publish          # Publish to Pact Broker
```

---

## Workflow Examples

### Example 1: New Feature from Figma

```
Day 1: Requirements
├── Review Figma designs
├── Use BDD Feature Agent to generate feature files
└── Review and refine scenarios with team (Three Amigos)

Day 2-3: Test Implementation
├── Phase 1: Create MSW handlers from scenarios
├── Phase 2: Implement step definitions
├── Run: npm run test:e2e (tests fail - no frontend yet)
└── Generate unit/integration tests

Day 4-5: Frontend Implementation
├── Use TDD Green Agent to implement components
├── Iterate until all tests pass
└── Phase 3: Generate Pact contracts

Day 6: Backend Handoff
├── Review Pact contracts
├── npm run pact:publish
└── Notify backend team
```

### Example 2: Updating Existing Feature

```
1. Update feature file with new scenarios
2. Run: npm run test:e2e:dry (generates new step scaffolding)
3. Update MSW handlers if new API endpoints needed
4. Implement new step definitions
5. Update unit tests
6. Implement frontend changes (TDD Green)
7. Regenerate Pact contracts: npm run pact:workflow
```

---

## File Naming Conventions

### Feature Files

```
specs/[feature-number]-[feature-name]/phase[N]-[description].feature
Example: specs/01-onboarding/phase1-account-setup-authentication.feature
```

### Step Definitions

```
features/step-definitions/[domain]-steps.ts
Example: features/step-definitions/onboarding-steps.ts
```

### MSW Handlers

```
test/msw/handlers/[domain].ts
Example: test/msw/handlers/auth.ts
```

### Tests

```
test/unit/[ComponentName].test.ts
test/integration/[page-name].test.ts
```

---

## Prompt Template Structure

Each agent has two types of files:

- **`*-template-*.md`** - Instructions for the AI agent
- **`*-example-*.md`** - Real implementation examples

**Using templates:**

1. Read the template to understand the expected input/output
2. Review the example to see a real implementation
3. Provide your specific inputs (feature file, requirements, etc.)
4. Let the AI agent follow the template structure

---

## Troubleshooting

### Tests Fail with "Component not found"

- Ensure component file exists at expected path
- Check import paths match test expectations
- Verify `data-testid` attributes are correct

### MSW Not Intercepting Requests

- Check MSW server is started in test setup
- Verify handler is registered in `test/msw/handlers/index.ts`
- Ensure request URL matches handler pattern

### Pact Validation Fails

- MSW response structure must match Pact contract
- Use standard response format: `{ success: boolean, data: T }`
- Regenerate Pact: `npm run pact:workflow`

### BDD Steps Not Found

- Run `npm run test:e2e:dry` to generate scaffolding
- Check step definition file is in correct directory
- Verify step text matches feature file exactly

---

## Best Practices

### Do's

- Start with feature files (requirements first)
- Use MSW for all API mocking (single source of truth)
- Run tests frequently during implementation
- Keep scenarios declarative (behavior, not implementation)
- Follow existing patterns in the codebase

### Don'ts

- Skip phases in the workflow
- Manually write Pact contracts (auto-generate from MSW)
- Modify tests to make them pass
- Add features not covered by tests
- Create `server/api/` mock endpoints (use MSW instead)

---

## Getting Help

- **Cucumber/Gherkin:** `workflow-context/bdd-agents/cucumber-context-doc.md`
- **Context Engineering:** `workflow-context/context_engineering_guide.md`
- **BDD-First Workflow:** `workflow-context/ai-context-design/fe-bdd-first-to-pact/BDD_FIRST_WORKFLOW.md`
- **MSW-Pact Sync:** `workflow-context/ai-context-design/fe-bdd-first-to-pact/MSW_PACT_SYNC_GUIDE.md`

---

## Summary

The workflow context files provide a structured approach to AI-assisted development:

### Test Automation Specialist (BDD Agents)

1. **BDD Feature Agent** → Generate requirements as executable scenarios
2. **BDD Frontend Agent** → Create MSW handlers, step definitions, Pact contracts

### Frontend Developer (Frontend Agents)

3. **Unit/Integration Test Agent** → Generate component/page tests
4. **TDD Green Agent** → Implement frontend code to pass tests

### Backend Developer (Backend Agents)

5. **Backend Unit/Integration Test Agent** → Generate NestJS unit and integration tests
6. **Backend TDD Green Agent** → Implement handlers, entities, and controllers
7. **Backend Validation Agent** → Verify all tests pass and validate DDD architecture

This ensures:

- Requirements drive development (not the other way around)
- Frontend isn't blocked by backend
- Clear API contracts between teams
- Comprehensive test coverage
- Consistent, high-quality implementations
- Full DDD compliance in backend code
