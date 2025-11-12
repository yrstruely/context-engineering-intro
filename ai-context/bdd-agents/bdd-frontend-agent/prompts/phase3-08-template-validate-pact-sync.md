## BDD Frontend Agent - Phase 3: Validate Pact-MSW Synchronization

You are playing the role of: BDD Frontend Agent - Phase 3 (Pact Contract Validation). Use the instructions below to validate that MSW handlers and Pact contracts are in sync.

## Initial Input Prompt

!!!! Important: Pact contracts must be generated first (Phase 3 Step 1) and BFFE spec must exist !!!!

{
  "task": "phase3-08-validate-pact-sync",
  "phase": "3-pact-contract-validation",
  "mswHandlersDirectory": "test/msw/handlers/",
  "pactDirectory": "test/pact/pacts/",
  "bffeSpec": "specs/<<YOUR-FEATURE-FOLDER-HERE>>/bffe-spec.md",
  "command": "npm run pact:validate"
}

## BDD Frontend Agent Behavior (Step-by-Step)

1. **Execute Validation Command**
   - Run: `npm run pact:validate`
   - Script compares MSW handler responses with Pact contracts
   - Validates structure synchronization

2. **Review Validation Results**
   - Check for any mismatches
   - Identify structural differences
   - Note sync status for each interaction

3. **Cross-Validate Against BFFE Spec**
   - **Read BFFE spec** from `specs/[feature-folder]/bffe-spec.md`
   - **Compare Pact contracts with BFFE spec**:
     - Endpoint paths match BFFE spec
     - Request parameters match BFFE spec
     - Response schemas match BFFE spec
     - HTTP methods match BFFE spec
   - **Note any discrepancies** between Pact and BFFE spec
   - **Priority**: BFFE spec is authoritative - MSW/Pact should match it

4. **Handle Validation Outcomes**
   - **Success (MSW-Pact-BFFE all match)**: Proceed to developer notification
   - **MSW-Pact Mismatch**: Report and suggest MSW handler fixes
   - **Pact-BFFE Mismatch**: Report and suggest MSW handler updates to match BFFE spec

4. **Inform Developer** (on success)
   - Confirm validation passed
   - Provide next steps for contract publication
   - Include version management guidance

## Expected Output (Agent's Response Schema)

### Success Case:
```json
{
  "task": "phase3-08-validate-pact-sync",
  "command": "npm run pact:validate",
  "status": "success",
  "validatedInteractions": 12,
  "syncStatus": "all-match",
  "results": [
    {
      "endpoint": "GET /api/dashboard",
      "mswHandler": "dashboardHandlers[0]",
      "pactInteraction": "GET dashboard summary",
      "status": "match",
      "message": "Response structures match"
    },
    {
      "endpoint": "GET /api/applications",
      "mswHandler": "applicationsHandlers[0]",
      "pactInteraction": "GET applications list",
      "status": "match",
      "message": "Response structures match"
    }
  ],
  "summary": "✅ All 12 MSW handlers match Pact contract structures",
  "nextStep": "developer-publish-contracts"
}
```

### Failure Case:
```json
{
  "task": "phase3-08-validate-pact-sync",
  "command": "npm run pact:validate",
  "status": "failure",
  "validatedInteractions": 12,
  "syncStatus": "mismatch-detected",
  "mismatches": [
    {
      "endpoint": "GET /api/dashboard",
      "mswHandler": "dashboardHandlers[0]",
      "pactInteraction": "GET dashboard summary",
      "status": "mismatch",
      "issue": "MSW returns 'activeAssets' but Pact expects 'activePatents'",
      "mswStructure": { "activeAssets": 45 },
      "pactStructure": { "activePatents": 45 },
      "fix": "Update MSW handler to use 'activePatents' field name"
    }
  ],
  "summary": "❌ Found 1 mismatch between MSW and Pact structures",
  "nextStep": "fix-msw-handlers-and-regenerate"
}
```

## Validation Process

### Step 1: Execute Validation

```bash
npm run pact:validate
```

**What Happens**:
1. Script reads Pact contracts from `test/pact/pacts/`
2. Reads MSW handlers from `test/msw/handlers/`
3. Compares response structures for each interaction
4. Validates field names, types, and nesting
5. Reports matches and mismatches

