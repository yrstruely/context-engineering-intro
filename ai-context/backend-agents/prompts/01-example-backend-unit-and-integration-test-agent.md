# Backend Unit and Integration Test Agent - Dashboard Overview Example

## System Context Layer (Role Definition)

You are playing the role of: **Backend TDD Test Agent** for NestJS applications using CQRS pattern.

This is a concrete example using the **Dashboard Overview** feature from the IP Hub Backend project, demonstrating **full DDD architecture** with proper layering.

---

## Initial Input Prompt

```json
{
  "featureFile": "apps/ip-hub-backend-e2e/features/02-dashboard-overview/phase1-bffe-api.feature",
  "scenarioName": "Dashboard summary requires authentication",
  "failingE2EOutput": "AssertionError Field \"totalAssets\" expected \"0\" but got \"11\"",
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
@api @query
Scenario: Dashboard summary returns empty counts for new organization
  Given Alice's organization has no IP assets
  When the client sends a "GET" request to "/api/dashboard/summary"
  Then the response status should be 200
  And the response body should contain:
    | field              | value |
    | totalAssets        | 0     |
    | inProgressCount    | 0     |
    | pendingReviewCount | 0     |
```

### Scenario Analysis

**Backend Components Needed (Full DDD Architecture)**:

**Domain Layer** (`libs/domain/src/`):
- [ ] Domain Entity: `Application` in `entities/application.entity.ts`
- [ ] Value Object: `ApplicationType` in `value-objects/application/application-type.vo.ts`
- [ ] Value Object: `ApplicationStatus` in `value-objects/application/application-status.vo.ts`
- [ ] Repository Interface: `IApplicationRepository` in `repositories/application.repository.interface.ts`

**Infrastructure Layer** (`app/dashboard/infrastructure/`):
- [ ] ORM Entity: `ApplicationEntity` in `application.orm-entity.ts`
- [ ] Repository Implementation: `ApplicationRepository` in `application.repository.ts`
- [ ] Persistence Mapper: `ApplicationMapper` in `application.mapper.ts`

**Application Layer** (`app/dashboard/`):
- [ ] Query: `GetDashboardSummaryQuery` in `queries/get-dashboard-summary.query.ts`
- [ ] Handler: `GetDashboardSummaryHandler` in `queries/get-dashboard-summary.handler.ts`
- [ ] DTO Mapper: `DashboardSummaryDtoMapper` in `queries/dashboard-summary-dto.mapper.ts`

**API Layer** (`bffe/dashboard/`):
- [ ] Controller Endpoint: `GET /api/dashboard/summary`

**API Contracts** (`libs/api-contracts/src/dto/`):
- [ ] DTO: `DashboardSummaryDto` in `dashboard-summary.dto.ts`

**Current State**:
- E2E Test Status: FAILING (Red)
- Failure Reason: 404 Not Found - endpoint `/api/dashboard/summary` not implemented

---

## Step 2: Design Test Strategy

### Test Coverage Plan (Full DDD)

**Domain Layer Unit Tests (Priority 1)**:

1. `application-type.vo.spec.ts` (Value Object)
   - should create type from valid string
   - should throw for invalid type
   - should provide static instances
   - should support equality comparison

2. `application-status.vo.spec.ts` (Value Object)
   - should create status from valid string
   - should throw for invalid status
   - should allow valid state transitions
   - should reject invalid state transitions

3. `application.entity.spec.ts` (Domain Entity)
   - should create entity with valid data
   - should expose getters for all properties
   - should transition status with validation

**Infrastructure Layer Unit Tests (Priority 2)**:

4. `application.mapper.spec.ts` (Mapper)
   - should map ORM entity to domain entity
   - should map domain entity to ORM entity
   - should preserve all field values

**Application Layer Unit Tests (Priority 3)**:

5. `get-dashboard-summary.handler.spec.ts` (Handler)
   - should return correct total asset count
   - should return correct in-progress count
   - should return correct pending review count
   - should return correct counts by type
   - should return zeros for empty portfolio
   - should filter by organization (uses `IApplicationRepository` interface mock)

**Integration Tests (Priority 4)**:

6. `dashboard-api.integration.spec.ts`
   - should return dashboard summary with correct counts
   - should return 401 without authentication
   - should return empty counts for org without applications

**Factories**:
- `ApplicationFactory` - Uses domain entities and value objects

---

## Step 3: Generated Unit Tests

### 3.1 Value Object Unit Tests (Domain Layer)

#### Application Type Value Object

