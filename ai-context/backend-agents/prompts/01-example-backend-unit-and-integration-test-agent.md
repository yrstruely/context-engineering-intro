# Backend Unit and Integration Test Agent - Dashboard Overview Example

## System Context Layer (Role Definition)

You are playing the role of: **Backend TDD Test Agent** for NestJS applications using CQRS pattern.

This is a concrete example using the **Dashboard Overview** feature from the IP Hub Backend project.

---

## Initial Input Prompt

```json
{
  "featureFile": "apps/ip-hub-backend-e2e/features/02-dashboard-overview/phase1-bffe-api.feature",
  "scenarioName": "Dashboard summary returns correct portfolio counts",
  "failingE2EOutput": "Error: Request failed with status code 404\n    at /api/dashboard/summary",
  "task": "01-generate-unit-and-integration-tests",
  "targetDomain": "dashboard",
  "existingGreenFeatures": [],
  "testPriority": "unit-first"
}
```

---

## Step 1: Analyze BDD Scenario

### Scenario from Feature File

```gherkin
@api @query @smoke
Scenario: Dashboard summary returns correct portfolio counts
  Given Alice's organization has the following IP assets:
    | type      | status      | count |
    | patent    | active      | 5     |
    | patent    | in_progress | 2     |
    | trademark | active      | 3     |
    | copyright | draft       | 1     |
  When the client sends a "GET" request to "/api/dashboard/summary"
  Then the response status should be 200
  And the response body should contain:
    | field              | value |
    | totalAssets        | 11    |
    | inProgressCount    | 2     |
    | pendingReviewCount | 0     |
  And the response body "countsByType" should contain:
    | patents    | 7 |
    | trademarks | 3 |
    | copyrights | 1 |
```

### Scenario Analysis

**Backend Components Needed**:

| Component | Name | File Path |
|-----------|------|-----------|
| Query | `GetDashboardSummaryQuery` | `app/dashboard/queries/get-dashboard-summary.query.ts` |
| Query Handler | `GetDashboardSummaryHandler` | `app/dashboard/queries/get-dashboard-summary.handler.ts` |
| DTO | `DashboardSummaryDto` | `libs/api-contracts` |
| Entity | `ApplicationEntity` | `test/shared/entities/application.entity.ts` |
| Controller | `DashboardController` | `bffe/dashboard/dashboard.controller.ts` |
| Endpoint | `GET /api/dashboard/summary` | |

**Current State**:
- E2E Test Status: FAILING (Red)
- Failure Reason: 404 Not Found - endpoint `/api/dashboard/summary` not implemented

---

## Step 2: Design Test Strategy

### Test Coverage Plan

**Unit Tests (Priority 1)**:

1. `get-dashboard-summary.handler.spec.ts`
   - should return correct total asset count
   - should return correct in-progress count
   - should return correct pending review count
   - should return correct counts by type
   - should return zeros for empty portfolio
   - should filter by organization

**Integration Tests (Priority 2)**:

1. `dashboard-api.integration.spec.ts`
   - should return dashboard summary with correct counts
   - should return 401 without authentication
   - should return empty counts for org without applications

**Factories**:
- `ApplicationFactory` - Already exists, may need updates

---

## Step 3: Generated Unit Tests

### Query Handler Unit Test

