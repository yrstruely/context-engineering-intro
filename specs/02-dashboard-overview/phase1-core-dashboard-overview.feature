# features/02-dashboard-overview/phase1-core-dashboard-overview.feature
@02-dashboard-overview
Feature: Dashboard Overview - Core Functionality (Phase 1)
  In order to efficiently manage my IP portfolio and quickly assess status
  As an IP creator, manager, legal advisor, or consultant
  I want to access a unified dashboard that displays all my applications, alerts, and quick actions

  The core dashboard provides the primary entry point to the IP Hub platform,
  consolidating portfolio status, active applications, critical alerts, and
  navigation to key platform functions including Patents, Trademarks, and Copyrights.

  Background:
    Given the IP Hub platform is available
    And IP registration services are operational
    And Alice is an authenticated user

    Rule: Dashboard provides intuitive navigation structure

    @frontend @navigation
    Scenario: User views main navigation menu
      Given Alice is viewing the dashboard
      Then Alice sees the main navigation menu
      And Alice sees a "Portfolio" navigation item
      And Alice sees a "Registration" navigation item
      And Alice sees a "Enforce" navigation item
      And Alice sees a "Commercialise" navigation item

    @frontend @navigation
    Scenario Outline: User navigates to sections
      Given Alice is viewing the dashboard
      When Alice clicks on <navigation item> in the main navigation
      Then Alice is navigated to the <section> section
      And Alice sees all her IP assets

      Examples:
        | navigation item | section            |
        | Portfolio       | portfolio          |
        | Registration    | registration tools |
        | Enforce         | enforcement guides |
        | Commercialise   | commercialisation  |

    @frontend @navigation
    Scenario: User's current location is indicated in navigation
      Given Alice is viewing the dashboard
      Then Alice sees the dashboard is highlighted in the navigation

  Rule: Dashboard displays unified portfolio overview on login

    @frontend @portfolio
    Scenario: User views dashboard after login
      Given Alice has submitted IP applications
      When Alice logs into the platform
      Then Alice sees the Dashboard page
      And Alice sees a personalized welcome message with her name
      And Alice sees the main navigation menu
      And Alice sees the alert banner section
      And Alice sees the quick actions bar
      And Alice sees the portfolio status cards
      And Alice sees the applications in progress section
      And Alice sees the asset portfolio breakdown section

  Rule: Dashboard displays alert banner with urgent notifications

    @frontend @alerts
    Scenario: User views dashboard with no alerts
      Given Alice has no pending notifications
      When Alice views the dashboard
      Then Alice does not see the alert banner

    @frontend @alerts
    Scenario: User views alert banner with pending notifications
      Given Alice has an office action deadline approaching in 14 days
      And Alice has a renewal deadline notice due in 45 days
      When Alice views the dashboard
      Then Alice sees the alert banner at the top of the dashboard
      And Alice sees an alert count badge showing 2 alerts
      And Alice sees office action deadline approaching in 14 days
      And Alice sees renewal deadline notice due in 45 days

    @frontend @alerts
    Scenario: User views alert banner with high priority alerts
      Given Alice has 1 high priority office action deadline
      And Alice has 2 standard renewal notices
      When Alice views the dashboard
      Then Alice sees the alert banner
      And Alice sees the high priority alert visually distinct from standard alerts
      And Alice sees the alert count badge showing 3 alerts

    @frontend @alerts
    Scenario: User dismisses alert notification
      Given Alice has pending notifications in the alert banner
      When Alice dismisses a notification
      Then the notification is removed from the alert banner
      And the alert count badge is updated

  Rule: Dashboard provides quick access to registration tools

    @frontend @quick-actions
    Scenario: User views quick actions bar
      Given Alice is viewing the dashboard
      Then Alice sees the quick actions bar
      And Alice sees a "Register Patent" button
      And Alice sees a "Register Trademark" button
      And Alice sees a "Register Copyright" button
      And Alice sees an "Upload Certificate" button

    @frontend @quick-actions
    Scenario Outline: User clicks a quick action button
      Given Alice is viewing the dashboard
      When Alice clicks the <button> button
      Then Alice is navigated to the <page> page

      Examples:
        | button             | page                   |
        | Register Patent    | patent registration    | 
        | Register Trademark | trademark registration |
        | Register Copyright | copyright registration |
        | Upload Certificate | portfolio              |

  Rule: Dashboard displays portfolio status cards with metrics

    @frontend @portfolio @empty-state
    Scenario: User views portfolio status with no assets
      Given Alice has no IP assets
      When Alice views the dashboard
      Then Alice sees the portfolio status cards section
      And Alice sees a "Total Assets" card showing 0 IP assets
      And Alice sees an empty state message in the portfolio status
      And Alice sees guidance text encouraging her to register her first asset

    @frontend @portfolio @metrics
    Scenario: User views portfolio status cards
      Given Alice has 11 active IP assets
      And Alice has 3 IP assets pending review where:
        | created this month | created last month |
        | 2                  | 1                  |
      And Alice has 5 IP applications in progress of these types:
        | patent | trademark | copyright | utility certificate |
        | 2      | 2         | 1         | 0                   |
      When Alice views the dashboard
      Then Alice sees the portfolio status cards section
      And Alice sees a "Total Assets" card showing 14 IP assets 
      And the "Total Assets" card shows that 2 assets were created this month
      And Alice sees an "Applications in Progress" card showing 5 IP applications
      And the "Applications in Progress" card has a breakdown showing:
        | patents | trademarks | copyrights | utility certificates |
        | 2       | 2          | 1          | 0                    |
      And Alice sees a "Pending Review" card showing 3 IP assets
      And the "Pending Review" card has a breakdown showing:
        | Awaiting action | Requires attention |
        | 3               | 0                  |
      And Alice sees an "Active Assets" card showing 11 IP assets
      And the "Pending Review" card has a breakdown showing:
        | Currently protected | % of portfolio |
        | 11                  | 79%            |

    @frontend @portfolio @metrics
    Scenario: Portfolio statistics update when new application is added
      Given Alice has 11 active IP assets
      And Alice has 3 IP assets pending review where:
        | created this month | created last month |
        | 2                  | 1                  |
      And Alice has 5 IP applications in progress of these types:
        | patent | trademark | copyright |
        | 2      | 2         | 1         |
      When Alice views the dashboard
      Then Alice sees the "Total Assets" card showing 11 IP Assets
      And Alice sees the "Applications in Progress" card showing 3 IP applications
      And Alice creates a new patent application
      And Alice returns to the dashboard
      Then Alice sees the "Total Assets" card showing 11 Assets
      And Alice sees the "Applications in Progress" card showing 4 IP applications

  Rule: Dashboard displays applications in progress with status tracking

    @frontend @applications @filtering
    Scenario: The Applications in Progress section has viewing and filtering options  
      Given Alice views the dashboard
      When Alice sees the "Applications in Progress" section
      Then Alice can choose to view the IP applications as either cards or list items
      And Alice and choose to filter the visible IP applications:
        | filter          |
        | All             |
        | Patent          |
        | Trademark       |
        | Copyright       |
        | Draft           |
        | In progress     |
        | Submitted       |
        | Action required |
        | Under review    | 

    @frontend @applications @filtering
    Scenario: User filters applications by type
      Given Alice has 3 patent applications
      And Alice has 2 trademark applications
      And Alice has 1 copyright application
      When Alice views the dashboard
      And Alice selects "Patents" from the type filter dropdown
      Then Alice sees only the 3 patent applications
      And Alice does not see trademark or copyright applications

    @frontend @applications @filtering
    Scenario: User filters applications by status
      Given Alice has 2 applications in "Draft" status
      And Alice has 3 applications in "Under Review" status
      When Alice views the dashboard
      And Alice selects "Under Review" from the status filter dropdown
      Then Alice sees only the 3 applications in "Under Review" status
      And Alice does not see applications in other statuses

    @frontend @applications @empty-state
    Scenario: User views empty applications in progress section
      Given Alice has no active applications
      When Alice views the dashboard
      Then Alice sees the "Applications in Progress" section
      And Alice sees an empty state message
      And Alice sees guidance text suggesting she start a new application

    @frontend @applications
    Scenario: User views applications in progress list
      Given Alice has 5 IP applications in progress of these types:
        | patent | trademark | copyright |
        | 2      | 2         | 1         |
      When Alice views the dashboard
      Then Alice sees the "Applications in Progress" section
      And Alice sees 5 application cards
      And each application card shows a type icon
      And each application card shows the application name
      And each application card shows a type text
      And each application card shows the current status
      And each application card shows the submission or last updated date
      And each "In progress" application card shows a progress bar with progress % and updated X days ago
      And each application card shows a footer section with a status pill and arrow button

    @frontend @applications @status
    Scenario: User views application with different statuses
      Given Alice has an application in "Draft" status
      And Alice has an application in "In progress" status
      And Alice has an application in "Submitted" status
      And Alice has an application in "Under review" status
      And Alice has an application in "Action required" status
      When Alice views the dashboard
      Then Alice sees all applications in the "Applications in Progress" section
      And each application shows its current status with appropriate status indicators
      And status indicators are color-coded for easy identification

    @frontend @applications @navigation
    Scenario: User clicks view details on an application
      Given Alice is viewing the applications in progress section
      And Alice sees an application card for "Smart Home Security System"
      When Alice clicks "View details" on the application card
      Then Alice is navigated to that application's detail view page

  Rule: Dashboard displays asset portfolio breakdown by IP type

    @frontend @portfolio @empty-state
    Scenario: User views asset portfolio breakdown with no assets
      Given Alice has no registered IP assets
      When Alice views the dashboard
      Then Alice sees the "Asset Portfolio Breakdown" section
      And all asset type cards show count 0
      And Alice sees an empty state message

    @frontend @portfolio
    Scenario: User views asset portfolio breakdown
      Given Alice has 11 active IP assets of these types:
        | patent | trademark | copyright | utility certificate |
        | 5      | 3         | 2         | 1                   |
      When Alice views the dashboard
      Then Alice sees the "Asset Portfolio Breakdown" section
      And Alice sees a "Patents" card showing count 5 and status
      And Alice sees a "Trademarks" card showing count 3 and status
      And Alice sees a "Copyrights" card showing count 2 and status
      And Alice sees a "Utility Certificates" card showing count 1 and status

    @frontend @portfolio @navigation
    Scenario: User clicks on asset type card
      Given Alice is viewing the asset portfolio breakdown section
      When Alice clicks on the "Patents" card
      Then Alice is navigated to the patents portfolio page
      And Alice sees all her registered patents

  Rule: Dashboard provides access to expert guides

    @frontend @guidance
    Scenario: User views expert guides section
      Given Alice is viewing the dashboard
      Then Alice sees the "Expert Guides" section
      And Alice sees these expert guidance cards:
        | icon         | title                            | text                                                                                                                                         |
        | patent       | Patent Management                | Learn about strategic patent filing, patent maintenance & renewals, office actions, response strategy and building a strong patent portfolio |
        | copyright    | Copyright Management             | Learn about copyright registration essentials, software copyright protection and copyright licensing strategies                              |
        | trademark    | Trademark Management             | Learn about selecting strong trademarks, trademark clearance & search, enforcing trademark rights and international trademark strategy       |
        | expert       | Find an Expert                   | For most IP activities you will need legal representation or technical expertise to help apply and manage your portfolio.                    |
        | fees         | Maintenance Fees                 | Plan for maintenance fees over an asset lifetime.                                                                                            |
        | jurisdiction | Strategic Jurisdiction Selection | File in jurisdictions where you have actual or planned business operations, manufacturing or key markets.                                    |

  Rule: Dashboard provides responsive and accessible user experience

    @frontend @ux @accessibility
    Scenario: User interacts with hover states
      Given Alice is viewing the dashboard on a desktop
      When Alice hovers over an application card
      Then Alice sees a hover state indicating interactivity
      And Alice can clearly identify clickable elements

