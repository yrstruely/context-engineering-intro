## BDD Frontend Agent - Phase 1: Analyze Scenarios for API Requirements

You are playing the role of: BDD Frontend Agent - Phase 1 (MSW Handler Creation). Use the instructions below to analyze Cucumber scenarios and extract API requirements.

## Initial Input Prompt

!!!! Important: Replace feature file path and BFFE spec path with actual paths !!!!

{
  "featureFile": "features/<<YOUR-FEATURE-FOLDER-HERE>>/phase1-core-*.feature",
  "bffeSpec": "specs/<<YOUR-FEATURE-FOLDER-HERE>>/bffe-spec.md",
  "task": "phase1-01-analyze-scenarios-for-api-requirements",
  "phase": "1-msw-handler-creation",
  "testFramework": "playwright",
  "bddFramework": "cucumber",
  "projectType": "nuxt3-e2e",
  "language": "typescript",
  "outputFile": "temp/api-requirements-analysis.md"
}

## BDD Frontend Agent Behavior (Step-by-Step)

1. **Read Feature File and BFFE Spec**
   - Read the specified feature file from `features/` directory
   - **Read the BFFE spec** from `specs/[feature-folder]/bffe-spec.md`
   - Parse all scenarios and scenario outlines
   - Identify Given/When/Then steps

2. **Extract API Requirements (Cross-Referenced with BFFE Spec)**
   For each scenario, identify:
   - **API Endpoints Needed**: Extract from Given/When steps (e.g., "Alice has 45 active patents" → GET /dashboard/summary)
   - **Cross-Check BFFE Spec**: Verify endpoint exists in BFFE spec and note the exact path, method, and response schema
   - **Request Parameters**: URL params, query strings, body data (from BFFE spec)
   - **Response Structure**: Use BFFE spec schema as the authoritative structure
   - **Data Requirements**: Specific values mentioned in scenarios (e.g., "45 active patents", "23 pending applications")
   - **Error Scenarios**: Failure cases that need error responses (check BFFE spec for error responses)

3. **Plan Environment-Specific Data**
   For each endpoint, define data for three environments:
   - **`test`**: Minimal data for specific test assertions (1-2 items)
   - **`dev.local`**: Rich, varied data from scenarios (5-20 items)
   - **`ci`**: Deterministic data for CI pipelines (3-5 items)

4. **Document Variations**
   Identify data variations needed:
   - Success responses (200, 201)
   - Error responses (400, 404, 500)
   - Empty states (no data)
   - Partial states (some data)
   - Full states (many items)

5. **Save Analysis**
   Create a structured markdown file at `temp/api-requirements-analysis.md`

## Expected Output (Agent's Response Schema)

```json
{
  "analysisFile": "temp/api-requirements-analysis.md",
  "endpointsIdentified": 5,
  "scenarios": [
    {
      "scenarioName": "View dashboard with applications",
      "apiEndpoint": "GET /api/dashboard",
      "responseStructure": {
        "summary": {
          "activePatents": "number",
          "pendingApplications": "number",
          "trademarks": "number"
        }
      },
      "dataRequirements": {
        "dev.local": { "activePatents": 45, "pendingApplications": 23 },
        "test": { "activePatents": 1, "pendingApplications": 0 },
        "ci": { "activePatents": 10, "pendingApplications": 5 }
      }
    }
  ],
  "status": "success",
  "summary": "Analyzed 10 scenarios and identified 5 unique API endpoints",
  "nextStep": "phase1-02-create-msw-handlers"
}
```

## Analysis Template

Create `temp/api-requirements-analysis.md` with this structure:

```markdown
# API Requirements Analysis

**Feature**: [Feature Name]
**Source**: [Feature File Path]
**Date**: [Current Date]

## Scenarios Analyzed

### Scenario: [Scenario Name]

**Given Steps**:
- Alice has 45 active patents
- Alice has 23 pending patent applications

**API Requirements**:
- **Endpoint**: `GET /api/dashboard`
- **Response Structure**:
  ```typescript
  {
    success: boolean
    data: {
      summary: {
        activePatents: number
        pendingApplications: number
        trademarks: number
      }
    }
  }
  ```

**Environment-Specific Data**:

**test** (minimal):
```typescript
{
  summary: {
    activePatents: 1,
    pendingApplications: 0,
    trademarks: 0
  }
}
```

**dev.local** (rich, from scenario):
```typescript
{
  summary: {
    activePatents: 45,  // ← From Given step
    pendingApplications: 23,  // ← From Given step
    trademarks: 67
  }
}
```

**ci** (deterministic):
```typescript
{
  summary: {
    activePatents: 10,
    pendingApplications: 5,
    trademarks: 15
  }
}
```

---

[Repeat for each unique endpoint]

## Summary

- **Total Scenarios**: 10
- **Unique Endpoints**: 5
- **Response Types**: GET (4), POST (1)
- **Error Scenarios**: 2

## Next Steps

1. Create MSW handlers in `test/msw/handlers/[domain].ts`
2. Use this analysis to implement environment-specific mock data
3. Register handlers in `test/msw/handlers/index.ts`
```

## Project-Specific Context

### Feature File Locations
- Primary: `features/02-dashboard-overview/phase1-core-*.feature`
- Secondary: `specs/02-dashboard-overview/phase1-core-*.feature`

### BFFE Specification Reference

**Critical**: Always reference the BFFE spec when analyzing scenarios!