```typescript
// apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.handler.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GetDashboardSummaryHandler } from './get-dashboard-summary.handler';
import { GetDashboardSummaryQuery } from './get-dashboard-summary.query';
import { ApplicationEntity } from '../../../../test/shared/entities/application.entity';

describe('GetDashboardSummaryHandler', () => {
  let handler: GetDashboardSummaryHandler;
  let mockRepository: jest.Mocked<Repository<ApplicationEntity>>;

  beforeEach(async () => {
    mockRepository = {
      find: jest.fn(),
      count: jest.fn(),
      createQueryBuilder: jest.fn(),
    } as unknown as jest.Mocked<Repository<ApplicationEntity>>;

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GetDashboardSummaryHandler,
        {
          provide: getRepositoryToken(ApplicationEntity),
          useValue: mockRepository,
        },
      ],
    }).compile();

    handler = module.get<GetDashboardSummaryHandler>(GetDashboardSummaryHandler);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('execute', () => {
    it('should return correct total asset count', async () => {
      // Arrange
      const query = new GetDashboardSummaryQuery(
        '550e8400-e29b-41d4-a716-446655440001', // Alice's org
        '550e8400-e29b-41d4-a716-446655440002', // Alice's user ID
      );

      const mockApplications: Partial<ApplicationEntity>[] = [
        { id: '1', type: 'patent', status: 'active', orgId: query.orgId },
        { id: '2', type: 'patent', status: 'active', orgId: query.orgId },
        { id: '3', type: 'patent', status: 'active', orgId: query.orgId },
        { id: '4', type: 'patent', status: 'active', orgId: query.orgId },
        { id: '5', type: 'patent', status: 'active', orgId: query.orgId },
        { id: '6', type: 'patent', status: 'in_progress', orgId: query.orgId },
        { id: '7', type: 'patent', status: 'in_progress', orgId: query.orgId },
        { id: '8', type: 'trademark', status: 'active', orgId: query.orgId },
        { id: '9', type: 'trademark', status: 'active', orgId: query.orgId },
        { id: '10', type: 'trademark', status: 'active', orgId: query.orgId },
        { id: '11', type: 'copyright', status: 'draft', orgId: query.orgId },
      ];

      mockRepository.find.mockResolvedValue(mockApplications as ApplicationEntity[]);

      // Act
      const result = await handler.execute(query);

      // Assert
      expect(result.totalAssets).toBe(11);
    });

    it('should return correct in-progress count', async () => {
      // Arrange
      const query = new GetDashboardSummaryQuery('org-001', 'user-001');

      const mockApplications: Partial<ApplicationEntity>[] = [
        { id: '1', type: 'patent', status: 'draft', orgId: 'org-001' },
        { id: '2', type: 'patent', status: 'in_progress', orgId: 'org-001' },
        { id: '3', type: 'patent', status: 'in_progress', orgId: 'org-001' },
        { id: '4', type: 'trademark', status: 'submitted', orgId: 'org-001' },
      ];

      mockRepository.find.mockResolvedValue(mockApplications as ApplicationEntity[]);

      // Act
      const result = await handler.execute(query);

      // Assert
      expect(result.inProgressCount).toBe(2);
    });

    it('should return correct pending review count', async () => {
      // Arrange
      const query = new GetDashboardSummaryQuery('org-001', 'user-001');

      const mockApplications: Partial<ApplicationEntity>[] = [
        { id: '1', type: 'patent', status: 'draft', orgId: 'org-001' },
        { id: '2', type: 'patent', status: 'under_review', orgId: 'org-001' },
        { id: '3', type: 'patent', status: 'under_review', orgId: 'org-001' },
        { id: '4', type: 'trademark', status: 'action_required', orgId: 'org-001' },
      ];

      mockRepository.find.mockResolvedValue(mockApplications as ApplicationEntity[]);

      // Act
      const result = await handler.execute(query);

      // Assert
      expect(result.pendingReviewCount).toBe(2); // under_review counts as pending
    });

    it('should return correct counts by type', async () => {
      // Arrange
      const query = new GetDashboardSummaryQuery('org-001', 'user-001');

      const mockApplications: Partial<ApplicationEntity>[] = [
        { id: '1', type: 'patent', status: 'active', orgId: 'org-001' },
        { id: '2', type: 'patent', status: 'draft', orgId: 'org-001' },
        { id: '3', type: 'trademark', status: 'active', orgId: 'org-001' },
        { id: '4', type: 'trademark', status: 'active', orgId: 'org-001' },
        { id: '5', type: 'trademark', status: 'active', orgId: 'org-001' },
        { id: '6', type: 'copyright', status: 'draft', orgId: 'org-001' },
      ];

      mockRepository.find.mockResolvedValue(mockApplications as ApplicationEntity[]);

      // Act
      const result = await handler.execute(query);

      // Assert
      expect(result.countsByType).toEqual({
        patents: 2,
        trademarks: 3,
        copyrights: 1,
      });
    });

    it('should return zeros for empty portfolio', async () => {
      // Arrange
      const query = new GetDashboardSummaryQuery('empty-org', 'user-001');
      mockRepository.find.mockResolvedValue([]);

      // Act
      const result = await handler.execute(query);

      // Assert
      expect(result.totalAssets).toBe(0);
      expect(result.inProgressCount).toBe(0);
      expect(result.pendingReviewCount).toBe(0);
      expect(result.countsByType).toEqual({
        patents: 0,
        trademarks: 0,
        copyrights: 0,
      });
    });

    it('should filter by organization', async () => {
      // Arrange
      const query = new GetDashboardSummaryQuery('specific-org-id', 'user-001');
      mockRepository.find.mockResolvedValue([]);

      // Act
      await handler.execute(query);

      // Assert
      expect(mockRepository.find).toHaveBeenCalledWith({
        where: { orgId: 'specific-org-id' },
      });
    });
  });
});
```

