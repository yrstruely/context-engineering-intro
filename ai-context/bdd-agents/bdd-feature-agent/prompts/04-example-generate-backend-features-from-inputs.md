# BDD Backend Feature Agent - Generate Backend Features from Frontend Specs

## Purpose

Generate backend-focused BDD feature files that complement frontend feature files. Backend features focus on:
1. **BFFE API behavior** - Testing the Backend-For-Frontend layer via HTTP/axios calls
2. **CQRS operations** - Commands that mutate state and queries that read data
3. **Domain events** - Event emission, handling, and cross-context communication
4. **Service-to-service interactions** - Core service orchestration and event-driven workflows
5. **Non-functional requirements** - Performance, security, reliability, and compliance

## Example Input Prompt

```json
{
  "specContext": "specs/02-dashboard-overview",
  "task": "04-generate-backend-features-from-inputs",
  "outputDirectory": "specs/02-dashboard-overview/backend/",
  "frontendFeatures": [
    "specs/02-dashboard-overview/phase1-core-dashboard-overview.feature",
    "specs/02-dashboard-overview/phase2-enhanced-dashboard-overview.feature"
  ],
  "specPackFiles": {
    "bffeSpec": "specs/02-dashboard-overview/bffe-spec.md",
    "cqrsContract": "specs/02-dashboard-overview/cqrs-contract.md",
    "coreServicesSpec": "specs/02-dashboard-overview/core-services-spec.md",
    "nonFunctionalRequirements": "specs/02-dashboard-overview/non-functional-requirements.md"
  },
  "domainModelDocs": "docs/domain-model-specification/",
  "userPersonas": "specs/user-types-and-personas/user-types-and-personas.md",
  "contextFile": "workflow-context/bdd-agents/bdd-feature-agent/bdd-agent-context.md"
}
```

## Agent Context

You are playing the role of: **BDD Backend Feature Agent** for generating backend-focused Gherkin feature files. Your focus is on the API layer, CQRS operations, domain events, and non-functional requirements - NOT the frontend UI.

Use the instructions in `workflow-context/bdd-agents/bdd-feature-agent/bdd-agent-context.md` as your foundation, but adapt the output for backend testing scenarios.

## BDD Backend Feature Agent Behavior (Step-by-Step)

### 1. Review Agent Context and Spec Pack

- Read the BDD agent context file for Gherkin best practices
- Read all spec pack files:
  - **bffe-spec.md** - OpenAPI specification for BFFE endpoints
  - **cqrs-contract.md** - Commands, queries, and domain events
  - **core-services-spec.md** - Core service YAML definitions
  - **non-functional-requirements.md** - Performance, security, accessibility requirements

### 2. Analyze Frontend Features for Backend Coverage

- Review existing frontend feature files
- Extract the **implied backend behavior** from frontend scenarios
- Identify which BFFE endpoints support each frontend scenario
- Map frontend scenarios to CQRS commands and queries
- Identify domain events that should be emitted

### 3. Generate Backend Feature Categories

Create separate feature files for each category:

#### A. BFFE API Features
Test the Backend-For-Frontend API layer using HTTP calls (axios):
- Request/response validation
- Authentication and authorization
- Error handling and status codes
- API versioning and compatibility

#### B. CQRS Command Features
Test state-changing operations:
- Command validation and preconditions
- Domain event emission
- Error handling and invariants
- Idempotency where applicable

#### C. CQRS Query Features
Test read operations:
- Query response structure
- Filtering and pagination
- Read model consistency
- Performance under load

#### D. Domain Event Features
Test event-driven behavior:
- Event emission on state changes
- Event handler subscriptions
- Cross-context event communication
- Event ordering and reliability

#### E. Non-Functional Requirement Features
Test quality attributes:
- Performance (response times, throughput)
- Security (authentication, authorization, input validation)
- Reliability (error handling, graceful degradation)
- Compliance (audit logging, data protection)

### 4. Apply Backend-Specific Gherkin Patterns

#### Backend Scenario Structure