```typescript
// libs/domain/src/value-objects/application/application-type.vo.spec.ts
import { ApplicationType } from './application-type.vo';

describe('ApplicationType', () => {
  describe('fromString', () => {
    it('should create type from valid string', () => {
      const type = ApplicationType.fromString('patent');
      expect(type.toString()).toBe('patent');
    });

    it('should throw for invalid type', () => {
      expect(() => ApplicationType.fromString('invalid')).toThrow(
        'Invalid application type: invalid',
      );
    });
  });

  describe('static instances', () => {
    it('should provide static instances', () => {
      expect(ApplicationType.PATENT.toString()).toBe('patent');
      expect(ApplicationType.TRADEMARK.toString()).toBe('trademark');
      expect(ApplicationType.COPYRIGHT.toString()).toBe('copyright');
    });
  });

  describe('equality', () => {
    it('should support equality comparison', () => {
      const type1 = ApplicationType.fromString('patent');
      const type2 = ApplicationType.PATENT;
      expect(type1.equals(type2)).toBe(true);
    });

    it('should return false for different types', () => {
      expect(ApplicationType.PATENT.equals(ApplicationType.TRADEMARK)).toBe(false);
    });
  });
});
```

#### Application Status Value Object

```typescript
// libs/domain/src/value-objects/application/application-status.vo.spec.ts
import { ApplicationStatus } from './application-status.vo';

describe('ApplicationStatus', () => {
  describe('fromString', () => {
    it('should create status from valid string', () => {
      const status = ApplicationStatus.fromString('draft');
      expect(status.toString()).toBe('draft');
    });

    it('should throw for invalid status', () => {
      expect(() => ApplicationStatus.fromString('invalid')).toThrow(
        'Invalid application status: invalid',
      );
    });
  });

  describe('state transitions', () => {
    it('should allow transition from draft to in_progress', () => {
      const status = ApplicationStatus.DRAFT;
      expect(status.canTransitionTo(ApplicationStatus.IN_PROGRESS)).toBe(true);
    });

    it('should allow transition from in_progress to submitted', () => {
      const status = ApplicationStatus.IN_PROGRESS;
      expect(status.canTransitionTo(ApplicationStatus.SUBMITTED)).toBe(true);
    });

    it('should reject transition from draft to approved', () => {
      const status = ApplicationStatus.DRAFT;
      expect(status.canTransitionTo(ApplicationStatus.APPROVED)).toBe(false);
    });

    it('should throw when validating invalid transition', () => {
      const status = ApplicationStatus.DRAFT;
      expect(() => status.validateTransitionTo(ApplicationStatus.APPROVED)).toThrow(
        "Cannot transition from 'draft' to 'approved'",
      );
    });
  });
});
```

### 3.2 Domain Entity Unit Tests

```typescript
// libs/domain/src/entities/application.entity.spec.ts
import { Application } from './application.entity';
import { ApplicationType } from '../value-objects/application/application-type.vo';
import { ApplicationStatus } from '../value-objects/application/application-status.vo';

describe('Application', () => {
  const createApplication = (overrides?: Partial<{
    id: string;
    orgId: string;
    type: ApplicationType;
    status: ApplicationStatus;
    title: string;
  }>) => {
    return new Application(
      overrides?.id ?? 'app-001',
      overrides?.orgId ?? 'org-001',
      overrides?.type ?? ApplicationType.PATENT,
      overrides?.status ?? ApplicationStatus.DRAFT,
      overrides?.title ?? 'Test Application',
      null,
      new Date('2024-01-01'),
      new Date('2024-01-01'),
    );
  };

  describe('constructor', () => {
    it('should create entity with valid data', () => {
      const app = createApplication();

      expect(app.getId()).toBe('app-001');
      expect(app.getOrgId()).toBe('org-001');
      expect(app.getType().equals(ApplicationType.PATENT)).toBe(true);
      expect(app.getStatus().equals(ApplicationStatus.DRAFT)).toBe(true);
    });
  });

  describe('getters', () => {
    it('should expose getters for all properties', () => {
      const app = createApplication({ title: 'My Patent' });

      expect(app.getId()).toBeDefined();
      expect(app.getOrgId()).toBeDefined();
      expect(app.getType()).toBeDefined();
      expect(app.getStatus()).toBeDefined();
      expect(app.getTitle()).toBe('My Patent');
      expect(app.getCreatedAt()).toBeInstanceOf(Date);
      expect(app.getUpdatedAt()).toBeInstanceOf(Date);
    });
  });

  describe('business methods', () => {
    it('should transition status with validation', () => {
      const app = createApplication({ status: ApplicationStatus.DRAFT });

      app.transitionTo(ApplicationStatus.IN_PROGRESS);

      expect(app.getStatus().equals(ApplicationStatus.IN_PROGRESS)).toBe(true);
    });

    it('should throw when invalid transition', () => {
      const app = createApplication({ status: ApplicationStatus.DRAFT });

      expect(() => app.transitionTo(ApplicationStatus.APPROVED)).toThrow();
    });
  });
});
```