### Query Class Unit Test

```typescript
// apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.query.spec.ts
import { GetDashboardSummaryQuery } from './get-dashboard-summary.query';

describe('GetDashboardSummaryQuery', () => {
  it('should create query with orgId and userId', () => {
    const query = new GetDashboardSummaryQuery('org-001', 'user-001');

    expect(query.orgId).toBe('org-001');
    expect(query.userId).toBe('user-001');
  });

  it('should be immutable', () => {
    const query = new GetDashboardSummaryQuery('org-001', 'user-001');

    // TypeScript should prevent this at compile time with readonly
    expect(query.orgId).toBe('org-001');
  });
});
```

---

## Step 4: Generated Integration Tests

### Dashboard API Integration Test

```typescript
// apps/ip-hub-backend/test/integration/dashboard-api.integration.spec.ts
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { TestDatabase } from '../shared/test-database';
import { createTestApp } from '../shared/test-app-factory';
import { ApplicationFactory } from '../shared/factories/application.factory';
import { UserFactory } from '../shared/factories/user.factory';

describe('Dashboard API Integration', () => {
  let app: INestApplication;
  let testDatabase: TestDatabase;
  let applicationFactory: ApplicationFactory;
  let userFactory: UserFactory;

  // Standard test UUIDs (matching step definitions)
  const ALICE_ORG_ID = '550e8400-e29b-41d4-a716-446655440001';
  const ALICE_USER_ID = '550e8400-e29b-41d4-a716-446655440002';

  beforeAll(async () => {
    testDatabase = new TestDatabase({ database: 'dashboard_integration' });
    await testDatabase.start();
    app = await createTestApp(testDatabase);
    applicationFactory = new ApplicationFactory(testDatabase.getDataSource());
    userFactory = new UserFactory(testDatabase.getDataSource());
  }, 120000);

  afterAll(async () => {
    await app.close();
    await testDatabase.stop();
  });

  beforeEach(async () => {
    await testDatabase.clearAllTables();
  });

  describe('GET /api/dashboard/summary', () => {
    it('should return dashboard summary with correct portfolio counts', async () => {
      // Arrange - Create test data matching BDD scenario
      await userFactory.createAlice();

      // Create applications matching the BDD scenario:
      // 5 active patents, 2 in_progress patents, 3 active trademarks, 1 draft copyright
      await applicationFactory.createMany(5, {
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'patent',
        status: 'active',
      });
      await applicationFactory.createMany(2, {
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'patent',
        status: 'in_progress',
      });
      await applicationFactory.createMany(3, {
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'trademark',
        status: 'active',
      });
      await applicationFactory.create({
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'copyright',
        status: 'draft',
      });

      // Act
      const response = await request(app.getHttpServer())
        .get('/api/dashboard/summary')
        .set('Authorization', `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`)
        .expect(200);

      // Assert - Match BDD expected values
      expect(response.body.totalAssets).toBe(11);
      expect(response.body.inProgressCount).toBe(2);
      expect(response.body.pendingReviewCount).toBe(0);
      expect(response.body.countsByType).toEqual({
        patents: 7,
        trademarks: 3,
        copyrights: 1,
      });
    });

    it('should return 401 without authentication', async () => {
      await request(app.getHttpServer())
        .get('/api/dashboard/summary')
        .expect(401);
    });

    it('should return empty counts for organization without applications', async () => {
      // Arrange - Create user but no applications
      await userFactory.createAlice();

      // Act
      const response = await request(app.getHttpServer())
        .get('/api/dashboard/summary')
        .set('Authorization', `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`)
        .expect(200);

      // Assert
      expect(response.body.totalAssets).toBe(0);
      expect(response.body.inProgressCount).toBe(0);
      expect(response.body.pendingReviewCount).toBe(0);
    });

    it('should not include applications from other organizations', async () => {
      // Arrange
      await userFactory.createAlice();

      // Create applications for Alice's org
      await applicationFactory.create({
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'patent',
        status: 'active',
      });

      // Create applications for different org (should not appear)
      await applicationFactory.create({
        orgId: 'other-org-id',
        userId: 'other-user-id',
        type: 'patent',
        status: 'active',
      });
      await applicationFactory.create({
        orgId: 'other-org-id',
        userId: 'other-user-id',
        type: 'trademark',
        status: 'active',
      });

      // Act
      const response = await request(app.getHttpServer())
        .get('/api/dashboard/summary')
        .set('Authorization', `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`)
        .expect(200);

      // Assert - Only Alice's application should be counted
      expect(response.body.totalAssets).toBe(1);
      expect(response.body.countsByType.patents).toBe(1);
      expect(response.body.countsByType.trademarks).toBe(0);
    });

    it('should handle performance for large portfolios', async () => {
      // Arrange - Create 100 applications
      await userFactory.createAlice();
      await applicationFactory.createMany(100, {
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
      });

      // Act
      const startTime = Date.now();
      const response = await request(app.getHttpServer())
        .get('/api/dashboard/summary')
        .set('Authorization', `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`)
        .expect(200);
      const duration = Date.now() - startTime;

      // Assert - Should complete within 500ms (performance requirement from BDD)
      expect(duration).toBeLessThan(500);
      expect(response.body.totalAssets).toBe(100);
    });
  });
});
```

