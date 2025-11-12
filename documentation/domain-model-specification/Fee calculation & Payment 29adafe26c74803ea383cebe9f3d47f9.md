# Fee calculation & Payment

Create a high level DDD definition specification md for Fee calculation & PAyment Bounded Context referencing on existing references in the Shared Kernel, Document Management,   Workflow & Status Tracking, Identity Management, Patent, Trademark And Copyright Application contexts that you already have. 

# Fee Calculation & Payment Bounded Context - DDD Specification

## Overview

The Fee Calculation & Payment Bounded Context is responsible for managing the calculation, tracking, and processing of fees associated with intellectual property applications and related services. This context handles fee schedules, payment processing, refunds, and financial reconciliation, supporting Patent, Trademark, and Copyright Application contexts.

## Ubiquitous Language

- **Fee:** A monetary charge for services or filings within the IP management system
- **Fee Schedule:** A structured list of fees for different services, application types, and entity sizes
- **Fee Calculation:** The process of determining applicable fees based on application type, entity size, and requested services
- **Payment:** A financial transaction that settles one or more fees
- **Payment Method:** The mechanism used to process payment (credit card, bank transfer, account balance, etc.)
- **Fee Waiver:** An exemption from paying certain fees based on specific criteria
- **Refund:** Return of payment when fees are overpaid or services are cancelled
- **Invoice:** A document detailing fees owed and payment status
- **Payment Status:** The current state of a payment (Pending, Completed, Failed, Refunded)
- **Entity Size:** Classification affecting fee amounts (Micro Entity, Small Entity, Large Entity)

## Core Domain Entities

### FeeCalculation (Aggregate Root)

- **Attributes:** CalculationId, ApplicationId, ApplicationType, EntitySize, RequestedServices, CalculatedFees, TotalAmount, CalculationDate, ValidUntil, Status
- **Behaviors:** CalculateFees, ApplyDiscount, ApplyWaiver, Recalculate, Validate
- **Invariants:** Total amount must equal sum of individual fees; calculation must reference valid fee schedule; entity size must be verified

### Payment (Aggregate Root)

- **Attributes:** PaymentId, CalculationId, PayerId (UserId from Identity Management), Amount, PaymentMethod, PaymentDate, TransactionId, Status, ConfirmationNumber
- **Behaviors:** ProcessPayment, ConfirmPayment, FailPayment, RefundPayment, CancelPayment
- **Invariants:** Payment amount must match calculated fees; payment must have valid payment method; refund cannot exceed original payment

### FeeSchedule (Entity)

- **Attributes:** ScheduleId, EffectiveDate, ExpirationDate, FeeItems, Version, PublishedBy
- **Behaviors:** GetApplicableFee, UpdateSchedule, PublishSchedule

### FeeItem (Value Object)

- **Attributes:** FeeCode, Description, BaseAmount, EntitySizeMultipliers, ServiceType
- **Behaviors:** CalculateAmount (based on entity size)

### Invoice (Entity)

- **Attributes:** InvoiceId, InvoiceNumber, CalculationId, PaymentId, IssuedTo (UserId), IssueDate, DueDate, LineItems, TotalAmount, Status, DocumentId (from Document Management)
- **Behaviors:** GenerateInvoice, MarkPaid, SendReminder, Void

### Refund (Entity)

- **Attributes:** RefundId, PaymentId, Amount, Reason, RequestedBy (UserId), RequestDate, ProcessedDate, Status
- **Behaviors:** RequestRefund, ApproveRefund, ProcessRefund, RejectRefund

### PaymentMethod (Value Object)

- **Attributes:** MethodType, AccountDetails (encrypted), ExpirationDate, BillingAddress
- **Behaviors:** Validate, Tokenize

### FeeWaiver (Value Object)

- **Attributes:** WaiverType, Percentage, Reason, ApprovedBy (UserId), ApprovalDate
- **Behaviors:** ApplyWaiver, ValidateEligibility

## Domain Services

### FeeCalculationService

Orchestrates the calculation of fees based on application type, entity size, and current fee schedule. Applies discounts and waivers as applicable.

### PaymentProcessingService

Handles payment processing through various payment gateways, manages transaction security, and coordinates with external payment providers.

### RefundProcessingService

Manages the refund workflow, including validation, approval, and processing of refunds back to original payment methods.

### EntitySizeVerificationService

Validates entity size classification based on business criteria (revenue, employee count, patent holdings) to ensure correct fee calculation.

## Application Services

- **FeeCalculationApplicationService:** Coordinates fee calculation workflows for various application types
- **PaymentApplicationService:** Manages payment processing, confirmation, and reconciliation
- **InvoiceApplicationService:** Generates, distributes, and tracks invoices
- **RefundApplicationService:** Handles refund requests and processing
- **FeeScheduleManagementService:** Manages fee schedule updates and versioning

## Integration with Other Bounded Contexts

### Shared Kernel

- Uses common types: **UserId**, **Timestamp**, **AuditInfo**, **Money** (value object for currency amounts)
- Shares value objects: **Address**, **EmailAddress**, **DateRange**
- Common events: **DomainEvent** base class for event-driven architecture

### Identity Management Context

- References **UserId** for payment processing and invoice generation
- Validates user identity and entity size classification
- Subscribes to **UserProfileUpdated** event to refresh entity size status

### Document Management Context

- Stores invoices, receipts, and payment confirmations using **DocumentId**
- Publishes **InvoiceGenerated** event that triggers document creation
- Retrieves fee schedule documents and payment authorization forms

