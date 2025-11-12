# ⚠️ DEPRECATED: MSW Workflow Context

**Status**: Deprecated as of 2025-01-13
**Reason**: Merged into unified BDD Frontend Agent

## Migration Information

This separate MSW workflow context has been **merged** into the comprehensive BDD Frontend Agent context.

### Old Location (Deprecated)
```
ai-context/frontend-agents/msw-workflow/
└── msw-handler-creation-guide.md
```

### New Location (Active)
```
ai-context/bdd-agents/bdd-frontend-agent/
├── README.md (workflow overview)
└── bdd-test-agent-context.md (complete unified context)
```

## Why This Changed

The MSW handler creation and step definition implementation are **sequential phases** of the same BDD-First workflow, not separate processes:

**Old Approach** (Deprecated):
- Use MSW workflow context to create handlers
- Switch to BDD frontend context to create step definitions
- Manual coordination between two contexts

**New Approach** (Current):
- Use unified BDD Frontend Agent for complete workflow
- Phase 1: MSW Handler Creation
- Phase 2: Step Definition Implementation
- Phase 3: Pact Contract Generation
- Single context, streamlined workflow

## What to Use Instead

**For AI Agents**:
Use `ai-context/bdd-agents/bdd-frontend-agent/bdd-test-agent-context.md`

**For Developers**:
Read `ai-context/bdd-agents/bdd-frontend-agent/README.md` for overview

## Content Preserved

All content from `msw-handler-creation-guide.md` has been integrated into Phase 1 of the unified BDD Frontend Agent context. Nothing was lost in the merge.

### What Was Merged

From `msw-handler-creation-guide.md`:
- ✅ MSW handler creation process → Now Phase 1
- ✅ Environment-specific data guidelines → Integrated
- ✅ Best practices → Merged with existing patterns
- ✅ Complete examples → Included in Phase 1
- ✅ Troubleshooting → Combined troubleshooting section
- ✅ Package.json scripts reference → Updated

## Timeline

- **Before 2025-01-13**: Separate MSW workflow and BDD frontend contexts
- **2025-01-13**: Merged into unified BDD Frontend Agent
- **Going forward**: Use only the unified context in `bdd-agents/bdd-frontend-agent/`

## Questions?

If you need the old MSW workflow context for reference, it's preserved in this folder. However, **always use the unified context** for new work.

---

**Last Updated**: 2025-01-13
**Migration Status**: Complete
**Removal Date**: TBD (will remain for reference)