---

## Step 5: Expected Failures Analysis

### Unit Tests Expected Failures

| Test File | Test Name | Expected Failure Reason |
|-----------|-----------|------------------------|
| `get-dashboard-summary.handler.spec.ts` | should return correct total asset count | `Cannot find module './get-dashboard-summary.handler'` |
| `get-dashboard-summary.handler.spec.ts` | should return correct in-progress count | `Cannot find module './get-dashboard-summary.handler'` |
| `get-dashboard-summary.handler.spec.ts` | should return correct pending review count | `Cannot find module './get-dashboard-summary.handler'` |
| `get-dashboard-summary.handler.spec.ts` | should return correct counts by type | `Cannot find module './get-dashboard-summary.handler'` |
| `get-dashboard-summary.handler.spec.ts` | should return zeros for empty portfolio | `Cannot find module './get-dashboard-summary.handler'` |
| `get-dashboard-summary.handler.spec.ts` | should filter by organization | `Cannot find module './get-dashboard-summary.handler'` |
| `get-dashboard-summary.query.spec.ts` | should create query with orgId and userId | `Cannot find module './get-dashboard-summary.query'` |

### Integration Tests Expected Failures

| Test File | Test Name | Expected Failure Reason |
|-----------|-----------|------------------------|
| `dashboard-api.integration.spec.ts` | should return dashboard summary with correct portfolio counts | `404 Not Found` - endpoint not implemented |
| `dashboard-api.integration.spec.ts` | should return 401 without authentication | `404 Not Found` - endpoint not implemented |
| `dashboard-api.integration.spec.ts` | should return empty counts for organization without applications | `404 Not Found` - endpoint not implemented |
| `dashboard-api.integration.spec.ts` | should not include applications from other organizations | `404 Not Found` - endpoint not implemented |
| `dashboard-api.integration.spec.ts` | should handle performance for large portfolios | `404 Not Found` - endpoint not implemented |