```gherkin
# Backend scenarios use API-centric language
@backend @api
Scenario: Dashboard summary API returns portfolio statistics
  Given Alice is an authenticated user with userId "user-123"
  And Alice's organization "org-456" has the following IP assets:
    | type      | status      | count |
    | patent    | active      | 5     |
    | trademark | in_progress | 3     |
    | copyright | active      | 2     |
  When the client sends a GET request to "/dashboard/summary"
  Then the response status should be 200
  And the response body should contain:
    | field           | value |
    | totalAssets     | 10    |
    | inProgressCount | 3     |

@backend @event
Scenario: PatentApplicationDrafted event is emitted when creating a patent
  Given Alice is an authenticated user with permission to create patent applications
  And no patent application exists with the provided details
  When the client sends a POST request to "/actions/register" with:
    | type   | patent                     |
    | title  | AI-Powered Search System   |
  Then the response status should be 201
  And a "PatentApplicationDrafted" event should be emitted with:
    | applicationId | <newly_created_id> |
    | actorId       | <alice_user_id>    |
```

### 5. Tag Strategy for Backend Features

| Tag | Purpose | Usage |
|-----|---------|-------|
| `@backend` | All backend tests | Apply to all backend scenarios |
| `@api` | BFFE API tests | HTTP endpoint tests |
| `@command` | CQRS command tests | State-changing operations |
| `@query` | CQRS query tests | Read operations |
| `@event` | Domain event tests | Event emission/handling |
| `@integration` | Cross-service tests | Service orchestration |
| `@performance` | Performance tests | Response time, throughput |
| `@security` | Security tests | Auth, authz, input validation |
| `@non-functional` | Non-functional requirements | Quality attribute tests |

### 6. Map Frontend to Backend Scenarios

For each frontend scenario, identify the corresponding backend behavior:

| Frontend Scenario | Backend Coverage |
|-------------------|------------------|
| "User views dashboard after login" | GET /dashboard/summary API, GetPortfolioSummary query |
| "User dismisses alert notification" | POST /alerts/{id}/dismiss API, DismissNotification command, NotificationDismissed event |
| "User creates a new patent application" | POST /actions/register API, DraftPatentApplication command, PatentApplicationDrafted event |

---

## Example Output: Dashboard Overview Backend Features

### File: `specs/02-dashboard-overview/backend/phase1-bffe-api.feature`

