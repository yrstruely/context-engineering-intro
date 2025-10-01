# Cucumber Documentation Context

**Source:** https://cucumber.io/docs/  
**Last Updated:** October 1, 2025

---

## Overview

Cucumber is a tool that supports **Behaviour-Driven Development (BDD)**. It enables teams to use discovery, collaboration, and examples rather than focusing solely on testing.

---

## What is Cucumber?

Cucumber reads **executable specifications** written in plain text and validates that the software does what those specifications say. The specifications consist of multiple **examples** or **scenarios**.

### Key Characteristics:
- Reads plain text specifications
- Validates software behavior against specifications
- Generates reports indicating success (✅) or failure (❌) for each scenario
- Uses scenarios as lists of steps to work through

### Example Scenario:

```gherkin
Scenario: Breaker guesses a word
  Given the Maker has chosen a word
  When the Breaker makes a guess
  Then the Maker is asked to score
```

---

## What is Gherkin?

**Gherkin** is a set of grammar rules that makes plain text structured enough for Cucumber to understand.

### Purpose of Gherkin:

1. **Unambiguous executable specification** - Clear, structured specifications that can be executed
2. **Automated testing** - Enables automated testing using Cucumber
3. **Documentation** - Documents how the system actually behaves

### Key Features:

- **Multiple language support** - Grammar exists in different flavours for many spoken languages, allowing teams to use keywords in their own language
- **File format** - Gherkin documents are stored in `.feature` text files
- **Version control** - Typically versioned in source control alongside the software

### Syntax Requirements:

Scenarios must follow basic syntax rules (Gherkin) for Cucumber to understand them.

---

## What are Step Definitions?

**Step definitions** are the bridge between Gherkin steps and programming code.

### How Step Definitions Work:

```
┌────────────┐     ┌──────────────┐     ┌───────────┐
│   Steps    │     │     Step     │     │           │
│ in Gherkin ├──►  │ Definitions  ├──►  │  System   │
│            │     │              │     │           │
└────────────┘     └──────────────┘     └───────────┘
  (matched with)    (manipulates)
```

### Key Concepts:

- **Connection** - Step definitions connect Gherkin steps to programming code
- **Action execution** - A step definition carries out the action that should be performed by the step
- **Implementation binding** - Step definitions hard-wire the specification to the implementation

### Language Support:

Step definitions can be written in many programming languages.

### Example (JavaScript):

```javascript
When('{maker} starts a game', maker => {
  maker.startGameWithWord({ word: 'whale' })
})
```

---

## Core Workflow

1. **Write scenarios** in Gherkin (plain text, in `.feature` files)
2. **Create step definitions** in your programming language
3. **Run Cucumber** to execute the scenarios
4. **Review reports** showing which scenarios passed or failed
5. **Iterate** on implementation until all scenarios pass

---

## Related Documentation Links

- BDD Introduction: `/docs/bdd/`
- Gherkin Reference: `/docs/gherkin/reference`
- Gherkin Spoken Languages: `/docs/gherkin/reference#spoken-languages`
- Step Definitions: `/docs/cucumber/step-definitions`

---

## Key Terminology

- **BDD (Behaviour-Driven Development)** - A development approach focused on discovery, collaboration, and examples
- **Scenario** - A concrete example that illustrates a business rule
- **Step** - An individual instruction in a scenario (Given, When, Then)
- **Gherkin** - The structured language used to write scenarios
- **Step Definition** - Code that implements what happens for each step
- **Feature File** - A `.feature` file containing Gherkin scenarios

---

## Notes

- Cucumber is NOT just a testing tool - it's a BDD tool focused on discovery and collaboration
- Scenarios should represent real examples of how the system behaves
- The plain text format makes specifications accessible to technical and non-technical team members alike

---

# Behaviour-Driven Development (BDD)

**Source:** https://cucumber.io/docs/bdd/

---

## What is BDD?

BDD is a way for software teams to work that closes the gap between business people and technical people by:

1. **Encouraging collaboration** across roles to build shared understanding of the problem to be solved
2. **Working in rapid, small iterations** to increase feedback and the flow of value
3. **Producing system documentation** that is automatically checked against the system's behaviour

### Core Focus

BDD focuses collaborative work around **concrete, real-world examples** that illustrate how we want the system to behave. These examples guide the team from concept through to implementation in a process of continuous collaboration.

---

## BDD and Agile

BDD does not replace your existing agile process—**it enhances it**. Think of BDD as a set of plugins for your existing process that will make your team more able to deliver on the promises of agile:

- Timely, reliable releases of working software
- Software that meets your organisation's evolving needs
- Requires minimal maintenance effort and discipline

### Rapid Iterations

