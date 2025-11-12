# MoEc API Integration Bounded Context

# MoEc API Integration Bounded Context

## Overview

The Ministry of Economy (MoEc) API Integration Bounded Context is responsible for orchestrating seamless communication between the IP Hub platform and the Ministry of Economy's intellectual property registration systems. This context acts as an anti-corruption layer, translating IP Hub domain concepts into MoEc-compatible formats and vice versa.

## Context Map

### Upstream Dependencies (Conformist/Customer-Supplier)

- **Ministry of Economy Systems:** External systems providing IP registration, examination, and decision-making services (Conformist relationship)
- **UAE Pass / Identity Server:** Authentication and user identity provider (Conformist relationship)
- **Government Service Bus (GSB):** Technical infrastructure for API communication (Conformist relationship)
- **Payment Gateway:** External payment processing system (Conformist relationship)

### Downstream Dependencies (Open Host Service/Published Language)

- **Patent Application Context:** Consumes MoEc integration services for patent submissions
- **Trademark Application Context:** Consumes MoEc integration services for trademark submissions
- **Copyright Application Context:** Consumes MoEc integration services for copyright submissions

### Shared Kernel References

- **Shared Kernel:** Common domain concepts (EmiratesId, ApplicationId, EntityId, ApplicationStatus)
- **Document Management:** Document upload, storage, and retrieval services
- **Identity Management:** User profile, authentication, and authorization
- **Workflow & Status Tracking:** Application lifecycle and status transitions
- **Fee Calculation & Payment:** Payment amount calculation and transaction processing
- **Translation:** Multi-language support for communication
- **Platform Administration:** System configuration and monitoring

### Partnership Relationships

- **Jurisdiction Context:** Maps IP Hub jurisdictions to MoEc territorial requirements
- **Enforcement Context:** Receives enforcement decisions from MoEc
- **Commercialization Context:** Updates based on MoEc registration status

## Core Domain Concepts

### Aggregates

### MoEcApplication (Aggregate Root)

- **ApplicationId:** Unique identifier (from Shared Kernel)
- **MoEcApplicationId:** Ministry-assigned application identifier
- **EmiratesId:** User identifier for correlation (from Shared Kernel)
- **EntityId:** Legal entity identifier (from Shared Kernel)
- **ApplicationType:** Patent, Trademark, Copyright, etc.
- **SubmissionStatus:** Draft, Submitted, UnderReview, Approved, Rejected, PaymentPending
- **FormData:** Application-specific form information
- **Documents:** Collection of MoEcDocument value objects
- **SubmittedAt:** Timestamp of submission to MoEc
- **LastSyncedAt:** Last synchronization timestamp

### MoEcUserProfile (Aggregate Root)

- **EmiratesId:** Primary identifier
- **MoEcUserId:** Ministry system user identifier
- **UAEPassLevel:** Authentication level (2 or 3)
- **RegistrationStatus:** NotRegistered, Pending, Registered, Failed
- **Entities:** Collection of associated legal entities
- **Personas:** Individual, Agent, CompanyRepresentative

### MoEcLegalEntity (Aggregate Root)

- **EntityId:** Unique identifier
- **MoEcEntityId:** Ministry system entity identifier
- **EntityType:** Government, ResearchCenter, Individual, Company, Agent
- **RegistrationStatus:** NotRegistered, Registered, ValidationRequired
- **Documents:** Entity registration documents
- **AssociatedUsers:** Users with access to this entity

### MoEcPaymentTransaction (Aggregate Root)

- **TransactionId:** Unique identifier
- **ApplicationId:** Associated application
- **CheckoutId:** Payment gateway checkout identifier
- **Amount:** Payment amount (calculated by MoEc)
- **Status:** Pending, Completed, Failed, Cancelled
- **RedirectUrl:** Payment gateway redirect URL
- **CreatedAt:** Transaction creation timestamp

### Value Objects

- **MoEcDocument:** DocumentId, DocumentType, FileName, FileSize, UploadedAt, MoEcDocumentReference
- **ApplicationFormData:** Asset-type-specific form fields in key-value format
- **MoEcCallbackEvent:** EventType, ApplicationId, Status, Message, Timestamp, AdditionalData
- **ApiEndpointConfig:** ServiceType, EndpointUrl, AuthenticationMethod, RetryPolicy

### Domain Events

- **ApplicationSubmittedToMoEc:** Published when application is successfully submitted
- **MoEcApplicationStatusChanged:** Published when MoEc updates application status
- **MoEcUserProfileCreated:** Published when user profile is registered with MoEc
- **MoEcLegalEntityRegistered:** Published when entity is registered with MoEc
- **MoEcPaymentInitiated:** Published when payment flow begins
- **MoEcPaymentCompleted:** Published when payment is confirmed
- **MoEcDocumentUploadCompleted:** Published when documents are successfully uploaded
- **MoEcApplicationRejected:** Published when MoEc rejects an application
- **MoEcApplicationApproved:** Published when MoEc approves an application
- **MoEcCallbackReceived:** Published when receiving callback from MoEc