```gherkin
# specs/02-dashboard-overview/backend/phase1-bffe-api.feature
@02-dashboard-overview @backend @api
Feature: Dashboard BFFE API - Core Endpoints (Phase 1)
  In order to provide dashboard data to the frontend
  As the IP Hub backend system
  I want to expose well-defined API endpoints that aggregate core service data

  The Dashboard BFFE orchestrates multiple core services to provide
  a unified API for the frontend dashboard, handling portfolio statistics,
  alerts, applications in progress, and quick actions.

  Background:
    Given the IP Hub backend services are running
    And the test database is seeded with standard test data
    And Alice is an authenticated user with a valid JWT token
    And Alice belongs to organization "org-dff-001"

  Rule: Dashboard Summary API provides portfolio statistics

    @api @query @smoke
    Scenario: Dashboard summary returns correct portfolio counts
      Given Alice's organization has the following IP assets:
        | type      | status      | count |
        | patent    | active      | 5     |
        | patent    | in_progress | 2     |
        | trademark | active      | 3     |
        | copyright | draft       | 1     |
      When the client sends a GET request to "/dashboard/summary"
      Then the response status should be 200
      And the response body should contain:
        | field              | value |
        | totalAssets        | 11    |
        | inProgressCount    | 3     |
        | pendingReviewCount | 0     |
      And the response body "countsByType" should contain:
        | patents    | 7 |
        | trademarks | 3 |
        | copyrights | 1 |

    @api @query
    Scenario: Dashboard summary returns empty counts for new organization
      Given Alice's organization has no IP assets
      When the client sends a GET request to "/dashboard/summary"
      Then the response status should be 200
      And the response body should contain:
        | field              | value |
        | totalAssets        | 0     |
        | inProgressCount    | 0     |
        | pendingReviewCount | 0     |

    @api @security
    Scenario: Dashboard summary requires authentication
      Given the client has no authentication token
      When the client sends a GET request to "/dashboard/summary"
      Then the response status should be 401
      And the response body should contain an error message "Authentication required"

    @api @security
    Scenario: Dashboard summary only returns data for user's organization
      Given Alice's organization has 5 IP assets
      And another organization "org-other-002" has 10 IP assets
      When the client sends a GET request to "/dashboard/summary"
      Then the response status should be 200
      And the response body "totalAssets" should be 5
      # Alice should not see assets from other organizations

  Rule: Alerts API provides urgent notifications

    @api @query
    Scenario: Alerts API returns approaching deadlines
      Given Alice has the following alerts:
        | type           | severity | message                          | daysRemaining |
        | office_action  | high     | Office action deadline in 14 days| 14            |
        | renewal        | medium   | Renewal deadline in 45 days      | 45            |
      When the client sends a GET request to "/dashboard/alerts"
      Then the response status should be 200
      And the response body should contain 2 alerts
      And the alerts should be ordered by severity descending

    @api @query
    Scenario: Alerts API filters by days remaining
      Given Alice has alerts with deadlines at 10, 30, and 60 days
      When the client sends a GET request to "/dashboard/alerts?withinDays=30"
      Then the response status should be 200
      And the response body should contain 2 alerts

    @api @query
    Scenario: Alerts API returns empty array when no alerts
      Given Alice has no pending alerts
      When the client sends a GET request to "/dashboard/alerts"
      Then the response status should be 200
      And the response body should be an empty array

  Rule: Applications In Progress API provides active application tracking

    @api @query
    Scenario: Applications API returns applications with progress
      Given Alice has the following applications in progress:
        | type      | name                    | status      | progressPct |
        | patent    | AI Search Algorithm     | in_progress | 60          |
        | trademark | IP Hub Brand            | submitted   | 100         |
        | patent    | Quantum Computing Method| draft       | 25          |
      When the client sends a GET request to "/dashboard/applications-in-progress"
      Then the response status should be 200
      And the response body should contain 3 applications
      And each application should have fields:
        | field       |
        | applicationId |
        | type        |
        | name        |
        | status      |
        | progressPct |
        | updatedAt   |

    @api @query
    Scenario: Applications API filters by type
      Given Alice has 2 patent applications and 1 trademark application
      When the client sends a GET request to "/dashboard/applications-in-progress?type=patent"
      Then the response status should be 200
      And the response body should contain 2 applications
      And all applications should have type "patent"

    @api @query
    Scenario: Applications API filters by status
      Given Alice has 1 draft and 2 in_progress applications
      When the client sends a GET request to "/dashboard/applications-in-progress?status=in_progress"
      Then the response status should be 200
      And the response body should contain 2 applications

  Rule: Quick Actions API handles application creation

    @api @command
    Scenario: Register new patent application creates draft
      Given Alice has permission to create patent applications
      When the client sends a POST request to "/actions/register" with:
        """json
        {
          "type": "patent",
          "payload": {
            "title": "AI-Powered Document Analysis System",
            "description": "A system for analyzing legal documents using AI"
          }
        }
        """
      Then the response status should be 201
      And the response body should contain:
        | field         | value     |
        | applicationId | <uuid>    |
      And the application should exist in the database with status "draft"

    @api @command
    Scenario: Register application validates required fields
      Given Alice has permission to create applications
      When the client sends a POST request to "/actions/register" with:
        """json
        {
          "type": "patent",
          "payload": {}
        }
        """
      Then the response status should be 400
      And the response body should contain validation errors

    @api @security
    Scenario: Register application requires permission
      Given Alice does not have permission to create patent applications
      When the client sends a POST request to "/actions/register" with type "patent"
      Then the response status should be 403
      And the response body should contain error "Insufficient permissions"

# Gaps Identified (requires clarification):
# 1. Rate Limiting - What are the rate limits for dashboard API endpoints?
# 2. Caching - Should dashboard summary be cached? What's the TTL?
# 3. Pagination - How should applications-in-progress handle large portfolios?
# 4. Sorting - What are the default and available sort options?
# 5. Error Codes - Should we use standard HTTP codes or custom error codes?
```

