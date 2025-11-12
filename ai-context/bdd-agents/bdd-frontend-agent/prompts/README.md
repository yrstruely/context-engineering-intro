# BDD Frontend Agent Prompts - Three-Phase Workflow

## Overview

This folder contains detailed prompt templates for implementing the **BDD-First Workflow** using a unified three-phase approach:

1. **Phase 1**: MSW Handler Creation
2. **Phase 2**: Step Definition Implementation
3. **Phase 3**: Pact Contract Generation

Each phase has specific prompts that guide the AI agent through the complete implementation process.

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BDD-First Workflow                                │
└─────────────────────────────────────────────────────────────────────┘

INPUT: Cucumber Feature File (.feature)
   │
   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 1: MSW Handler Creation                                       │
├─────────────────────────────────────────────────────────────────────┤
│ 01 → Analyze Scenarios for API Requirements                         │
│ 02 → Create MSW Handlers with Environment-Specific Data             │
└─────────────────────────────────────────────────────────────────────┘
   │
   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 2: Step Definition Implementation                             │
├─────────────────────────────────────────────────────────────────────┤
│ 03 → Generate Step Definition Scaffolding                           │
│ 04 → Implement Step Definitions (using MSW-mocked APIs)             │
│ 05 → Update Step Definitions Post-Review                            │
│ 06 → Verify Step Definitions Fail Appropriately (Red Phase)         │
└─────────────────────────────────────────────────────────────────────┘
   │
   ↓
┌─────────────────────────────────────────────────────────────────────┐
│ PHASE 3: Pact Contract Generation                                   │
├─────────────────────────────────────────────────────────────────────┤
│ 07 → Generate Pact Contracts from MSW                               │
│ 08 → Validate MSW-Pact Synchronization                              │
└─────────────────────────────────────────────────────────────────────┘
   │
   ↓