### Domain Services

### ApplicationSubmissionService

Orchestrates the multi-step process of submitting applications to MoEc, including user profile verification, entity validation, form data submission, and document upload.

### MoEcUserSynchronizationService

Manages user profile creation and synchronization between IP Hub and MoEc systems, handling EmiratesId-based matching and multi-persona scenarios.

### PaymentOrchestrationService

Coordinates payment flow between IP Hub, MoEc fee calculation APIs, and the payment gateway, ensuring proper amount calculation and transaction tracking.

### CallbackHandlerService

Processes incoming callbacks from MoEc, validates authenticity, transforms external events into domain events, and triggers appropriate workflows.

### EntityRegistrationService

Manages legal entity registration and validation with MoEc's centralized entity service, handling document requirements and association with users.

## API Endpoints Specification

### Common/Foundational APIs

### User Profile Management

```markdown
POST /api/moec/user-profile/register
Description: Register new user profile in MoEc system
Request Body:
  - emiratesId: string (required)
  - uaePassLevel: integer (2 or 3, required)
  - fullName: string (required)
  - email: string (required)
  - phoneNumber: string (required)
  - persona: enum [Individual, Agent, CompanyRepresentative] (required)
Response:
  - moecUserId: string
  - registrationStatus: enum
  - registeredAt: timestamp

GET /api/moec/user-profile/{emiratesId}
Description: Retrieve user profile from MoEc by EmiratesId
Response:
  - moecUserId: string
  - emiratesId: string
  - registrationStatus: enum
  - associatedEntities: array of entityId
  - personas: array of persona types

```

### Legal Entity Management

```markdown
POST /api/moec/entity/register
Description: Register legal entity with MoEc centralized service
Request Body:
  - entityType: enum [Government, ResearchCenter, Individual, Company, Agent]
  - entityName: string (required)
  - registrationNumber: string (optional for individuals)
  - documents: array of documentId (required)
  - associatedEmiratesId: string (required)
Response:
  - moecEntityId: string
  - registrationStatus: enum
  - validationRequired: boolean

GET /api/moec/entity/{entityId}
Description: Retrieve entity information from MoEc
Response:
  - moecEntityId: string
  - entityType: enum
  - registrationStatus: enum
  - associatedUsers: array of emiratesId

```

### Payment APIs

```markdown
POST /api/moec/payment/calculate-fees
Description: Calculate payment amount for application
Request Body:
  - applicationId: string (required)
  - applicationType: enum [Patent, Trademark, Copyright]
  - formData: object (application-specific data for calculation)
Response:
  - amount: decimal
  - currency: string (AED)
  - calculationBreakdown: object
  - expiresAt: timestamp

POST /api/moec/payment/initiate
Description: Initiate payment flow and get checkout ID
Request Body:
  - applicationId: string (required)
  - amount: decimal (required)
  - emiratesId: string (required)
Response:
  - checkoutId: string
  - paymentGatewayUrl: string (redirect URL)
  - transactionId: string
  - expiresAt: timestamp

POST /api/moec/payment/confirm
Description: Confirm payment completion (called after gateway redirect)
Request Body:
  - transactionId: string (required)
  - checkoutId: string (required)
  - paymentStatus: enum [Completed, Failed, Cancelled]
Response:
  - confirmed: boolean
  - applicationStatus: enum

```

### Copyright Application APIs

### Copyright Form Submission

```markdown
POST /api/moec/copyright/application/submit-form
Description: Submit copyright application form data to MoEc
Request Body:
  - applicationId: string (required)
  - emiratesId: string (required)
  - entityId: string (optional)
  - applicantType: enum [Author, Disposer, LegalPerson, AuthorOnBehalf]
  - workTitle: string (required)
  - workType: enum (required)
  - creationDate: date (required)
  - publicationDate: date (optional)
  - workDescription: text (required)
  - authorsInfo: array of author objects
  - rightsInfo: object
  - additionalInfo: object
Response:
  - moecApplicationId: string
  - submissionStatus: enum
  - submittedAt: timestamp
  - nextSteps: array of required actions

```

### Copyright Document Upload