### File: `specs/02-dashboard-overview/backend/phase1-cqrs-commands.feature`

```gherkin
# specs/02-dashboard-overview/backend/phase1-cqrs-commands.feature
@02-dashboard-overview @backend @command
Feature: Dashboard CQRS Commands (Phase 1)
  In order to maintain consistent application state
  As the IP Hub backend system
  I want to execute validated commands that emit domain events

  Commands represent intentions to change state. Each command is validated,
  executed atomically, and emits domain events for downstream processing.

  Background:
    Given the CQRS command infrastructure is running
    And the event bus is available
    And Alice is an authenticated user with userId "user-alice-001"
    And Alice belongs to organization "org-dff-001"

  Rule: DraftPatentApplication command creates new patent applications

    @command @event
    Scenario: DraftPatentApplication command succeeds with valid payload
      Given Alice has permission to create patent applications
      When the DraftPatentApplication command is executed with:
        | orgId       | org-dff-001                      |
        | initiatorId | user-alice-001                   |
        | title       | AI-Powered Search System         |
        | description | A novel search algorithm using AI|
      Then the command should succeed
      And a new patent application should be created with status "Draft"
      And a "PatentApplicationDrafted" event should be emitted with:
        | applicationId | <newly_created_id> |
        | draftedAt     | <current_timestamp>|
        | actorId       | user-alice-001     |

    @command @validation
    Scenario: DraftPatentApplication command fails without permission
      Given Alice does not have permission "create_patent_applications"
      When the DraftPatentApplication command is executed
      Then the command should fail with error "Unauthorized"
      And no "PatentApplicationDrafted" event should be emitted

    @command @validation
    Scenario: DraftPatentApplication command validates required fields
      Given Alice has permission to create patent applications
      When the DraftPatentApplication command is executed without a title
      Then the command should fail with error "ValidationFailed"
      And the error details should indicate "title is required"

  Rule: DismissNotification command updates alert state

    @command @event
    Scenario: DismissNotification command succeeds for owned alert
      Given Alice has an alert with alertId "alert-001"
      When the DismissNotification command is executed with:
        | alertId | alert-001        |
        | userId  | user-alice-001   |
      Then the command should succeed
      And a "NotificationDismissed" event should be emitted with:
        | alertId     | alert-001          |
        | userId      | user-alice-001     |
        | dismissedAt | <current_timestamp>|

    @command @security
    Scenario: DismissNotification command fails for other user's alert
      Given Bob has an alert with alertId "alert-bob-001"
      When Alice attempts to dismiss alert "alert-bob-001"
      Then the command should fail with error "Unauthorized"
      And no "NotificationDismissed" event should be emitted

    @command @validation
    Scenario: DismissNotification command fails for non-existent alert
      Given no alert exists with alertId "alert-nonexistent"
      When the DismissNotification command is executed for "alert-nonexistent"
      Then the command should fail with error "NotFound"

  Rule: RequestStatusTransition command validates workflow transitions

    @command @event
    Scenario: RequestStatusTransition succeeds for valid transition
      Given Alice has an application "app-001" in status "draft"
      And the workflow allows transition from "draft" to "in_progress"
      When the RequestStatusTransition command is executed with:
        | applicationId | app-001     |
        | targetStatus  | in_progress |
        | userId        | user-alice-001 |
      Then the command should succeed
      And a "WorkflowStageChanged" event should be emitted with:
        | applicationId | app-001     |
        | from          | draft       |
        | to            | in_progress |
      And an "ApplicationStatusChanged" event should be emitted

    @command @validation
    Scenario: RequestStatusTransition fails for invalid transition
      Given Alice has an application "app-001" in status "draft"
      And the workflow does not allow transition from "draft" to "approved"
      When the RequestStatusTransition command is executed with targetStatus "approved"
      Then the command should fail with error "TransitionNotAllowed"
      And no events should be emitted

  Rule: UploadDocument command handles file attachments

    @command @event
    Scenario: UploadDocument command attaches document to application
      Given Alice has an application "app-001"
      And a file has been uploaded to storage with reference "file-ref-001"
      When the UploadDocument command is executed with:
        | applicationId | app-001                 |
        | fileRef       | file-ref-001            |
        | metadata      | {"type": "specification"}|
        | userId        | user-alice-001          |
      Then the command should succeed
      And a "DocumentUploaded" event should be emitted
      And a "DocumentCreated" event should be emitted

# Gaps Identified:
# 1. Command Idempotency - Should commands be idempotent? How to handle retries?
# 2. Saga Transactions - How to handle multi-step commands that may fail?
# 3. Event Ordering - Is event ordering guaranteed within a transaction?
# 4. Audit Trail - Are all commands logged for compliance?
```

