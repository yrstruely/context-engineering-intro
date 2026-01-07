## BDD Frontend Agent - Phase 3: Generate Pact Contracts

You are playing the role of: BDD Frontend Agent - Phase 3 (Pact Contract Generation). Use the instructions below to generate Pact contracts from MSW handlers.

## Initial Input Prompt

!!!! Important: MSW handlers, step definitions, and BFFE spec must exist first !!!!

{
"task": "phase3-07-generate-pact-contracts",
"phase": "3-pact-contract-generation",
"mswHandlersDirectory": "test/msw/handlers/",
"pactOutputDirectory": "test/pact/pacts/",
"bffeSpec": "specs/011-onboarding/bffe-spec.md",
"command": "npm run pact:generate"
}

## BDD Frontend Agent Behavior (Step-by-Step)

1. **Verify Prerequisites**
   - Confirm MSW handlers exist in `test/msw/handlers/`
   - Confirm step definitions are implemented
   - Verify tests are running (even if failing due to missing frontend code)

2. **Generate Pact Contracts**
   - Execute: `npm run pact:generate`
   - Script analyzes MSW handlers
   - Extracts request/response structures
   - Generates Pact contract files

3. **Review Generated Contracts**
   - Check files in `test/pact/pacts/`
   - Verify interaction descriptions are clear
   - Ensure request/response structures are accurate
   - Confirm all MSW handlers are represented

4. **Cross-Check Against BFFE Spec**
   - **Read BFFE spec** from `specs/011-onboarding/bffe-spec.md`
   - **Verify endpoint paths match** BFFE spec exactly
   - **Verify response schemas match** BFFE spec definitions
   - **Note any discrepancies** between Pact contracts and BFFE spec
   - **Report mismatches** to developer for resolution

5. **Report Success (or Discrepancies)**
   - List generated contract files
   - Show interaction count
   - **Report BFFE spec compliance status**
   - Provide next steps for developer

## Expected Output (Agent's Response Schema)

```json
{
  "task": "phase3-07-generate-pact-contracts",
  "command": "npm run pact:generate",
  "generatedContracts": ["test/pact/pacts/frontend-backend-consumer.json"],
  "totalInteractions": 12,
  "interactions": [
    {
      "description": "GET /api/dashboard",
      "method": "GET",
      "path": "/api/dashboard",
      "status": 200
    },
    {
      "description": "GET /api/applications",
      "method": "GET",
      "path": "/api/applications",
      "status": 200
    }
  ],
  "status": "success",
  "summary": "Generated Pact contracts with 12 interactions from MSW handlers",
  "nextStep": "phase3-08-validate-pact-sync"
}
```

## Pact Contract Generation Process

### Step 1: Execute Generation Command

```bash
npm run pact:generate
```

**What Happens**:

1. Script reads MSW handlers from `test/msw/handlers/`
2. Analyzes each HTTP handler (http.get, http.post, etc.)
3. Extracts request patterns and response structures
4. Generates Pact interactions in standard format
5. Writes contracts to `test/pact/pacts/`

### Step 2: Understand Generated Contract Structure

Example generated contract:

```json
{
  "consumer": {
    "name": "ip-hub-frontend"
  },
  "provider": {
    "name": "ip-hub-backend"
  },
  "interactions": [
    {
      "description": "GET dashboard summary",
      "request": {
        "method": "GET",
        "path": "/api/dashboard"
      },
      "response": {
        "status": 200,
        "headers": {
          "Content-Type": "application/json"
        },
        "body": {
          "success": true,
          "data": {
            "summary": {
              "activePatents": 45,
              "pendingApplications": 23,
              "trademarks": 67
            }
          }
        },
        "matchingRules": {
          "body": {
            "$.data.summary.activePatents": {
              "matchers": [{ "match": "type" }]
            },
            "$.data.summary.pendingApplications": {
              "matchers": [{ "match": "type" }]
            }
          }
        }
      }
    },
    {
      "description": "GET applications list",
      "request": {
        "method": "GET",
        "path": "/api/applications",
        "query": {
          "type": ["patent"]
        }
      },
      "response": {
        "status": 200,
        "headers": {
          "Content-Type": "application/json"
        },
        "body": {
          "success": true,
          "data": [
            {
              "id": "APP-001",
              "title": "Dubai Patent Application",
              "status": "in_progress",
              "type": "patent"
            }
          ],
          "meta": {
            "total": 1
          }
        }
      }
    }
  ],
  "metadata": {
    "pactSpecification": {
      "version": "2.0.0"
    }
  }
}
```

### Step 3: Verify Contract Quality

Check that contracts include:

- ✅ Clear interaction descriptions
- ✅ Accurate request paths and methods
- ✅ Query parameters where applicable
- ✅ Expected response status codes
- ✅ Response body structures
- ✅ Matching rules (type matchers for flexible validation)
- ✅ All MSW handlers represented

## Understanding Pact Matchers

Pact uses matchers to define flexible contract validation:

**Type Matcher** (`match: type`):

- Validates field exists and is correct type
- Doesn't validate exact value
- Example: `activePatents: 45` → Backend can return any number