```markdown
POST /api/moec/copyright/application/upload-documents
Description: Upload required documents for copyright application
Request Body:
  - applicationId: string (required)
  - moecApplicationId: string (required)
  - documents: array of objects
    - documentType: enum [WorkSample, ProofOfCreation, PowerOfAttorney, IdentityDocument, etc.]
    - documentId: string (IP Hub document reference)
    - fileName: string
    - fileSize: integer
    - mimeType: string
    - base64Content: string (or URL for download)
Response:
  - uploadedDocuments: array of objects
    - documentId: string
    - moecDocumentReference: string
    - uploadStatus: enum [Success, Failed, ValidationRequired]
  - allDocumentsUploaded: boolean
  - applicationStatus: enum

```

### Patent Application APIs

### Patent Form Submission

```markdown
POST /api/moec/patent/application/submit-form
Description: Submit patent application form data to MoEc
Request Body:
  - applicationId: string (required)
  - emiratesId: string (required)
  - entityId: string (required for non-individuals)
  - applicantType: enum [Individual, Company, Government, ResearchCenter, Agent]
  - inventionTitle: string (required)
  - inventionType: enum (required)
  - fieldOfInvention: string (required)
  - backgroundArt: text (required)
  - summaryOfInvention: text (required)
  - detailedDescription: text (required)
  - claims: array of claim objects (required)
  - inventors: array of inventor objects (required)
  - priorityClaim: object (optional)
  - internationalFilingInfo: object (optional)
Response:
  - moecApplicationId: string
  - submissionStatus: enum
  - submittedAt: timestamp
  - workflowSteps: array of step objects
  - nextSteps: array of required actions

```

### Patent Document Upload

```markdown
POST /api/moec/patent/application/upload-documents
Description: Upload required documents for patent application
Request Body:
  - applicationId: string (required)
  - moecApplicationId: string (required)
  - documents: array of objects
    - documentType: enum [Specification, Claims, Drawings, Abstract, PowerOfAttorney, PriorityDocument, etc.]
    - documentId: string
    - fileName: string
    - fileSize: integer
    - mimeType: string
    - base64Content: string (or URL for download)
Response:
  - uploadedDocuments: array of objects
    - documentId: string
    - moecDocumentReference: string
    - uploadStatus: enum
  - allDocumentsUploaded: boolean
  - applicationStatus: enum

```

### Trademark Application APIs

### Trademark Form Submission (Old System)

```markdown
POST /api/moec/trademark/legacy/application/submit-form
Description: Submit trademark application to legacy MoEc system
Note: Integration feasibility to be confirmed by MoEc technical team
Request Body:
  - applicationId: string (required)
  - emiratesId: string (required)
  - entityId: string (required)
  - applicantType: enum
  - markType: enum [Word, Figurative, Combined, ThreeDimensional, Sound, etc.]
  - markRepresentation: string or file reference (required)
  - goodsAndServices: array of class objects (required)
  - distinctiveElements: text
  - translationIfApplicable: string
  - colorClaim: object (optional)
  - priorityClaim: object (optional)
Response:
  - moecApplicationId: string
  - submissionStatus: enum
  - submittedAt: timestamp
  - systemVersion: string (legacy)

```

### Trademark Document Upload (Old System)

```markdown
POST /api/moec/trademark/legacy/application/upload-documents
Description: Upload documents for trademark application (legacy system)
Request Body:
  - applicationId: string (required)
  - moecApplicationId: string (required)
  - documents: array of objects
    - documentType: enum [MarkImage, PowerOfAttorney, PriorityDocument, ProofOfUse, etc.]
    - documentId: string
    - fileName: string
    - fileSize: integer
    - mimeType: string
    - base64Content: string
Response:
  - uploadedDocuments: array of objects
  - applicationStatus: enum

```

### Callback/Webhook API (Inbound from MoEc)

### MoEc Status Update Callback

```markdown
POST /api/iphub/moec-callback/status-update
Description: Receive status updates from MoEc (single endpoint for all services)
Security: System-to-system authentication via GSB
Request Body:
  - moecApplicationId: string (required)
  - applicationId: string (IP Hub identifier, if available)
  - serviceType: enum [Patent, Trademark, Copyright]
  - eventType: enum [StatusChanged, DocumentRequested, PaymentRequired, Approved, Rejected, UnderReview, etc.]
  - newStatus: enum
  - message: string (optional)
  - actionRequired: boolean
  - requiredDocuments: array of document types (if applicable)
  - reviewerComments: text (optional)
  - timestamp: timestamp (required)
  - additionalData: object (flexible for service-specific info)
Response:
  - acknowledged: boolean
  - processedAt: timestamp
  - iphubApplicationStatus: enum

```

## Integration Patterns

### Anti-Corruption Layer (ACL)

The MoEc API Integration context implements an ACL to translate between IP Hub's ubiquitous language and MoEc's external system language, preventing MoEc concepts from leaking into other bounded contexts.

### Outbound Adapters

