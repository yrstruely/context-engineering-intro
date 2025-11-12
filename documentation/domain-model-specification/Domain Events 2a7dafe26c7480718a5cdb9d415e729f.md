# Domain Events

# Domain Events Catalogue by Bounded Context

## [Identity Management Context](Identity%20Management%20Context%2029adafe26c748019be0fd2e0e95195ff.md)

- **UserRegistered:** New user account created in system
- **UserAuthenticatedViaUAEPass:** User successfully authenticated through UAE Pass OAuth2
- **UserVerified:** User identity verified against Emirates ID
- **UserProfileCompleted:** User finished required profile information
- **UserRoleAssigned:** Role granted to user (system or organization level)
- **UserRoleRevoked:** Role removed from user
- **UserSuspended:** User account temporarily disabled
- **UserDeactivated:** User account permanently disabled
- **OrganizationRegistered:** New organization created in system
- **OrganizationVerified:** Organization's legal status verified via trade license
- **OrganizationMemberInvited:** User invited to join organization
- **OrganizationMemberJoined:** User accepted invitation and joined organization
- **OrganizationMemberRoleChanged:** Member's role within organization modified
- **OrganizationMemberRemoved:** User removed from organization
- **OrganizationLicenseExpired:** Organization's trade license has expired
- **OrganizationSuspended:** Organization temporarily unable to perform operations
- **PermissionGranted:** Specific permission assigned to user or role
- **PermissionRevoked:** Permission removed from user or role
- **AuthenticationFailed:** Login attempt failed
- **MFAEnabled:** Multi-factor authentication activated for user

## [Patent Application Context](Patent%20Application%20Context%2029adafe26c7480dc9f3aff915cdbdd95.md)

- **PatentApplicationDrafted:** Initial application created by user
- **PatentApplicationSubmitted:** Application filed with UAE patent office
- **FormalExaminationStarted:** Initial formal review commenced
- **FormalExaminationCompleted:** Formal requirements verified
- **SubstantiveExaminationStarted:** Technical examination initiated
- **OfficialActionIssued:** Patent office requires response or provides feedback
- **ApplicantResponseSubmitted:** Response to official action filed
- **PatentGranted:** Patent approved and certificate issued
- **PatentRejected:** Application denied with reasons
- **PatentWithdrawn:** Applicant withdraws application
- **PatentAbandoned:** Application abandoned due to non-response
- **PatentPublished:** Application published in official gazette
- **PriorityClaimAdded:** Priority claim added or modified
- **ClaimsAmended:** Patent claims modified during prosecution

## [Copyright Application Context](Copyright%20Application%20Context%2029adafe26c7480dea4d3d4db1809926f.md)

- **CopyrightApplicationDrafted:** Initial application created by user
- **CopyrightApplicationSubmitted:** Application filed with UAE copyright office
- **FormalReviewStarted:** Initial review of application completeness commenced
- **FormalReviewCompleted:** Formal requirements verified
- **AdditionalDocumentsRequested:** Copyright office requires supplementary materials
- **ApplicantDocumentsSubmitted:** Response with requested documents filed
- **CopyrightRegistered:** Copyright approved and certificate issued
- **CopyrightRejected:** Application denied with reasons
- **CopyrightWithdrawn:** Applicant withdraws application
- **CopyrightCancelled:** Registration cancelled (voluntarily or by authority)
- **AuthorAdded:** Additional author or co-author added to application
- **RightsTransferred:** Ownership rights transferred to new rights holder
- **WorkSampleDeposited:** Work sample or deposit copy submitted
- **RegistrationRenewed:** Registration renewed (if applicable for certain work types)

## [Trademark Application Context](Trademark%20Application%20Context%2029adafe26c74806c9319c04fd34f2905.md)