# Gaps Identified (requires clarification):
# 1. Authentication & Session Management
#    Question: What happens when a user's session expires while viewing the dashboard?
#    Impact: Need to define behavior for session timeout and re-authentication flow
#
# 2. Data Refresh & Real-time Updates
#    Question: Should dashboard data refresh automatically? If so, at what interval?
#    Question: Should users see real-time updates when collaborators make changes?
#    Impact: Affects implementation of polling or websocket connections
#
# 3. Notification Preferences
#    Question: Can users customize which alerts appear in the alert banner?
#    Question: Can users set notification preferences (email, SMS, in-app)?
#    Impact: May require additional settings and configuration screens
#
# 4. Pagination & Performance
#    Question: If a user has hundreds of applications, should the "Applications in Progress" section be paginated?
#    Question: What is the maximum number of applications to display before pagination?
#    Impact: Affects performance and UX for users with large portfolios
#
# 5. Multi-language Support
#    Question: Should the dashboard support multiple languages for non-native English speakers (as mentioned in requirements)?
#    Question: How should language selection be handled?
#    Impact: Requires localization infrastructure and translated content
#
# 6. Offline Capability
#    Question: Should any dashboard functionality work offline?
#    Question: How should the dashboard indicate when it's offline?
#    Impact: May require service workers and offline data caching
#
# 7. Accessibility Requirements
#    Question: What WCAG level compliance is required (A, AA, or AAA)?
#    Question: Are there specific accessibility features needed for screen readers?
#    Impact: Affects implementation of ARIA labels and keyboard navigation
#
# 8. Empty State Actions
#    Question: What specific guidance should be shown in empty states?
#    Question: Should empty states have direct action buttons or just text?
#    Impact: Affects UX for new users with no assets
#
# 9. Status Change Notifications
#    Question: When an application status changes, how is the user notified beyond the alert banner?
#    Question: Are email notifications sent for status changes?
#    Impact: Affects notification system and user engagement
#
# 10. Dashboard Customization
#     Question: Can users customize which sections appear on their dashboard?
#     Question: Can users rearrange sections or pin favorite items?
#     Impact: May require additional settings and user preference storage