### Step 2: Understand Validation Results

**Validation Checks**:
- ✅ Response field names match
- ✅ Response field types match
- ✅ Nested structure depth matches
- ✅ Required fields present in both
- ✅ Status codes match

### Step 3: Handle Mismatches (if any)

If validation finds mismatches:

1. **Read the Error Report**
   ```
   ❌ Mismatch: GET /api/dashboard

   MSW Handler Returns:
   {
     "success": true,
     "data": {
       "summary": {
         "activeAssets": 45    // ← Field name mismatch
       }
     }
   }

   Pact Contract Expects:
   {
     "success": true,
     "data": {
       "summary": {
         "activePatents": 45   // ← Field name mismatch
       }
     }
   }

   Fix: Update MSW handler to use 'activePatents' instead of 'activeAssets'
   ```

2. **Fix MSW Handler**
   ```typescript
   // test/msw/handlers/dashboard.ts
   // BEFORE (incorrect):
   const dashboardData = getEnvironmentData({
     'dev.local': {
       summary: {
         activeAssets: 45  // ❌ Wrong field name
       }
     }
   })

   // AFTER (correct):
   const dashboardData = getEnvironmentData({
     'dev.local': {
       summary: {
         activePatents: 45  // ✅ Matches Pact contract
       }
     }
   })
   ```

3. **Re-run Workflow**
   ```bash
   npm run pact:workflow
   # Runs: pact:generate && pact:validate
   ```

## Success Output Example

```
✅ MSW-Pact Validation Successful

Validated Interactions: 12/12
Sync Status: All Match

Results:
  ✅ GET /api/dashboard - Response structures match
  ✅ GET /api/dashboard/recent-activity - Response structures match
  ✅ GET /api/applications - Response structures match
  ✅ GET /api/applications/:id - Response structures match
  ✅ POST /api/applications - Response structures match
  ✅ GET /api/collaborators - Response structures match
  ✅ GET /api/assets - Response structures match
  ✅ GET /api/assets/:type - Response structures match
  ✅ POST /api/collaborators - Response structures match
  ✅ GET /api/prior-art - Response structures match
  ✅ GET /api/fees - Response structures match
  ✅ POST /api/fees - Response structures match

All MSW handlers match Pact contract structures!
Contracts are ready for publication.
```

## Developer Notification (on Success)

After successful validation, inform the developer to complete the following steps:

### Step 1: Review Contracts

```bash
# View generated contract
cat test/pact/pacts/frontend-backend-consumer.json | jq

# Check interaction count
cat test/pact/pacts/frontend-backend-consumer.json | jq '.interactions | length'
```

Verify:
- ✅ All expected endpoints are present
- ✅ Interaction descriptions are clear
- ✅ Request/response structures are accurate

### Step 2: Version Management

**If API Contracts Changed**:
- Update `package.json` version
- Follow semantic versioning:
  - **Major** (x.0.0): Breaking changes
  - **Minor** (0.x.0): New endpoints/fields (backward compatible)
  - **Patch** (0.0.x): Bug fixes, no API changes

```bash
# Example: Adding new endpoint (minor version)
npm version minor  # 1.2.3 → 1.3.0
```

### Step 3: Publish Contracts to Pact Broker

```bash
npm run pact:publish
```

**Environment Variables Required**:
- `PACT_BROKER_URL`: Pact Broker server URL
- `PACT_BROKER_TOKEN`: Authentication token for broker

**What Happens**:
1. Contracts uploaded to Pact Broker
2. Tagged with current package version
3. Available for backend team to pull and verify

### Step 4: Notify Backend Team

After publishing, notify backend team:
- ✉️ New/updated contracts published to Pact Broker
- 📦 Consumer version: `[package version]`
- 🔗 Pact Broker URL: `[broker url]`
- 📋 Interactions count: `[number]`
- 🎯 Backend should run `pact:verify` to test against contracts

**Example Notification**:
```
Subject: New API Contracts Published - IP Hub Frontend v1.3.0

Hi Backend Team,

New Pact contracts have been published for IP Hub Frontend v1.3.0.

Contract Details:
- Consumer: ip-hub-frontend
- Version: 1.3.0
- Interactions: 12 endpoints
- Pact Broker: https://pact-broker.example.com

New Endpoints:
- GET /api/assets/:type (filter assets by type)
- POST /api/collaborators (invite new collaborator)

Updated Endpoints:
- GET /api/dashboard (added upcomingDeadlines field)

Please verify these contracts against your API:
  npm run pact:verify

Let me know if you have any questions!

Best,
[Your Name]
```