### File: `specs/02-dashboard-overview/backend/phase1-cqrs-queries.feature`

```gherkin
# specs/02-dashboard-overview/backend/phase1-cqrs-queries.feature
@02-dashboard-overview @backend @query
Feature: Dashboard CQRS Queries (Phase 1)
  In order to efficiently serve read operations
  As the IP Hub backend system
  I want to execute optimized queries against read models

  Queries read from eventually consistent read models (projections).
  They are optimized for the dashboard's specific data needs.

  Background:
    Given the CQRS query infrastructure is running
    And read model projections are up to date
    And Alice is an authenticated user with userId "user-alice-001"
    And Alice belongs to organization "org-dff-001"

  Rule: GetPortfolioSummary query returns aggregated statistics

    @query @performance
    Scenario: GetPortfolioSummary returns within performance SLA
      Given Alice's organization has 100 IP assets
      When the GetPortfolioSummary query is executed with:
        | userId | user-alice-001 |
        | orgId  | org-dff-001    |
      Then the query should complete within 150ms (p95)
      And the result should contain:
        | field              | type    |
        | totalAssets        | integer |
        | countsByType       | object  |
        | inProgressCount    | integer |
        | pendingReviewCount | integer |

    @query @consistency
    Scenario: GetPortfolioSummary reflects recent changes with eventual consistency
      Given Alice's organization has 10 IP assets
      When a new patent application is created
      And we wait for projection updates (max 1000ms)
      And the GetPortfolioSummary query is executed
      Then the result should show 11 total assets

  Rule: ListUrgentAlerts query returns filtered notifications

    @query
    Scenario: ListUrgentAlerts returns alerts for user's organization
      Given the following alerts exist:
        | alertId | orgId       | type          | severity | dueDate    |
        | alert-1 | org-dff-001 | office_action | high     | 2025-02-01 |
        | alert-2 | org-dff-001 | renewal       | medium   | 2025-03-15 |
        | alert-3 | org-other   | renewal       | high     | 2025-02-01 |
      When the ListUrgentAlerts query is executed for org-dff-001
      Then the result should contain 2 alerts
      And alert-3 should not be in the results

    @query @performance
    Scenario: ListUrgentAlerts maintains strong consistency for deadlines
      Given an office action deadline is due tomorrow
      When the ListUrgentAlerts query is executed
      Then the deadline should appear immediately (strong consistency)
      And the query should complete within 200ms (p95)

  Rule: ListApplicationsInProgress query supports filtering and pagination

    @query
    Scenario: ListApplicationsInProgress returns paginated results
      Given Alice's organization has 50 applications in progress
      When the ListApplicationsInProgress query is executed with:
        | orgId  | org-dff-001 |
        | limit  | 20          |
        | offset | 0           |
      Then the result should contain 20 applications
      And the result should include pagination metadata

    @query
    Scenario: ListApplicationsInProgress filters by type and status
      Given Alice's organization has applications:
        | type      | status      |
        | patent    | draft       |
        | patent    | in_progress |
        | trademark | draft       |
      When the ListApplicationsInProgress query is executed with:
        | type   | patent |
        | status | draft  |
      Then the result should contain 1 application

  Rule: SearchAssetsAndApplications query provides full-text search

    @query @performance
    Scenario: Search returns relevant results within SLA
      Given Alice's organization has applications with various titles
      When the SearchAssetsAndApplications query is executed with:
        | query | AI algorithm |
      Then the query should complete within 300ms (p95)
      And results should be ranked by relevance

# Gaps Identified:
# 1. Projection Lag - What's the maximum acceptable lag for read models?
# 2. Full-Text Search - Which search engine (Elasticsearch, PostgreSQL FTS)?
# 3. Result Limits - What are the max/default limits for list queries?
# 4. Field Selection - Can clients request specific fields only?
```