### Workflow & Status Tracking Context

- Publishes **PaymentCompleted** and **PaymentFailed** events that affect workflow progression
- Subscribes to **WorkflowStepCompleted** events to trigger fee calculations for next steps
- Payment status changes update application workflow status
- Fee deadlines integrate with workflow deadline tracking

### Patent Application Context

- Calculates fees for patent filings, maintenance fees, and amendment fees
- Subscribes to **PatentApplicationSubmitted** event to calculate initial filing fees
- Publishes **FeesCalculated** and **PaymentReceived** events consumed by Patent context
- Patent applications reference **CalculationId** and **PaymentId** for fee tracking

### Trademark Application Context

- Calculates fees for trademark applications, renewals, and class additions
- Handles per-class fee calculations for multi-class trademark applications
- Subscribes to **TrademarkApplicationSubmitted** and **TrademarkRenewalDue** events
- Trademark applications maintain **PaymentId** references for each fee payment

### Copyright Application Context

- Calculates fees for copyright registrations and special handling requests
- Subscribes to **CopyrightApplicationSubmitted** event to trigger fee calculation
- Copyright applications reference **CalculationId** for fee tracking

## Domain Events

- **FeesCalculated:** Published when fees are calculated for an application
- **FeeScheduleUpdated:** Published when a new fee schedule becomes effective
- **PaymentInitiated:** Published when a payment process begins
- **PaymentCompleted:** Published when a payment is successfully processed
- **PaymentFailed:** Published when a payment processing fails
- **PaymentRefunded:** Published when a refund is processed
- **InvoiceGenerated:** Published when an invoice is created
- **InvoiceOverdue:** Published when an invoice payment is overdue
- **FeeWaiverApplied:** Published when a fee waiver is granted
- **RefundRequested:** Published when a refund is requested
- **RefundProcessed:** Published when a refund is completed

## Repositories

- **IFeeCalculationRepository:** Persistence interface for FeeCalculation aggregate
- **IPaymentRepository:** Manages payment records and transaction history
- **IFeeScheduleRepository:** Handles fee schedule storage and versioning
- **IInvoiceRepository:** Manages invoice records and queries
- **IRefundRepository:** Handles refund request storage and tracking

## Aggregates and Consistency Boundaries

**FeeCalculation Aggregate:** The FeeCalculation entity is an aggregate root maintaining consistency for all calculated fees, discounts, and waivers within a single calculation. Changes to individual fee items must go through the aggregate root.

**Payment Aggregate:** The Payment entity is an aggregate root ensuring transactional consistency for payment processing, including status changes, confirmations, and related refunds. Payment method details and transaction logs are managed within this boundary.

## Anti-Corruption Layer

When integrating with external payment gateways and financial institutions, an anti-corruption layer translates between external payment APIs and internal domain models. This prevents vendor-specific payment processing concerns from leaking into the domain and allows flexibility to switch payment providers.

## Context Mapping

- **Shared Kernel:** with Identity Management (user identification), Shared Kernel (Money value object)
- **Customer-Supplier:** Fee Calculation & Payment (upstream) supplies payment services to Patent, Trademark, and Copyright contexts (downstream)
- **Published Language:** Fee Calculation & Payment publishes payment-related events consumed by multiple contexts
- **Conformist:** Conforms to Identity Management for user authentication and Document Management for invoice storage

## Bounded Context Responsibilities

- Calculate fees based on current fee schedules and application characteristics
- Process payments through various payment methods and gateways
- Generate and manage invoices for services rendered
- Handle refund requests and processing
- Maintain fee schedule versions and effective dates
- Verify entity size classifications for accurate fee calculation
- Apply fee waivers and discounts based on eligibility criteria
- Track payment status and send reminders for overdue payments
- Ensure PCI DSS compliance for payment data handling
- Provide financial reporting and reconciliation capabilities

## Key Architectural Decisions

- **Payment Gateway Integration:** Use adapter pattern to support multiple payment processors without coupling to specific vendors
- **Fee Schedule Versioning:** Maintain historical fee schedules to ensure accurate fee calculation for applications filed under previous schedules
- **Payment Security:** Tokenize payment methods and never store raw card numbers; use PCI-compliant payment processors
- **Idempotency:** Implement idempotent payment processing to prevent duplicate charges from retry attempts
- **Event Sourcing:** Consider event sourcing for payment transactions to maintain complete audit trail
- **Async Processing:** Use asynchronous processing for payment gateway communication to improve responsiveness
- **Currency Handling:** Support multiple currencies with proper conversion rates and precision handling

## Compliance and Security Considerations

- Maintain PCI DSS compliance for payment card data handling
- Encrypt sensitive payment information at rest and in transit
- Implement fraud detection and prevention mechanisms
- Maintain complete audit logs for all financial transactions
- Support tax compliance requirements for different jurisdictions
- Implement proper access controls for refund processing and fee schedule management
- Ensure GDPR compliance for payment-related personal data
- Maintain transaction records according to financial record retention requirements

## Business Rules

- Fees must be calculated using the fee schedule effective at the time of application submission
- Entity size classification must be verified before applying reduced fees
- Payments must be confirmed before applications can proceed to examination
- Refunds require approval and cannot exceed the original payment amount
- Fee waivers require documentation and approval by authorized personnel
- Overdue payments may result in application abandonment after grace period
- Partial payments are not accepted unless specifically allowed by fee schedule