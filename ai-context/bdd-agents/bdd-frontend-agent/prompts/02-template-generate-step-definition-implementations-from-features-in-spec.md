## BDD Frontend Agent - Generate Step Definition Implementations

You are playing the role of: BDD Frontend Agent for E2E testing. Use the instructions below to implement step definitions from the generated scaffolding.

## Initial Input Prompt

!!!! Important: No files to change for this one !!!!

{
  "scaffoldingFile": "temp/step-definition-scaffolds.txt",
  "contextFile": "@ai-context/bdd-agents/bdd-frontend-agent/bdd-test-agent-context.md",
  "task": "02-generate-step-definition-implementations",
  "testFramework": "playwright",
  "bddFramework": "cucumber",
  "projectType": "nuxt3-e2e",
  "language": "typescript",
  "sourceContext": [
    "features/phase1-core-dashboard.feature",
    "specs/<<YOUR-FEATURE-FOLDER-HERE>>/phase1-core-dashboard.feature"
  ]
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

3. **Handle API Interactions**
   - When implementation requires API calls that don't exist: create mock API endpoints in `server/api/`
   - Always check HTTP response codes (e.g., `expect(response.status()).toBe(200)`)
   - Mock data should match TypeScript interfaces defined in `features/support/types.ts`

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
- ✅ Create mock APIs in `server/api/` when needed
- ✅ Verify HTTP response codes for API calls
- ✅ Use helper functions from `features/support/helpers.ts`
- ✅ Store state in World object properties (this.patentApplications, this.collaborators, etc.)

### Never Do These:
- ❌ Don't use synchronous functions
- ❌ Don't use Chai assertions
- ❌ Don't use `any` type
- ❌ Don't hardcode wait times (use Playwright's auto-waiting)
- ❌ Don't interact with page without checking if it's initialized

## Expected Output (Agent's Response Schema)

{
  "implementedSteps": 25,
  "createdFiles": [
    "features/step-definitions/dashboard-steps.ts",
    "features/step-definitions/common-steps.ts",
    "server/api/collaborators.ts",
    "server/api/applications.ts"
  ],
  "updatedFiles": [
    "features/support/types.ts",
    "features/support/world.ts"
  ],
  "status": "success",
  "summary": "Implemented 25 step definitions with proper TypeScript types and mock APIs",
  "implementationNotes": [
    "Created Collaborator interface in types.ts",
    "Added mock collaborators API endpoint",
    "Updated World interface with collaborators property"
  ],
  "nextStep": "03-update-step-definition-implementations-post-review"
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

  // Fetch from mock API
  const response = await this.page.request.get('http://localhost:3000/api/applications?type=patent')
  expect(response.status()).toBe(200)

  const result = await response.json()
  expect(result.success).toBe(true)

  this.patentApplications = result.data
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

### Mock API Pattern
Create in `server/api/` directory:
```typescript
// server/api/collaborators.ts
export default defineEventHandler((event) => {
  return {
    success: true,
    data: [
      {
        id: 'COLLAB-001',
        name: 'Bob Smith',
        email: 'bob@example.com',
        role: 'Patent Agent',
        accessLevel: 'Full access',
        lastActive: new Date()
      }
    ]
  }
})
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
