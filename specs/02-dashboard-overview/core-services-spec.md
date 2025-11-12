# Core Services Spec

# Core Services Spec

Below is the CQRS spec YAML generated from the Dashboard CQRS Contract in [CQRS Contract ](CQRS%20Contract%202a8dafe26c748019ab1bcae5e7f7ffd4.md). It follows the structure defined in [Core Services CQRS Spec](https://www.notion.so/Core-Services-CQRS-Spec-2a8dafe26c748050be4ed91bb985e6ec?pvs=21) and groups items by bounded context from [Domain Model Specification](https://www.notion.so/Domain-Model-Specification-29adafe26c7480d2a288ff0b9c01d9ba?pvs=21). All items are [New] unless later re-labeled.

```yaml
commands:
  - name: DraftPatentApplication
    bc: patent-application
    payload:
      orgId: UUID
      initiatorId: UUID
      payload: object
    preconditions:
      - Initiator has permission to create patent applications
    invariants:
      - Draft must start in status=Draft
    emits: [PatentApplicationDrafted]
    errors: [Unauthorized, ValidationFailed]
    nfr: {latency_p95_ms: 300}

  - name: DraftTrademarkApplication
    bc: trademark-application
    payload:
      orgId: UUID
      initiatorId: UUID
      payload: object
    preconditions:
      - Initiator has permission to create trademark applications
    invariants:
      - Draft must start in status=Draft
    emits: [TrademarkApplicationDrafted]
    errors: [Unauthorized, ValidationFailed]

  - name: DraftCopyrightApplication
    bc: copyright-application
    payload:
      orgId: UUID
      initiatorId: UUID
      payload: object
    preconditions:
      - Initiator has permission to create copyright applications
    invariants:
      - Draft must start in status=Draft
    emits: [CopyrightApplicationDrafted]
    errors: [Unauthorized, ValidationFailed]

  - name: ImportAsset
    bc: ip-asset-management
    payload:
      orgId: UUID
      initiatorId: UUID
      source: string
      metadata: object
    preconditions:
      - Source is trusted or whitelisted
    invariants:
      - Imported asset must have unique externalId per org
    emits: [IPAssetEntityCreated]
    errors: [Conflict, Unauthorized, ValidationFailed]

  - name: DismissNotification
    bc: notifications
    payload:
      alertId: UUID
      userId: UUID
    preconditions:
      - User is recipient of alert
    emits: [NotificationDismissed]
    errors: [NotFound, Unauthorized]

  - name: StartWorkflowTask
    bc: workflow-status
    payload:
      alertId: UUID
      userId: UUID
    emits: [TaskCreated]
    errors: [NotFound, Unauthorized]

  - name: InitiatePaymentForInvoice
    bc: fee-payment
    payload:
      invoiceId: UUID
      userId: UUID
    emits: [PaymentInitiated]
    errors: [NotFound, Unauthorized]

  - name: CreateApplicantResponse
    bc: patent-trademark
    payload:
      applicationId: UUID
      draftPayload: object
    emits: [ApplicantResponseSubmitted]
    errors: [NotFound, Unauthorized, ValidationFailed]

  - name: OpenRegistrationWorkflow
    bc: workflow-status
    payload:
      applicationId: UUID
      userId: UUID
    emits: [WorkflowInstanceStarted]

  - name: RequestStatusTransition
    bc: workflow-status
    payload:
      applicationId: UUID
      targetStatus: string
      userId: UUID
    preconditions:
      - Transition allowed from current status
    emits: [WorkflowStageChanged, ApplicationStatusChanged]
    errors: [TransitionNotAllowed, Unauthorized]

  - name: UploadDocument
    bc: document-management
    payload:
      applicationId: UUID
      fileRef: string
      metadata: object
      userId: UUID
    emits: [DocumentUploaded, DocumentCreated]
    errors: [Unauthorized, ValidationFailed]

  - name: CalculateFees
    bc: fee-payment
    payload:
      applicationId: UUID
      calculationContext: object
      userId: UUID
    emits: [FeesCalculated]

  - name: InitiatePayment
    bc: fee-payment
    payload:
      invoiceId: UUID
      paymentMethod: string
      userId: UUID
    emits: [PaymentInitiated]
    errors: [NotFound, PaymentMethodInvalid]

  - name: DraftApplicantResponse
    bc: patent-trademark
    payload:
      applicationId: UUID
      payload: object
      userId: UUID
    emits: []

  - name: SubmitApplicantResponse
    bc: patent-trademark
    payload:
      applicationId: UUID
      responseId: UUID
      userId: UUID
    emits: [ApplicantResponseSubmitted, OfficialCommunicationSent]

queries:
  - name: GetPortfolioSummary
    bc: shared-kernel
    params:
      userId: UUID
      orgId: UUID
    read_model: DashboardSummary
    consistency: eventual
    p95_ms: 150
    fields:
      - totalAssets: int
      - countsByType: object
      - inProgressCount: int
      - pendingReviewCount: int

  - name: GetCountsByType
    bc: shared-kernel
    params:
      userId: UUID
      orgId: UUID
    read_model: TypeCounts
    consistency: eventual
    p95_ms: 150
    fields:
      - patents: int
      - trademarks: int
      - copyrights: int
      - other: int

  - name: GetPendingReviewCounts
    bc: shared-kernel
    params:
      userId: UUID
      orgId: UUID
    read_model: PendingReviewCounts
    consistency: eventual
    fields:
      - actionsRequired: int
      - officeActions: int
      - renewals: int

  - name: ListUrgentAlerts
    bc: notifications
    params:
      userId: UUID
      orgId: UUID
      filters?: object
    read_model: AlertList
    consistency: strong
    p95_ms: 200
    fields:
      - alertId: UUID
      - type: string
      - severity: string
      - message: string
      - dueDate: date

  - name: ListApproachingDeadlines
    bc: workflow-status
    params:
      orgId: UUID
      withinDays: int
    read_model: DeadlineList
    consistency: eventual
    fields:
      - applicationId: UUID
      - deadlineType: string
      - deadlineDate: datetime
      - daysRemaining: int

  - name: ListApplicationsInProgress
    bc: ip-asset-management
    params:
      orgId: UUID
      filters?: object
    read_model: ApplicationRow
    consistency: eventual
    fields:
      - applicationId: UUID
      - type: string
      - name: string
      - status: string
      - submittedAt?: datetime
      - updatedAt: datetime
      - progressPct: int

  - name: GetApplicationProgress
    bc: ip-asset-management
    params:
      applicationId: UUID
    read_model: ApplicationProgress
    fields:
      - progressPct: int
      - steps: object[]

  - name: GetAssetBreakdown
    bc: ip-asset-management
    params:
      orgId: UUID
    read_model: AssetBreakdown
    fields:
      - patents: object
      - trademarks: object
      - copyrights: object

  - name: SearchAssetsAndApplications
    bc: ip-asset-management
    params:
      orgId: UUID
      query: string
      filters?: object
    read_model: SearchResults
    p95_ms: 300
    fields:
      - id: UUID
      - type: string
      - title: string
      - status: string

  - name: ListFilterOptions
    bc: shared-kernel
    params: {}
    read_model: FilterOptions
    fields:
      - types: string[]
      - statuses: string[]

  - name: GetApplicationSummary
    bc: ip-asset-management
    params:
      applicationId: UUID
    read_model: ApplicationSummary
    fields:
      - header: object
      - status: string
      - keyDates: object
      - counts: object

  - name: GetApplicationTimeline
    bc: application-context
    params:
      applicationId: UUID
    read_model: ApplicationTimeline
    fields:
      - event: string
      - at: datetime

  - name: ListDeadlines
    bc: workflow-status
    params:
      orgId: UUID
      withinDays: int
      filters?: object
    read_model: DeadlineList

  - name: GetApplicationInvoices
    bc: fee-payment
    params:
      applicationId: UUID
    read_model: InvoiceList
    fields:
      - invoiceId: UUID
      - amount: money
      - dueDate: date
      - status: string

  - name: GetPaymentStatus
    bc: fee-payment
    params:
      paymentId: UUID
    read_model: PaymentStatus
    fields:
      - status: string

  - name: ListOfficialCommunications
    bc: shared-kernel
    params:
      applicationId: UUID
    read_model: OfficialComms
    fields:
      - id: UUID
      - type: string
      - sentDate: datetime
      - link: url

events:
  produced:
    - name: PatentApplicationDrafted
      schema: {applicationId: UUID, draftedAt: datetime, actorId: UUID}
    - name: TrademarkApplicationDrafted
      schema: {applicationId: UUID, draftedAt: datetime, actorId: UUID}
    - name: CopyrightApplicationDrafted
      schema: {applicationId: UUID, draftedAt: datetime, actorId: UUID}
    - name: IPAssetEntityCreated
      schema: {assetId: UUID, orgId: UUID, createdAt: datetime}
    - name: NotificationDismissed
      schema: {alertId: UUID, userId: UUID, dismissedAt: datetime}
    - name: TaskCreated
      schema: {taskId: UUID, createdAt: datetime, createdBy: UUID}
    - name: PaymentInitiated
      schema: {paymentId: UUID, invoiceId: UUID, initiatedAt: datetime}
    - name: ApplicantResponseSubmitted
      schema: {applicationId: UUID, responseId: UUID, submittedAt: datetime}
    - name: WorkflowInstanceStarted
      schema: {workflowInstanceId: UUID, applicationId: UUID, startedAt: datetime}
    - name: WorkflowStageChanged
      schema: {applicationId: UUID, from: string, to: string, changedAt: datetime}
    - name: ApplicationStatusChanged
      schema: {applicationId: UUID, oldStatus: string, newStatus: string, changedAt: datetime}
    - name: DocumentUploaded
      schema: {applicationId: UUID, documentId: UUID, uploadedAt: datetime}
    - name: DocumentCreated
      schema: {documentId: UUID, createdAt: datetime}
    - name: FeesCalculated
      schema: {applicationId: UUID, invoiceId?: UUID, calculatedAt: datetime}
    - name: PaymentCompleted
      schema: {paymentId: UUID, completedAt: datetime}
    - name: PaymentFailed
      schema: {paymentId: UUID, failedAt: datetime, reason: string}
    - name: OfficialCommunicationSent
      schema: {applicationId: UUID, commId: UUID, sentAt: datetime}
  consumed:
    - name: DeadlineApproaching
      from: workflow-status
      use: project into DeadlineList
    - name: DeadlineMissed
      from: workflow-status
      use: project into DeadlineList

projections:
  - name: DashboardSummary
    source_events: [ApplicationStatusChanged, FeesCalculated, NotificationCreated]
    storage: postgres (table: dashboard_summary)
    index: [orgId]
    sla_refresh_ms: 1000

  - name: ApplicationRow
    source_events: [ApplicationStatusChanged, PatentApplicationDrafted, TrademarkApplicationDrafted, CopyrightApplicationDrafted]
    storage: postgres (table: app_rows)
    index: [status, type, updatedAt]

  - name: DeadlineList
    source_events: [DeadlineApproaching, DeadlineMissed]
    storage: postgres (table: deadlines)
    index: [deadlineDate]

  - name: InvoiceList
    source_events: [FeesCalculated, InvoiceGenerated, PaymentCompleted, PaymentFailed]
    storage: postgres (table: invoices)
    index: [status, dueDate]

  - name: OfficialComms
    source_events: [OfficialCommunicationSent, ApplicantResponseSubmitted]
    storage: postgres (table: official_comms)
    index: [sentDate]
```

Linked sources:

- Contract: [CQRS Contract ](CQRS%20Contract%202a8dafe26c748019ab1bcae5e7f7ffd4.md)
- Contexts: [Domain Model Specification](https://www.notion.so/Domain-Model-Specification-29adafe26c7480d2a288ff0b9c01d9ba?pvs=21)
- Events catalogue: [Domain Events](https://www.notion.so/Domain-Events-2a7dafe26c7480718a5cdb9d415e729f?pvs=21)
- CQRS catalogue: [Core Services CQRS Catalogue](https://www.notion.so/Core-Services-CQRS-Catalogue-2a7dafe26c74802fb86dd688a6e2d33e?pvs=21)