- **TrademarkApplicationDrafted:** Initial application created by user
- **TrademarkApplicationSubmitted:** Application filed with UAE trademark office
- **FormalExaminationStarted:** Initial formal review commenced
- **FormalExaminationCompleted:** Formal requirements verified
- **SubstantiveExaminationStarted:** Technical examination initiated (distinctiveness, conflicts)
- **OfficialActionIssued:** Trademark office requires response or provides feedback
- **ApplicantResponseSubmitted:** Response to official action filed
- **TrademarkPublished:** Application published in official gazette for opposition
- **OppositionFiled:** Third party files opposition to trademark
- **OppositionPeriodExpired:** Opposition period ended without challenges
- **TrademarkAccepted:** Application approved for registration
- **TrademarkRegistered:** Certificate of registration issued
- **TrademarkRefused:** Application denied with reasons
- **TrademarkWithdrawn:** Applicant withdraws application
- **TrademarkAbandoned:** Application abandoned due to non-response
- **TrademarkRenewed:** Registration renewed for additional 10-year term
- **TrademarkCancelled:** Registration cancelled (non-use, legal grounds)
- **TrademarkExpired:** Registration expired due to non-renewal
- **PriorityClaimAdded:** Priority claim added or modified
- **ClassesAmended:** Goods/services classes modified during prosecution

## [Shared Kernel Context](Shared%20Kernel%20Context%2029adafe26c7480a69db2d1b78aaa9d72.md)

- **ApplicationNumberAssigned:** ApplicationId, ApplicationNumber, ApplicationType, AssignedDate
- **ApplicationStatusChanged:** ApplicationId, OldStatus, NewStatus, ChangedBy, ChangedDate, Reason
- **FeeCalculated:** ApplicationId, FeeType, Amount, CalculationDate, DueDate
- **PaymentReceived:** ApplicationId, PaymentReference, Amount, PaymentDate, PaymentMethod
- **DocumentUploaded:** ApplicationId, DocumentId, DocumentType, UploadedBy, UploadDate
- **DocumentVerified:** DocumentId, VerifiedBy, VerificationDate, VerificationNotes
- **OfficialCommunicationSent:** ApplicationId, CommunicationType, Recipient, SentDate, DeliveryMethod
- **DeadlineApproaching:** ApplicationId, DeadlineType, DeadlineDate, DaysRemaining
- **DeadlineMissed:** ApplicationId, DeadlineType, DeadlineDate, MissedDate

## [Document Management Context](Document%20Management%20Context%2029adafe26c7480119d90ca6b3d401d14.md)

- **DocumentCreated:** Published when a new document is created
- **DocumentUpdated:** Published when a document is modified
- **DocumentVersioned:** Published when a new version is created
- **DocumentArchived:** Published when a document is archived
- **DocumentDeleted:** Published when a document is permanently deleted
- **DocumentAccessGranted:** Published when access permissions are granted
- **DocumentAccessRevoked:** Published when access permissions are revoked

## [Workflow & Status Tracking Context](Worfklow%20&%20Status%20Tracking%20Context%2029adafe26c7480acbafdfb696436862a.md)

- **WorkflowInstanceStarted:** Published when a new workflow instance begins
- **WorkflowStageChanged:** Published when a workflow transitions to a new stage
- **WorkflowInstanceCompleted:** Published when a workflow instance finishes
- **WorkflowInstanceSuspended:** Published when a workflow is suspended
- **TaskCreated:** Published when a new task is created
- **TaskAssigned:** Published when a task is assigned to a user
- **TaskCompleted:** Published when a task is completed
- **TaskEscalated:** Published when a task deadline is exceeded
- **MilestoneAchieved:** Published when a workflow milestone is reached
- **TransitionValidationFailed:** Published when a status transition fails validation

## [Fee Calculation & Payment Context](Fee%20calculation%20&%20Payment%2029adafe26c74803ea383cebe9f3d47f9.md)

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

## [Translation Context](Translation%20Context%2029adafe26c7480a29c22ebc0e6f48fae.md)

- **TranslationRequestSubmitted:** Triggered when a new translation is requested
- **TranslatorAssigned:** Triggered when a translator is assigned to a task
- **TranslationCompleted:** Triggered when translator completes work
- **QualityReviewInitiated:** Triggered when translation enters QA phase
- **TranslationApproved:** Triggered when QA approves translation
- **TranslationRejected:** Triggered when translation fails QA and requires rework
- **TranslationDelivered:** Triggered when approved translation is delivered to requesting context

## [Jurisdiction Context](Jurisdiction%20Context%2029adafe26c748000be15e7b5acf05538.md)