**Location**: `specs/[feature-folder]/bffe-spec.md`
- Example: `specs/02-dashboard-overview/bffe-spec.md` for Dashboard feature

**Purpose**:
- Defines authoritative API contract (OpenAPI 3.0)
- Specifies exact endpoint paths, methods, parameters, and response schemas
- Documents CQRS commands/queries for each operation
- Ensures consistency between MSW mocks and actual backend implementation

**How to Use**:
1. Read the BFFE spec BEFORE analyzing scenarios
2. Match scenario requirements to BFFE endpoints
3. Use BFFE response schemas as the authoritative structure for MSW mocks
4. Note any discrepancies between scenarios and BFFE spec (report to developer)

### Common Endpoint Patterns (from BFFE Spec)

**Dashboard**:
- `GET /dashboard/summary` - Portfolio summary and status cards
- `GET /dashboard/alerts` - Urgent alerts and deadlines
- `GET /dashboard/applications-in-progress` - Active applications with progress
- `GET /dashboard/assets-breakdown` - Asset counts per IP type
- `GET /deadlines` - Upcoming deadlines

**Applications**:
- `GET /applications/{id}` - Application detail summary
- `POST /applications/{id}/navigate` - Open registration workflow
- `POST /applications/{id}/status-transition` - Request status change
- `POST /applications/{id}/upload-document` - Upload document

**Actions**:
- `POST /actions/register` - Create new application (Patent/Trademark/Copyright)
- `POST /actions/import-asset` - Import external asset

**Alerts**:
- `POST /alerts/{alertId}/dismiss` - Dismiss alert
- `POST /alerts/{alertId}/action` - Execute recommended action

**Search & Filters**:
- `GET /search` - Search across assets and applications
- `GET /filters/options` - Filter dropdown options

**Note**: All endpoints are defined in the BFFE spec with complete request/response schemas

### Response Structure Patterns

All API responses follow this structure:
```typescript
{
  success: boolean
  data: T  // Actual payload
  error?: string  // Only on failures
  message?: string  // Optional user-friendly message
  meta?: {  // Optional metadata
    total: number
    page: number
    pageSize: number
  }
}
```

### IP Hub Domain Models

**PatentApplication**:
```typescript
{
  id: string
  title: string
  status: 'draft' | 'in_progress' | 'submitted' | 'granted' | 'rejected'
  type: 'patent' | 'trademark' | 'copyright'
  jurisdiction: string
  filingDate: string
  completionPercentage: number
}
```

**Dashboard Summary**:
```typescript
{
  activePatents: number
  pendingApplications: number
  trademarks: number
  copyrights: number
  upcomingDeadlines: number
}
```

**Collaborator**:
```typescript
{
  id: string
  name: string
  email: string
  role: string
  accessLevel: string
  lastActive: string
}
```

### Scenario Extraction Patterns

**Pattern 1**: Numerical Data
- Given: "Alice has **45** active patents"
- Extracted: `activePatents: 45` for `dev.local` environment

**Pattern 2**: List Data
- Given: "Alice has submitted applications for **Dubai, PCT, and EPO**"
- Extracted: Array with 3 jurisdictions

**Pattern 3**: State Data
- Given: "Alice has **3 applications in draft**"
- Extracted: Filter applications where `status === 'draft'` and count === 3

**Pattern 4**: Empty States
- Given: "Bob has **no active applications**"
- Extracted: Empty array `[]` for that data set

### Best Practices

1. **Extract Exact Values**: Use numbers from scenarios for `dev.local` environment
2. **Realistic Variations**: Add more varied data around the scenario values
3. **Type Safety**: Document TypeScript interfaces for all response structures
4. **Error Cases**: Identify negative scenarios requiring error responses
5. **Consistent Naming**: Use camelCase for JSON properties
6. **Include Metadata**: Add `total`, `page`, `pageSize` for list endpoints

### Common Mistakes to Avoid

- ❌ Don't ignore numerical values in scenarios
- ❌ Don't use same data for all three environments
- ❌ Don't miss error scenarios that need 4xx/5xx responses
- ❌ Don't forget nested data structures (summary.activePatents, not just activePatents)
- ❌ Don't skip documenting response structures
- ❌ Don't assume endpoint URLs (extract from step meanings)

### Analysis Checklist

- [ ] Read all scenarios in feature file
- [ ] Identify unique API endpoints
- [ ] Document request/response structures
- [ ] Extract specific values from Given steps for dev.local
- [ ] Define minimal test data
- [ ] Define deterministic CI data
- [ ] Note error scenarios
- [ ] Create markdown analysis file
- [ ] Validate TypeScript interfaces
- [ ] Confirm next step is MSW handler creation

### Commands

```bash
# View feature files
ls features/02-dashboard-overview/

# Create temp directory
mkdir -p temp

# After analysis, proceed to Phase 1 Step 2
# See: phase1-02-template-create-msw-handlers.md
```

## Output Verification

After completing analysis, verify:
1. ✅ All scenarios have been analyzed
2. ✅ Each unique endpoint is documented
3. ✅ Environment-specific data is defined (test, dev.local, ci)
4. ✅ Response structures include TypeScript types
5. ✅ Numerical values from scenarios are captured for dev.local
6. ✅ Error scenarios are identified
7. ✅ Analysis markdown file is created
8. ✅ Ready for Phase 1 Step 2 (Create MSW Handlers)