### File: `specs/02-dashboard-overview/backend/phase1-domain-events.feature`

```gherkin
# specs/02-dashboard-overview/backend/phase1-domain-events.feature
@02-dashboard-overview @backend @event
Feature: Dashboard Domain Events (Phase 1)
  In order to maintain loose coupling between bounded contexts
  As the IP Hub backend system
  I want to publish and consume domain events reliably

  Domain events enable asynchronous communication between contexts.
  Events are published when state changes and consumed by interested parties.

  Background:
    Given the event bus is running
    And all event handlers are subscribed
    And the event store is available

  Rule: Application lifecycle events are emitted correctly

    @event @patent
    Scenario: PatentApplicationDrafted event triggers downstream handlers
      Given the notification service is subscribed to "PatentApplicationDrafted"
      And the analytics service is subscribed to "PatentApplicationDrafted"
      When a PatentApplicationDrafted event is published with:
        | applicationId | app-001            |
        | draftedAt     | 2025-01-15T10:00:00|
        | actorId       | user-alice-001     |
      Then the notification service should receive the event
      And the analytics service should receive the event
      And the event should be stored in the event store

    @event @trademark
    Scenario: TrademarkApplicationDrafted event follows same pattern
      When a TrademarkApplicationDrafted event is published
      Then appropriate handlers should process the event

  Rule: Status change events trigger workflow updates

    @event @integration
    Scenario: ApplicationStatusChanged event updates read models
      Given the dashboard summary projection is subscribed to "ApplicationStatusChanged"
      When an ApplicationStatusChanged event is published with:
        | applicationId | app-001      |
        | oldStatus     | draft        |
        | newStatus     | in_progress  |
        | changedAt     | 2025-01-15T10:00:00 |
      Then the dashboard summary projection should update
      And the applications list projection should update

    @event @workflow
    Scenario: WorkflowStageChanged event advances workflow state
      When a WorkflowStageChanged event is published
      Then the workflow instance should reflect the new stage
      And deadline projections should be recalculated

  Rule: Notification events update alert projections

    @event
    Scenario: NotificationDismissed event removes alert from dashboard
      Given the alert list projection contains alert "alert-001"
      When a NotificationDismissed event is published for "alert-001"
      Then the alert should be removed from the alert list projection

    @event @deadline
    Scenario: DeadlineApproaching event creates urgent alert
      When a DeadlineApproaching event is published with:
        | applicationId | app-001          |
        | deadlineType  | office_action    |
        | deadlineDate  | 2025-02-01       |
        | daysRemaining | 14               |
      Then an alert should be created in the notification system
      And the alert should appear in the dashboard alerts

  Rule: External events trigger internal state updates

    @event @external @integration
    Scenario: Document updated event from external system triggers re-processing
      Given an application "app-001" is waiting for document updates
      When a "DocumentUpdatedFromExternalSource" event is received with:
        | documentId    | doc-ext-001    |
        | source        | moec           |
        | applicationId | app-001        |
      Then the application document list should be updated
      And any dependent workflows should be notified

    @event @external
    Scenario: MoEc status change event updates application status
      Given an application "app-001" is submitted to MoEc
      When a "MoEcApplicationStatusChanged" event is received with:
        | applicationId | app-001       |
        | newStatus     | under_review  |
      Then the application status should be updated internally
      And an ApplicationStatusChanged event should be emitted

  Rule: Event reliability and ordering

    @event @reliability
    Scenario: Events are delivered at least once
      Given the event consumer is temporarily unavailable
      When an event is published
      And the consumer becomes available again
      Then the event should be delivered to the consumer
      And the event should be processed exactly once (idempotent)

    @event @ordering
    Scenario: Events for same aggregate maintain order
      When multiple events are published for application "app-001"
      Then they should be processed in order of occurrence

# Gaps Identified:
# 1. Event Versioning - How to handle event schema evolution?
# 2. Dead Letter Queue - Where do unprocessable events go?
# 3. Event Replay - Can projections be rebuilt from event history?
# 4. Cross-DC Replication - How are events replicated across regions?
```