BDD encourages:
- Responding quickly to feedback from users
- Doing only the minimal work necessary to meet needs
- Breaking down user problems into small pieces
- Moving work through the development process as quickly as possible

---

## Three Core Practices

BDD consists of three iterative practices that work together:

### 1. Discovery: What it Could Do

> "The hardest single part of building a software system is deciding precisely what to build." — Fred Brooks, The Mythical Man-Month

**Goal:** Valuable, working software through effective conversations.

**Process:**
- Use structured conversations called **discovery workshops**
- Focus around real-world examples from the users' perspective
- Grow shared understanding of:
  - User needs
  - Rules governing how the system should function
  - Scope of what needs to be done
- Identify gaps in understanding where more information is needed
- Defer low-priority functionality to improve flow

**Key Point:** Discovery is where to start with BDD. You won't get much value from the other practices until you've mastered discovery.

### 2. Formulation: What it Should Do

**Goal:** Document examples as structured, executable specifications.

**Process:**
- Take valuable examples from discovery sessions
- Formulate each as structured documentation
- Write in a medium readable by both humans and computers (Gherkin)
- Get feedback from the whole team
- Establish a shared language for talking about the system

**Benefits:**
- Quick confirmation of shared understanding
- Enables automation to guide development
- Uses problem-domain terminology all the way into the code

### 3. Automation: What it Actually Does

**Goal:** Use executable specifications to guide implementation development.

**Process:**
1. Take one example at a time
2. Automate it by connecting it to the system as a test
3. Test fails (behaviour not implemented yet)
4. Develop implementation code
5. Use lower-level examples to guide internal component development
6. Automated examples act as guide-rails

**Benefits:**
- Rapid, repeatable feedback
- Reduces manual regression testing burden
- Helps understand current system behaviour
- Enables safe changes without unintentionally breaking things
- Frees people for exploratory testing

### Practice Diagram

```
┌─────────────┐
│  Discovery  │ ←──┐
│ (Examples)  │    │
└──────┬──────┘    │
       │           │
       ↓           │
┌─────────────┐   │
│ Formulation │   │ Iterate rapidly,
│ (Scenarios) │   │ moving back up
└──────┬──────┘   │ when you need
       │           │ more information
       ↓           │
┌─────────────┐   │
│ Automation  │   │
│   (Tests)   │ ──┘
└─────────────┘
```

---

## History of BDD

### Origins

**Pioneered by:** Daniel Terhorst-North (early 2000s)
- Introduced in 2006 article "Introducing BDD"
- Grew as a response to Test-Driven Development (TDD)
- Goal: Help programmers on agile teams "get straight to the good stuff"
- Minimize misunderstandings about testing and coding

**Evolution:**
- Evolved into both analysis and automated testing at acceptance level
- Liz Keogh began writing and speaking extensively about it in 2004

### Early Tools (2003-2005)

**JBehave (2003):**
- Created by Daniel Terhorst-North as replacement for JUnit
- Used vocabulary based on "behaviour" rather than "test"
- Contributors: Liz Keogh, Chris Matts

**Given/When/Then Template:**
- Influenced by Eric Evans' Domain-Driven Design concept of "ubiquitous language"
- Focused on business value
- Grew from Rachel Davies' "As a..., I..., So that..." template for user stories at Connextra

**RSpec (2005):**
- Supported BDD in Ruby language
- Founded by Dave Astels, Steven Baker, Aslak Hellesøy, and David Chelimsky

### Origins of Cucumber

**Creator:** Aslak Hellesøy
- Worked on improving RSpec
- Had ideas for improvements in error messages, step definition snippets, and result reporting
- RSpec was for programmers; Story Runner was for the whole team

**Creation:**
- Started new project to make better version of Story Runner
- Initially called it "Stories"
- Asked his then-fiancée for catchier name
- She thought of "Cucumber" and it stuck

---

## Common BDD Myths

### Myth #1: You can pick and choose practices in any order

**Reality:** Order matters!

> "Having conversations is more important than capturing conversations is more important than automating conversations." — Liz Keogh

- Without effective discovery work, formulating scenarios is a waste of time
- Can't automate examples without figuring out important examples first
- Need business stakeholder feedback on wording

### Myth #2: You can automate scenarios after code is implemented

**Reality:** That's test automation, not BDD.

Many people use Cucumber for test automation after code implementation. While this is reasonable test automation, **it's not BDD**. BDD uses automation to guide development, not check it afterwards.

### Myth #3: Discovery doesn't need a conversation

**Reality:** Discovery must be collaborative.

Teams often try to leave example identification and scenario formulation to a single individual. That's not BDD. Discovery work needs:
- Collaboration bringing together different specialists
- Representatives from different roles
- Shared understanding about what will be built

### Myth #4: Using Cucumber means you're doing BDD