**Equality Matcher** (`match: equality`):

- Validates exact value
- Use for constants (status codes, fixed strings)

**Regex Matcher** (`match: regex`):

- Validates pattern
- Use for IDs, dates, emails

Example from generated contract:

```json
{
  "$.data.summary.activePatents": {
    "matchers": [{ "match": "type" }]
  }
}
```

Means: `activePatents` must be a number, but can be any value

## Project-Specific Context

### Package.json Scripts

```json
{
  "pact:generate": "tsx scripts/generate-pact-from-msw.ts",
  "pact:validate": "tsx scripts/validate-msw-pact-sync.ts",
  "pact:workflow": "npm run pact:generate && npm run pact:validate",
  "pact:publish": "pact-broker publish test/pact/pacts --consumer-version=$npm_package_version --broker-base-url=$PACT_BROKER_URL --broker-token=$PACT_BROKER_TOKEN"
}
```

### File Locations

- **MSW Handlers** (Input): `test/msw/handlers/*.ts`
- **Pact Contracts** (Output): `test/pact/pacts/*.json`
- **Generation Script**: `scripts/generate-pact-from-msw.ts`
- **Validation Script**: `scripts/validate-msw-pact-sync.ts`

### Contract Naming

Generated contract file:

```
frontend-backend-consumer.json
```

Format: `{consumer}-{provider}-consumer.json`

### Consumer-Driven Contracts

**Important Concept**:

- ✅ Pact contracts define what **frontend NEEDS** from backend
- ✅ Backend implements to **match the contract**
- ✅ This is "consumer-driven" contracts
- ❌ NOT backend-first design where frontend adapts

## Success Output Example

```
✅ Pact Contract Generation Successful

Generated Contracts:
  - test/pact/pacts/frontend-backend-consumer.json

Interactions Generated:
  - GET /api/dashboard (200)
  - GET /api/dashboard/recent-activity (200)
  - GET /api/applications (200)
  - GET /api/applications/:id (200)
  - POST /api/applications (201)
  - GET /api/collaborators (200)
  - GET /api/assets (200)

Total Interactions: 12
Pact Specification Version: 2.0.0

Contracts written to: test/pact/pacts/
```

## Next Steps for Developer

After successful Pact generation, inform the developer to:

1. **Review Generated Contracts**

   ```bash
   cat test/pact/pacts/frontend-backend-consumer.json | jq
   ```

   - Verify interaction descriptions are clear
   - Check request/response structures are accurate
   - Ensure all endpoints are represented

2. **Proceed to Validation** (Phase 3 Step 2)

   ```bash
   npm run pact:validate
   ```

   - Validates MSW and Pact structures match
   - See: phase3-08-template-validate-pact-sync.md

3. **OR Run Complete Workflow**
   ```bash
   npm run pact:workflow
   ```

   - Runs both generate and validate together
   - Recommended for efficiency

## Common Issues & Solutions

**Issue**: Generation script fails with "MSW handlers not found"
**Solution**: Verify MSW handlers exist in `test/msw/handlers/` and are properly exported

**Issue**: Some endpoints missing from contract
**Solution**: Check MSW handler is registered in `test/msw/handlers/index.ts`

**Issue**: Contract structure looks incorrect
**Solution**: Review MSW handler response format - should match `{ success: boolean, data: T }`

**Issue**: Matchers not generated
**Solution**: Generation script creates type matchers automatically - no action needed

## Verification Checklist

Before proceeding to validation, verify:

- [ ] Pact contract file exists in `test/pact/pacts/`
- [ ] All MSW endpoints are represented as interactions
- [ ] Interaction count matches expected endpoints
- [ ] Request methods and paths are correct
- [ ] Response status codes are appropriate
- [ ] Response bodies include expected structures
- [ ] Matching rules are present for flexible fields
- [ ] Consumer and provider names are correct

## Commands Reference

```bash
# Generate Pact contracts from MSW
npm run pact:generate

# View generated contract (formatted)
cat test/pact/pacts/frontend-backend-consumer.json | jq

# Count interactions
cat test/pact/pacts/frontend-backend-consumer.json | jq '.interactions | length'

# View interaction descriptions
cat test/pact/pacts/frontend-backend-consumer.json | jq '.interactions[].description'

# Proceed to validation (next step)
npm run pact:validate

# OR run complete workflow
npm run pact:workflow
```

## Important Notes

- ✅ Pact contracts are **auto-generated** from MSW (no manual writing)
- ✅ Contracts define what frontend **NEEDS** (consumer-driven)
- ✅ Backend implements to **match the contract** structure
- ✅ Integration "just works" when backend implements contracts
- ❌ **Don't manually edit** generated Pact files (update MSW instead)
- ❌ **Don't skip validation** step (Phase 3 Step 2)

## Output Verification

After completing Pact generation, confirm:

1. ✅ Contract file exists in `test/pact/pacts/`
2. ✅ All interactions generated successfully
3. ✅ Interaction count matches MSW handlers
4. ✅ Contract structure is valid JSON
5. ✅ Ready for Phase 3 Step 2 (Pact Validation)