---

## Step 6: Implementation Order

To make these tests pass, implement in this order:

### 1. Create Query Class

```typescript
// apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.query.ts
export class GetDashboardSummaryQuery {
  constructor(
    public readonly orgId: string,
    public readonly userId: string,
  ) {}
}
```

### 2. Create DTO (if not in api-contracts)

```typescript
// libs/api-contracts/src/dashboard/dashboard-summary.dto.ts
export interface DashboardSummaryDto {
  totalAssets: number;
  inProgressCount: number;
  pendingReviewCount: number;
  countsByType: {
    patents: number;
    trademarks: number;
    copyrights: number;
  };
}
```

### 3. Create Query Handler

```typescript
// apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.handler.ts
import { QueryHandler, IQueryHandler } from '@nestjs/cqrs';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GetDashboardSummaryQuery } from './get-dashboard-summary.query';
import { DashboardSummaryDto } from '@ip-hub/api-contracts';
import { ApplicationEntity } from '../../../../test/shared/entities/application.entity';

@QueryHandler(GetDashboardSummaryQuery)
export class GetDashboardSummaryHandler
  implements IQueryHandler<GetDashboardSummaryQuery>
{
  constructor(
    @InjectRepository(ApplicationEntity)
    private readonly repository: Repository<ApplicationEntity>,
  ) {}

  async execute(query: GetDashboardSummaryQuery): Promise<DashboardSummaryDto> {
    // Implementation here
  }
}
```

### 4. Create Dashboard Module

```typescript
// apps/ip-hub-backend/src/app/dashboard/dashboard.module.ts
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GetDashboardSummaryHandler } from './queries/get-dashboard-summary.handler';
import { DashboardController } from './dashboard.controller';
import { ApplicationEntity } from '../../../test/shared/entities/application.entity';

@Module({
  imports: [
    CqrsModule,
    TypeOrmModule.forFeature([ApplicationEntity]),
  ],
  controllers: [DashboardController],
  providers: [GetDashboardSummaryHandler],
})
export class DashboardModule {}
```

### 5. Create Controller Endpoint

```typescript
// apps/ip-hub-backend/src/app/dashboard/dashboard.controller.ts
import { Controller, Get, UseGuards, Req } from '@nestjs/common';
import { QueryBus } from '@nestjs/cqrs';
import { GetDashboardSummaryQuery } from './queries/get-dashboard-summary.query';
import { DashboardSummaryDto } from '@ip-hub/api-contracts';

@Controller('dashboard')
export class DashboardController {
  constructor(private readonly queryBus: QueryBus) {}

  @Get('summary')
  @UseGuards(AuthGuard)
  async getSummary(@Req() req: AuthenticatedRequest): Promise<DashboardSummaryDto> {
    return this.queryBus.execute(
      new GetDashboardSummaryQuery(req.user.orgId, req.user.userId),
    );
  }
}
```

### 6. Register Module in AppModule

```typescript
// apps/ip-hub-backend/src/app/app.module.ts
import { DashboardModule } from './dashboard/dashboard.module';

@Module({
  imports: [
    // ... other imports
    DashboardModule,
  ],
})
export class AppModule {}
```