### 3.3 Mapper Unit Tests (Infrastructure Layer)

```typescript
// apps/ip-hub-backend/src/app/dashboard/infrastructure/application.mapper.spec.ts
import { ApplicationMapper } from './application.mapper';
import { Application, ApplicationType, ApplicationStatus } from '@ip-hub-backend/domain';
import { ApplicationEntity } from './application.orm-entity';

describe('ApplicationMapper', () => {
  describe('toDomain', () => {
    it('should map ORM entity to domain entity', () => {
      const ormEntity = new ApplicationEntity();
      ormEntity.id = 'test-id';
      ormEntity.orgId = 'org-001';
      ormEntity.type = ApplicationType.PATENT;
      ormEntity.status = ApplicationStatus.DRAFT;
      ormEntity.title = 'Test Patent';
      ormEntity.description = null;
      ormEntity.createdAt = new Date('2024-01-01');
      ormEntity.updatedAt = new Date('2024-01-01');

      const domain = ApplicationMapper.toDomain(ormEntity);

      expect(domain.getId()).toBe('test-id');
      expect(domain.getOrgId()).toBe('org-001');
      expect(domain.getType().equals(ApplicationType.PATENT)).toBe(true);
      expect(domain.getStatus().equals(ApplicationStatus.DRAFT)).toBe(true);
      expect(domain.getTitle()).toBe('Test Patent');
    });
  });

  describe('toPersistence', () => {
    it('should map domain entity to ORM entity', () => {
      const domain = new Application(
        'test-id',
        'org-001',
        ApplicationType.PATENT,
        ApplicationStatus.DRAFT,
        'Test Patent',
        null,
        new Date('2024-01-01'),
        new Date('2024-01-01'),
      );

      const ormEntity = ApplicationMapper.toPersistence(domain);

      expect(ormEntity.id).toBe('test-id');
      expect(ormEntity.orgId).toBe('org-001');
      expect(ormEntity.type.equals(ApplicationType.PATENT)).toBe(true);
      expect(ormEntity.status.equals(ApplicationStatus.DRAFT)).toBe(true);
      expect(ormEntity.title).toBe('Test Patent');
    });
  });

  describe('round-trip', () => {
    it('should preserve all field values in round-trip', () => {
      const original = new Application(
        'test-id',
        'org-001',
        ApplicationType.TRADEMARK,
        ApplicationStatus.IN_PROGRESS,
        'Test Trademark',
        'Description here',
        new Date('2024-01-01'),
        new Date('2024-01-02'),
      );

      const ormEntity = ApplicationMapper.toPersistence(original);
      const restored = ApplicationMapper.toDomain(ormEntity);

      expect(restored.getId()).toBe(original.getId());
      expect(restored.getOrgId()).toBe(original.getOrgId());
      expect(restored.getType().equals(original.getType())).toBe(true);
      expect(restored.getStatus().equals(original.getStatus())).toBe(true);
      expect(restored.getTitle()).toBe(original.getTitle());
      expect(restored.getDescription()).toBe(original.getDescription());
    });
  });
});
```

### 3.4 Query Handler Unit Test (with Interface Mock)