**Reality:** Tools don't make it BDD.

Just because you're using Cucumber doesn't mean you're doing BDD. There's much more to BDD than using Cucumber—it's about the three practices and collaboration.

---

## Discovery Workshops

### What is a Discovery Workshop?

A **discovery workshop** is a conversation where technical and business people collaborate to explore, discover, and agree on the desired behaviour for a User Story.

### Models for Discovery Workshops

1. **Example Mapping**
   - Uses four colors of index cards
   - Maps rules (constraints/acceptance criteria) to examples

2. **OOPSI Mapping**
   - Outcomes, Outputs, Processes, Scenarios, Inputs
   - Uses Post-it Notes
   - Maps shared processes/relationships between outputs and scenarios

3. **Event Storming**
   - Uses Post-it Notes
   - Identifies actors involved
   - Breaks story down into tasks
   - Maps tasks to specific examples

### When to Hold Discovery Workshops

**Timing:** As late as possible before development begins

**Reasons:**
- Prevents details from being lost
- Gives team flexibility to shift plans if new details surface
- Ensures information is fresh and relevant

### Who Should Attend?

**Recommended:** 3-6 people

**Minimum (The Three Amigos):**
1. **Product Owner** - Identifies the problem to solve
2. **Developer** - Addresses how to build a solution
3. **Tester** - Addresses edge cases that could arise

### Duration

**Ideal:** 25-30 minutes per story

**If longer:**
- Story is too large (needs to be broken down)
- Specifics are missing (needs more research)

### Why Bother?

**Benefits:**
- Gives all stakeholders shared understanding
- Encourages cross-functional collaboration
- Increases feedback
- Covers lost details or incorrect assumptions
- Prevents miscommunications
- Discovers unknowns early

---

## Example Mapping

### Purpose

Make the discovery conversation short and very productive by clarifying and confirming acceptance criteria before pulling a user story into development.

### How It Works

Concrete examples help explore and understand the problem domain and form the basis for acceptance tests.

### Four Types of Information (Four Colors)

1. **Yellow Card (Top)** - The User Story
2. **Blue Cards** - Rules (acceptance criteria, constraints)
3. **Green Cards** - Examples illustrating the rules
4. **Red Cards** - Questions that cannot be answered (captured to move conversation forward)

### The Mapping Process

```
┌─────────────────────────────┐
│   YELLOW: User Story        │
└─────────────────────────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼────┐  ┌────▼────┐
│ BLUE:  │  │  BLUE:  │
│ Rule 1 │  │ Rule 2  │
└───┬────┘  └────┬────┘
    │            │
  ┌─┴──┬───┐  ┌─┴───┐
  │    │   │  │     │
┌─▼─┐┌─▼┐┌─▼┐┌▼───┐
│GRN││GRN│GRN││GRN │
│Ex1││Ex2│Ex3││Ex4 │
└───┘└───┘└──┘└────┘

┌──────────────┐
│ RED: Question│
│ (unresolved) │
└──────────────┘
```

### When to Stop

Continue until:
- The group is satisfied the scope is clear, OR
- You run out of time

---

## The Three Amigos

### What is The Three Amigos?

A meeting that takes user stories and turns them into clean, thorough Gherkin scenarios, involving three voices (at least):

### The Three Voices

1. **Product Owner**
   - Most concerned with scope
   - Translates user stories into features
   - Decides what's in scope as edge cases emerge

2. **Tester**
   - Generates scenarios and edge cases
   - Asks: "How will the application break?"
   - Identifies unaccounted user stories

3. **Developer**
   - Adds steps to scenarios
   - Thinks through requirement details
   - Considers: "How will this execute?"
   - Identifies roadblocks and behind-the-scenes requirements

### Why Three Amigos?

Each amigo sees the product from a different perspective, producing great tests through collaborative discovery.

**Note:** Not limited to three people or one meeting—continually refine features and collaborate throughout the project.

---

## Who Does What?

### Writing Gherkin

**Initially (when establishing style):**
- Entire team collaborates on writing Gherkin

**Later (once style is established):**
- Can be done efficiently by a pair:
  - Developer (or automation owner)
  - Tester (or quality owner)
- Output actively reviewed by product owner (or business representative)

### Feature Structure

**Feature File Components:**

```gherkin
Feature: Explaining Cucumber
  In order to gain an understanding of the Cucumber testing system
  As a non-programmer
  I want to have an overview of Cucumber that is understandable by non-geeks

  Scenario: A worker seeks an overview of Cucumber
    Given I have a coworker who knows a lot about Cucumber
    When I ask my coworker to give an overview of how Cucumber works
    And I listen to their explanation
    Then I should have a basic understanding of Cucumber
```

### Feature Header Structure