### File: `specs/02-dashboard-overview/backend/phase1-non-functional.feature`

```gherkin
# specs/02-dashboard-overview/backend/phase1-non-functional.feature
@02-dashboard-overview @backend @non-functional
Feature: Dashboard Non-Functional Requirements (Phase 1)
  In order to provide a reliable and secure dashboard service
  As the IP Hub backend system
  I want to meet defined quality attribute requirements

  Non-functional requirements ensure the dashboard meets performance,
  security, reliability, and compliance standards.

  Background:
    Given the backend services are running in test environment
    And monitoring and observability tools are configured

  Rule: Performance requirements are met under load

    @non-functional @performance @critical
    Scenario: Dashboard summary API meets response time SLA
      Given the system is under normal load (100 concurrent users)
      When 1000 requests are made to GET /dashboard/summary over 60 seconds
      Then 95% of responses should complete within 150ms
      And 99% of responses should complete within 300ms
      And no requests should fail due to timeout

    @non-functional @performance
    Scenario: Applications list API handles pagination efficiently
      Given a user has 500 applications
      When requesting the first page of 20 applications
      Then the response should complete within 200ms
      And memory usage should remain stable

    @non-functional @performance @load
    Scenario: System handles concurrent dashboard requests
      Given 200 concurrent users accessing the dashboard
      When each user makes 10 requests per minute
      Then the system should maintain response time SLAs
      And error rate should be below 0.1%

  Rule: Security requirements protect sensitive data

    @non-functional @security @critical
    Scenario: All API endpoints require valid authentication
      When any dashboard API endpoint is called without a valid token
      Then the response status should be 401
      And no sensitive data should be exposed in the error

    @non-functional @security @critical
    Scenario: API prevents cross-tenant data access
      Given Alice belongs to organization "org-001"
      And Bob belongs to organization "org-002"
      When Alice's token is used to request Bob's dashboard data
      Then the response should only contain Alice's data
      And no data from org-002 should be visible

    @non-functional @security
    Scenario: Input validation prevents injection attacks
      When a request is made with malicious input:
        | field       | value                              |
        | searchQuery | '; DROP TABLE applications; --     |
      Then the request should be rejected with status 400
      And the database should remain unaffected
      And the malicious input should be logged for security review

    @non-functional @security
    Scenario: API rate limiting prevents abuse
      Given rate limits are configured at 100 requests per minute
      When a client makes 150 requests within 1 minute
      Then requests beyond the limit should receive status 429
      And the client should receive a "Retry-After" header

    @non-functional @security @audit
    Scenario: All sensitive operations are logged for audit
      When Alice views the dashboard
      And Alice dismisses an alert
      And Alice creates a new application
      Then audit logs should contain:
        | action               | userId         | timestamp |
        | dashboard.view       | user-alice-001 | <time>    |
        | alert.dismiss        | user-alice-001 | <time>    |
        | application.create   | user-alice-001 | <time>    |

  Rule: Reliability requirements ensure service availability

    @non-functional @reliability @critical
    Scenario: System maintains 99.9% uptime
      Given the monitoring period is 30 days
      When uptime is measured
      Then total downtime should be less than 43.2 minutes

    @non-functional @reliability
    Scenario: Graceful degradation when dependent service fails
      Given the notifications service is unavailable
      When a request is made to GET /dashboard/summary
      Then the response should succeed with portfolio data
      And the alerts section should indicate "temporarily unavailable"
      And no 500 errors should be returned to clients

    @non-functional @reliability
    Scenario: Database connection failures are handled gracefully
      Given the database connection pool is exhausted
      When a request is made to GET /dashboard/summary
      Then the response should be 503 Service Unavailable
      And the client should receive a "Retry-After" header
      And circuit breaker should activate after repeated failures

    @non-functional @reliability @recovery
    Scenario: System recovers from database restart
      Given the database is restarted
      When requests resume after restart
      Then the system should reconnect automatically
      And requests should succeed within 30 seconds of database availability

  Rule: Data integrity requirements ensure accurate information

    @non-functional @data-integrity @critical
    Scenario: Dashboard counts match actual database state
      Given the database contains:
        | table        | count |
        | applications | 100   |
        | patents      | 50    |
        | trademarks   | 30    |
      When the dashboard summary is requested
      Then totalAssets should equal the database count
      And counts by type should match database groupings

    @non-functional @data-integrity
    Scenario: Alert delivery is 100% reliable for critical deadlines
      Given a critical office action deadline is due in 14 days
      When the alerts are queried
      Then the deadline should appear in the results
      And the deadline should never be missed from query results

  Rule: Compliance requirements for legal and regulatory needs

    @non-functional @compliance @gdpr
    Scenario: User data can be exported for GDPR requests
      Given Alice requests a data export
      When the export is generated
      Then all of Alice's data should be included
      And the export should be in a portable format (JSON/CSV)

    @non-functional @compliance @data-residency
    Scenario: Data residency requirements are respected
      Given the platform operates in UAE
      When data is stored
      Then data should reside in UAE-compliant data centers
      And cross-border data transfers should be logged

# Gaps Identified:
# 1. Disaster Recovery - What's the RTO/RPO for dashboard service?
# 2. Backup Strategy - How frequently are read model backups taken?
# 3. Compliance Certifications - Which certifications are required (ISO 27001, SOC 2)?
# 4. Data Retention - How long is audit log data retained?
```

