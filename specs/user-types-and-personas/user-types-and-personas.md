# User types and personas for initial release (expanded)

Related Product & Strategy Documentation: [Internal] DNA team Scope Alignment & Implementation plan — For Discussion (https://www.notion.so/Internal-DNA-team-Scope-Alignment-Implementation-plan-For-Discussion-24edafe26c74805dbd86fcc26bf89d0d?pvs=21)
Last Updated: September 24, 2025
Category: Research & Discovery
Status: Foundation
Version: 1
Owner: Ciaran McLoughlin
Programme Phase: Phase 1 2025— Discovery Technical Solution & High level design & Product definition

![DFF-IP-Hub-Primary-Ueer-Profiles-23092025.png](User%20types%20and%20personas%20for%20initial%20release%20(expan%2024edafe26c7480b8acf6fa638a30cce2/DFF-IP-Hub-Primary-Ueer-Profiles-23092025.png)

## Executive summary

This document outlines the primary user types and personas for the initial scope of the Dubai IP Hub platform, focusing on patents as the core IP class with potential expansion to copyright. Users are categorised as Player One (external-facing) and Player Two (internal/behind-the-scenes), prioritising patents first with copyright considerations where differentiated.

**Updated following recent governance discussion in August ‘25:** Following the latest governance call, user personas have been expanded to include university tech transfer offices and VC/PE funds [recent governance call notes], recognising their significant roles in patent creation and commercialisation.

## Player One: External users

### Patents - Primary external user types

### 1. IP creators

**Definition:** Individuals and organisations seeking to protect their intellectual property through patent registration.

**Sub-categories identified:**

- **Startups and SMEs:** [Research insights ProjectKey_Booklet_Masterfile.pdf] "Startups can't afford just going to IP registration; it's a luxury" and report feeling "disadvantaged in navigating IP"
- **Researchers and academics:** Including university researchers and R&D teams [Research insights ProjectKey_Booklet_Masterfile.pdf] who lack legal guidance
- **Tech entrepreneurs:** Innovation-driven enterprises seeking patent protection [030424_PROJECT KEY_MOE_Share_V5.0.pdf]
- **Inventors:** Individual creators developing new technologies

**Key characteristics:**

- Limited IP knowledge and legal expertise [Research insights ProjectKey_Booklet_Masterfile.pdf] "Language was very overwhelming, especially for a student who doesn't know legal jargon"
- Cost-sensitive, particularly smaller entities [030424_PROJECT KEY_MOE_Share_V5.0.pdf]
- Need guided, simplified processes [Dubai IP Hub Technical Design 121224.pdf]
- Require multi-language support for non-native English speakers

**Platform needs:**

- Streamlined registration workflows [Dubai IP Hub Technical Design 121224.pdf]
- Guided application tools tailored to different IP asset types
- Educational resources integrated throughout the process
- Document templates and preparation guides
- Progress tracking for application status

### 2. IP managers

**Definition:** Professionals responsible for managing IP portfolios on behalf of organisations.

**Key characteristics:**

- Need oversight and administrative efficiency tools [Dubai IP Hub Technical Design 121224.pdf]
- Manage multiple IP assets across different categories
- Require comprehensive reporting and analytics
- Focus on compliance and deadline management

**Platform needs:**

- Centralised portfolio management with unified view of all IP assets [Dubai IP Hub Technical Design 121224.pdf]
- Automated notification systems for important dates and deadlines
- Document management features for IP-related documentation
- Reporting tools providing insights into portfolio performance
- Collaboration features for stakeholder communication

### 3. Legal advisors

**Definition:** Legal professionals providing IP-related services to clients.

**Key characteristics:**

- Represent clients in IP registration and enforcement matters [030424_PROJECT KEY_MOE_Share_V5.0.pdf] includes "Law Firms" and "IP Representatives"
- Need efficient client communication and case management tools
- Require secure document sharing capabilities
- Focus on compliance and audit trails

**Platform needs:**

- Collaborative workspaces for secure client interaction [Dubai IP Hub Technical Design 121224.pdf]
- Document-sharing features for sensitive information exchange
- Case management tools for enforcement activities
- Client communication systems for advisory services
- Comprehensive audit trails for all activities

### 4. University tech transfer offices (TTOs)

**Definition:** Commercialisation and licensing offices that handle patents on behalf of universities and research institutions.

**Key characteristics:**

- "Handle patents more than individual creators" [recent governance call] and play crucial roles in patent management and advocacy
- Manage technology transfer from research to commercial applications
- Need portfolio oversight across multiple research projects and inventors
- Focus on commercialisation and licensing opportunities
- Require coordination with researchers, legal teams, and commercial partners

**Platform needs:**

- Multi-project portfolio management capabilities
- Researcher collaboration and communication tools
- Commercialisation workflow and licensing management
- Revenue tracking and reporting for technology transfer
- Integration with university research management systems

### 5. VC/PE funds

**Definition:** Venture capital and private equity funds with investment portfolios requiring IP protection.

**Key characteristics:**

- "Often force their start-ups to register patents and have in-house teams to manage this process" [recent governance call]
- Represent influential stakeholders in the patent ecosystem
- Need oversight across portfolio companies' IP strategies
- Focus on IP value assessment and portfolio protection
- Require due diligence capabilities for investment decisions

**Platform needs:**

- Portfolio-wide IP tracking and analytics across investments
- Due diligence tools for IP assessment during investment evaluation
- Portfolio company collaboration and oversight capabilities
- IP valuation and strategic assessment tools
- Reporting dashboards for investment committee presentations

### Copyright - External user considerations

{While the documentation indicates copyright is being explored as another IP class [user request mentions "we may also try to do copyright"], the specific user types for copyright largely align with patents but may include additional creator types such as:}

- **Content creators:** Artists, writers, musicians, filmmakers
- **Media companies:** Publishers, production houses, digital content platforms
- **Software developers:** For code and digital asset protection

{Copyright users would likely follow similar patterns to patent users but with different registration workflows and protection mechanisms.}

## Player Two: Internal and partner users

### Patents - Internal Dubai client-side users

### 1. Ministry of Economy (MoEc) staff

**Definition:** Government officials responsible for IP registration processing and examination.

**Key characteristics:**

- Process and examine patent applications [Dubai IP Hub Technical Design 121224.pdf] mentions "IP registration processes" under MoEc oversight
- Need integration with existing OutSystems platform [Dubai IP Hub Technical Design 121224.pdf]
- Require workflow management and case tracking tools

**Platform needs:**

- Application review and processing workflows
- Integration with existing MoEc systems for submission and tracking
- Status update capabilities for applicant communication
- Validation tools against regulatory requirements

### 2. Dubai Future Foundation (DFF) staff

**Definition:** Strategic oversight and platform governance team.

**Key characteristics:**

- "The driving force behind the platform's strategic vision and development" [Dubai IP Hub Technical Design 121224.pdf]
- Need strategic insights and platform performance metrics
- Focus on ecosystem development and innovation support

**Platform needs:**

- Strategic reporting and analytics dashboards
- Platform usage and adoption metrics
- Innovation ecosystem insights and trends analysis

### 3. Dubai Customs officers

**Definition:** Border protection and IP enforcement personnel.

**Key characteristics:**

- "Supports enforcement by monitoring imports and exports for IP compliance" [Dubai IP Hub Technical Design 121224.pdf]
- Use separate IPR Plus system for IP registration and monitoring
- Need document preparation support rather than direct integration

**Platform needs:**

- Standardised document templates for customs registration
- Quality validation checks for IP documentation
- Clear guidance for customs complaint processes
- Document export capabilities for offline submission

### 4. Enforcement agency staff

**Definition:** Personnel from Dubai Police, TDRA, and Dubai Courts involved in IP protection.

**Key characteristics:**

- Dubai Police: "Investigates and enforces criminal IP infringement cases" [Dubai IP Hub Technical Design 121224.pdf]
- TDRA: "Facilitates technical and telecommunications compliance"
- Dubai Courts: "Adjudicates disputes and enforces legal outcomes"

**Platform needs:**

- Case submission and tracking capabilities
- Evidence management and documentation
- Integration with agency communication systems
- Status reporting and feedback mechanisms

### Administrative and support users

### 1. Platform administrators

**Definition:** Technical and operational staff managing the platform.

**Key characteristics:**

- Responsible for user onboarding and system configuration [Dubai IP Hub Technical Design 121224.pdf] mentions "admin dashboard to monitor organisational onboarding progress"
- Need comprehensive user and organisation management tools
- Focus on system performance and compliance monitoring

**Platform needs:**

- User role and permission management [Dubai IP Hub Technical Design 121224.pdf] includes RBAC and Permission Policies contexts
- Organisation profile management capabilities
- System monitoring and reporting tools
- Audit trail management for compliance

### 2. Customer support staff

**Definition:** Support personnel assisting users with platform issues and guidance.

**Key characteristics:**

- Provide user assistance and troubleshooting support [Dubai IP Hub Technical Design 121224.pdf] mentions Customer Service & Support context
- Need access to user accounts and case histories
- Focus on issue resolution and user guidance

**Platform needs:**

- Support ticket management system
- User account support tools
- Knowledge base management
- Communication tools for user assistance

## Priority and implementation approach

### Phase 1 priority: Patents

1. **Primary focus:** IP creators (startups, SMEs, researchers) - highest volume, greatest need for simplification
2. **Secondary focus:** Legal advisors and university tech transfer offices - critical for platform credibility, professional adoption, and institutional research commercialisation
3. **Strategic focus:** VC/PE funds - influential stakeholders driving portfolio company IP strategies
4. **Supporting systems:** MoEc staff and platform administrators - essential for basic operations

**Governance validation required:** Expansion of user personas to include university tech transfer offices and VC/PE funds for validation in the patent platform [follow-up task from recent governance call].

**Additional considerations:** Benchmarking patent processes against major Asian jurisdictions (Japan, China, South Korea) and their cross-Pacific application networks [follow-up task from recent governance call] may influence user requirements for multi-jurisdictional filing.

### Phase 2 consideration: Copyright

{If copyright proceeds as planned, the user types would largely mirror patent users with content-specific variations. The technical infrastructure and user management systems established for patents would support copyright users with modified workflows and validation rules.}

## Justification and evidence base

**Research foundation:** User types are derived from comprehensive research including [Research insights ProjectKey_Booklet_Masterfile.pdf] "29 conversations from various user groups" and user testing aimed at securing "10 participants for user testing that cover a range of our identified personas" [09042024_PROJECT KEY_Phase 2_FOR DNA.pdf].

**Recent governance expansion:** Following the latest governance call, personas have been expanded to include university tech transfer offices and VC/PE funds, recognising that "university tech transfer offices and commercialisation and licensing offices are crucial as they handle patents more than individual creators" and "VC and PE funds often force their start-ups to register patents and have in-house teams to manage this process" [recent governance call notes].

**Technical alignment:** User categorisation aligns with the technical architecture's bounded contexts [Dubai IP Hub Technical Design 121224.pdf], particularly User Profiles, Organisation Profiles, and Role-Based Access Control systems.

**Market validation:** The focus on SMEs and startups addresses the documented "gap in accessible legal support for smaller entities" [Research insights ProjectKey_Booklet_Masterfile.pdf] and supports Dubai's goal to become "a preferred place for registration" [Dubai IP Hub Technical Design 121224.pdf].