- **JurisdictionAdded:** A new jurisdiction has been added to a filing strategy
- **NationalPhaseEntryInitiated:** PCT application entering national phase in a jurisdiction
- **JurisdictionDeadlineApproaching:** Critical deadline approaching in a specific jurisdiction
- **JurisdictionRequirementChanged:** Local requirements updated by jurisdiction office
- **ApplicationStatusChangedInJurisdiction:** Status update from a specific jurisdiction office
- **PriorityClaimEstablished:** Priority claim established between applications in different jurisdictions
- **JurisdictionalDocumentRequired:** Jurisdiction-specific document needed
- **CrossBorderValidationCompleted:** Validation of application across jurisdictions completed

## [Enforcement Context](Enforcement%20Context%2029adafe26c748051ab7fd2139b5887f4.md)

- **InfringementDetected:** Potential infringement has been identified
- **InfringementCaseOpened:** Formal infringement case has been initiated
- **EnforcementActionInitiated:** Enforcement action (cease and desist, opposition, litigation) has been started
- **CeaseAndDesistIssued:** Cease and desist letter sent to infringing party
- **OppositionFiled:** Opposition filed against infringing application
- **LitigationCommenced:** Lawsuit filed in a jurisdiction
- **SettlementReached:** Settlement agreement concluded with infringing party
- **JudgmentIssued:** Court or tribunal judgment rendered
- **CustomsSeizureMade:** Customs authority seized infringing goods
- **EnforcementCaseClosed:** Infringement case concluded
- **AppealFiled:** Appeal initiated against enforcement decision
- **EnforcementDeadlineApproaching:** Critical deadline for enforcement action approaching

## [Commercialization Context](Commercialization%20Context%2029adafe26c74809c9876fcac63e8580d.md)

- **AssetReadyForCommercialization:** IP asset has reached appropriate stage for commercialization activities
- **CommercializationStrategyDefined:** Strategy for commercializing an asset has been established
- **LicensingNegotiationStarted:** Licensing discussions initiated with potential partner
- **LicenseAgreementExecuted:** License agreement has been signed and is now active
- **TerritoryGranted:** Commercialization rights granted for specific jurisdiction(s)
- **RoyaltyPaymentReceived:** Royalty payment received from licensee
- **RoyaltyPaymentOverdue:** Expected royalty payment not received by due date
- **MilestoneAchieved:** Commercialization milestone reached by partner
- **ValuationUpdated:** IP asset valuation revised based on new information
- **MarketOpportunityIdentified:** New commercialization opportunity discovered
- **LicenseTerminationInitiated:** Process to terminate license agreement started
- **TechnologyTransferCompleted:** Technology successfully transferred to partner
- **RevenueThresholdExceeded:** Revenue from asset exceeded projected threshold
- **ComplianceIssueDetected:** Compliance issue identified in commercialization activities

## [Platform Administration Context](Platform%20Administration%20Context%2029adafe26c74804f9d44fe1e4755ce19.md)

- **PlatformConfigurationChanged:** System-wide configuration has been updated
- **FeatureFlagToggled:** A feature flag has been enabled or disabled
- **OrganizationalUnitCreated:** New department, team, or office has been added
- **OrganizationalUnitRestructured:** Organizational hierarchy has been modified
- **RoleDefinitionUpdated:** A role's permissions have been modified
- **UserRoleAssigned:** A user has been assigned a new role
- **UserRoleRevoked:** A user's role has been removed
- **WorkflowTemplatePublished:** New workflow template available for use
- **JurisdictionEnabled:** A jurisdiction has been enabled for platform use
- **JurisdictionDisabled:** A jurisdiction has been disabled
- **ServiceProviderRegistered:** New external service provider has been configured
- **ServiceProviderStatusChanged:** Service provider availability or status updated
- **ComplianceReportGenerated:** Scheduled compliance report has been created
- **SecurityEventDetected:** Security-related event requiring attention
- **SystemMaintenanceScheduled:** Planned maintenance window announced
- **DataRetentionPolicyApplied:** Data archival or deletion executed per policy

## [IP Asset Management Context](IP%20Asset%20Management%20Context%2029adafe26c7480a5a83bece8920bcece.md)

