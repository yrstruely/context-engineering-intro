# features/02-dashboard-overview/phase2-enhanced-dashboard-overview.feature
@02-dashboard-overview
Feature: Dashboard Overview - Enhanced Functionality (Phase 2)
  In order to have deeper insights into my IP portfolio and improve collaboration
  As an IP creator, manager, legal advisor, or consultant
  I want advanced dashboard features including analytics, enhanced filtering, and collaboration tools

  Phase 2 enhances the core dashboard with advanced filtering, sorting, analytics,
  bulk actions, and improved collaboration features for power users managing
  larger IP portfolios.

  Background:
    Given the IP Hub platform is available
    And IP registration services are operational
    And Alice is an authenticated user
    And Alice has access to enhanced dashboard features

  Rule: Dashboard provides advanced filtering and sorting capabilities

    @frontend @filtering @advanced
    Scenario: User applies multiple filters simultaneously
      Given Alice has 20 applications across different types and statuses
      When Alice selects "Patents" from the type filter
      And Alice selects "Action Required" from the status filter
      Then Alice sees only patent applications with "Action Required" status
      And Alice sees the applied filters clearly indicated
      And Alice can remove individual filters

    @frontend @filtering @presets
    Scenario: User saves filter preset for quick access
      Given Alice has configured multiple filters
      When Alice saves the filter combination as "My Action Items"
      Then Alice sees "My Action Items" in her saved filter presets
      And Alice can quickly apply this preset in future sessions

    @frontend @sorting
    Scenario: User sorts applications by different criteria
      Given Alice is viewing the applications in progress section
      When Alice selects "Sort by: Last Updated" from the sort dropdown
      Then Alice sees applications sorted by last updated date in descending order
      And the most recently updated application appears first

    @frontend @sorting @deadlines
    Scenario: User sorts applications by deadline
      Given Alice has applications with different deadlines
      When Alice selects "Sort by: Deadline" from the sort dropdown
      Then Alice sees applications sorted by deadline in ascending order
      And applications with nearest deadlines appear first

  Rule: Dashboard displays portfolio analytics and insights

    @frontend @analytics @insights
    Scenario: User views portfolio statistics and trends
      Given Alice has been using the platform for 6 months
      And Alice has submitted 15 applications
      When Alice views the analytics section on the dashboard
      Then Alice sees her total application count over time
      And Alice sees a breakdown of applications by type
      And Alice sees application success rates
      And Alice sees average processing times

    @frontend @analytics @deadlines
    Scenario: User views upcoming deadlines summary
      Given Alice has 5 applications with deadlines in the next 30 days
      When Alice views the deadlines summary section
      Then Alice sees a timeline of upcoming deadlines
      And Alice sees the most urgent deadline highlighted
      And Alice can click on a deadline to view the related application

    @frontend @analytics @valuation
    Scenario: User views portfolio value metrics
      Given Alice has registered IP assets with estimated values
      When Alice views the portfolio analytics section
      Then Alice sees the estimated total portfolio value in AED
      And Alice sees value breakdown by asset type
      And Alice sees value trends over time

  Rule: Dashboard supports bulk actions for efficient management

    @frontend @bulk-actions
    Scenario: User selects multiple applications for bulk action
      Given Alice is viewing the applications in progress section
      When Alice selects 3 applications using checkboxes
      Then Alice sees a bulk actions toolbar appear
      And Alice sees available bulk actions
      And Alice sees the count of selected items

    @frontend @bulk-actions @status
    Scenario: User performs bulk status update
      Given Alice has selected 3 applications
      When Alice chooses "Update Status" from the bulk actions
      And Alice selects "Under Review" as the new status
      Then all 3 selected applications are updated to "Under Review" status
      And Alice sees a confirmation message
      And the applications list refreshes to show the updated statuses

    @frontend @bulk-actions @export
    Scenario: User exports multiple applications
      Given Alice has selected 5 applications
      When Alice chooses "Export" from the bulk actions
      And Alice selects PDF format
      Then Alice receives a download containing all 5 applications in PDF format
      And the export includes all relevant details for each application

  Rule: Dashboard provides enhanced collaboration features

    @frontend @collaboration @activity
    Scenario: User views detailed activity feed
      Given Alice's applications have multiple collaborators
      And collaborators have taken various actions
      When Alice views the enhanced activity feed
      Then Alice sees a chronological list of all activities
      And Alice sees the collaborator name, action type, and timestamp for each activity
      And Alice can filter activities by collaborator
      And Alice can filter activities by action type

    @frontend @collaboration @notifications
    Scenario: User mentions collaborator in activity comment
      Given Alice is viewing an application
      When Alice adds a comment mentioning "@Bob Smith"
      Then Bob receives a notification about being mentioned
      And Bob can click the notification to view the comment

    @frontend @collaboration @analytics
    Scenario: User views collaborator workload distribution
      Given Alice manages a team of collaborators
      When Alice views the collaboration analytics section
      Then Alice sees the number of active applications per collaborator
      And Alice sees the completion rate for each collaborator
      And Alice can identify workload imbalances

  Rule: Dashboard provides customizable views and layouts

    @frontend @customization @layout
    Scenario: User customizes dashboard layout
      Given Alice is viewing the dashboard
      When Alice enters dashboard edit mode
      Then Alice can drag and drop sections to rearrange them
      And Alice can hide sections she doesn't use
      And Alice can save her custom layout

    @frontend @customization @layout
    Scenario: User switches between dashboard views
      Given Alice has created custom dashboard layouts
      When Alice selects "Detailed View" from the view switcher
      Then Alice sees her detailed dashboard layout with all sections expanded
      And Alice can switch back to "Compact View" for a condensed layout

    @frontend @customization @layout
    Scenario: User resets dashboard to default layout
      Given Alice has customized her dashboard layout
      When Alice selects "Reset to Default" from the settings menu
      Then Alice's dashboard returns to the default layout
      And Alice sees a confirmation message

  Rule: Dashboard provides advanced search with filters

    @frontend @search @advanced
    Scenario: User performs advanced search with multiple criteria
      Given Alice has a large IP portfolio
      When Alice opens the advanced search panel
      And Alice enters "Security" in the name field
      And Alice selects "Patents" as the type
      And Alice selects "2024" as the year
      Then Alice sees search results matching all criteria
      And Alice sees the number of results found

    @frontend @search @presets
    Scenario: User saves search criteria for future use
      Given Alice has configured advanced search criteria
      When Alice saves the search as "My Security Patents 2024"
      Then Alice sees "My Security Patents 2024" in her saved searches
      And Alice can run this search again with one click

    @frontend @search @jurisdiction
    Scenario: User searches by jurisdiction
      Given Alice has applications filed in multiple jurisdictions
      When Alice searches for applications in "Dubai/GCC"
      Then Alice sees only applications filed in Dubai/GCC jurisdictions
      And Alice sees jurisdiction information displayed for each result

  Rule: Dashboard provides quick insights and recommendations

    @frontend @recommendations @insights
    Scenario: User views personalized recommendations
      Given Alice has applications in various stages
      When Alice views the recommendations section
      Then Alice sees suggested next actions for her applications
      And Alice sees recommendations prioritized by importance
      And Alice can dismiss or act on recommendations

    @frontend @recommendations @deadlines @risk
    Scenario: User views deadline risk indicators
      Given Alice has applications with approaching deadlines
      When Alice views the dashboard
      Then Alice sees risk indicators on applications with deadlines within 7 days
      And high-risk items are highlighted in red
      And medium-risk items are highlighted in yellow

    @frontend @recommendations @strategy
    Scenario: User receives proactive filing strategy suggestions
      Given Alice has submitted patent applications
      And the system has analyzed her filing patterns
      When Alice views the strategy recommendations section
      Then Alice sees suggestions for additional jurisdictions to consider
      And Alice sees recommendations based on her industry and competitors

  Rule: Dashboard supports team performance metrics

    @frontend @team-management @analytics
    Scenario: Team manager views team performance dashboard
      Given Bob is a team manager with 5 team members
      And Bob's team manages 30 applications
      When Bob views the team performance section
      Then Bob sees the total number of applications managed by the team
      And Bob sees average time to complete applications
      And Bob sees team members ranked by productivity
      And Bob sees bottlenecks in the application process

    @frontend @analytics @comparison
    Scenario: User compares performance across time periods
      Given Alice wants to analyze her portfolio trends
      When Alice selects "Compare: Last Quarter vs This Quarter"
      Then Alice sees side-by-side metrics for both periods
      And Alice sees percentage changes highlighted
      And Alice sees improvement or decline indicators

  Rule: Dashboard provides integration status and health monitoring

    @frontend @integrations @monitoring
    Scenario: User views system integration status
      Given the platform integrates with external IP offices
      When Alice views the integrations section
      Then Alice sees the status of all integrated services
      And Alice sees last successful sync time for each integration
      And Alice sees any integration errors or warnings

    @frontend @integrations @alerts @error-handling
    Scenario: User receives alert for integration failure
      Given Alice has applications that depend on external integrations
      When an integration fails
      Then Alice sees an alert in the dashboard
      And Alice sees which applications are affected
      And Alice sees recommended actions to resolve the issue

