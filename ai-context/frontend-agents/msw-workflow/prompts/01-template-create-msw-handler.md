# Create MSW Handler Prompt Template

You are creating a new MSW handler for the IP Hub Frontend. Follow the MSW Handler Creation Guide.

## Input

```json
{
  "endpoint": "/api/[resource]",
  "method": "GET|POST|PUT|DELETE",
  "description": "Brief description of what this endpoint does",
  "responseStructure": {
    "success": true,
    "data": {
      // Expected response shape
    }
  },
  "environments": {
    "test": "Description of test data needs",
    "development": "Description of development data needs",
    "ci": "Description of CI data needs"
  },
  "errorScenarios": [
    {
      "status": 404,
      "condition": "When resource not found",
      "response": {}
    }
  ]
}
```

## Tasks

1. Create handler file in `test/msw/handlers/[domain].ts`
2. Define environment-specific mock data
3. Implement success and error scenarios
4. Register in `test/msw/handlers/index.ts`
5. Test with `npm run test`
6. Generate Pact with `npm run pact:generate`
7. Validate with `npm run pact:validate`
8. **Report to Developer**:
   - Changes made
   - Tests passing
   - Suggest: Increment package version
   - Suggest: Publish to Pact Broker with `npm run pact:publish`

## Output

- Handler file path
- Test results
- Pact generation results
- Version increment recommendation