**Feature:** Short label naming the feature

**In order to:** Reason/justification for having the feature
- Should match project's core purposes/business values:
  - Protect revenue
  - Increase revenue
  - Manage cost
  - Increase brand value
  - Make the product remarkable
  - Provide more value to customers

**As a:** Role of people/users being served

**I want:** One sentence explanation of what feature does

**Summary:** Covers Why (In order to), Who (As a), and What (I want)

### Writing Scenarios

**Scenario Count:**
- Any number of scenarios per feature
- If "lots and lots" → probably describing more than one feature → split into separate files

**First Line:**
- Short description of what scenario covers
- Should be single sentence
- If can't describe in single sentence → split into multiple scenarios

**Steps:**
- Use keywords: `Given`, `When`, `Then`
- Can repeat keywords
- Use `And` or `But` for readability
- Each `Given` should describe only one thing

**Example of splitting steps:**

❌ Bad:
```gherkin
When I fill in the "Name" field and the "Address" field
```

✅ Good:
```gherkin
When I fill in the "Name" field
And I fill in the "Address" field
```

### Consistency is Key

Don't say the same thing in different ways—use consistent wording.

❌ Inconsistent:
```gherkin
Given I am logged in
# vs
Given I have logged in to the site
```

✅ Consistent (pick one):
```gherkin
Given I am logged in
```

---

## Writing Better Gherkin

### Describe Behaviour, Not Implementation

**Principle:** Scenarios should describe **what** (intended behaviour), not **how** (implementation).

❌ Procedural (Implementation-focused):
```gherkin
Given I visit "/login"
When I enter "Bob" in the "user name" field
And I enter "tester" in the "password" field
And I press the "login" button
Then I should see the "welcome" page
```

✅ Functional (Behaviour-focused):
```gherkin
When "Bob" logs in
```

**Benefits:**
- When implementation changes, only update process steps behind the scenes
- Behaviour doesn't change when implementation does
- Scenarios are shorter and easier to understand
- Less brittle and easier to maintain

**Test Question:** "Will this wording need to change if the implementation does?"
- If yes → rework to avoid implementation-specific details

---

## Declarative vs. Imperative Style

### Imperative Style (Detailed)

Communicates precise details and mechanics. More closely tied to current UI implementation.

**Example:**
```gherkin
Feature: Subscribers see different articles based on their subscription level

Scenario: Free subscribers see only the free articles
  Given users with a free subscription can access "FreeArticle1" but not "PaidArticle1"
  When I type "freeFrieda@example.com" in the email field
  And I type "validPassword123" in the password field
  And I press the "Submit" button
  Then I see "FreeArticle1" on the home page
  And I do not see "PaidArticle1" on the home page
```

**Characteristics:**
- Precise instructions
- Exact inputs and expected results
- Requires updating when implementation changes
- More maintenance work

### Declarative Style (Conceptual) — Recommended

Describes behaviour without implementation details. More resilient to change.

**Example:**
```gherkin
Feature: Subscribers see different articles based on their subscription level

Scenario: Free subscribers see only the free articles
  Given Free Frieda has a free subscription
  When Free Frieda logs in with her valid credentials
  Then she sees a Free article

Scenario: Paid subscriber can access both free and paid articles
  Given Paid Patty has a basic-level paid subscription
  When Paid Patty logs in with her valid credentials
  Then she sees a Free article and a Paid article
```

**Characteristics:**
- Communicates ideas without exact values
- Details specified in step definitions (automation code)
- More resilient to implementation changes
- Reads better as "living documentation"
- Focuses on customer value, not keystrokes
- Easier to add new scenarios
- Intent remains clear even if implementation changes

**Where Details Go:**
- Specific values (which articles, subscription levels) live in step definitions
- Interaction details (clicks, fields) live in automation code
- Scenarios stay focused on behaviour

---

## Good BDD Examples

### Characteristics of Good Examples

**Concrete, not abstract:**
- Mention names of people and places
- Use exact dates and amounts
- Include anything relevant to problem domain

**Technology-agnostic:**
- Don't mention technical details
- Imagine it's 1922 (no computers)
- Describe what people could do manually

**Example with JavaScript step definition:**

```gherkin
Scenario: Customer withdraws cash
  Given Patricia has $500 in her checking account
  When Patricia withdraws $100 from an ATM
  Then Patricia should have $400 in her checking account
```

```javascript
// Step definition in JavaScript
const { Given, When, Then } = require('@cucumber/cucumber');

Given('Patricia has ${int} in her checking account', function(amount) {
  this.account = { balance: amount };
});

When('Patricia withdraws ${int} from an ATM', function(amount) {
  this.account.balance -= amount;
});

Then('Patricia should have ${int} in her checking account', function(expectedAmount) {
  assert.equal(this.account.balance, expectedAmount);
});
```