OUTPUT: Complete BDD Implementation + API Contracts for Backend
```

## Prompt Files

### Phase 1: MSW Handler Creation

**Purpose**: Create mock API responses from Cucumber scenarios

| File | Description | Input | Output |
|------|-------------|-------|--------|
| `phase1-01-template-analyze-scenarios-for-api-requirements.md` | Analyze Cucumber scenarios to extract API endpoint requirements and data needs | Feature file | API requirements analysis |
| `phase1-02-template-create-msw-handlers.md` | Create MSW handlers with environment-specific mock data | API analysis | MSW handler files |

**Key Outputs**:
- `temp/api-requirements-analysis.md` - Documented API requirements
- `test/msw/handlers/[domain].ts` - MSW handler files
- `test/msw/handlers/index.ts` - Handler registration

### Phase 2: Step Definition Implementation

**Purpose**: Implement executable Cucumber step definitions using MSW-mocked APIs

| File | Description | Input | Output |
|------|-------------|-------|--------|
| `phase2-03-template-run-cucumber-js-to-generate-step-definition-scaffolding.md` | Generate skeleton step definition files from feature files | Feature file | Scaffold files |
| `phase2-04-template-generate-step-definition-implementations-from-features-in-spec.md` | Implement complete step definitions using MSW mocks | Scaffolds + MSW handlers | Implemented steps |
| `phase2-05-template-update-step-definition-implementations-post-review.md` | Update step definitions after code review | Review feedback | Updated steps |
| `phase2-06-template-run-cucumber-js-to-verify-the-newly-implemented-step-definitions-fail.md` | Verify tests fail appropriately (Red phase of TDD) | Implemented steps | Test results |

**Key Outputs**:
- `features/step-definitions/*.ts` - Step definition files
- `features/support/types.ts` - TypeScript interfaces
- `features/support/world.ts` - World object updates

### Phase 3: Pact Contract Generation

**Purpose**: Generate and validate API contracts for backend implementation

| File | Description | Input | Output |
|------|-------------|-------|--------|
| `phase3-07-template-generate-pact-contracts.md` | Generate Pact contracts from MSW handlers | MSW handlers | Pact contract files |
| `phase3-08-template-validate-pact-sync.md` | Validate MSW-Pact synchronization | MSW + Pact | Validation report |

**Key Outputs**:
- `test/pact/pacts/*.json` - Pact contract files
- Validation report confirming sync
- Developer notification for contract publication

## Example Prompts

Each prompt file also has corresponding `*-example-*.md` files showing real implementations:

- `phase2-04-example-generate-step-definition-implementations-from-features-in-spec.md`
- `phase2-05-example-update-step-definition-implementations-post-review.md`
- `phase2-06-example-run-cucumber-js-to-verify-the-newly-implemented-step-definitions-fail.md`

## Usage

### For AI Agents

1. **Start at Phase 1** if implementing a new feature
2. **Use template files** (`*-template-*.md`) for instructions
3. **Reference example files** (`*-example-*.md`) for patterns
4. **Follow phases sequentially** - each phase depends on previous outputs

### For Developers

1. **Provide feature file** to AI agent
2. **Agent executes all three phases** automatically
3. **Review outputs** at each phase
4. **Publish contracts** after Phase 3 validation passes

## Phase Dependencies

```
Phase 1 → Phase 2 → Phase 3
  ↓         ↓          ↓
 MSW    Step Defs   Pact
Handlers              Contracts
  ↓         ↓          ↓
 Must     Uses MSW    Generated
 Exist    Mocks      from MSW
  First
```

**Critical Dependencies**:
- ✅ Phase 2 requires Phase 1 MSW handlers
- ✅ Phase 3 requires Phase 1 MSW handlers
- ✅ Can't skip phases - must execute sequentially

## Key Differences from Old Structure

### Before (Deprecated)

Separate workflows, unclear ordering:
```
01 → Generate scaffolding
02 → Implement steps (create server/api/ mocks)
03 → Update post-review
04 → Verify failures
```

**Problems**:
- No MSW handler creation guidance
- Created redundant server/api/ mocks
- No Pact contract generation
- No clear phases

### After (Current)

Unified three-phase workflow:
```
PHASE 1 → Create MSW Handlers
PHASE 2 → Implement Step Definitions (using MSW)
PHASE 3 → Generate Pact Contracts
```

**Benefits**:
- ✅ Clear phase structure
- ✅ MSW as single source of mock data
- ✅ No redundant server/api/ mocks
- ✅ Automated Pact contract generation
- ✅ Complete BDD-First workflow

## Important Conventions

### File Naming

**Templates**: `phase[N]-[step]-template-[description].md`
- Example: `phase1-01-template-analyze-scenarios-for-api-requirements.md`

**Examples**: `[step]-example-[description].md`
- Example: `phase2-04-example-generate-step-definition-implementations-from-features-in-spec.md`

### Phase Numbering

- **Phase 1**: Steps 01-02 (MSW Handler Creation)
- **Phase 2**: Steps 03-06 (Step Definition Implementation)
- **Phase 3**: Steps 07-08 (Pact Contract Generation)

Note: Phase 2 reuses existing prompts 01-04 (now references 03-06 in context)

## Package.json Scripts Reference

### Phase 1: MSW Handler Creation
```bash
# No specific scripts - manual file creation
# Handlers created in: test/msw/handlers/
```

### Phase 2: Step Definition Implementation
```bash
npm run test:e2e:dry    # Generate scaffolding
npm run test:e2e        # Run Cucumber tests
npm run test:e2e:results # View test report
```

### Phase 3: Pact Contract Generation
```bash
npm run pact:generate   # Generate Pact from MSW
npm run pact:validate   # Validate MSW-Pact sync
npm run pact:workflow   # Generate + validate (recommended)
npm run pact:publish    # Publish to Pact Broker (manual)
```

## Quick Start Example

**Scenario**: Implement dashboard overview feature

1. **Phase 1**: Create MSW handlers
   ```bash
   # AI Agent uses: phase1-01-template & phase1-02-template
   # Output: test/msw/handlers/dashboard.ts
   ```

2. **Phase 2**: Implement step definitions
   ```bash
   # AI Agent uses: 01-template (scaffolding), 02-template (implementation)
   # Output: features/step-definitions/dashboard-steps.ts
   npm run test:e2e  # Tests fail (no frontend code yet) - expected!
   ```

3. **Phase 3**: Generate Pact contracts
   ```bash
   # AI Agent uses: phase3-07-template, phase3-08-template
   npm run pact:workflow
   # Output: test/pact/pacts/frontend-backend-consumer.json
   ```

4. **Developer publishes contracts**
   ```bash
   npm version minor  # Increment version
   npm run pact:publish  # Publish to broker
   ```

## Troubleshooting

### Phase 1 Issues

**Issue**: Don't know which API endpoints are needed
**Solution**: Use `phase1-01-template` to analyze scenarios systematically

**Issue**: Not sure what data to include
**Solution**: Extract exact values from Cucumber Given steps for `dev.local` environment

### Phase 2 Issues

**Issue**: Step definitions creating server/api/ mocks
**Solution**: Reference updated `02-template` - MSW handles all mocking, no server/api/ needed

**Issue**: Tests not finding MSW mocks
**Solution**: Verify MSW handlers registered in `test/msw/handlers/index.ts`

### Phase 3 Issues

**Issue**: Pact validation failing
**Solution**: Check MSW response structure matches expected format (`{ success: boolean, data: T }`)

**Issue**: Missing endpoints in Pact contract
**Solution**: Ensure all MSW handlers are exported and registered

## Best Practices

1. **Always start at Phase 1** for new features
2. **Use environment-specific data** in MSW handlers
3. **Never create server/api/ mocks** - MSW handles all mocking
4. **Always run pact:validate** before publishing contracts
5. **Include all three phases** in feature implementation
6. **Follow sequential order** - don't skip phases

## Migration Notes

If you have old prompts or workflows:

- ✅ Use new three-phase structure for all new work
- ✅ MSW handlers replace server/api/ mocks
- ✅ Pact contracts are auto-generated, not manual
- ❌ Don't use old separate MSW workflow context
- ❌ Don't create server/api/ endpoints anymore

---

**Version**: 2.0 (Unified Three-Phase Workflow)
**Last Updated**: 2025-01-13
**Status**: Active
