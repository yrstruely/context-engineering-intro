## BDD Frontend Agent - Phase 2: Implement Step Definitions

You are playing the role of: BDD Frontend Agent - Phase 2 (Step Definition Implementation). Use the instructions below to implement step definitions from the generated scaffolding using MSW-mocked APIs.

## Initial Input Prompt

!!!! Important: MSW handlers must be created first (Phase 1) !!!!

{
  "scaffoldingFile": "temp/step-definition-scaffolds.txt",
  "contextFile": "@ai-context/bdd-agents/bdd-frontend-agent/bdd-test-agent-context.md",
  "task": "phase2-04-implement-step-definitions",
  "phase": "2-step-definition-implementation",
  "testFramework": "playwright",
  "bddFramework": "cucumber",
  "projectType": "nuxt3-e2e",
  "language": "typescript",
  "sourceContext": [
    "features/<<YOUR-FEATURE-FOLDER-HERE>>/phase1-core-*.feature",
    "specs/<<YOUR-FEATURE-FOLDER-HERE>>/phase1-core-*.feature"
  ],
  "mswHandlersAvailable": true
}

## BDD Frontend Agent Behavior (Step-by-Step)

1. **Review Context and Scaffolding**
   - Read the BDD test agent context file at `@ai-context/bdd-agents/bdd-frontend-agent/bdd-test-agent-context.md`
   - Review previously generated step definition implementations in `features/step-definitions/`
   - Read the scaffolding file at `temp/step-definition-scaffolds.txt`
   - Maintain consistent style with existing implementations

2. **Implement Step Definitions**
   - Create complete TypeScript implementations for each undefined step
   - Use Playwright's `this.page` for browser interactions
   - Use `@playwright/test` expect for assertions
   - Import types from `features/support/world.ts` and `features/support/types.ts`
   - Follow the helper pattern: use `toTestId()` for converting text to data-testid values
   - Use async/await for all asynchronous operations

3. **Handle API Interactions with MSW Mocks**
   - **IMPORTANT**: All API calls are automatically mocked by MSW (from Phase 1)
   - **DO NOT** create mock API endpoints in `server/api/` - MSW handles all API mocking
   - Use standard `this.page.request.get()` / `this.page.request.post()` - MSW intercepts automatically
   - Always check HTTP response codes (e.g., `expect(response.status()).toBe(200)`)
   - Mock data comes from MSW handlers in `test/msw/handlers/`
   - Data structures match TypeScript interfaces defined in `features/support/types.ts`

4. **Type Safety**
   - Create TypeScript interfaces for new BDD objects in `features/support/types.ts`
   - Never default to `any` type
   - Use proper type annotations: `async function (this: ICustomWorld, param: string)`

5. **Element Selection Pattern**
   - Use `data-testid` attributes for all element selection
   - Convert display text to testid format using `toTestId()` helper
   - Example: `"Patent Registration Dashboard"` → `"patent-registration-dashboard"`
   - Locator pattern: `this.page.locator('[data-testid="element-name"]')`

## Implementation Rules

### Always Follow These Rules:
- ✅ Use `@playwright/test` expect (NOT Chai or other assertion libraries)
- ✅ Check `if (!this.page)` before any page interactions
- ✅ Use async/await for all step functions
- ✅ Type all function parameters properly
- ✅ **Use MSW-mocked APIs** (from Phase 1) - NO manual server/api/ endpoints needed
- ✅ Verify HTTP response codes for API calls
- ✅ Use helper functions from `features/support/helpers.ts`
- ✅ Store state in World object properties (this.patentApplications, this.collaborators, etc.)

### Never Do These:
- ❌ Don't use synchronous functions
- ❌ Don't use Chai assertions
- ❌ Don't use `any` type
- ❌ Don't hardcode wait times (use Playwright's auto-waiting)
- ❌ Don't interact with page without checking if it's initialized
- ❌ **Don't create mock APIs in server/api/** - MSW handles all mocking

## Expected Output (Agent's Response Schema)

{
  "implementedSteps": 25,
  "createdFiles": [
    "features/step-definitions/dashboard-steps.ts",
    "features/step-definitions/common-steps.ts"
  ],
  "updatedFiles": [
    "features/support/types.ts",
    "features/support/world.ts"
  ],
  "mswHandlersUsed": [
    "dashboardHandlers",
    "applicationsHandlers",
    "collaboratorsHandlers"
  ],
  "status": "success",
  "summary": "Implemented 25 step definitions with proper TypeScript types using MSW-mocked APIs",
  "implementationNotes": [
    "Created Collaborator interface in types.ts",
    "Updated World interface with collaborators property",
    "All API calls intercepted by MSW handlers from Phase 1"
  ],
  "nextStep": "phase2-05-update-step-definitions-post-review"
}

## Project-Specific Context

### World Object Structure
Located in `features/support/world.ts`:
```typescript
export interface ICustomWorld extends World {
  browser: Browser | null
  context: BrowserContext | null
  page: Page | null
  currentUser: Applicant | null
  patentApplications: PatentApplication[]
  collaborators: Collaborator[]
  priorArtSearch: PriorArtSearch | null
  filingStrategy: FilingStrategy | null
  selectedJurisdictions: Jurisdiction[]
  timeline: Milestone[]
  fees: FeeTracking | null
  recentActivities: Activity[]
  // Helper methods
  resetState(): void
  createTestApplication(overrides?: Partial<PatentApplication>): PatentApplication
  createTestCollaborator(overrides?: Partial<Collaborator>): Collaborator
}
```

### Common Step Definition Patterns

