# BFFE Spec

# BFFE Spec

OpenAPI draft for the Dashboard BFFE. Bounded contexts are sourced from [Domain Model Specification](https://www.notion.so/Domain-Model-Specification-29adafe26c7480d2a288ff0b9c01d9ba?pvs=21). Endpoints aggregate/adapt core services per [CQRS Contract ](CQRS%20Contract%202a8dafe26c748019ab1bcae5e7f7ffd4.md). Dependent CQRS commands/queries are listed as comments under each operation.

```yaml
openapi: 3.0.3
info:
  title: IP Hub Dashboard BFFE
  version: 0.1.0
  description: Back-end-for-front-end API that orchestrates core services for the Dashboard feature.
servers:
  - url: [https://api.ip-hub.example.com](https://api.ip-hub.example.com)
    description: Production
  - url: [https://staging.api.ip-hub.example.com](https://staging.api.ip-hub.example.com)
    description: Staging

tags:
  - name: Dashboard
  - name: Applications
  - name: Alerts
  - name: Payments
  - name: Documents

paths:
  /dashboard/summary:
    get:
      tags: [Dashboard]
      summary: Portfolio summary and status cards
      operationId: getDashboardSummary
      # queries: getPortfolioSummary [Shared Kernel], getCountsByType [Shared Kernel], getPendingReviewCounts [Shared Kernel]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  totalAssets: { type: integer }
                  countsByType:
                    type: object
                    additionalProperties: { type: integer }
                  inProgressCount: { type: integer }
                  pendingReviewCount: { type: integer }

  /dashboard/alerts:
    get:
      tags: [Alerts]
      summary: Urgent alerts and deadlines
      operationId: listDashboardAlerts
      parameters:
        - in: query
          name: withinDays
          schema: { type: integer, minimum: 1 }
        - in: query
          name: type
          schema: { type: string }
      # queries: listUrgentAlerts [Notifications], listApproachingDeadlines [Workflow & Status]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    alertId: { type: string, format: uuid }
                    type: { type: string }
                    severity: { type: string }
                    message: { type: string }
                    dueDate: { type: string, format: date-time }

  /dashboard/applications-in-progress:
    get:
      tags: [Applications]
      summary: List active applications with progress
      operationId: listApplicationsInProgress
      parameters:
        - in: query
          name: status
          schema: { type: string }
        - in: query
          name: type
          schema: { type: string, enum: [patent, trademark, copyright] }
      # queries: listApplicationsInProgress [IP Asset Management], getApplicationProgress [IP Asset Management]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    applicationId: { type: string, format: uuid }
                    type: { type: string }
                    name: { type: string }
                    status: { type: string }
                    submittedAt: { type: string, format: date-time, nullable: true }
                    updatedAt: { type: string, format: date-time }
                    progressPct: { type: integer, minimum: 0, maximum: 100 }

  /dashboard/assets-breakdown:
    get:
      tags: [Dashboard]
      summary: Asset counts and status breakdown per IP type
      operationId: getAssetsBreakdown
      # query: getAssetBreakdown [IP Asset Management]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  patents: { type: object }
                  trademarks: { type: object }
                  copyrights: { type: object }

  /actions/register:
    post:
      tags: [Applications]
      summary: Create a new application (Patent/Trademark/Copyright)
      operationId: registerApplication
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                type: { type: string, enum: [patent, trademark, copyright] }
                payload: { type: object }
              required: [type, payload]
      # commands: draftPatentApplication [Patent], draftTrademarkApplication [Trademark], draftCopyrightApplication [Copyright]
      responses:
        '201':
          description: Created
          content:
            application/json:
              schema:
                type: object
                properties:
                  applicationId: { type: string, format: uuid }

  /actions/import-asset:
    post:
      tags: [Applications]
      summary: Import an external asset into portfolio
      operationId: importAsset
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                source: { type: string }
                metadata: { type: object }
              required: [source, metadata]
      # command: importAsset [IP Asset Management]
      responses:
        '201':
          description: Created
          content:
            application/json:
              schema:
                type: object
                properties:
                  assetId: { type: string, format: uuid }

  /search:
    get:
      tags: [Dashboard]
      summary: Search across assets and applications
      operationId: search
      parameters:
        - in: query
          name: q
          schema: { type: string }
        - in: query
          name: type
          schema: { type: string }
      # query: searchAssetsAndApplications [IP Asset Management]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id: { type: string }
                    type: { type: string }
                    title: { type: string }
                    status: { type: string }

  /filters/options:
    get:
      tags: [Dashboard]
      summary: Filter dropdown options
      operationId: listFilterOptions
      # query: listFilterOptions [Shared Kernel]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  types: { type: array, items: { type: string } }
                  statuses: { type: array, items: { type: string } }

  /alerts/{alertId}/dismiss:
    post:
      tags: [Alerts]
      summary: Dismiss an alert
      operationId: dismissAlert
      parameters:
        - in: path
          name: alertId
          required: true
          schema: { type: string, format: uuid }
      # command: dismissNotification [Notifications]
      responses:
        '204': { description: No Content }

  /alerts/{alertId}/action:
    post:
      tags: [Alerts]
      summary: Execute recommended action for an alert
      operationId: actionAlert
      parameters:
        - in: path
          name: alertId
          required: true
          schema: { type: string, format: uuid }
      requestBody:
        required: false
        content:
          application/json:
            schema:
              type: object
              properties:
                invoiceId: { type: string, format: uuid }
                applicationId: { type: string, format: uuid }
                draftPayload: { type: object }
      # commands: startWorkflowTask [Workflow & Status], initiatePaymentForInvoice [Fee], createApplicantResponse [Application Contexts]
      responses:
        '202': { description: Accepted }

  /applications/{id}:
    get:
      tags: [Applications]
      summary: Application detail summary
      operationId: getApplication
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      # queries: getApplicationSummary [IP Asset Mgmt], getApplicationTimeline [App Context]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  header: { type: object }
                  status: { type: string }
                  keyDates: { type: object }
                  counts: { type: object }
                  timeline:
                    type: array
                    items:
                      type: object
                      properties:
                        event: { type: string }
                        at: { type: string, format: date-time }

  /applications/{id}/navigate:
    post:
      tags: [Applications]
      summary: Open registration workflow for application
      operationId: navigateApplication
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      # command: openRegistrationWorkflow [Workflow & Status]
      responses:
        '202':
          description: Accepted
          content:
            application/json:
              schema:
                type: object
                properties:
                  workflowInstanceId: { type: string, format: uuid }

  /deadlines:
    get:
      tags: [Dashboard]
      summary: Upcoming deadlines
      operationId: listDeadlines
      parameters:
        - in: query
          name: withinDays
          schema: { type: integer, minimum: 1 }
      # query: listDeadlines [Workflow & Status]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    applicationId: { type: string, format: uuid }
                    deadlineType: { type: string }
                    deadlineDate: { type: string, format: date-time }
                    daysRemaining: { type: integer }

  /applications/{id}/status-transition:
    post:
      tags: [Applications]
      summary: Request status transition
      operationId: requestStatusTransition
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                targetStatus: { type: string }
              required: [targetStatus]
      # command: requestStatusTransition [Workflow & Status] (emits WorkflowStageChanged, ApplicationStatusChanged [Shared Kernel])
      responses:
        '202': { description: Accepted }

  /applications/{id}/upload-document:
    post:
      tags: [Documents]
      summary: Upload a document for application
      operationId: uploadDocument
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                fileRef: { type: string }
                metadata: { type: object }
              required: [fileRef]
      # command: uploadDocument [Document Management] (emits DocumentUploaded, DocumentCreated)
      responses:
        '201':
          description: Created
          content:
            application/json:
              schema:
                type: object
                properties:
                  documentId: { type: string, format: uuid }

  /applications/{id}/calculate-fees:
    post:
      tags: [Payments]
      summary: Calculate fees for application
      operationId: calculateFees
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      requestBody:
        required: false
        content:
          application/json:
            schema:
              type: object
              properties:
                calculationContext: { type: object }
      # command: calculateFees [Fee Calculation & Payment]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  invoiceId: { type: string, format: uuid, nullable: true }
                  items:
                    type: array
                    items: { type: object }

  /applications/{id}/payments:
    get:
      tags: [Payments]
      summary: List invoices and payment status for application
      operationId: getApplicationPayments
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      # queries: getApplicationInvoices, getPaymentStatus [Fee Calculation & Payment]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: object
                properties:
                  invoices:
                    type: array
                    items:
                      type: object
                      properties:
                        invoiceId: { type: string, format: uuid }
                        amount: { type: number }
                        dueDate: { type: string, format: date }
                        status: { type: string }

  /applications/{id}/pay:
    post:
      tags: [Payments]
      summary: Initiate payment for an invoice
      operationId: payInvoice
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                invoiceId: { type: string, format: uuid }
                paymentMethod: { type: string }
              required: [invoiceId, paymentMethod]
      # command: initiatePayment [Fee Calculation & Payment] (emits PaymentInitiated -> PaymentCompleted/PaymentFailed)
      responses:
        '202':
          description: Accepted
          content:
            application/json:
              schema:
                type: object
                properties:
                  paymentId: { type: string, format: uuid }

  /applications/{id}/communications:
    get:
      tags: [Applications]
      summary: Official communications for application
      operationId: listOfficialCommunications
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      # query: listOfficialCommunications [Shared Kernel]
      responses:
        '200':
          description: OK
          content:
            application/json:
              schema:
                type: array
                items:
                  type: object
                  properties:
                    id: { type: string, format: uuid }
                    type: { type: string }
                    sentDate: { type: string, format: date-time }
                    link: { type: string, format: uri }

  /applications/{id}/respond:
    post:
      tags: [Applications]
      summary: Draft and submit response to official action
      operationId: respondToOfficialAction
      parameters:
        - in: path
          name: id
          required: true
          schema: { type: string, format: uuid }
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                draftPayload: { type: object }
                submit: { type: boolean, default: false }
              required: [draftPayload]
      # commands: draftApplicantResponse [Application Contexts], submitApplicantResponse [Application Contexts]; events: ApplicantResponseSubmitted, OfficialCommunicationSent
      responses:
        '202': { description: Accepted }

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
security:
  - bearerAuth: []
```