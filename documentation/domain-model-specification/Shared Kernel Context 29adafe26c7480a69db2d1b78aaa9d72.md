# Shared Kernel Context

Create a high level DDD definition specification md for Shared Kernel Bounded Context referencing on existing references in the Identity Management, Patent, Trademark And Copyright Application contexts that you already have. 

# Shared Kernel Bounded Context - DDD Specification

## Context Overview

The Shared Kernel Context contains common domain concepts, value objects, and business rules that are shared across multiple bounded contexts in the IP Hub system. This kernel provides a stable foundation of shared abstractions used by Identity Management, Patent Application, Trademark Application, and Copyright Application contexts. It ensures consistency in how fundamental IP concepts are represented and validated across the entire system.

## Shared Aggregates

### Address (Value Object / Entity)

- **Attributes:** StreetAddress, Building, Floor, Apartment, Area, City, Emirate, POBox, Country, PostalCode, IsVerified
- **Invariants:** Emirate must be valid UAE emirate if Country is UAE, Street address and City are required
- **Business Rules:** UAE addresses must follow MOE addressing standards, P.O. Box mandatory for official correspondence

### ContactInformation (Value Object)

- **Attributes:** PrimaryEmail, SecondaryEmail, PrimaryPhone, SecondaryPhone, Fax, PreferredContactMethod
- **Invariants:** At least one email and one phone number required, email format validation, phone number in E.164 format
- **Business Rules:** Primary contact must be verified for official communications

### ApplicantReference (Value Object)

- **Attributes:** ApplicantId, ApplicantType (Individual/Organization), ApplicantName, EmiratesId/TradeLicenseNumber
- **Invariants:** Reference must point to verified user or organization from Identity Management context
- **Business Rules:** Applicant must be active and verified at time of application submission

## Shared Value Objects

### Core Value Objects

- **Money:** Amount (decimal), Currency (AED, USD, EUR, etc.), ExchangeRate, CalculationDate
- **DateRange:** StartDate, EndDate, validation ensuring EndDate ≥ StartDate
- **LocalizedText:** TextInArabic, TextInEnglish, PreferredLanguage
- **OfficialReference:** ReferenceType, ReferenceNumber, IssuingAuthority, IssueDate, ExpiryDate
- **Nationality:** CountryCode (ISO 3166), CountryName (Arabic/English)
- **Language:** LanguageCode (ar, en, etc.), LanguageName

### IP-Specific Value Objects

- **ApplicationNumber:** Year, SequenceNumber, ApplicationType, FormattedNumber (e.g., P/2025/00123)
- **RegistrationNumber:** Year, SequenceNumber, RegistrationType, FormattedNumber
- **PriorityClaimReference:** CountryCode, ApplicationNumber, FilingDate, AcceptedConvention
- **ClassificationCode:** ClassificationSystem (IPC, Nice, Locarno), Code, Description
- **ApplicationStatus:** Draft, Submitted, UnderExamination, Published, Registered, Rejected, Withdrawn, Expired, Abandoned
- **FeeType:** FilingFee, ExaminationFee, PublicationFee, RegistrationFee, RenewalFee, AppealFee, TranslationFee
- **IPRightType:** Patent, UtilityModel, IndustrialDesign, Trademark, ServiceMark, CollectiveMark, Copyright, RelatedRight

### Document Value Objects

- **DocumentMetadata:** FileName, FileSize, MimeType, UploadDate, DocumentType, Language, PageCount, Hash
- **DocumentType:** PowerOfAttorney, PriorityDocument, SpecificationDocument, ClaimsDocument, DrawingsDocument, AbstractDocument, ProofOfPayment, TradeLicense, EmiratesID, etc.
- **DocumentStatus:** Pending, Verified, Rejected, RequiresRevision

### Geographic Value Objects

- **Emirate:** AbuDhabi, Dubai, Sharjah, Ajman, UmmAlQuwain, RasAlKhaimah, Fujairah
- **Country:** CountryCode (ISO 3166), CountryNameAr, CountryNameEn, IsGCCMember, IsParisConventionMember, IsPCTMember
- **GeographicScope:** UAE, GCC, Arab, International

## Shared Domain Events

- **ApplicationNumberAssigned:** ApplicationId, ApplicationNumber, ApplicationType, AssignedDate
- **ApplicationStatusChanged:** ApplicationId, OldStatus, NewStatus, ChangedBy, ChangedDate, Reason
- **FeeCalculated:** ApplicationId, FeeType, Amount, CalculationDate, DueDate
- **PaymentReceived:** ApplicationId, PaymentReference, Amount, PaymentDate, PaymentMethod
- **DocumentUploaded:** ApplicationId, DocumentId, DocumentType, UploadedBy, UploadDate
- **DocumentVerified:** DocumentId, VerifiedBy, VerificationDate, VerificationNotes
- **OfficialCommunicationSent:** ApplicationId, CommunicationType, Recipient, SentDate, DeliveryMethod
- **DeadlineApproaching:** ApplicationId, DeadlineType, DeadlineDate, DaysRemaining
- **DeadlineMissed:** ApplicationId, DeadlineType, DeadlineDate, MissedDate