- **IPAssetEntityCreated:** New asset entity type defined in the system
- **IPAssetVariantCreated:** Jurisdiction-specific variant created from entity
- **IPAssetInstanceCreated:** Real-world asset instance created from variant
- **AssetVersionCommitted:** New version created due to asset changes
- **AssetRevisionSubmitted:** Official submission made to IP office
- **AssetStatusChanged:** Lifecycle status changed in jurisdiction
- **AssetAttributesUpdated:** Asset attributes modified
- **AssetDocumentAttached:** Document linked to asset from Document Management context
- **AssetTransitionedToJurisdiction:** Asset expanding to new jurisdiction
- **AssetMerged:** Multiple assets combined (e.g., portfolio consolidation)
- **AssetSplit:** Asset divided into multiple assets
- **AssetArchivedOrAbandoned:** Asset end-of-life event

## [Notifications Context](Notifications%20Context%2029adafe26c7480c393aff436e66cd674.md)

### Notification Lifecycle Events

- **NotificationCreated:** New notification created in the system
- **NotificationQueued:** Notification queued for delivery
- **NotificationSent:** Notification successfully sent through delivery channel
- **NotificationDelivered:** Notification confirmed delivered to recipient
- **NotificationFailed:** Notification delivery failed
- **NotificationRetrying:** Notification delivery being retried
- **NotificationRead:** User opened/read notification
- **NotificationClicked:** User clicked through notification link
- **NotificationDismissed:** User dismissed notification
- **NotificationExpired:** Notification expired without delivery or reading

### Preference & Configuration Events

- **NotificationPreferenceUpdated:** User changed notification preferences
- **NotificationChannelEnabled:** User enabled notification channel
- **NotificationChannelDisabled:** User disabled notification channel
- **NotificationTypeSubscribed:** User subscribed to notification type
- **NotificationTypeUnsubscribed:** User unsubscribed from notification type

### Template & Schedule Events

- **NotificationTemplateCreated:** New template created
- **NotificationTemplateUpdated:** Template modified
- **NotificationScheduleCreated:** Scheduled notification configured
- **NotificationScheduleCancelled:** Scheduled notification cancelled
- **NotificationDigestGenerated:** Digest compiled and ready for delivery

## [User Behavior Tracking and Analytics Context](User%20Behavior%20Tracking%20and%20Analytics%20Context%2029adafe26c748088970de6696a7e4113.md)

- **UserSessionStarted:** New user session initiated
- **UserSessionEnded:** User session concluded
- **BehaviorEventCaptured:** Individual user action or system event recorded
- **UserJourneyStarted:** User begins a tracked journey (e.g., application creation)
- **UserJourneyCompleted:** User successfully completes a journey
- **UserJourneyAbandoned:** User drops off from journey without completion
- **AnalyticsReportGenerated:** New report created and available
- **FeatureUsageRecorded:** Feature interaction tracked
- **UserSegmentCreated:** New user segment defined
- **UserSegmentUpdated:** Segment membership or criteria changed
- **ExperimentCreated:** New A/B test or experiment initiated
- **ExperimentVariantAssigned:** User assigned to experiment variant
- **ExperimentCompleted:** Experiment concluded with results
- **PerformanceThresholdExceeded:** Performance metric exceeds defined threshold
- **AnomalyDetected:** Unusual pattern or anomaly identified in user behavior
- **InsightGenerated:** System generates actionable insight from data analysis

## [Professional Services Labor Marketplace Context](Professional%20Services%20Labor%20Marketplace%20Context%2029adafe26c7480deaf4df10e6b66d706.md)

### Service Request Lifecycle Events

- **ServiceRequestCreated:** New service request posted by asset creator
- **ServiceRequestPublished:** Request made visible to service providers
- **ServiceRequestAssigned:** Request assigned to specific provider
- **ServiceRequestWithdrawn:** Request cancelled by creator
- **ServiceRequestExpired:** Request expired without engagement

### Proposal Events

- **ProposalSubmitted:** Provider submitted proposal for request
- **ProposalUpdated:** Provider revised their proposal
- **ProposalAccepted:** Creator accepted provider's proposal
- **ProposalRejected:** Creator rejected provider's proposal
- **ProposalWithdrawn:** Provider withdrew their proposal

### Engagement Lifecycle Events

- **EngagementCreated:** Service engagement initiated
- **EngagementStarted:** Service work commenced
- **EngagementMilestoneReached:** Engagement milestone achieved
- **EngagementAmended:** Engagement terms modified
- **EngagementPaused:** Engagement temporarily suspended
- **EngagementResumed:** Paused engagement resumed
- **EngagementCompleted:** Service engagement finished
- **EngagementCancelled:** Engagement terminated early
- **EngagementDisputed:** Dispute raised regarding engagement