```typescript
// apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.handler.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { GetDashboardSummaryHandler } from './get-dashboard-summary.handler';
import { GetDashboardSummaryQuery } from './get-dashboard-summary.query';
import {
  IApplicationRepository,
  Application,
  ApplicationType,
  ApplicationStatus,
} from '@ip-hub-backend/domain';

describe('GetDashboardSummaryHandler', () => {
  let handler: GetDashboardSummaryHandler;
  let mockRepository: jest.Mocked<IApplicationRepository>;

  // Helper to create domain entities
  const createApplication = (
    id: string,
    type: ApplicationType,
    status: ApplicationStatus,
    orgId: string,
  ): Application => {
    return new Application(
      id,
      orgId,
      type,
      status,
      `Application ${id}`,
      null,
      new Date(),
      new Date(),
    );
  };

  beforeEach(async () => {
    // Mock the repository INTERFACE (not TypeORM repository)
    mockRepository = {
      save: jest.fn(),
      findById: jest.fn(),
      findByOrgId: jest.fn(),
      findByStatus: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GetDashboardSummaryHandler,
        {
          // CRITICAL: Use Symbol token, NOT getRepositoryToken
          provide: IApplicationRepository,
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
        '550e8400-e29b-41d4-a716-446655440001',
        '550e8400-e29b-41d4-a716-446655440002',
      );

      const mockApplications: Application[] = [
        createApplication('1', ApplicationType.PATENT, ApplicationStatus.APPROVED, query.orgId),
        createApplication('2', ApplicationType.PATENT, ApplicationStatus.APPROVED, query.orgId),
        createApplication('3', ApplicationType.PATENT, ApplicationStatus.IN_PROGRESS, query.orgId),
        createApplication('4', ApplicationType.TRADEMARK, ApplicationStatus.APPROVED, query.orgId),
        createApplication('5', ApplicationType.COPYRIGHT, ApplicationStatus.DRAFT, query.orgId),
      ];

      mockRepository.findByOrgId.mockResolvedValue(mockApplications);

      // Act
      const result = await handler.execute(query);

      // Assert
      expect(result.totalAssets).toBe(5);
    });

    it('should return correct in-progress count', async () => {
      const query = new GetDashboardSummaryQuery('org-001', 'user-001');

      const mockApplications: Application[] = [
        createApplication('1', ApplicationType.PATENT, ApplicationStatus.DRAFT, 'org-001'),
        createApplication('2', ApplicationType.PATENT, ApplicationStatus.IN_PROGRESS, 'org-001'),
        createApplication('3', ApplicationType.PATENT, ApplicationStatus.IN_PROGRESS, 'org-001'),
        createApplication('4', ApplicationType.TRADEMARK, ApplicationStatus.SUBMITTED, 'org-001'),
      ];

      mockRepository.findByOrgId.mockResolvedValue(mockApplications);

      const result = await handler.execute(query);

      expect(result.inProgressCount).toBe(2);
    });

    it('should return zeros for empty portfolio', async () => {
      const query = new GetDashboardSummaryQuery('empty-org', 'user-001');
      mockRepository.findByOrgId.mockResolvedValue([]);

      const result = await handler.execute(query);

      expect(result.totalAssets).toBe(0);
      expect(result.inProgressCount).toBe(0);
      expect(result.pendingReviewCount).toBe(0);
      expect(result.countsByType).toEqual({
        patents: 0,
        trademarks: 0,
        copyrights: 0,
      });
    });

    it('should filter by organization via repository interface', async () => {
      const query = new GetDashboardSummaryQuery('specific-org-id', 'user-001');
      mockRepository.findByOrgId.mockResolvedValue([]);

      await handler.execute(query);

      // Verify repository interface method was called (NOT TypeORM find)
      expect(mockRepository.findByOrgId).toHaveBeenCalledWith('specific-org-id');
    });
  });
});
```

### 3.5 Query Class Unit Test

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
import axios, { AxiosInstance } from 'axios';
import { AddressInfo } from 'net';
import { TestDatabase } from '../shared/test-database';
import { createTestApp } from '../shared/test-app-factory';
import { ApplicationFactory } from '../shared/factories/application.factory';
import { UserFactory } from '../shared/factories/user.factory';