## Shared Domain Services

### ApplicationNumberGeneratorService

Generates unique application numbers following UAE MOE format conventions. Manages sequential number allocation per application type per year. Ensures no collisions across different IP right types.

### FeeCalculationService

Calculates fees based on application type, number of claims/classes, filing route (national/international), applicant type (individual/organization/small entity), and current fee schedule. Applies discounts and surcharges as per MOE regulations.

### LocalizationService

Manages bilingual (Arabic/English) content throughout the system. Handles translation requirements for official documents. Ensures compliance with Arabic-first language policy for official communications.

### AddressValidationService

Validates UAE addresses against standard format. Integrates with Emirates Post address verification systems. Normalizes address data for consistency.

### DeadlineCalculationService

Calculates statutory deadlines based on filing dates, publication dates, and examination dates. Accounts for UAE weekends (Friday-Saturday), public holidays, and grace periods. Provides deadline extensions based on regulations.

### PriorityValidationService

Validates priority claims against Paris Convention rules. Verifies priority dates fall within 12-month window (patents) or 6-month window (trademarks/designs). Confirms priority countries are Paris Convention members.

## Shared Repository Interfaces

- **IApplicationNumberRepository:** Get next sequence number for application type and year, record assigned number
- **IFeeScheduleRepository:** Get current fee schedule, get historical fees for date range, get fee by type
- **ICountryRepository:** Find by code, find all convention members, find GCC members
- **IClassificationRepository:** Find IPC codes, find Nice classes, find Locarno classes, search by keyword
- **IHolidayCalendarRepository:** Get UAE holidays for year, check if date is working day

## Shared Business Rules & Invariants

### Application Rules

- Application number assigned only after successful submission and validation
- Application number format: {Type}/{Year}/{Sequence} (e.g., P/2025/00123)
- Arabic content required for all official documents and correspondence
- Filing date is date of receipt of minimum requirements (application form, description, applicant details)
- All statutory fees must be paid before registration grant

### Priority Claim Rules

- Priority claim must be filed within 12 months for patents/utility models
- Priority claim must be filed within 6 months for trademarks/industrial designs
- Priority country must be Paris Convention or WTO member
- Priority documents must be submitted within 3 months of filing (extensible to 16 months)
- Multiple priorities allowed if from same or different applications

### Document Rules

- All documents must be in Arabic or accompanied by certified Arabic translation
- PDF/A format preferred for long-term archival
- Maximum file size per document: 50MB
- Minimum resolution for technical drawings: 300 DPI
- Power of Attorney must be notarized and legalized if from outside UAE

### Fee Rules

- All fees in UAE Dirhams (AED)
- 50% discount for individual inventors and small entities (defined as organizations with <50 employees)
- Fee schedule updated annually by MOE
- Late payment surcharge: 10% per month up to maximum 100%
- Refund policy: 50% refund if application withdrawn before examination

### Deadline Rules

- Deadlines calculated in months or days from triggering event
- If deadline falls on non-working day, extended to next working day
- UAE weekend: Friday-Saturday
- Grace period: 2 months for most deadlines with surcharge
- Extensions available for certain deadlines with justified cause

## UAE-Specific Requirements in Shared Kernel

### Language Requirements

- Arabic is the official language for all legal documents and official communications
- Bilingual interface (Arabic/English) for user convenience
- Right-to-left (RTL) layout support for Arabic content
- Certified translation requirements for non-Arabic documents
- Arabic takes precedence in case of interpretation disputes

### Calendar & Timing

- Weekend: Friday-Saturday (non-working days)
- Working week: Sunday-Thursday
- UAE public holidays observed (National Day, Eid holidays, Islamic New Year, etc.)
- Islamic calendar considerations for religious holidays
- Timezone: Gulf Standard Time (GST, UTC+4)

### Address Standards

- Seven emirates: Abu Dhabi, Dubai, Sharjah, Ajman, Umm Al Quwain, Ras Al Khaimah, Fujairah
- Makani number support (Dubai addressing system)
- P.O. Box required for official correspondence
- Building/Villa number, Street name, Area, City, Emirate structure
- Integration with Emirates Post address validation

### Legal Entity Types