## Contract Publication Flow

```
Frontend (Phase 3 Complete)
   ↓
Generate Pact Contracts (npm run pact:generate)
   ↓
Validate MSW-Pact Sync (npm run pact:validate) ✅
   ↓
Publish to Pact Broker (npm run pact:publish)
   ↓
Backend Team Receives Notification
   ↓
Backend Pulls Contracts from Broker
   ↓
Backend Runs Provider Verification (pact:verify)
   ↓
Backend Implements APIs Matching Contracts
   ↓
Integration Works Seamlessly! 🎉
```

## Common Validation Issues & Solutions

### Issue 1: Field Name Mismatch

**Error**:
```
MSW returns 'userId' but Pact expects 'user_id'
```

**Solution**: Use consistent naming (camelCase recommended)
```typescript
// Update MSW handler
const data = {
  userId: '123'  // ✅ Consistent
}
```

### Issue 2: Missing Field

**Error**:
```
Pact expects field 'totalCount' but MSW doesn't return it
```

**Solution**: Add field to MSW handler
```typescript
const data = {
  items: [],
  totalCount: 0  // ✅ Added
}
```

### Issue 3: Type Mismatch

**Error**:
```
MSW returns string '45' but Pact expects number 45
```

**Solution**: Fix type in MSW handler
```typescript
const data = {
  activePatents: 45  // ✅ Number, not string
}
```

### Issue 4: Nested Structure Different

**Error**:
```
MSW structure: { data: { items: [] } }
Pact structure: { data: [] }
```

**Solution**: Match nesting level
```typescript
return HttpResponse.json({
  success: true,
  data: []  // ✅ Match Pact structure
})
```

## Project-Specific Context

### Validation Script

Located in `scripts/validate-msw-pact-sync.ts`:
- Reads Pact contracts
- Reads MSW handlers
- Deep comparison of structures
- Reports mismatches with helpful error messages

### Package.json Scripts

```json
{
  "pact:validate": "tsx scripts/validate-msw-pact-sync.ts",
  "pact:workflow": "npm run pact:generate && npm run pact:validate",
  "pact:publish": "pact-broker publish test/pact/pacts --consumer-version=$npm_package_version"
}
```

## Verification Checklist

After successful validation, confirm:
- [ ] All interactions validated (count matches expected)
- [ ] All structures match between MSW and Pact
- [ ] No mismatches reported
- [ ] Contracts reviewed for correctness
- [ ] Package version updated (if API changed)
- [ ] Ready to publish to Pact Broker

## Commands Reference

```bash
# Validate MSW-Pact sync
npm run pact:validate

# If mismatches found, fix MSW handlers and re-run workflow
npm run pact:workflow

# After successful validation, publish contracts
npm run pact:publish

# Check published contracts on Pact Broker
open $PACT_BROKER_URL
```

## Important Notes

- ✅ Validation ensures MSW mocks match Pact contracts
- ✅ Prevents frontend-backend integration issues
- ✅ Must pass before publishing contracts
- ✅ Re-run after any MSW handler changes
- ❌ Don't skip validation - it catches structural issues early
- ❌ Don't manually edit Pact files - update MSW instead

## Next Steps After Successful Validation

1. ✅ **Review Contracts**: Verify all endpoints represented
2. ✅ **Version Management**: Bump package.json version if needed
3. ✅ **Publish Contracts**: Run `npm run pact:publish`
4. ✅ **Notify Backend Team**: Share contract details and version
5. ✅ **Backend Verification**: Backend runs `pact:verify`
6. ✅ **Backend Implementation**: Backend implements matching APIs
7. ✅ **Integration Success**: Frontend-backend "just works"!

## Output Verification

After completing validation, confirm:
1. ✅ Validation passed with all structures matching
2. ✅ Developer notified with next steps
3. ✅ Contracts ready for publication
4. ✅ BDD-First workflow complete (Phase 1 → Phase 2 → Phase 3) ✅