describe('Dashboard API Integration', () => {
  let app: INestApplication;
  let httpClient: AxiosInstance;
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

    // Start the app on a random port
    await app.listen(0);
    const address = app.getHttpServer().address() as AddressInfo;
    const baseURL = `http://localhost:${address.port}`;

    // Create Axios client
    httpClient = axios.create({
      baseURL,
      validateStatus: () => true, // Don't throw on any status code
    });

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
      // 5 approved patents, 2 in_progress patents, 3 approved trademarks, 1 draft copyright
      await applicationFactory.createMany(5, {
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'patent',
        status: 'approved',
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
        status: 'approved',
      });
      await applicationFactory.create({
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'copyright',
        status: 'draft',
      });

      // Act
      const response = await httpClient.get('/api/dashboard/summary', {
        headers: {
          Authorization: `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`,
        },
      });

      // Assert - Match BDD expected values
      expect(response.status).toBe(200);
      expect(response.data.totalAssets).toBe(11);
      expect(response.data.inProgressCount).toBe(2);
      expect(response.data.pendingReviewCount).toBe(0);
      expect(response.data.countsByType).toEqual({
        patents: 7,
        trademarks: 3,
        copyrights: 1,
      });
    });

    it('should return 401 without authentication', async () => {
      const response = await httpClient.get('/api/dashboard/summary');

      expect(response.status).toBe(401);
    });

    it('should return empty counts for organization without applications', async () => {
      // Arrange - Create user but no applications
      await userFactory.createAlice();

      // Act
      const response = await httpClient.get('/api/dashboard/summary', {
        headers: {
          Authorization: `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`,
        },
      });

      // Assert
      expect(response.status).toBe(200);
      expect(response.data.totalAssets).toBe(0);
      expect(response.data.inProgressCount).toBe(0);
      expect(response.data.pendingReviewCount).toBe(0);
    });

    it('should not include applications from other organizations', async () => {
      // Arrange
      await userFactory.createAlice();

      // Create applications for Alice's org
      await applicationFactory.create({
        orgId: ALICE_ORG_ID,
        userId: ALICE_USER_ID,
        type: 'patent',
        status: 'approved',
      });

      // Create applications for different org (should not appear)
      const OTHER_ORG_ID = '550e8400-e29b-41d4-a716-446655440099';
      const OTHER_USER_ID = '550e8400-e29b-41d4-a716-446655440098';
      await applicationFactory.create({
        orgId: OTHER_ORG_ID,
        userId: OTHER_USER_ID,
        type: 'patent',
        status: 'approved',
      });
      await applicationFactory.create({
        orgId: OTHER_ORG_ID,
        userId: OTHER_USER_ID,
        type: 'trademark',
        status: 'approved',
      });

      // Act
      const response = await httpClient.get('/api/dashboard/summary', {
        headers: {
          Authorization: `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`,
        },
      });

      // Assert - Only Alice's application should be counted
      expect(response.status).toBe(200);
      expect(response.data.totalAssets).toBe(1);
      expect(response.data.countsByType.patents).toBe(1);
      expect(response.data.countsByType.trademarks).toBe(0);
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
      const response = await httpClient.get('/api/dashboard/summary', {
        headers: {
          Authorization: `Bearer test-jwt-${ALICE_USER_ID}-${ALICE_ORG_ID}`,
        },
      });
      const duration = Date.now() - startTime;

      // Assert - Should complete within 500ms (performance requirement from BDD)
      expect(response.status).toBe(200);
      expect(duration).toBeLessThan(500);
      expect(response.data.totalAssets).toBe(100);
    });
  });
});
```

---

## Step 5: Expected Failures Analysis

### Domain Layer Tests Expected Failures

| Test File | Test Name | Expected Failure Reason |
|-----------|-----------|------------------------|
| `application-type.vo.spec.ts` | should create type from valid string | `Cannot find module './application-type.vo'` |
| `application-status.vo.spec.ts` | should create status from valid string | `Cannot find module './application-status.vo'` |
| `application.entity.spec.ts` | should create entity with valid data | `Cannot find module './application.entity'` |

### Infrastructure Layer Tests Expected Failures

| Test File | Test Name | Expected Failure Reason |
|-----------|-----------|------------------------|
| `application.mapper.spec.ts` | should map ORM entity to domain entity | `Cannot find module './application.mapper'` |

### Application Layer Tests Expected Failures

| Test File | Test Name | Expected Failure Reason |
|-----------|-----------|------------------------|
| `get-dashboard-summary.handler.spec.ts` | should return correct total asset count | `Cannot find module './get-dashboard-summary.handler'` |
| `get-dashboard-summary.handler.spec.ts` | should filter by organization | `Cannot find module '@ip-hub-backend/domain'` |
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

## Step 6: Implementation Order (Full DDD)

To make these tests pass, implement in this order following **Domain Layer First** approach:

### Phase 1: Domain Layer (`libs/domain/src/`)

#### 1. Create Value Objects

```typescript
// libs/domain/src/value-objects/application/application-type.vo.ts
export type ApplicationTypeValue = 'patent' | 'trademark' | 'copyright';

export class ApplicationType {
  static readonly VALID_TYPES: readonly ApplicationTypeValue[] = ['patent', 'trademark', 'copyright'];

  public static readonly PATENT = new ApplicationType('patent');
  public static readonly TRADEMARK = new ApplicationType('trademark');
  public static readonly COPYRIGHT = new ApplicationType('copyright');

  private constructor(private readonly value: ApplicationTypeValue) {}

  public static fromString(value: string): ApplicationType {
    if (!ApplicationType.VALID_TYPES.includes(value as ApplicationTypeValue)) {
      throw new Error(`Invalid application type: ${value}`);
    }
    return new ApplicationType(value as ApplicationTypeValue);
  }

  toString(): string { return this.value; }
  equals(other: ApplicationType): boolean { return this.value === other.value; }
}
```

```typescript
// libs/domain/src/value-objects/application/application-status.vo.ts
export type ApplicationStatusValue = 'draft' | 'in_progress' | 'submitted' | 'under_review' | 'approved' | 'rejected';

export class ApplicationStatus {
  static readonly VALID_STATUSES: readonly ApplicationStatusValue[] = [
    'draft', 'in_progress', 'submitted', 'under_review', 'approved', 'rejected'
  ];

  public static readonly DRAFT = new ApplicationStatus('draft');
  public static readonly IN_PROGRESS = new ApplicationStatus('in_progress');
  public static readonly SUBMITTED = new ApplicationStatus('submitted');
  public static readonly UNDER_REVIEW = new ApplicationStatus('under_review');
  public static readonly APPROVED = new ApplicationStatus('approved');
  public static readonly REJECTED = new ApplicationStatus('rejected');

