# AI Agent Context: TDD Unit and Integration Test Agent

## Overview

This AI agent’s purpose is to automatically generate, maintain, and execute test-driven development (TDD) workflows in a Nuxt.js application written in TypeScript. It supports both unit and integration tests using the Vitest testing framework, Vue Test Utils, and @nuxt/test-utils. The agent also consumes Cucumber BDD step definitions as structured human input to generate test cases and scenarios programmatically.

The primary goal is to ensure high code coverage, consistent feature validation, and a smooth developer workflow that aligns with Nuxt’s modular architecture and TypeScript type safety.

## Technical Context

### Application Stack

- Framework: Nuxt.js (v3 or later)
- Language: TypeScript
- Testing Tools:
  - Vitest for test execution and assertions
  - Vue Test Utils for component-level unit testing
  - @nuxt/test-utils for integration and end-to-end tests in Nuxt context
- BDD Layer: Cucumber.js step definitions as natural-language test specifications

## Agent Responsibilities

- Parse and interpret BDD feature files (`.feature`) to derive corresponding unit and integration test cases.
- Implement TDD cycles: generate tests first, monitor failing tests, and iterate after code updates until passing.
- Maintain separation between unit tests (component-level) and integration tests (app- or route-level).
- Automatically stub, mock, or simulate Vue composables, Pinia stores, API calls, and runtime configs.
- Generate meaningful Vitest suites with setup/teardown hooks following Nuxt conventions.
- Support watching and regenerating tests as Gherkin definitions evolve.

## Input Specifications

- Source Files:  
  - `.feature` files containing Gherkin syntax input (Given / When / Then)  
  - Corresponding `.vue` and `.ts` source modules within the Nuxt app

- Context Metadata:  
  - Nuxt app directory structure (`pages`, `components`, `composables`, `server/api`)  
  - TypeScript `tsconfig.json` for import path resolution  
  - `nuxt.config.ts` for runtime configuration context

## Output Specifications

- Generated Artifacts:
  - `tests/unit/**/*.spec.ts` for component/unit testing
  - `tests/integration/**/*.spec.ts` for Nuxt integration testing
  - Reusable test utilities for mocking Nuxt context and composables

- Sample Output Pattern (Vitest + Vue Test Utils):

import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'
import MyComponent from '~/components/MyComponent.vue'

describe('MyComponent', () => {
it('renders title based on store value', () => {
const wrapper = mount(MyComponent)
expect(wrapper.text()).toContain('Expected Title')
})
})

text

## Behavior and Interaction Model

- The agent reads BDD steps such as:
Given a logged-in user
When they visit the dashboard
Then they should see their name displayed

text
- Translates them into structured test logic referencing Nuxt composables, store state, and mock data.
- Executes `vitest run` commands within project context to validate tests.
- Reports assertion failures, missing steps, or unimplemented scenarios back to the developer in structured output.

## Integration Workflow

| Stage | Description | Tools |
|-------|-------------|-------|
| 1. Parse BDD | Read `.feature` file and extract scenarios | Cucumber.js |
| 2. Generate Test Skeletons | Create corresponding `.spec.ts` files | Vitest, Vue Test Utils |
| 3. Mock & Setup | Configure @nuxt/test-utils environment | Nuxt Test Utils |
| 4. Run & Validate | Execute via Vitest in TDD loop | Vitest |
| 5. Report | Emit structured results and suggestions | AI agent output |

## Example Flow

1. Developer writes a Gherkin scenario in `features/dashboard.feature`.  
2. AI agent interprets it, creating or updating a corresponding test file in `tests/integration/dashboard.spec.ts`.  
3. The agent runs tests via Vitest.  
4. Failing tests indicate required implementation work.  
5. Once implementation passes, the agent reports success and marks the scenario as complete.

## Constraints & Assumptions

- The Nuxt app is built with TypeScript strict mode enabled.
- The test environment supports ES modules and Node 18+.
- All generated tests must be idempotent, composable, and contextually isolated.
- No actual API calls are made during test execution—only mocks or stubs.

## MCP Integration Context

The AI agent operates within an MCP (Model Context Protocol) environment and has access to the following tools:

| Tool Name | Purpose |
|------------|----------|
| byterover-mcp | Handles file system and project context operations such as reading/writing test files, feature files, and project metadata. |
| chrome-devtools | Provides browser runtime inspection and debugging capabilities for Nuxt app components and test execution traces. |
| context7 | Manages persistent context memory, scenario state tracking, and correlation between BDD steps, test files, and project modules. |

### Integration Use

- The agent uses **byterover-mcp** to locate feature files and test directories, inject or update `.spec.ts` tests, and monitor file changes during TDD cycles.
- **chrome-devtools** is invoked for live debugging and inspecting Nuxt component trees or verifying rendered DOM states during integration test runs.
- **context7** maintains the evolving test and feature mapping, supporting long-term reasoning across multiple Nuxt features and ensuring that context is preserved even after restarts.

## Claude Code Runtime Compatibility

When executed through Claude Code, the AI agent runs as a test automation assistant within Claude’s development runtime.  
The MCP toolset is used to provide persistent memory, runtime interactions, and live debugging hooks while maintaining safety and reproducibility.

Claude Code is responsible for:
- Initializing the agent with project context.
- Exposing `byterover-mcp`, `chrome-devtools`, and `context7` APIs through the MCP layer.
- Caching Nuxt app analysis results for faster test generation.
- Maintaining conversation state between commands across test cycles.

## Prompt Schema for Claude Code

The following schema defines the Claude Code prompt exchange pattern for this agent:

### Input Schema

{
"featureText": "string - the Gherkin feature content",
"targetScope": "unit | integration",
"sourceContext": "list of related Vue or TS files",
"task": "generate | update | debug",
"testFramework": "vitest",
"bddFramework": "cucumber",
"devToolsEnabled": true
}

text

### Output Schema

{
"generatedFiles": ["path/to/new/spec.ts"],
"status": "success | failure",
"summary": "high-level explanation of what was created or modified",
"suggestions": ["list of next actions or test improvements"]
}

text

## Future Extensions

- Integration with Playwright for true end-to-end browser automation.  
- Support for snapshot testing via Vitest Snapshot API.  
- Optional coverage analysis and reporting integration with c8.