### Deliverable Events

- **DeliverableSubmitted:** Provider submitted deliverable
- **DeliverableUnderReview:** Creator reviewing deliverable
- **DeliverableRevisionRequested:** Creator requested revisions
- **DeliverableApproved:** Creator approved deliverable
- **DeliverableRejected:** Creator rejected deliverable

### Provider Events

- **ProviderRegistered:** New service provider joined platform
- **ProviderProfileUpdated:** Provider updated their profile
- **ProviderCredentialAdded:** Provider added credential
- **ProviderCredentialVerified:** Platform verified provider credential
- **ProviderAvailabilityChanged:** Provider availability status changed
- **ProviderSuspended:** Provider suspended from platform
- **ProviderReactivated:** Suspended provider reactivated

### Payment & Fee Events

- **ServicePaymentDue:** Payment due for service milestone
- **ServicePaymentProcessed:** Payment processed for service
- **PlatformFeeCalculated:** Platform fee calculated for engagement
- **PlatformFeeCollected:** Platform fee successfully collected
- **ProviderPayoutInitiated:** Payout to provider initiated
- **ProviderPayoutCompleted:** Provider received payment

### Review Events

- **ReviewSubmitted:** Client submitted provider review
- **ReviewPublished:** Review made publicly visible
- **ProviderRespondedToReview:** Provider responded to review
- **ReviewFlagged:** Review flagged for moderation

## [IP Asset Marketplace Context](IP%20Asset%20Marketplace%20Context%2029adafe26c74804e9451f3db2458171c.md)

### Listing Lifecycle Events

- **ListingCreated:** New marketplace listing created
- **ListingPublished:** Listing activated and visible in marketplace
- **ListingUpdated:** Listing details modified
- **ListingFeatured:** Listing promoted to featured status
- **ListingSuspended:** Listing temporarily suspended
- **ListingExpired:** Listing reached expiration date
- **ListingRenewed:** Expired listing renewed for new period
- **ListingWithdrawn:** Seller withdrew listing before sale
- **ListingSold:** Asset sold through marketplace
- **ListingLicensed:** Asset licensed through marketplace

### Offer & Negotiation Events

- **OfferSubmitted:** Buyer submitted offer on listing
- **OfferReceived:** Seller received offer notification
- **OfferCountered:** Seller countered with different terms
- **OfferAccepted:** Offer accepted by seller
- **OfferRejected:** Offer rejected by seller
- **OfferExpired:** Offer expired without response
- **OfferWithdrawn:** Buyer withdrew offer
- **NegotiationStarted:** Negotiation process initiated
- **NegotiationConcluded:** Negotiation reached agreement

### Transaction Events

- **TransactionInitiated:** Purchase or license transaction started
- **PaymentRequested:** Buyer payment requested
- **PaymentReceived:** Buyer payment confirmed
- **FundsEscrowed:** Funds held in escrow pending completion
- **PlatformFeeCalculated:** Platform fee calculated from transaction
- **PlatformFeeCollected:** Platform fee deducted
- **SellerPayoutInitiated:** Seller payout processed
- **SellerPayoutCompleted:** Seller received funds
- **TransactionCompleted:** Transaction fully completed
- **TransactionCancelled:** Transaction cancelled before completion
- **TransactionDisputed:** Dispute raised on transaction
- **DisputeResolved:** Transaction dispute resolved

### Transfer Events

- **AssetTransferInitiated:** Asset ownership transfer started
- **TransferDocumentationGenerated:** Transfer documents prepared
- **TransferDocumentsSigned:** All parties signed transfer documents
- **TransferRecorded:** Transfer recorded with jurisdiction authorities
- **TransferCompleted:** Asset ownership fully transferred
- **LicenseGranted:** License rights granted to buyer

### Participant Events

- **ParticipantRegistered:** User registered as marketplace participant
- **ParticipantVerified:** Participant identity verified
- **ParticipantRated:** Participant received rating from transaction partner
- **ReviewPosted:** Review posted for participant
- **ParticipantSuspended:** Participant suspended from marketplace

## [MoEc API Integration Bounded Context](MoEc%20API%20Integration%20Bounded%20Context%202a7dafe26c74802998f7dd2b2cda75bb.md)

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