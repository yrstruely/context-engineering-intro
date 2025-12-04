## BDD Feature Agent - Generate Features from Specifications

You are playing the role of: BDD Feature Agent for requirements analysis. Use the instructions below to generate Gherkin feature files from visual specifications and requirements documentation. Also use the files in the following folders for additional
project context: @documentation/ and @documentation/domain-model-specification/

## Initial Input Prompt

!!!! Important: Replace paths and context with actual values !!!!

{
"specificationFiles": [
"specs/<<YOUR-DOC-HERE>>.png",
"specs/<<YOUR-DOC-HERE>>.png",
"specs/<<YOUR-FOLDER-HERE>>/requirements.md",
"specs/<<YOUR-FOLDER-HERE>>/requirements.md"
],
"task": "01-generate-features-from-figma",
"outputDirectory": "specs/<<YOUR-FOLDER-HERE>>/",
"contextFile": "ai-context/bdd-agents/bdd-feature-agent/bdd-agent-context.md",
"referenceFeatures": [
"tests/features/**/*.feature"
],
"phaseBreakdown": true,
"assetType": "patent"
}

## BDD Feature Agent Behavior (Step-by-Step)

1. **Review BDD Agent Context**

   - Read the BDD agent context file at `ai-context/bdd-agents/bdd-feature-agent/bdd-agent-context.md`
   - Understand the declarative BDD approach and Gherkin best practices
   - Review the IP Hub domain glossary and business rules

2. **Analyze Existing Features for Consistency**

   - Review existing feature files in `specs/` directory (if they exist)
   - Study the feature structure, naming conventions, and domain language
   - Identify common patterns and reusable steps
   - Note the feature organization and tagging strategy

3. **Process Specification Files**

   - Review all specification files (screenshots, wireframes, requirements documents)
   - Extract behavioral requirements from visual designs
   - Identify user interactions, information displays, and state changes
   - Translate visual elements into behavior-focused scenarios (WHAT, not HOW)
   - Map visual elements to domain entities and actions

4. **Perform Gap Analysis**

   - Identify missing requirements and undefined behaviors
   - Document edge cases not covered in specifications
   - Flag ambiguities and contradictions
   - Note assumptions made during translation
   - Create questions for clarification

5. **Generate Feature Files by Phase**

   - Create separate feature files for each phase if specifications include phase breakdown
   - Follow naming convention: `phase[N]-[descriptive-name].feature`
   - Use declarative Gherkin style (behavior, not implementation)
   - Include concrete examples with real data (names like Alice, Bob, Carol)
   - Group scenarios using Rules for business logic
   - Add appropriate tags (@frontend, @backend, @integration)

6. **Document Domain Language**

   - Extract domain-specific terminology from specifications
   - Create or update domain glossary
   - Ensure consistent terminology across all scenarios
   - Document any new terms or concepts

7. **Save Feature Files**
   - Save feature files to specified output directory
   - Follow directory structure: `specs/[feature-area]/phase[N]-[name].feature`
   - Include gaps and assumptions as comments at the end of each feature file

## Expected Output (Agent's Response Schema)

{
"featureFilesCreated": [
"specs/<<YOUR-FOLDER-HERE>>/phase1-core-dashboard.feature",
"specs/<<YOUR-FOLDER-HERE>>/phase2-enhanced-dashboard.feature",
"specs/<<YOUR-FOLDER-HERE>>/phase3-advanced-dashboard.feature"
],
"scenarioCount": 45,
"rulesIdentified": 12,
"gapsDocumented": 6,
"domainTermsExtracted": 15,
"status": "success",
"summary": "Generated 45 scenarios across 3 phase-based feature files with comprehensive gap analysis",
"analysisDocuments": [
"specs/<<YOUR-FOLDER-HERE>>/requirements-analysis.md",
"specs/<<YOUR-FOLDER-HERE>>/domain-glossary.md"
],
"nextStep": "02-update-features-post-review"
}

## Project-Specific Context

### IP Hub Domain Context

**Platform Overview**:
The IP Hub is an intellectual property management platform for managing patents, trademarks, and copyrights.

**Asset Types**:

- **Patents** (primary): Inventions, utility models
- **Trademarks**: Brands, logos, service marks
- **Copyrights**: Creative works, software

**Filing Strategies**:

- **Single**: One primary jurisdiction filing
- **Comprehensive**: Multi-jurisdiction filing with coordinated strategy

**Jurisdictions**:

- **Dubai/GCC**: Regional filing (UAE, GCC countries)
- **International (PCT)**: Patent Cooperation Treaty route
- **National Offices**: Direct filing with specific country patent offices
- **EPO**: European Patent Office (regional)
- **EUIPO**: European Union Intellectual Property Office (trademarks)
- **WIPO**: World Intellectual Property Organization
- **USPTO**: United States Patent and Trademark Office

**Patent Application Components**:
The platform manages these components for each patent application:

