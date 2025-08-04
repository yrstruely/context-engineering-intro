### 🔄 Project Awareness & Context
- **Always read `PLANNING.md`** at the start of a new conversation to understand the project's architecture, goals, style, and constraints.
- **Check `TASK.md`** before starting a new task. If the task isn’t listed, add it with a brief description and today's date.
- **Use consistent naming conventions, file structure, and architecture patterns** as described in `PLANNING.md`.
- **Use venv_linux** (the virtual environment) whenever executing Python commands, including for unit tests.

### 🧱 Code Structure & Modularity
- **Never create a file longer than 500 lines of code.** If a file approaches this limit, refactor by splitting it into modules or helper files.
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
  For agents this looks like:
    - `agent` - Main agent definition and execution logic 
    - `tools` - Tool functions used by the agent 
    - `prompts` - System prompts
- **Use clear, consistent imports** (prefer relative imports within packages).
- **Use dotenv and load_env()** for environment variables.

### Development Process
- **Always develop code using BDD and TDD principles** (prefer Cucumber for BDD then breakdown BDD tests into integration and unit tests, before writing the code to make these tests pass)
- **Always use the Red, Green, Refactor cycle** no new code is complete until the tests are passing.
- **When the project has APIs, use Pact contract tests** see: https://github.com/pact-foundation, https://github.com/pact-foundation/pact-js, https://github.com/pact-foundation/pact-python and other pact repos for more information.
- **Where appropriate, include integration tests** ensuring that code modules work correctly with each other
- **If the development environment is in Docker, run the tests in docker** check to see if there is an existing docker setup and create it if not.
- **When the project has database(s), and code changes require schema changes** always run database migrations before running tests.
- **Always include instructions for running the tests in the `README.md`**


### 🧪 Testing & Reliability
- **Always create, BDD, integration and unit tests for new features** (functions, classes, routes, etc).
- **After updating any logic**, check whether existing tests need to be updated. If so, do it.
- **Tests should live in a `/tests` folder** mirroring the main app structure.
  - Include at least:
    - 1 test for expected use
    - 1 edge case
    - 1 failure case

### ✅ Task Completion
- **Mark completed tasks in `TASK.md`** immediately after finishing them.
- Add new sub-tasks or TODOs discovered during development to `TASK.md` under a “Discovered During Work” section.

### 📎 Style & Conventions
- Write **docstrings for every function** using the Google style:
  ```
  def example():
      """
      Brief summary.

      Args:
          param1 (type): Description.

      Returns:
          type: Description.
      """
  ```

### 📚 Documentation & Explainability
- **Update `README.md`** when new features are added, dependencies change, or setup steps are modified.
- **Comment non-obvious code** and ensure everything is understandable to a mid-level developer.
- When writing complex logic, **add an inline `# Reason:` comment** explaining the why, not just the what.

### 🧠 AI Behavior Rules
- **Never assume missing context. Ask questions if uncertain.**
- **Never hallucinate libraries or functions** – only use known, verified packages.
- **Always confirm file paths and module names** exist before referencing them in code or tests.
- **Never delete or overwrite existing code** unless explicitly instructed to or if part of a task from `TASK.md`.