---

## Expected Output Summary

After running this agent with the example inputs, you should have:

```json
{
  "featureFilesCreated": [
    "specs/02-dashboard-overview/backend/phase1-bffe-api.feature",
    "specs/02-dashboard-overview/backend/phase1-cqrs-commands.feature",
    "specs/02-dashboard-overview/backend/phase1-cqrs-queries.feature",
    "specs/02-dashboard-overview/backend/phase1-domain-events.feature",
    "specs/02-dashboard-overview/backend/phase1-non-functional.feature"
  ],
  "scenarioCount": 48,
  "coverageMapping": {
    "bffeEndpoints": 20,
    "cqrsCommands": 6,
    "cqrsQueries": 4,
    "domainEvents": 12,
    "nfrScenarios": 15
  },
  "gapsDocumented": 18,
  "frontendScenariosWithBackendCoverage": 25,
  "status": "success",
  "summary": "Generated 48 backend scenarios across 5 feature files covering BFFE API, CQRS operations, domain events, and NFRs",
  "nextStep": "Review generated features with backend team, then proceed to step definition implementation"
}
```

## Key Differences from Frontend Features

| Aspect | Frontend Features | Backend Features |
|--------|-------------------|------------------|
| **Focus** | User interactions, UI behavior | API contracts, data flow, events |
| **Language** | "Alice sees...", "Alice clicks..." | "The response contains...", "Event emitted..." |
| **Tags** | @frontend, @ux | @backend, @api, @command, @query, @event |
| **Assertions** | Visual elements, navigation | Status codes, response bodies, events |
| **Test Runner** | Playwright, browser | Axios, database assertions |
| **NFR Focus** | Accessibility, visual design | Performance, security, reliability |

## Best Practices

1. **Use concrete test data** - Real organization IDs, user IDs, timestamps
2. **Reference CQRS contracts** - Map scenarios to commands/queries from spec
3. **Include event assertions** - Verify domain events are emitted
4. **Test error paths** - Unauthorized, validation errors, not found
5. **Cover NFRs explicitly** - Performance SLAs, security requirements
6. **Document gaps** - Questions for backend team review
7. **Maintain traceability** - Link backend scenarios to frontend features