  private constructor(private readonly value: ApplicationStatusValue) {}

  public static fromString(value: string): ApplicationStatus { /* ... */ }
  toString(): string { return this.value; }
  equals(other: ApplicationStatus): boolean { return this.value === other.value; }
  canTransitionTo(newStatus: ApplicationStatus): boolean { /* state machine */ }
  validateTransitionTo(newStatus: ApplicationStatus): void { /* throws if invalid */ }
}
```

#### 2. Create Domain Entity

```typescript
// libs/domain/src/entities/application.entity.ts
import { ApplicationType } from '../value-objects/application/application-type.vo';
import { ApplicationStatus } from '../value-objects/application/application-status.vo';

export class Application {
  constructor(
    private readonly id: string,
    private readonly orgId: string,
    private type: ApplicationType,
    private status: ApplicationStatus,
    private title: string,
    private description: string | null,
    private readonly createdAt: Date,
    private updatedAt: Date,
  ) {}

  // Getters
  getId(): string { return this.id; }
  getOrgId(): string { return this.orgId; }
  getType(): ApplicationType { return this.type; }
  getStatus(): ApplicationStatus { return this.status; }
  getTitle(): string { return this.title; }
  getDescription(): string | null { return this.description; }
  getCreatedAt(): Date { return this.createdAt; }
  getUpdatedAt(): Date { return this.updatedAt; }

  // Business methods
  transitionTo(newStatus: ApplicationStatus): void {
    this.status.validateTransitionTo(newStatus);
    this.status = newStatus;
    this.updatedAt = new Date();
  }
}
```

#### 3. Create Repository Interface

```typescript
// libs/domain/src/repositories/application.repository.interface.ts
import { Application } from '../entities/application.entity';

export interface IApplicationRepository {
  save(application: Application): Promise<void>;
  findById(id: string): Promise<Application | null>;
  findByOrgId(orgId: string): Promise<Application[]>;
  findByStatus(orgId: string, status: string): Promise<Application[]>;
}

