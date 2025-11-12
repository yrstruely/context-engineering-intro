# CQRS Contract

## CQRS Contract for 2.1.1 | Dashboard

This contract derives functionality from the Figma design and RSOMS/JTBD spec in [2.1.1 | Dashboard](https://www.notion.so/2-1-1-Dashboard-2a7dafe26c7480048c8ed4f89d8f7147?pvs=21), aligns bounded contexts with [Domain Model Specification](https://www.notion.so/Domain-Model-Specification-29adafe26c7480d2a288ff0b9c01d9ba?pvs=21), and uses domain events from [Domain Events](https://www.notion.so/Domain-Events-2a7dafe26c7480718a5cdb9d415e729f?pvs=21). Existing Core Services commands/queries were checked in [Core Services CQRS Catalogue](https://www.notion.so/Core-Services-CQRS-Catalogue-2a7dafe26c74802fb86dd688a6e2d33e?pvs=21) and are currently not enumerated there, so all items below are marked as [New] unless stated otherwise.

---

### Bounded Contexts referenced

- Identity Management Context
- Shared Kernel Context
- Document Management Context
- Workflow & Status Tracking Context
- Fee Calculation & Payment Context
- Translation Context
- Jurisdiction Context
- IP Asset Management Context
- Notifications Context

These correspond to the contexts listed in the Domain Model Specification page and are used where responsibilities naturally lie.

---

### BFFE endpoints and wrapped CQRS operations

Each endpoint lists the commands and queries it orchestrates, along with emitted domain events.

### 1) GET /dashboard/summary

Returns portfolio statistics, counts by IP type, and status card metrics.

- Queries
    - getPortfolioSummary(userId, orgId) [New]
    - getCountsByType(userId, orgId) [New]
    - getPendingReviewCounts(userId, orgId) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Shared Kernel Context, IP Asset Management Context

### 2) GET /dashboard/alerts

Returns urgent alerts: office action deadlines, renewals, status changes.

- Queries
    - listUrgentAlerts(userId, orgId, filters?) [New]
    - listApproachingDeadlines(orgId, withinDays) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Notifications Context, Workflow & Status Tracking Context, Shared Kernel Context

### 3) GET /dashboard/applications-in-progress

Lists active applications across Patent, Trademark, Copyright with progress and dates.

- Queries
    - listApplicationsInProgress(orgId, filters?) [New]
    - getApplicationProgress(applicationId) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Patent Application Context, Trademark Application Context, Copyright Application Context, Shared Kernel Context

### 4) GET /dashboard/assets-breakdown

Returns asset portfolio counts and status breakdown per IP type.

- Queries
    - getAssetBreakdown(orgId) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - IP Asset Management Context, Shared Kernel Context

### 5) POST /actions/register

Opens a creation flow shortcut for new applications (Patent/Trademark/Copyright).

- Commands
    - draftPatentApplication(orgId, initiatorId, payload) [New]
    - draftTrademarkApplication(orgId, initiatorId, payload) [New]
    - draftCopyrightApplication(orgId, initiatorId, payload) [New]
- Emitted domain events
    - PatentApplicationDrafted, TrademarkApplicationDrafted, CopyrightApplicationDrafted
- Contexts
    - Patent Application Context, Trademark Application Context, Copyright Application Context

### 6) POST /actions/import-asset

Imports an external asset record into portfolio.

- Commands
    - importAsset(orgId, initiatorId, source, metadata) [New]
- Emitted domain events
    - IPAssetEntityCreated or IPAssetInstanceCreated (per scope)
- Contexts
    - IP Asset Management Context, Document Management Context (if files attached)

### 7) GET /search

Unified search bar for assets and applications.

- Queries
    - searchAssetsAndApplications(orgId, query, filters?) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Shared Kernel Context, IP Asset Management Context

### 8) GET /filters/options

Returns filter dropdown options for type/status.

- Queries
    - listFilterOptions() [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Shared Kernel Context

### 9) POST /alerts/{alertId}/dismiss

Dismisses a dashboard alert.

- Commands
    - dismissNotification(alertId, userId) [New]
- Emitted domain events
    - NotificationDismissed
- Contexts
    - Notifications Context

### 10) POST /alerts/{alertId}/action

Takes the recommended action for an alert, e.g., respond to official action or pay fee.

- Commands
    - startWorkflowTask(alertId, userId) [New]
    - initiatePaymentForInvoice(invoiceId, userId) [New]
    - createApplicantResponse(applicationId, draftPayload) [New]
- Emitted domain events
    - TaskCreated, PaymentInitiated, ApplicantResponseSubmitted
- Contexts
    - Workflow & Status Tracking Context, Fee Calculation & Payment Context, Patent/Trademark/Copyright Application Contexts

### 11) GET /applications/{id}

Returns detail summary for an application row selected in the list.

- Queries
    - getApplicationSummary(applicationId) [New]
    - getApplicationTimeline(applicationId) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Relevant Application Context, Shared Kernel Context, Document Management Context

### 12) POST /applications/{id}/navigate

Navigational convenience to open the registration workflow for the selected application.

- Commands
    - openRegistrationWorkflow(applicationId, userId) [New]
- Emitted domain events
    - WorkflowInstanceStarted
- Contexts
    - Workflow & Status Tracking Context

### 13) GET /deadlines

Dedicated list for upcoming deadlines and countdowns.

- Queries
    - listDeadlines(orgId, withinDays, filters?) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Workflow & Status Tracking Context, Shared Kernel Context

### 14) POST /applications/{id}/status-transition

Allows status change when permitted from dashboard context.

- Commands
    - requestStatusTransition(applicationId, targetStatus, userId) [New]
- Emitted domain events
    - WorkflowStageChanged, ApplicationStatusChanged (Shared Kernel)
- Contexts
    - Workflow & Status Tracking Context, Shared Kernel Context, Relevant Application Context

### 15) POST /applications/{id}/upload-document

Quick upload from dashboard for a selected application.

- Commands
    - uploadDocument(applicationId, fileRef, metadata, userId) [New]
- Emitted domain events
    - DocumentUploaded, DocumentCreated
- Contexts
    - Document Management Context, Shared Kernel Context

### 16) POST /applications/{id}/calculate-fees

On-demand fee calculation for the selected application.

- Commands
    - calculateFees(applicationId, calculationContext, userId) [New]
- Emitted domain events
    - FeesCalculated or FeeCalculated (per catalog)
- Contexts
    - Fee Calculation & Payment Context

### 17) GET /applications/{id}/payments

Retrieve payment and invoice info for quick actions.

- Queries
    - getApplicationInvoices(applicationId) [New]
    - getPaymentStatus(paymentId) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Fee Calculation & Payment Context

### 18) POST /applications/{id}/pay

Initiates payment for a selected invoice from the dashboard.

- Commands
    - initiatePayment(invoiceId, paymentMethod, userId) [New]
- Emitted domain events
    - PaymentInitiated, PaymentCompleted or PaymentFailed
- Contexts
    - Fee Calculation & Payment Context

### 19) GET /applications/{id}/communications

Show official communications at a glance.

- Queries
    - listOfficialCommunications(applicationId) [New]
- Emitted domain events
    - None (read only)
- Contexts
    - Shared Kernel Context

### 20) POST /applications/{id}/respond

Draft and submit response to official action.

- Commands
    - draftApplicantResponse(applicationId, payload, userId) [New]
    - submitApplicantResponse(applicationId, responseId, userId) [New]
- Emitted domain events
    - ApplicantResponseSubmitted, OfficialCommunicationSent
- Contexts
    - Patent/Trademark Application Contexts, Shared Kernel Context, Document Management Context

---

### Core domain services interfaces (CQRS)

Below are concise interface shapes the BFFE relies on. Types are schematic.

- Query: getPortfolioSummary(userId, orgId) -> { totalAssets, countsByType, inProgressCount, pendingReviewCount }
- Query: getCountsByType(userId, orgId) -> { patents, trademarks, copyrights, other }
- Query: getPendingReviewCounts(userId, orgId) -> { actionsRequired, officeActions, renewals }
- Query: listUrgentAlerts(userId, orgId, filters?) -> [ { alertId, type, severity, message, dueDate } ]
- Query: listApproachingDeadlines(orgId, withinDays) -> [ { applicationId, deadlineType, deadlineDate, daysRemaining } ]
- Query: listApplicationsInProgress(orgId, filters?) -> [ { applicationId, type, name, status, submittedAt?, updatedAt, progressPct } ]
- Query: getApplicationProgress(applicationId) -> { progressPct, steps }
- Query: getAssetBreakdown(orgId) -> { patents: { total, byStatus }, trademarks: {...}, copyrights: {...} }
- Command: draftPatentApplication(orgId, initiatorId, payload) -> { applicationId }
- Command: draftTrademarkApplication(orgId, initiatorId, payload) -> { applicationId }
- Command: draftCopyrightApplication(orgId, initiatorId, payload) -> { applicationId }
- Command: importAsset(orgId, initiatorId, source, metadata) -> { assetId }
- Query: searchAssetsAndApplications(orgId, query, filters?) -> [ { id, type, title, status } ]
- Query: listFilterOptions() -> { types: [...], statuses: [...] }
- Command: dismissNotification(alertId, userId) -> { success }
- Command: startWorkflowTask(alertId, userId) -> { taskId }
- Command: initiatePaymentForInvoice(invoiceId, userId) -> { paymentId }
- Command: createApplicantResponse(applicationId, draftPayload) -> { responseId }
- Query: getApplicationSummary(applicationId) -> { header, status, keyDates, counts }
- Query: getApplicationTimeline(applicationId) -> [ { event, at } ]
- Command: openRegistrationWorkflow(applicationId, userId) -> { workflowInstanceId }
- Query: listDeadlines(orgId, withinDays, filters?) -> [ ... ]
- Command: requestStatusTransition(applicationId, targetStatus, userId) -> { requestId }
- Command: uploadDocument(applicationId, fileRef, metadata, userId) -> { documentId }
- Command: calculateFees(applicationId, calculationContext, userId) -> { invoiceId?, items }
- Query: getApplicationInvoices(applicationId) -> [ { invoiceId, amount, dueDate, status } ]
- Query: getPaymentStatus(paymentId) -> { status }
- Command: initiatePayment(invoiceId, paymentMethod, userId) -> { paymentId }
- Query: listOfficialCommunications(applicationId) -> [ { id, type, sentDate, link } ]
- Command: draftApplicantResponse(applicationId, payload, userId) -> { responseId }
- Command: submitApplicantResponse(applicationId, responseId, userId) -> { submissionId }

All above are [New] unless a matching entry is later added to the Core Services CQRS Catalogue.

---

### Domain events mapping by action

- Draft application: PatentApplicationDrafted, TrademarkApplicationDrafted, CopyrightApplicationDrafted
- Status transition: WorkflowStageChanged, ApplicationStatusChanged
- Deadlines pipeline: DeadlineApproaching, DeadlineMissed
- Documents: DocumentCreated, DocumentUploaded, DocumentVersioned (when updated)
- Fees and payments: FeesCalculated, PaymentInitiated, PaymentCompleted, PaymentFailed, InvoiceGenerated, InvoiceOverdue
- Notifications: NotificationCreated, NotificationDismissed, NotificationRead
- Official comms and responses: OfficialCommunicationSent, ApplicantResponseSubmitted

Events are referenced directly from the Domain Events catalogue to ensure consistency.

---

### Notes on cross-cutting concerns

- Authorization and roles come from Identity Management Context.
- Audit trail is captured via event sourcing and persisted per context.
- Bilingual content uses Translation Context where UI or documents require Arabic/English.

---

Generated for the Dashboard feature per the provided specs and catalogues.

[Core Services Spec](Core%20Services%20Spec%202a8dafe26c7480d7853ae4986d0ae1bb.md)

[BFFE Spec](BFFE%20Spec%202a8dafe26c7480bea873c80aba46f707.md)