---

## Key BDD Principles Summary

1. **Collaboration is essential** - Discovery must involve multiple perspectives
2. **Order matters** - Discovery → Formulation → Automation
3. **Examples drive development** - Use concrete, real-world examples
4. **Focus on behaviour** - What the system should do, not how
5. **Keep it declarative** - Describe intent, hide implementation
6. **Iterate rapidly** - Small increments with continuous feedback
7. **Living documentation** - Scenarios document actual system behaviour
8. **Shared understanding** - Common language across technical and business teams

---

# Gherkin Reference

**Source:** https://cucumber.io/docs/gherkin/reference/

---

## What is Gherkin?

Gherkin is a set of special keywords that give structure and meaning to executable specifications. It's designed to be readable by both humans and computers.

### Key Characteristics

- **Plain language structure** - Written in plain text that anyone can read
- **Keyword-based** - Uses specific keywords to organize scenarios
- **Multilingual** - Translated to over 70 spoken languages
- **Executable** - Can be automated and run as tests
- **File format** - Stored in `.feature` files

---

## Gherkin Syntax Basics

### Comments

- Only permitted at the start of a new line
- Begin with zero or more spaces, followed by hash sign (`#`)
- Block comments are not currently supported

```gherkin
# This is a comment
Feature: Guess the word

  # Another comment
  Scenario: Maker starts a game
    When the Maker starts a game
    Then the Maker waits for a Breaker to join
```

### Indentation

- Either spaces or tabs may be used
- Recommended: two spaces
- Indentation improves readability but is not syntactically significant

---

## Primary Keywords

### Feature

**Purpose:** Provide high-level description of a software feature and group related scenarios.

**Structure:**
- Must be the first primary keyword in a Gherkin document
- Followed by `:` and short descriptive text
- Can include free-form description underneath

**Example:**
```gherkin
Feature: Guess the word
  The word guess game is a turn-based game for two players.
  The Maker makes a word for the Breaker to guess. The game
  is over when the Breaker guesses the Maker's word.

  Scenario: Maker starts a game
    Given the Maker has chosen a word
    When the Breaker makes a guess
    Then the Maker is asked to score
```

**Key Points:**
- Only one `Feature` per `.feature` file
- Name and description have no special meaning to Cucumber
- Used for documentation and reporting
- Can place tags above `Feature` to group related features

---

### Rule (Gherkin 6+)

**Purpose:** Represent one business rule that should be implemented.

**Usage:**
- Optional keyword (introduced in Gherkin 6)
- Groups together several scenarios belonging to a business rule
- Provides additional information for a feature

**Example:**
```gherkin
Feature: Highlander

  Rule: There can be only One

    Example: Only One -- More than one alive
      Given there are 3 ninjas
      And there are more than one ninja alive
      When 2 ninjas meet, they will fight
      Then one ninja dies (but not me)
      And there is one ninja less alive

    Example: Only One -- One alive
      Given there is only 1 ninja alive
      Then they will live forever ;-)

  Rule: There can be Two (in some cases)

    Example: Two -- Dead and Reborn as Phoenix
      ...
```

---

### Scenario / Example

**Purpose:** Concrete example that illustrates a business rule.

**Aliases:** `Scenario` and `Example` are synonymous

**Structure:**
- Consists of a list of steps
- Recommended: 3-5 steps per scenario
- Too many steps reduces expressive power

**Pattern:**
1. **Given** - Describe initial context
2. **When** - Describe an event
3. **Then** - Describe expected outcome

**Example:**
```gherkin
Scenario: Breaker guesses a word
  Given the Maker has chosen a word "silky"
  When the Breaker makes a guess "silly"
  Then the Breaker is told the guess is wrong
```

**Key Points:**
- Each scenario is both specification/documentation AND a test
- All scenarios together form executable specification
- First line should be short description (one sentence)
- If can't describe in single sentence → split into multiple scenarios

---

## Steps

### Step Keywords

Each step starts with one of these keywords:
- `Given` - Initial context/preconditions
- `When` - Event or action
- `Then` - Expected outcome
- `And` / `But` - For readability when repeating keywords
- `*` - Alternative to any keyword (bullet-point style)

### Important Notes

**Keywords are not considered in matching:**
- Cannot have different step keywords with same text
- This enforces clearer domain language

❌ **Duplicates (not allowed):**
```gherkin
Given there is money in my account
Then there is money in my account
```

✅ **Better approach:**
```gherkin
Given my account has a balance of £430
Then my account should have a balance of £430
```

---

### Given Steps

**Purpose:** Describe the initial context of the system (the scene).

**Characteristics:**
- Something that happened in the past
- Configures system to well-defined state
- Creates/configures objects or adds data to test database
- Puts system in known state before user interaction