- **MoEcHttpApiAdapter:** REST API client for synchronous calls to MoEc endpoints
- **GovernmentServiceBusAdapter:** GSB-compliant communication adapter
- **PaymentGatewayAdapter:** Integration with MoEc payment gateway

### Inbound Adapters

- **MoEcCallbackController:** Receives and validates incoming callbacks from MoEc
- **CallbackAuthenticationMiddleware:** Validates GSB authentication tokens

### Retry and Resilience Policies

- **ExponentialBackoff:** For transient failures in API calls
- **CircuitBreaker:** Prevent cascading failures when MoEc services are unavailable
- **IdempotencyHandler:** Ensure duplicate submissions don't create multiple applications

## Data Synchronization Strategy

### User Profile Matching

EmiratesId is used as the primary correlation key between IP Hub and MoEc user profiles. On first submission, if no MoEc profile exists, the system creates one via the user registration API.

### Application Status Synchronization

Application status is synchronized bidirectionally: IP Hub pushes submissions to MoEc, and MoEc pushes status updates back via callbacks. The MoEcApplication aggregate maintains both statuses for audit purposes.

### Document Synchronization

Documents are stored in IP Hub's Document Management context but references (MoEcDocumentReference) are maintained in the MoEc integration context after successful upload.

## Security Considerations

- **System-to-System Authentication:** All API calls authenticated via GSB-provided credentials
- **UAE Pass Integration:** Users must authenticate with UAE Pass (Level 2 or 3) before submission
- **Data Encryption:** All sensitive data encrypted in transit (TLS 1.3) and at rest
- **Audit Logging:** All API calls, callbacks, and status changes logged for compliance
- **Rate Limiting:** Implement rate limiting to prevent abuse of MoEc APIs
- **Webhook Signature Validation:** Validate callback authenticity using GSB-provided signatures

## Technical Constraints

- **Frontend Business Logic Migration:** MoEc's current system has business logic in the frontend that must be replicated in API layer
- **Payment Flow Restriction:** Payment must flow through MoEc system for fee calculation consistency
- **Legacy Trademark System:** Integration with old trademark system requires separate technical assessment (feasibility uncertain)
- **Entity Registration Dependency:** Legal entities must be registered in MoEc's centralized service before application submission
- **Multi-Persona Support:** System must support users applying in different capacities (individual, agent, company representative)
- **Document Size Limits:** Large patent documents may require chunked upload approach

## Implementation Roadmap

### Phase 1: Foundation (Common APIs)

- User Profile Registration API
- Legal Entity Registration API
- Payment Calculation & Initiation APIs
- Callback Handler Infrastructure

**Estimated Timeline:** To be assessed by MoEc team

### Phase 2: Copyright Services

- Copyright Form Submission API
- Copyright Document Upload API
- Copyright-specific Callback Handlers

**Estimated Timeline:** To be provided by MoEc IT team (internal development)

**Priority Rationale:** Less complex, managed internally by MoEc, serves as integration pilot

### Phase 3: Patent Services

- Patent Form Submission API
- Patent Document Upload API
- Patent-specific Workflow Synchronization

**Estimated Timeline:** Months (vendor-dependent)

**Note:** ~10 workflow steps, external examination system integration required

### Phase 4: Trademark Services

- Assess feasibility of legacy system integration
- If feasible: Trademark Legacy APIs
- If not feasible: Wait for new system migration (~1 year)
- Trademark Form Submission API (new system)
- Trademark Document Upload API (new system)

## Testing Strategy

### Integration Testing

- Mock MoEc API endpoints for IP Hub development
- GSB Staging Environment for pre-production validation
- End-to-end testing with MoEc team before production release

### Contract Testing

- API interface specifications shared by MoEc for contract-based development
- Consumer-driven contract tests to ensure backward compatibility

### Resilience Testing

- Simulate MoEc service outages to validate retry logic
- Test idempotency of submission APIs
- Validate callback processing under high load

## Monitoring and Observability

- **API Call Metrics:** Track success rates, response times, and error rates for each endpoint
- **Submission Funnel Tracking:** Monitor application progression from IP Hub to MoEc
- **Callback Processing Metrics:** Track callback receipt, processing time, and failure rates
- **Synchronization Lag Monitoring:** Alert when status synchronization delays exceed thresholds
- **Document Upload Success Rates:** Track document upload failures by type and size
- **Payment Flow Completion Rates:** Monitor payment initiation vs. completion rates

## Open Questions for MoEc Team

- Exact timeline assessment for copyright service integration
- Technical documentation of current system workflows and business rules
- Backend role definitions and permissions structure
- Feasibility of integrating with legacy trademark system
- Detailed patent examination workflow steps and external system integration points
- GSB onboarding process timeline and requirements post-MOU
- API interface specifications for mock implementation
- Direct payment gateway redirect feasibility assessment