- Sole Proprietorship
- Limited Liability Company (LLC)
- Public Joint Stock Company (PJSC)
- Private Joint Stock Company
- Free Zone Company (FZ-LLC, FZ-CO)
- Branch of Foreign Company
- Civil Company
- Government Entity

### Regulatory Compliance

- Compliance with Federal Law No. 31 of 2006 (Industrial Property Rights)
- Compliance with Federal Law No. 37 of 1992 on Trademarks (as amended)
- Compliance with Federal Law No. 7 of 2002 on Copyrights and Related Rights
- GCC Patent Regulation considerations for regional applications
- PCT, Paris Convention, and Madrid Protocol implementation

## Integration Points

- **Identity Management Context:** Validates applicant references, retrieves user/organization details, checks verification status
- **Patent Application Context:** Uses application numbering, fee calculation, priority validation, document management
- **Trademark Application Context:** Uses Nice classification, fee calculation, application status workflow
- **Copyright Application Context:** Uses applicant references, fee calculation, document management
- **Payment Context:** Provides fee calculations, receives payment confirmations
- **Document Management Context:** Provides document metadata standards and validation rules
- **Notification Context:** Provides deadline calculations and status change events
- **Workflow Context:** Provides status transitions and business rule validations

## Ubiquitous Language - Shared Terms

- **Applicant:** Individual or organization filing an IP application (can be owner or representative)
- **Application:** Formal request to register intellectual property right
- **Filing Date:** Official date when minimum filing requirements are met
- **Priority Date:** Date of earliest application from which priority is claimed
- **Registration Date:** Date when IP right is officially granted and recorded
- **Publication:** Official disclosure of application details in IP Gazette
- **Examination:** Official review of application for compliance with legal requirements
- **Opposition:** Formal objection by third party to application grant
- **Certificate:** Official document evidencing IP right registration
- **Renewal:** Extension of IP right protection term through fee payment
- **Assignment:** Transfer of IP right ownership from one party to another
- **License:** Permission granted by owner for others to use IP right
- **Agent:** Licensed IP professional authorized to represent applicants
- **Representative:** Person or entity acting on behalf of applicant
- **Power of Attorney:** Legal document authorizing representative to act for applicant
- **Official Fee:** Statutory fee charged by IP office for services
- **Gazette:** Official publication of IP office for public notices
- **Specification:** Detailed description of invention or design
- **Claims:** Legal definitions of scope of protection sought
- **Class:** Category in classification system (IPC for patents, Nice for trademarks, etc.)

## Architectural Patterns

### Value Object Pattern

Extensive use of immutable value objects for domain concepts. Value objects are compared by value equality, not identity. Examples: Money, ApplicationNumber, DateRange, Address.

### Specification Pattern

Business rules encoded as specifications for validation and query filtering. Examples: ValidPriorityClaimSpecification, CompleteApplicationSpecification, EligibleForRegistrationSpecification.

### Strategy Pattern

Different calculation strategies for fees, deadlines, and classifications based on IP type and filing route. Enables flexibility as regulations change.

### Domain Event Pattern

Status changes, deadline events, and payment confirmations published as domain events for cross-context integration.

### Anti-Corruption Layer

Translation layer between shared kernel concepts and external systems (WIPO, EPO, international IP offices). Protects domain model from external complexity.

## Validation Rules

### Data Validation

- Emirates ID: 15 digits, valid checksum algorithm
- Trade License: Format varies by emirate and issuing authority
- Email: RFC 5322 compliant format
- Phone: E.164 format with country code (+971 for UAE)
- Date ranges: End date must be after or equal to start date
- Money amounts: Positive values, maximum 2 decimal places for AED

### Business Validation

- Applicant must exist and be verified before application submission
- Priority date must be before filing date
- Priority period must not have expired at time of claim
- All required documents must be uploaded before submission
- Fees must be calculated and presented before payment
- Status transitions must follow allowed workflow paths

## Key Metrics & KPIs

- Total applications filed (by type, by year, by month)
- Average processing time per application type
- Fee collection rates and outstanding fees
- Priority claim utilization rate
- Document rejection and resubmission rates
- Deadline compliance rates
- Translation turnaround time for non-Arabic documents
- System availability and performance

## Future Considerations

- Blockchain integration for immutable IP records and certificates
- AI-assisted classification and prior art searching
- Real-time integration with international IP offices (WIPO, EPO)
- Smart contracts for automated licensing and royalty payments
- Enhanced data analytics for IP trends and insights
- Integration with UAE digital economy initiatives
- Support for emerging IP types (AI-generated works, NFTs)
- Advanced machine translation for multi-language support
- Predictive analytics for application success probability
- Integration with UAE smart city infrastructure