**Guidelines:**
- Avoid talking about user interaction in `Given` steps
- These are your preconditions (use case terminology)
- Okay to have multiple `Given` steps (use `And`/`But` for readability)

**Examples:**
```gherkin
Given Mickey and Minnie have started a game
Given I am logged in
Given Joe has a balance of £42
```

---

### When Steps

**Purpose:** Describe an event or action.

**Characteristics:**
- Person interacting with system
- Event triggered by another system
- Should be technology-agnostic
- Imagine it's 1922 (no computers)

**Guidelines:**
- Hide implementation details in step definitions
- Focus on what happens, not how

**Examples:**
```gherkin
When I guess a word
When I invite a friend
When I withdraw money
```

**JavaScript Step Definition Example:**
```javascript
const { When } = require('@cucumber/cucumber');

When('I withdraw ${int}', function(amount) {
  this.account.withdraw(amount);
});
```

---

### Then Steps

**Purpose:** Describe expected outcome or result.

**Characteristics:**
- Should use assertions to compare actual vs expected
- Outcome should be observable output
- Something that comes out of the system

**Guidelines:**
- Don't look in database (not observable by user)
- Verify user-observable outcomes only
- Report, UI, message, etc.

**Examples:**
```gherkin
Then I should see that the guessed word was wrong
Then I should receive an invitation
Then my card should be swallowed
```

**JavaScript Step Definition Example:**
```javascript
const { Then } = require('@cucumber/cucumber');
const assert = require('assert');

Then('my account should have a balance of ${int}', function(expectedAmount) {
  assert.equal(this.account.balance, expectedAmount);
});
```

---

### And, But

**Purpose:** Improve readability when you have successive steps with same keyword.

**Without And/But:**
```gherkin
Example: Multiple Givens
  Given one thing
  Given another thing
  Given yet another thing
  When I open my eyes
  Then I should see something
  Then I shouldn't see something else
```

**With And/But (more fluid):**
```gherkin
Example: Multiple Givens
  Given one thing
  And another thing
  And yet another thing
  When I open my eyes
  Then I should see something
  But I shouldn't see something else
```

---

### Asterisk (*) - Bullet Point Style

**Purpose:** Express steps as bullet points when natural language doesn't read elegantly.

**Example:**
```gherkin
Scenario: All done
  Given I am out shopping
  * I have eggs
  * I have milk
  * I have butter
  When I check my list
  Then I don't need anything
```

---

## Background

**Purpose:** Add context that repeats in all scenarios.

**Characteristics:**
- Groups common `Given` steps
- Run before each scenario
- Run after any Before hooks
- Can only have one `Background` per `Feature` or `Rule`

**Example:**
```gherkin
Feature: Multiple site support
  Only blog owners can post to a blog, except administrators,
  who can post to all blogs.

  Background:
    Given a global administrator named "Greg"
    And a blog named "Greg's anti-tax rants"
    And a customer named "Dr. Bill"
    And a blog named "Expensive Therapy" owned by "Dr. Bill"

  Scenario: Dr. Bill posts to his own blog
    Given I am logged in as Dr. Bill
    When I try to post to "Expensive Therapy"
    Then I should see "Your article was published."

  Scenario: Dr. Bill tries to post to somebody else's blog
    Given I am logged in as Dr. Bill
    When I try to post to "Greg's anti-tax rants"
    Then I should see "Hey! That's not your blog!"
```

### Background at Rule Level

```gherkin
Feature: Overdue tasks

  Rule: Users are notified about overdue tasks on first use of the day
  
    Background:
      Given I have overdue tasks

    Example: First use of the day
      Given I last used the app yesterday
      When I use the app
      Then I am notified about overdue tasks

    Example: Already used today
      Given I last used the app earlier today
      When I use the app
      Then I am not notified about overdue tasks
```

### Tips for Using Background

1. **Don't set up complicated states** unless client needs to know
   - Use higher-level steps like `Given I am logged in as a site owner`

2. **Keep it short** (4 lines or less)
   - Readers need to remember this context

3. **Make it vivid**
   - Use colourful names
   - Tell a story (brain remembers stories better than "User A", "Site 1")

4. **Keep scenarios short**
   - If `Background` scrolls off screen, consider higher-level steps or splitting file

---

## Scenario Outline

**Purpose:** Run the same scenario multiple times with different value combinations.

**Alias:** `Scenario Template` is a synonym

### Without Scenario Outline (Repetitive)

```gherkin
Scenario: eat 5 out of 12
  Given there are 12 cucumbers
  When I eat 5 cucumbers
  Then I should have 7 cucumbers

Scenario: eat 5 out of 20
  Given there are 20 cucumbers
  When I eat 5 cucumbers
  Then I should have 15 cucumbers
```