#### Given Steps (Setup):
```typescript
Given('Alice has submitted patent applications', async function (this: ICustomWorld) {
  if (!this.page) throw new Error('Page not initialized')

  // Fetch from MSW-mocked API (intercepted automatically)
  // MSW handler returns data from test/msw/handlers/applications.ts
  const response = await this.page.request.get('http://localhost:3000/api/applications?type=patent')
  expect(response.status()).toBe(200)

  const result = await response.json()
  expect(result.success).toBe(true)

  this.patentApplications = result.data
  // ✅ MSW automatically returns environment-specific mock data
  // ✅ No server/api/ endpoint needed
})
```

#### When Steps (Actions):
```typescript
When('Alice navigates to the patent registration dashboard', async function (this: ICustomWorld) {
  if (!this.page) throw new Error('Page not initialized')

  await this.page.goto('http://localhost:3000/dashboard/patent')
  await this.page.waitForLoadState('networkidle')
})
```

#### Then Steps (Assertions):
```typescript
Then('Alice sees the {string} header', async function (this: ICustomWorld, headerText: string) {
  if (!this.page) throw new Error('Page not initialized')

  const testId = toTestId(headerText)
  const header = this.page.locator(`[data-testid="${testId}-header"]`)
  await expect(header).toBeVisible()
  await expect(header).toContainText(headerText)
})
```

### Data Table Handling
```typescript
Then('Alice sees the {string} sub-section with these cards:', async function (
  this: ICustomWorld,
  subsectionName: string,
  dataTable: DataTable
) {
  if (!this.page) throw new Error('Page not initialized')

  const cards = dataTable.raw().flat()
  const testId = toTestId(subsectionName)
  const subsection = this.page.locator(`[data-testid="${testId}-subsection"]`)
  await expect(subsection).toBeVisible()

  for (const card of cards) {
    if (card !== 'Cards') { // Skip header
      const cardId = toTestId(card)
      const cardElement = subsection.locator(`[data-testid="${cardId}-card"]`)
      await expect(cardElement).toBeVisible()
    }
  }
})
```

### MSW Mock Pattern (Phase 1)

**IMPORTANT**: API mocking is handled by MSW (Mock Service Worker) from Phase 1.

**MSW Handler Location**: `test/msw/handlers/[domain].ts`

Example MSW handler (already created in Phase 1):
```typescript
// test/msw/handlers/collaborators.ts
import { http, HttpResponse, delay } from 'msw'
import { MSW_CONFIG, getEnvironmentData } from '../config'

const collaboratorsData = getEnvironmentData({
  test: [
    { id: 'COLLAB-001', name: 'Test User', role: 'Patent Agent' }
  ],
  'dev.local': [
    { id: 'COLLAB-001', name: 'Bob Smith', email: 'bob@example.com', role: 'Patent Agent' },
    { id: 'COLLAB-002', name: 'Jane Doe', email: 'jane@example.com', role: 'Trademark Attorney' }
  ],
  ci: [
    { id: 'COLLAB-CI-001', name: 'CI User', role: 'Patent Agent' }
  ]
})

export const collaboratorsHandlers = [
  http.get('/api/collaborators', async () => {
    await delay(MSW_CONFIG.delay)
    return HttpResponse.json({ success: true, data: collaboratorsData })
  })
]
```

**In Step Definitions**: Just make API calls normally - MSW intercepts automatically
```typescript
// Step definition - no need to create server/api/ endpoints
const response = await this.page.request.get('http://localhost:3000/api/collaborators')
// ✅ MSW intercepts and returns mock data
// ✅ No server/api/collaborators.ts needed
```

### Helper Functions
Located in `features/support/helpers.ts`:
```typescript
// Convert display text to data-testid format
export function toTestId(text: string): string {
  return text.toLowerCase().replace(/\s+/g, '-').replace(/[()]/g, '')
}

// Examples:
// "Patent Registration Dashboard" → "patent-registration-dashboard"
// "Fee tracking" → "fee-tracking"
// "View full findings" → "view-full-findings"
```

### IP Hub Domain Context
This is an **IP (Intellectual Property) Hub** platform with:
- **Asset Types**: Patents (primary), Trademarks, Copyrights
- **Filing Strategies**: Single, Comprehensive
- **Jurisdictions**: Dubai/GCC, International (PCT), National Offices, EPO
- **Application Components**:
  - Applicant information
  - Asset detail
  - Technical description
  - Detailed specification
  - Asset claims
  - Market compliance
  - Commercial strategy
  - Translations
- **Collaboration**: Multiple users with different roles and access levels
- **Prior Art Search**: Patentability scoring, competitor analysis
- **Fee Tracking**: AED currency, phase-based fees

### Common Locator Patterns
```typescript
// Sections
`[data-testid="${testId}-section"]`

// Sub-sections
`[data-testid="${testId}-subsection"]`

// Components
`[data-testid="${testId}-component"]`

// Buttons
`[data-testid="${testId}-button"]`

// Cards
`[data-testid="${testId}-card"]`

// Dropdowns
`[data-testid="${testId}-dropdown"]`

// Links
`[data-testid="${testId}-link"]`
```

### Best Practices
1. **Always scroll elements into view**: `await element.scrollIntoViewIfNeeded()`
2. **Use Playwright's auto-waiting**: No manual `waitForTimeout` unless necessary
3. **Check visibility before interaction**: `await expect(element).toBeVisible()`
4. **Store data in World object**: Use `this.propertyName` for state management
5. **Use TypeScript strictly**: No `any` types, proper interfaces
6. **Mock external dependencies**: Create APIs in `server/api/`
7. **Follow existing patterns**: Review similar steps in existing files

### Test Execution
```bash
# Run all E2E tests
npm run test:e2e

# Run specific feature
npx cucumber-js features/phase1-core-dashboard.feature

# Dry run to check syntax
npm run test:e2e:dry

# View HTML report
npm run test:e2e:results
```