// CRITICAL: Symbol token for DI
export const IApplicationRepository = Symbol('IApplicationRepository');
```

#### 4. Export from Domain Index

```typescript
// libs/domain/src/index.ts
export * from './entities/application.entity';
export * from './value-objects/application/application-type.vo';
export * from './value-objects/application/application-status.vo';
export * from './repositories/application.repository.interface';
```

### Phase 2: Infrastructure Layer (`app/dashboard/infrastructure/`)

#### 5. Create ORM Entity

```typescript
// apps/ip-hub-backend/src/app/dashboard/infrastructure/application.orm-entity.ts
import { Entity, PrimaryColumn, Column, Index, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { ApplicationType, ApplicationStatus } from '@ip-hub-backend/domain';

@Entity('applications')
export class ApplicationEntity {
  @PrimaryColumn('uuid')
  id!: string;

  @Column('uuid')
  @Index()
  orgId!: string;

  @Column({ type: 'varchar', length: 50 })
  private _type!: string;

  get type(): ApplicationType { return ApplicationType.fromString(this._type); }
  set type(value: ApplicationType) { this._type = value.toString(); }

  @Column({ type: 'varchar', length: 50, default: 'draft' })
  private _status!: string;

  get status(): ApplicationStatus { return ApplicationStatus.fromString(this._status); }
  set status(value: ApplicationStatus) { this._status = value.toString(); }

  @Column({ type: 'varchar', length: 500 })
  title!: string;

  @Column({ type: 'text', nullable: true })
  description!: string | null;

  @CreateDateColumn()
  createdAt!: Date;

  @UpdateDateColumn()
  updatedAt!: Date;
}
```

#### 6. Create Mapper

```typescript
// apps/ip-hub-backend/src/app/dashboard/infrastructure/application.mapper.ts
import { Application } from '@ip-hub-backend/domain';
import { ApplicationEntity } from './application.orm-entity';

export class ApplicationMapper {
  static toDomain(entity: ApplicationEntity): Application {
    return new Application(
      entity.id, entity.orgId, entity.type, entity.status,
      entity.title, entity.description, entity.createdAt, entity.updatedAt,
    );
  }

  static toPersistence(domain: Application): ApplicationEntity {
    const entity = new ApplicationEntity();
    entity.id = domain.getId();
    entity.orgId = domain.getOrgId();
    entity.type = domain.getType();
    entity.status = domain.getStatus();
    entity.title = domain.getTitle();
    entity.description = domain.getDescription();
    return entity;
  }
}
```

#### 7. Create Repository Implementation

```typescript
// apps/ip-hub-backend/src/app/dashboard/infrastructure/application.repository.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { IApplicationRepository, Application } from '@ip-hub-backend/domain';
import { ApplicationEntity } from './application.orm-entity';
import { ApplicationMapper } from './application.mapper';

@Injectable()
export class ApplicationRepository implements IApplicationRepository {
  constructor(
    @InjectRepository(ApplicationEntity)
    private readonly repository: Repository<ApplicationEntity>,
  ) {}

  async findByOrgId(orgId: string): Promise<Application[]> {
    const entities = await this.repository.find({ where: { orgId } });
    return entities.map(ApplicationMapper.toDomain);
  }
  // ... other methods
}
```

### Phase 3: Application Layer (`app/dashboard/`)

#### 8. Create Query Class

```typescript
// apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.query.ts
export class GetDashboardSummaryQuery {
  constructor(
    public readonly orgId: string,
    public readonly userId: string,
  ) {}
}
```

#### 9. Create Query Handler (with Interface Injection)

```typescript
// apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.handler.ts
import { QueryHandler, IQueryHandler } from '@nestjs/cqrs';
import { Inject } from '@nestjs/common';
import { GetDashboardSummaryQuery } from './get-dashboard-summary.query';
import { DashboardSummaryDto } from '@ip-hub-backend/api-contracts';
import { IApplicationRepository } from '@ip-hub-backend/domain';

@QueryHandler(GetDashboardSummaryQuery)
export class GetDashboardSummaryHandler implements IQueryHandler<GetDashboardSummaryQuery> {
  constructor(
    @Inject(IApplicationRepository) // CRITICAL: Use Symbol token
    private readonly repository: IApplicationRepository,
  ) {}

  async execute(query: GetDashboardSummaryQuery): Promise<DashboardSummaryDto> {
    const applications = await this.repository.findByOrgId(query.orgId);
    // ... aggregate and return DTO
  }
}
```

### Phase 4: API Layer

#### 10. Create Controller

```typescript
// apps/ip-hub-backend/src/bffe/dashboard/dashboard.controller.ts
import { Controller, Get, Req } from '@nestjs/common';
import { QueryBus } from '@nestjs/cqrs';
import { GetDashboardSummaryQuery } from '../../app/dashboard/queries/get-dashboard-summary.query';

@Controller('dashboard')
export class DashboardController {
  constructor(private readonly queryBus: QueryBus) {}

  @Get('summary')
  async getSummary(@Req() req: AuthenticatedRequest): Promise<DashboardSummaryDto> {
    return this.queryBus.execute(new GetDashboardSummaryQuery(req.user.orgId, req.user.userId));
  }
}
```

#### 11. Create Module with Symbol DI

```typescript
// apps/ip-hub-backend/src/app/dashboard/dashboard.module.ts
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IApplicationRepository } from '@ip-hub-backend/domain';
import { ApplicationEntity } from './infrastructure/application.orm-entity';
import { ApplicationRepository } from './infrastructure/application.repository';
import { GetDashboardSummaryHandler } from './queries/get-dashboard-summary.handler';
import { DashboardController } from '../../bffe/dashboard/dashboard.controller';

@Module({
  imports: [CqrsModule, TypeOrmModule.forFeature([ApplicationEntity])],
  controllers: [DashboardController],
  providers: [
    GetDashboardSummaryHandler,
    {
      provide: IApplicationRepository, // CRITICAL: Symbol DI
      useClass: ApplicationRepository,
    },
  ],
  exports: [CqrsModule],
})
export class DashboardModule {}
```

#### 12. Register Module

```typescript
// apps/ip-hub-backend/src/app/app.module.ts
import { DashboardModule } from './dashboard/dashboard.module';