---

## Expected Output (Agent's Response Schema)

```json
{
  "generatedTests": {
    "unitTests": [
      {
        "path": "apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.handler.spec.ts",
        "purpose": "Test GetDashboardSummaryHandler with mocked repository",
        "testCases": [
          "should return correct total asset count",
          "should return correct in-progress count",
          "should return correct pending review count",
          "should return correct counts by type",
          "should return zeros for empty portfolio",
          "should filter by organization"
        ]
      },
      {
        "path": "apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.query.spec.ts",
        "purpose": "Test GetDashboardSummaryQuery class instantiation",
        "testCases": [
          "should create query with orgId and userId",
          "should be immutable"
        ]
      }
    ],
    "integrationTests": [
      {
        "path": "apps/ip-hub-backend/test/integration/dashboard-api.integration.spec.ts",
        "purpose": "Test GET /api/dashboard/summary with real database",
        "testCases": [
          "should return dashboard summary with correct portfolio counts",
          "should return 401 without authentication",
          "should return empty counts for organization without applications",
          "should not include applications from other organizations",
          "should handle performance for large portfolios"
        ]
      }
    ],
    "factories": [
      {
        "path": "apps/ip-hub-backend/test/shared/factories/application.factory.ts",
        "entities": ["ApplicationEntity"],
        "status": "exists"
      },
      {
        "path": "apps/ip-hub-backend/test/shared/factories/user.factory.ts",
        "entities": ["UserEntity"],
        "status": "exists"
      }
    ]
  },
  "expectedFailures": {
    "unitTests": [
      "Cannot find module './get-dashboard-summary.handler' - handler not implemented",
      "Cannot find module './get-dashboard-summary.query' - query class not defined"
    ],
    "integrationTests": [
      "404 Not Found - GET /api/dashboard/summary endpoint not implemented"
    ]
  },
  "status": "red_tests_generated",
  "summary": "Generated 8 unit tests and 5 integration tests for Dashboard Summary scenario. All tests are expected to FAIL until backend implementation is complete.",
  "nextStep": "02-implement-backend-to-pass-tests",
  "implementationOrder": [
    "1. Create GetDashboardSummaryQuery class",
    "2. Create DashboardSummaryDto in api-contracts",
    "3. Create GetDashboardSummaryHandler",
    "4. Create DashboardModule",
    "5. Create DashboardController with GET /summary endpoint",
    "6. Register DashboardModule in AppModule"
  ]
}
```

---

## Verification Commands

```bash
# Run unit tests (should fail with module not found)
npx nx test ip-hub-backend --testPathPattern="dashboard.*handler.spec"

# Run integration tests (should fail with 404)
npx nx test ip-hub-backend --testPathPattern="integration/dashboard"

# TypeScript compilation check
npx tsc --noEmit

# Run all tests with verbose output
npx nx test ip-hub-backend --verbose
```

---

## Post-Generation Checklist

- [x] Query handler test covers all aggregation scenarios
- [x] Query handler test verifies organization filtering
- [x] Query handler test handles empty results
- [x] Integration test matches BDD scenario exactly (11 assets, counts by type)
- [x] Integration test verifies authentication requirement
- [x] Integration test verifies org isolation
- [x] Integration test includes performance assertion
- [x] Using existing ApplicationFactory and UserFactory
- [x] Expected failures documented with reasons
- [x] Implementation order specified
- [x] Tests use standard test UUIDs matching BDD step definitions

---

## TDD Red-Green-Refactor Summary

**Current State**: TDD Red (Unit and Integration tests generated, all failing)

**Next Steps**:
1. Run tests to confirm they fail for expected reasons
2. Implement query class
3. Implement handler (run unit tests - should pass)
4. Implement controller endpoint
5. Register module
6. Run integration tests (should pass)
7. Run BDD E2E tests (should pass - BDD Green)