# Gaps Identified (requires clarification):
# 1. Analytics Data Retention
#    Question: How long should historical analytics data be retained?
#    Question: Should users be able to export historical analytics?
#    Impact: Affects database storage and data archival strategy
#
# 2. Bulk Action Permissions
#    Question: Should bulk actions be restricted based on user role?
#    Question: Should there be approval workflows for certain bulk actions?
#    Impact: Affects permission system and audit logging requirements
#
# 3. Customization Limits
#    Question: Are there limits on how many custom layouts a user can save?
#    Question: Should custom layouts be shareable with team members?
#    Impact: Affects storage and sharing functionality
#
# 4. Real-time Collaboration
#    Question: Should users see when collaborators are actively viewing the same application?
#    Question: Should there be a live typing indicator for comments?
#    Impact: Requires real-time synchronization infrastructure
#
# 5. Advanced Search Performance
#    Question: What is the maximum number of search results to display?
#    Question: Should search use full-text indexing or database queries?
#    Impact: Affects search performance and infrastructure requirements
#
# 6. Notification Throttling
#    Question: Should there be limits on notification frequency to prevent spam?
#    Question: Can users set quiet hours for notifications?
#    Impact: Affects notification system design
#
# 7. Portfolio Value Calculation
#    Question: How is IP asset value estimated?
#    Question: Should users be able to manually override estimated values?
#    Impact: Affects valuation algorithm and user input requirements
#
# 8. Team Performance Privacy
#    Question: Should individual team member metrics be visible to all team members?
#    Question: Should there be privacy settings for performance data?
#    Impact: Affects privacy controls and data access policies