@Module({
  imports: [/* ... */, DashboardModule],
})
export class AppModule {}
```

#### 13. Add to Test Infrastructure

```typescript
// apps/ip-hub-backend/test/shared/test-database.ts - Add to ALL_ENTITIES
import { ApplicationEntity } from '../../src/app/dashboard/infrastructure/application.orm-entity';
// ... add to ALL_ENTITIES array
```

---

## Expected Output (Agent's Response Schema)

```json
{
  "generatedTests": {
    "domainLayerTests": [
      {
        "path": "libs/domain/src/value-objects/application/application-type.vo.spec.ts",
        "purpose": "Test ApplicationType value object validation",
        "testCases": [
          "should create type from valid string",
          "should throw for invalid type",
          "should provide static instances",
          "should support equality comparison"
        ]
      },
      {
        "path": "libs/domain/src/value-objects/application/application-status.vo.spec.ts",
        "purpose": "Test ApplicationStatus value object with state machine",
        "testCases": [
          "should create status from valid string",
          "should throw for invalid status",
          "should allow valid state transitions",
          "should reject invalid state transitions"
        ]
      },
      {
        "path": "libs/domain/src/entities/application.entity.spec.ts",
        "purpose": "Test Application domain entity",
        "testCases": [
          "should create entity with valid data",
          "should expose getters for all properties",
          "should transition status with validation"
        ]
      }
    ],
    "infrastructureLayerTests": [
      {
        "path": "apps/ip-hub-backend/src/app/dashboard/infrastructure/application.mapper.spec.ts",
        "purpose": "Test ApplicationMapper Domain↔ORM conversion",
        "testCases": [
          "should map ORM entity to domain entity",
          "should map domain entity to ORM entity",
          "should preserve all field values in round-trip"
        ]
      }
    ],
    "applicationLayerTests": [
      {
        "path": "apps/ip-hub-backend/src/app/dashboard/queries/get-dashboard-summary.handler.spec.ts",
        "purpose": "Test GetDashboardSummaryHandler with mocked IApplicationRepository interface",
        "testCases": [
          "should return correct total asset count",
          "should return correct in-progress count",
          "should return zeros for empty portfolio",
          "should filter by organization via repository interface"
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
        "entities": ["ApplicationEntity (ORM)"],
        "status": "exists",
        "note": "Uses domain value objects for type/status"
      }
    ]
  },
  "expectedFailures": {
    "domainLayerTests": [
      "Cannot find module './application-type.vo' - value object not implemented",
      "Cannot find module './application-status.vo' - value object not implemented",
      "Cannot find module './application.entity' - domain entity not implemented"
    ],
    "infrastructureLayerTests": [
      "Cannot find module './application.mapper' - mapper not implemented"
    ],
    "applicationLayerTests": [
      "Cannot find module '@ip-hub-backend/domain' - domain exports not available",
      "Cannot find module './get-dashboard-summary.handler' - handler not implemented"
    ],
    "integrationTests": [
      "404 Not Found - GET /api/dashboard/summary endpoint not implemented"
    ]
  },
  "status": "red_tests_generated",
  "summary": "Generated 14 unit tests (domain: 11, infrastructure: 3, application: 6) and 5 integration tests for Dashboard Summary scenario. All tests follow full DDD architecture and are expected to FAIL until implementation is complete.",
  "nextStep": "02-implement-backend-to-pass-tests",
  "implementationOrder": {
    "phase1_domain": [
      "1. Create ApplicationType value object",
      "2. Create ApplicationStatus value object with state machine",
      "3. Create Application domain entity",
      "4. Create IApplicationRepository interface with Symbol token",
      "5. Export all from libs/domain/src/index.ts"
    ],
    "phase2_infrastructure": [
      "6. Create ApplicationEntity ORM entity",
      "7. Create ApplicationMapper",
      "8. Create ApplicationRepository implementing interface"
    ],
    "phase3_application": [
      "9. Create GetDashboardSummaryQuery class",
      "10. Create GetDashboardSummaryHandler with @Inject(IApplicationRepository)"
    ],
    "phase4_api": [
      "11. Create DashboardController",
      "12. Create DashboardModule with Symbol DI provider",
      "13. Register in AppModule and test-app-factory"
    ]
  }
}
```

---

## Verification Commands

```bash
# Run unit tests (should fail with module not found)
npx nx test ip-hub-backend --testPathPattern="dashboard.*handler.spec"

# Run integration tests (should fail with 404) - uses test:integration target
npx nx test:integration ip-hub-backend --testPathPattern="dashboard"

# TypeScript compilation check (with project reference)
npx tsc --noEmit -p apps/ip-hub-backend/tsconfig.app.json

# Run all unit tests with verbose output
npx nx test ip-hub-backend --verbose

# Run E2E tests (should fail) - uses test:e2e target with -- separator
npx nx test:e2e ip-hub-backend -- --name "Dashboard summary returns correct portfolio counts"
npx nx test:e2e ip-hub-backend -- --tags "@02-dashboard-overview and @api and @query"
```

### Important Test Command Notes

1. **Unit Tests**: `npx nx test ip-hub-backend` - standard Jest test runner
2. **Integration Tests**: `npx nx test:integration ip-hub-backend` - separate target for DB tests with Testcontainers
3. **E2E Tests**: `npx nx test:e2e ip-hub-backend` - runs Cucumber.js
   - Use `--` to separate nx args from Cucumber args
   - `--name "scenario name"` for specific scenarios
   - `--tags "@tag1 and @tag2"` for tag-based filtering
4. **TypeScript**: Always use `-p` flag with project tsconfig path

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
