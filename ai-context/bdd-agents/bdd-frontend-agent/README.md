# BDD Frontend Agent - Unified Context

## Purpose

This comprehensive AI agent context handles the complete BDD-First frontend development workflow, from Cucumber features to production-ready code with contract testing.

## What This Agent Does

The BDD Frontend Agent implements features end-to-end using a BDD-First approach:

1. **Creates MSW Handlers** - Provides rich mock data from Cucumber scenarios
2. **Implements Step Definitions** - Writes executable Cucumber tests
3. **Generates Pact Contracts** - Creates API contracts for backend teams

## When to Use This Agent

Use this agent when:
- ✅ Starting implementation of new Cucumber features
- ✅ Adding new API endpoints to the frontend
- ✅ Implementing BDD tests for existing features
- ✅ Updating mock data for feature scenarios
- ✅ Generating API contracts for backend integration

## Complete BDD-First Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                     BDD-First Workflow                          │
└─────────────────────────────────────────────────────────────────┘

1. Cucumber Features (Given) → Requirements in Gherkin
           ↓
2. MSW Handlers (Create) → Rich mock data for scenarios
           ↓
3. Step Definitions (Implement) → Executable Cucumber tests
           ↓
4. Frontend Code (Build) → Components using MSW-mocked APIs
           ↓
5. Pact Contracts (Generate) → API contracts for backend
           ↓
6. Backend Implementation (Deliver) → Backend implements contracts
```

## Key Files

**Main Context**:
- `bdd-test-agent-context.md` - Complete unified context for the agent

**Supporting Documentation**:
- `workflows/` - Detailed phase-by-phase workflows (if needed)
- `examples/` - Code examples and patterns (if needed)

## Quick Start

**For AI Agents**:
Read `bdd-test-agent-context.md` to understand:
- Your role and capabilities
- The complete BDD-First workflow
- How to create MSW handlers from scenarios
- How to implement step definitions
- How to generate Pact contracts

**For Developers**:
This context teaches AI agents to:
1. Analyze Cucumber scenarios for API requirements
2. Create environment-specific mock data
3. Implement complete, executable step definitions
4. Generate Pact contracts automatically
5. Follow project conventions and best practices

## Philosophy

**MSW** = Development tool for rich, varied test data
**Pact** = Contract tool for backend API requirements
**BDD** = Requirements tool for stakeholder communication

All three work together in a unified workflow to enable:
- ✅ Frontend development not blocked by backend
- ✅ Clear API contracts between teams
- ✅ Automated testing at all levels
- ✅ Stakeholder-approved requirements

## Package.json Scripts Reference

```bash
npm run test:e2e        # Run Cucumber BDD tests
npm run pact:generate   # Generate Pact from MSW
npm run pact:validate   # Validate MSW-Pact sync
npm run pact:workflow   # Generate + validate
npm run pact:publish    # Publish to Pact Broker
```

## Migration from Separate Contexts

**Previous Setup** (deprecated):
- `ai-context/frontend-agents/msw-workflow/` - MSW handlers only
- `ai-context/bdd-agents/bdd-frontend-agent/` - Step definitions only

**New Setup** (current):
- `ai-context/bdd-agents/bdd-frontend-agent/` - **Complete unified workflow**

The separate MSW workflow context has been merged into this comprehensive agent.

---

**Version**: 2.0 (Unified)
**Last Updated**: 2025-01-13
**Status**: Active