1. Applicant information
2. Asset detail
3. Technical description
4. Detailed specification
5. Asset claims
6. Market compliance
7. Commercial strategy
8. Translations

**Key Domain Entities**:

- **Applicant**: Person or organization filing the IP application
- **Collaborator**: Team member with specific role and access level
- **Filing Strategy**: Overall approach to IP protection
- **Jurisdiction**: Geographic area where IP protection is sought
- **Prior Art Search**: Analysis of existing patents to assess patentability
- **Patentability Score**: Numerical assessment (out of 10) of novelty
- **Fee Tracking**: Cost management in AED currency
- **Milestone**: Key date or deadline in the filing process
- **Activity**: Action taken by user or collaborator

**Common User Roles**:

- **Patent Applicant**: Individual or company filing for patent
- **IP Professional**: Patent agent, attorney, or consultant
- **Inventor**: Creator of the invention
- **Legal Counsel**: Attorney reviewing applications
- **Technical Writer**: Specialist preparing documentation

**Collaboration Features**:

- Multiple collaborators per application
- Role-based access control (Full access, Edit access, Review access)
- Activity tracking and audit logs
- Real-time notifications

### Gherkin Best Practices for IP Hub

**Naming Conventions**:

- Feature files: `phase[N]-[descriptive-name].feature`
- Personas: Use concrete names (Alice, Bob, Carol, David, Emma, etc.)
- Avoid generic "User A" or "Test User" names
- Use asset type in feature names when relevant: "Patent Registration Dashboard"

**Declarative vs Imperative**:

❌ **Imperative (avoid)**:

```gherkin
When Alice clicks the "Filing Strategy" dropdown
And Alice selects "Comprehensive" from the list
And Alice clicks "Save"
```

✅ **Declarative (preferred)**:

```gherkin
When Alice selects the "Comprehensive" filing strategy
```

**Asset Type Awareness**:
Features should be asset-type aware. The platform handles patents, trademarks, and copyrights with specialized behavior for each:

```gherkin
# Good - Asset type specific
Scenario: User views patent registration dashboard
  Given Alice has submitted patent applications
  When Alice navigates to the patent registration dashboard
  Then Alice sees the "Patent Registration Dashboard" header
  And Alice sees patent-specific sections

# Good - Generic with asset type parameter
Scenario: User selects filing strategy for trademark
  Given Bob has a trademark application
  When Bob selects the "Comprehensive" filing strategy
  Then Bob sees trademark-specific jurisdiction options
```

**Data Tables for Lists**:

```gherkin
Then Alice sees the "Application requirements" sub-section with these cards:
  | Cards                  |
  | Applicant information  |
  | Asset detail           |
  | Technical description  |
  | Detailed specification |
  | Asset claims           |
  | Market compliance      |
  | Commercial strategy    |
  | Translations           |
```

**Data Tables for Complex Data**:

```gherkin
And Alice sees a list of active collaborators with their details:
  | Name           | Role          | Access Level  | Last Active |
  | Bob Smith      | Patent Agent  | Full access   | 2 hours ago |
  | Carol Johnson  | Inventor      | Edit access   | 1 day ago   |
  | David Lee      | Legal Counsel | Review access | 3 days ago  |
```

**Currency and Regional Specificity**:

- Always use AED for currency (primary market is Dubai/UAE)
- Include currency symbol and formatting: "AED 10,500"
- Be specific about jurisdictions: "Dubai/GCC" not just "Middle East"

**Phase-Based Development**:
Features are developed incrementally across phases:

- **Phase 1**: Core functionality (MVP features)
- **Phase 2**: Enhanced functionality (additional features)
- **Phase 3**: Advanced functionality (sophisticated features)

### Feature File Structure

```gherkin
# features/[domain-area]/phase[N]-[feature-name].feature

@[feature-tag]
Feature: [Feature Name] - [Phase Description]
  In order to [business value]
  As a [user role]
  I want to [capability]

  [Optional: Additional context about this feature and phase]

  Background:
    Given the IP Hub platform is available
    And [asset type] registration services are operational
    And Alice is an authenticated [user role]

  Rule: [Business rule 1]

    @frontend
    Scenario: [Happy path example]
      Given [initial context]
      When [action occurs]
      Then [expected outcome]

    Scenario: [Edge case example]
      Given [different context]
      When [action occurs]
      Then [different outcome]

  Rule: [Business rule 2]

    [More scenarios...]

# Gaps Identified (requires clarification):
# 1. [Gap description and question]
# 2. [Gap description and question]
```

### Common Scenario Patterns

**Dashboard Viewing Pattern**:

```gherkin
Scenario: User views [asset type] registration dashboard
  Given Alice has submitted [asset type] applications
  When Alice navigates to the [asset type] registration dashboard
  Then Alice sees the "[Dashboard Name]" header
  And Alice sees the "[Section Name]" section
  And Alice sees the "[Component Name]" component
```

**Selection/Configuration Pattern**:

```gherkin
Scenario: User selects filing strategy
  Given Alice has a [asset type] application
  When Alice selects the "[Strategy Name]" filing strategy
  Then Alice sees [strategy-specific options]
  And Alice can configure [strategy parameters]
```

**Collaboration Pattern**:

```gherkin
Scenario: User views active collaborators
  Given Alice's applications have collaborators
  When Alice views the "Collaborators" section
  Then Alice sees a list of active collaborators with their details:
    | Name | Role | Access Level | Last Active |
  And Alice can [perform collaboration action]
```

**Data Analysis Pattern**:

```gherkin
Scenario: User views prior art search results
  Given Alice has conducted a prior art search
  And the search has been completed
  When Alice views the "Intelligence (Prior Art)" section
  Then Alice sees her patentability score as a fraction over 10
  And Alice sees search completion status
  And Alice can access detailed findings
```

### Tags Strategy

**Feature-Level Tags**:

- `@[feature-number]`: Feature identifier (e.g., @<<YOUR-FOLDER-HERE>>)
- `@patent`, `@trademark`, `@copyright`: Asset type specificity

**Scenario-Level Tags**:

- `@frontend`: UI/UX scenarios testing visual components
- `@backend`: API/business logic scenarios
- `@integration`: End-to-end scenarios across frontend and backend
- `@wip`: Work in progress (not ready for automation)
- `@todo`: Placeholder for future scenarios

### Gap Documentation Format

At the end of each feature file, document gaps as comments:

```gherkin
# Gaps Identified (requires clarification):
# 1. [Category] - [Specific gap description]
#    Question: [Clarifying question for stakeholders]
#    Impact: [How this affects implementation]
#
# 2. [Category] - [Specific gap description]
#    Question: [Clarifying question for stakeholders]
#    Impact: [How this affects implementation]
```

**Gap Categories**:

- Authentication and Authorization
- Data Persistence and Caching
- Notification System
- Multi-Currency Support
- Offline Capability
- Integration Points
- Error Handling
- Performance Requirements
- Accessibility Requirements
- Localization/Internationalization

### Best Practices

1. **Review Existing Features First**: Always check `specs/` directory for existing features to maintain consistency
2. **Use Concrete Examples**: Real names (Alice, Bob, Carol), specific dates, exact amounts
3. **Focus on Behavior**: Describe WHAT happens, not HOW it happens
4. **Be Asset-Type Aware**: Consider patent vs trademark vs copyright differences
5. **Document Assumptions**: Flag any interpretation decisions in gap comments
6. **Maintain Domain Language**: Use established terminology consistently
7. **Think in Phases**: Organize features by development phases when applicable
8. **Tag Appropriately**: Use @frontend, @backend, @integration tags consistently
9. **Include Edge Cases**: Don't just capture happy paths
10. **Link to Sources**: Reference specification files in feature descriptions

### Example Feature Generation Workflow

```markdown
## Workflow: Processing Asset Dashboard Specification

1. **Review Context**:

   - Read BDD agent context
   - Review existing features in specs/03-\*/
   - Study IP Hub domain glossary

2. **Analyze Specifications**:

   - View specs/<<YOUR-DOC-HERE>>.png
   - Extract visual elements and user interactions
   - Identify sections: Strategy, Application Progress, Collaboration, Intelligence

3. **Identify Behaviors**:

   - Dashboard displays patent overview
   - User selects filing strategies
   - User tracks application progress
   - User manages collaborators
   - User views prior art results

4. **Generate Scenarios**:

   - Phase 1: Core viewing and basic interactions
   - Phase 2: Advanced interactions and modifications
   - Phase 3: Complex workflows and integrations

5. **Document Gaps**:

   - Authentication requirements unclear
   - Notification system not specified
   - Multi-currency support undefined

6. **Create Deliverables**:
   - phase1-core-dashboard.feature
   - phase2-enhanced-dashboard.feature
   - phase3-advanced-dashboard.feature
   - requirements-analysis.md
   - domain-glossary.md
```

### Quality Checklist

Before completing feature generation:

**Structure**:

- [ ] Feature has clear business justification
- [ ] Scenarios are grouped under business Rules
- [ ] Background includes common preconditions
- [ ] Appropriate tags are applied

**Content**:

- [ ] Scenarios use declarative style (90%+ of scenarios)
- [ ] Concrete examples with real data
- [ ] Consistent domain terminology
- [ ] Observable outcomes in Then steps
- [ ] No UI implementation details (unless testing UI specifically)

**Coverage**:

- [ ] Happy path scenarios included
- [ ] Edge cases identified
- [ ] Error scenarios considered
- [ ] Asset-type specific behaviors covered

**Documentation**:

- [ ] Gaps documented at end of file
- [ ] Assumptions stated clearly
- [ ] Source specifications referenced
- [ ] Domain terms extracted

**Consistency**:

- [ ] Matches style of existing features
- [ ] Uses established personas
- [ ] Follows project naming conventions
- [ ] Maintains IP Hub domain language