### With Scenario Outline (Concise)

```gherkin
Scenario Outline: eating
  Given there are <start> cucumbers
  When I eat <eat> cucumbers
  Then I should have <left> cucumbers

  Examples:
    | start | eat | left |
    |  12   |  5  |  7   |
    |  20   |  5  |  15  |
```

### How It Works

- Template with `<>`-delimited parameters
- Never runs directly
- Runs once for each row in `Examples` table (excluding header)
- Parameters replaced with table values before matching step definitions
- Can use parameters in descriptions and multiline step arguments

**JavaScript Step Definition Example:**
```javascript
const { Given, When, Then } = require('@cucumber/cucumber');

Given('there are {int} cucumbers', function(count) {
  this.cucumbers = count;
});

When('I eat {int} cucumbers', function(count) {
  this.cucumbers -= count;
});

Then('I should have {int} cucumbers', function(count) {
  assert.equal(this.cucumbers, count);
});
```

---

## Step Arguments

### Doc Strings

**Purpose:** Pass larger piece of text to a step definition.

**Delimiters:** Three double-quotes (`"""`) or three backticks (` ``` `)

**Example with triple quotes:**
```gherkin
Given a blog post named "Random" with Markdown body
  """
  Some Title, Eh?
  ===============
  Here is the first paragraph of my blog post. Lorem ipsum dolor sit amet,
  consectetur adipiscing elit.
  """
```

**Example with backticks:**
```gherkin
Given a blog post named "Random" with Markdown body
  ```
  Some Title, Eh?
  ===============
  Here is the first paragraph of my blog post.
  ```
```

**With Content Type:**
```gherkin
Given a blog post named "Random" with Markdown body
  """markdown
  Some Title, Eh?
  ===============
  Here is the first paragraph.
  """
```

**JavaScript Step Definition:**
```javascript
const { Given } = require('@cucumber/cucumber');

Given('a blog post named {string} with Markdown body', function(title, docString) {
  // docString is automatically passed as last argument
  this.createBlogPost(title, docString);
});
```

**Key Points:**
- Automatically passed as last argument to step definition
- No need to match in pattern
- Indentation of opening delimiter is unimportant (usually 2 spaces)
- Internal indentation is significant (dedented according to opening delimiter)

---

### Data Tables

**Purpose:** Pass a list of values to a step definition.

**Example:**
```gherkin
Given the following users exist:
  | name   | email               | twitter        |
  | Aslak  | aslak@cucumber.io   | @aslak_hellesoy |
  | Julien | julien@cucumber.io  | @jbpros        |
  | Matt   | matt@cucumber.io    | @mattwynne     |
```

**JavaScript Step Definition:**
```javascript
const { Given } = require('@cucumber/cucumber');

Given('the following users exist:', function(dataTable) {
  // dataTable is automatically passed as last argument
  const users = dataTable.hashes(); // Convert to array of objects
  users.forEach(user => {
    this.createUser(user.name, user.email, user.twitter);
  });
});
```

**Common Data Table Methods (JavaScript):**
```javascript
// Get array of arrays (including header)
const rows = dataTable.raw();

// Get array of objects (header as keys)
const users = dataTable.hashes();

// Get single row as array
const firstRow = dataTable.rawTable[0];

// Get array of values from single column
const names = dataTable.rows().map(row => row[0]);
```

### Table Cell Escaping

- Newline: `\n`
- Pipe: `\|`
- Backslash: `\\`

**Example:**
```gherkin
Given the following data:
  | description          | value |
  | Line 1\nLine 2       | text  |
  | Pipe \| character    | text  |
  | Backslash \\ char    | text  |
```

---

## Descriptions

Free-form descriptions can be placed underneath:
- `Feature`
- `Scenario` / `Example`
- `Background`
- `Scenario Outline`
- `Rule`

**Guidelines:**
- Can write anything as long as no line starts with a keyword
- Can use Markdown format
- Ignored by Cucumber at runtime
- Available for reporting (HTML formatter includes them)

---

## Spoken Languages

### Language Support

Gherkin has been translated to **over 70 languages** to match the language your users and domain experts use.

### Specifying Language

Use `# language:` header on first line:

```gherkin
# language: no
Funksjonalitet: Gjett et ord

  Eksempel: Ordmaker starter et spill
    Når Ordmaker starter et spill
    Så må Ordmaker vente på at Gjetter blir med

  Eksempel: Gjetter blir med
    Gitt at Ordmaker har startet et spill med ordet "bløtt"
    Når Gjetter blir med på Ordmakers spill
    Så må Gjetter gjette et ord på 5 bokstaver
```

**Default:** If omitted, defaults to English (`en`)

**Configuration:** Some implementations let you set default language in configuration

### Popular Language Codes

- `en` - English
- `es` - español (Spanish)
- `fr` - français (French)
- `de` - Deutsch (German)
- `pt` - português (Portuguese)
- `ru` - русский (Russian)
- `zh-CN` - 简体中文 (Chinese Simplified)
- `ja` - 日本語 (Japanese)
- `ar` - العربية (Arabic)
- `hi` - हिंदी (Hindi)

**Full language list:** See https://github.com/cucumber/gherkin for complete translations

---

## Step Organization

**Source:** https://cucumber.io/docs/gherkin/step-organization/

### File Organization

**Starting Out:**
- All step definitions probably in one file

**As Project Grows:**
- Split into meaningful groups in different files
- Makes project more logical and easier to maintain

### How Cucumber Finds Files

- Cucumber flattens the directory tree when running tests
- Treats anything ending in appropriate extension as step definition
- Searches for features corresponding to step definitions

### Grouping by Domain Concept

**Recommended:** One file for each major domain object

**Example: Curriculum Vitae Application**

```
features/
  step_definitions/
    employee_steps.js
    education_steps.js
    experience_steps.js
    authentication_steps.js
```

**Structure:**
- First three files: CRUD operations for domain objects
- Last file: Authentication and authorization logic

**Benefit:** Avoids Feature-coupled step definitions anti-pattern

### Best Practices

#### 1. Only Write Needed Step Definitions

- Don't write steps for scenarios that don't exist
- Avoid unused cruft
- Implement only what you need
- Refactor as project grows

#### 2. Avoid Duplication

**Problem - Similar steps:**
```gherkin
Given I go to the home page
Given I check the about page
Given I get the contact details
```

**Solution - Single parameterized step:**
```gherkin
Given I go to the {string} page
```

**JavaScript Implementation:**
```javascript
const { Given } = require('@cucumber/cucumber');

Given('I go to the {string} page', function(webpage) {
  webpageFactory.openPage(webpage);
});
```

**Benefits:**
- Increased maintainability
- Increased scalability with reusable steps
- More understandable tests

#### 3. Use Helper Methods

**Purpose:** Abstract common functionality for modularity and reuse

**Key Points:**
- Full expressiveness of programming language available in step definitions
- Refactor into helper methods for greater modularity
- Methods can reside in same file as step definitions
- Makes project more understandable and maintainable

**Example Helper Methods:**
```javascript
// helper-functions.js
function openWebPage(pageName) {
  const url = getUrlForPage(pageName);
  return browser.url(url);
}

function getUrlForPage(pageName) {
  const urls = {
    'home': '/',
    'about': '/about',
    'contact': '/contact'
  };
  return urls[pageName.toLowerCase()] || '/';
}

module.exports = { openWebPage, getUrlForPage };
```

**Using Helpers in Steps:**
```javascript
const { Given, When, Then } = require('@cucumber/cucumber');
const { openWebPage } = require('./helper-functions');

Given('I go to the {string} page', function(webpage) {
  return openWebPage(webpage);
});

When('I click the {string} button', function(buttonName) {
  return clickButton(buttonName);
});
```

#### 4. Use Data Tables

Data Tables help increase maintainability and understandability:

```gherkin
Given the following users exist:
  | name   | role  | email             |
  | Alice  | admin | alice@example.com |
  | Bob    | user  | bob@example.com   |
  | Charlie| user  | charlie@example.com |
```

```javascript
Given('the following users exist:', function(dataTable) {
  const users = dataTable.hashes();
  users.forEach(user => {
    createUser(user.name, user.role, user.email);
  });
});
```

### Naming Conventions

**Examples by Language:**
- **Java:** `EmployeeStepDefinitions.java`
- **JavaScript:** `employee_steps.js`
- **Ruby:** `employee_steps.rb`
- **Kotlin:** `EmployeeStepDefinitions.kt`
- **Go:** `employee_steps.go`

**Key Point:** Naming doesn't technically matter, but consistency and organization do.

---

## Gherkin Best Practices Summary

1. **One Feature per file** - Keep features focused and manageable
2. **3-5 steps per scenario** - Avoid too many steps
3. **One thing per Given step** - Split steps with "and" in middle
4. **Consistent wording** - Say same thing same way every time
5. **Describe behaviour, not implementation** - Focus on what, not how
6. **Use declarative style** - Hide implementation details
7. **Keep Background short** - 4 lines or less
8. **Use meaningful names** - Colourful, story-telling names
9. **Organize by domain** - One file per major domain object
10. **Avoid duplication** - Use parameterized steps and helper methods
11. **Technology-agnostic examples** - No technical details in scenarios
12. **Concrete examples** - Use real names, dates, amounts