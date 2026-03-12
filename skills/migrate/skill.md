---
name: Migrate
slug: migrate
description: Execute a multi-step infrastructure migration with rollback safety, automatic config updates, full verification, and det
category: operations
complexity: complex
version: "1.0.0"
author: "id8Labs"
triggers:
  - "migrate"
  - "migrate"
tags:
  - operations
  - tool-factory-retrofitted
---

# Migrate — Autonomous Infrastructure Migration Pipeline


## Core Workflows

### Workflow 1: Primary Action
1. Analyze the input and context
2. Validate prerequisites are met
3. Execute the core operation
4. Verify the output meets expectations
5. Report results

Execute a multi-step infrastructure migration with rollback safety, automatic config updates, full verification, and detailed logging. No confirmation prompts — runs end-to-end and reports results.

## Usage

```
/migrate "Move auth schema from Supabase project homer-dev to homer-prod"
/migrate "Consolidate two Supabase projects into one, update all .env files"
/migrate "Switch from Redis Cloud to Upstash, update all connection strings"
/migrate "Move from Vercel Postgres to Supabase, migrate schema and data"
```

The argument is a plain-English description of the migration. Be specific about source, destination, and what's moving.

## Instructions

When invoked with a migration description:

### Step 0: Initialize

1. Identify the project(s) involved from the current directory and the migration description.
2. State: "Migration: [DESCRIPTION] | Project: [PROJECT] | Branch: [BRANCH]"
3. Create `MIGRATION_LOG.md` in the project root:
   ```markdown
   # Migration Log — {date}

   **Goal:** {migration description}
   **Started:** {timestamp}
   **Status:** IN PROGRESS

   ---
   ```
4. Every action taken from this point forward gets logged to MIGRATION_LOG.md with a timestamp and result.

### Step 1: Audit Current State

Before touching anything, build a complete picture:

1. **Find all env files** across the repo:
   ```
   .env, .env.local, .env.development, .env.production, .env.test
   ```
   Also check: `vercel.json`, `next.config.js/ts`, `docker-compose.yml`, CI/CD configs.

2. **Catalog every connection string, API key, and URL** that relates to the migration:
   - Database URLs (Supabase, Postgres, Redis)
   - API keys and service tokens
   - Webhook URLs
   - CDN or storage bucket references

3. **Check active connections:**
   - Can we reach the source? (curl, pg_isready, or equivalent)
   - Can we reach the destination? (same checks)
   - Are there active sessions or locks?

4. **Map dependencies:**
   - Which source files import or reference the affected services?
   - Which config files need updating?
   - Are there migration files, seed scripts, or schema definitions?

5. **Log the complete audit** to MIGRATION_LOG.md under `## Step 1: Audit`.

Output to the user:
```
Audit Complete
==============
Env files found: {N}
Connection strings to update: {N}
Source reachable: YES/NO
Destination reachable: YES/NO
Files referencing old config: {list}
```

If source or destination is unreachable, log the error and attempt to diagnose (wrong URL, missing credentials, network issue). Fix if possible. If not fixable, STOP and report — do not proceed with a broken connection.

### Step 2: Create Rollback Safety Net

Before making any changes:

1. **Dump the source schema** (if database migration):
   ```bash
   # For Supabase/Postgres
   pg_dump --schema-only -d "{SOURCE_URL}" > migration_rollback_schema.sql
   pg_dump -d "{SOURCE_URL}" > migration_rollback_full.sql  # if data too
   ```
   If `pg_dump` is not available, use Supabase CLI or MCP to export.

2. **Snapshot all env files:**
   ```bash
   mkdir -p .migration-backup
   cp .env* .migration-backup/ 2>/dev/null
   cp vercel.json .migration-backup/ 2>/dev/null
   ```

3. **Create a git stash or checkpoint:**
   ```bash
   git stash push -m "pre-migration checkpoint"
   ```
   Or if working tree is clean, tag the current commit:
   ```bash
   git tag pre-migration-{timestamp}
   ```

4. **Log all backup locations** to MIGRATION_LOG.md under `## Step 2: Rollback Safety`.

### Step 3: Execute Migration

This step varies by migration type. Apply the appropriate sub-procedure:

#### Database Migration (Supabase/Postgres)
1. Apply schema to destination (use dumped schema or Supabase migrations)
2. Migrate data if required (pg_dump/pg_restore, or INSERT...SELECT via dblink)
3. Verify row counts match between source and destination
4. Verify foreign keys and constraints are intact
5. Run any seed scripts if needed

#### Service Migration (Redis, Storage, CDN)
1. Export data from source service
2. Import data to destination service
3. Verify data integrity (key counts, checksums)

#### Config-Only Migration (URL/key swap)
1. Skip directly to Step 4

**For each action:** Log to MIGRATION_LOG.md with result (success/failure).

**On failure:** Diagnose the issue. Common fixes:
- Permission denied → Check service role vs anon key
- Schema conflict → Drop and recreate (destination only, NEVER source)
- Data type mismatch → ALTER column or cast during transfer
- Timeout → Retry with smaller batch size

If a fix is applied, log it and continue. Do NOT stop unless data loss is possible.

### Step 4: Update All Config Files

For every connection string, API key, or URL identified in the audit:

1. **Replace old values with new values** in all env files.
2. **Update source code** that hard-codes connection details (find with Grep).
3. **Update infrastructure configs:** vercel.json, docker-compose, CI/CD.
4. **Update Vercel environment variables** if the project deploys to Vercel:
   ```bash
   # Read new value, update Vercel
   vercel env rm {VAR_NAME} production
   vercel env add {VAR_NAME} production < <(echo "{NEW_VALUE}")
   ```
   Only do this if user has Vercel CLI configured and the project uses Vercel.

5. **Log every file changed** to MIGRATION_LOG.md under `## Step 4: Config Updates`.

**CRITICAL:** Never log actual secrets to MIGRATION_LOG.md. Use placeholders:
```
Updated .env.local: SUPABASE_URL changed from [old-project].supabase.co to [new-project].supabase.co
```

### Step 5: Verify Everything Works

Run the full verification suite:

1. **Type check:** `npx tsc --noEmit`
2. **Build:** `npm run build`
3. **Unit tests:** `npm test`
4. **E2E tests:** `npx playwright test` (if available)
5. **Connectivity check:** Verify the app can reach the new service:
   - Start dev server briefly and check a health endpoint, OR
   - Run a simple connection test script

**If any check fails:**
- Diagnose the root cause
- Fix it (update config, fix import, adjust type)
- Re-run the failing check
- Log the fix to MIGRATION_LOG.md
- Maximum 3 fix attempts per failure before marking as unresolved

### Step 6: Commit and Report

1. **Clean up backup files** (remove .migration-backup directory — it's in git stash already).
2. **Stage all changed files.**
3. **Commit:**
   ```
   feat: migrate {source} to {destination}

   - Schema migrated: {yes/no}
   - Data migrated: {yes/no}
   - Config files updated: {N}
   - Tests: {PASS/FAIL}
   - Build: {PASS/FAIL}

   See MIGRATION_LOG.md for full details.

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   ```
4. **Finalize MIGRATION_LOG.md:**
   ```markdown
   ---
   **Completed:** {timestamp}
   **Status:** COMPLETE (or COMPLETE WITH WARNINGS)
   **Duration:** {time}

   ## Summary
   - Files modified: {list}
   - Services migrated: {list}
   - Tests: PASS/FAIL
   - Build: PASS/FAIL
   - Unresolved issues: {list or "None"}

   ## Rollback Instructions
   To revert this migration:
   1. git stash pop (or git revert {commit})
   2. Restore .env files from .migration-backup
   3. {any service-specific rollback steps}
   ```

5. **Output summary to user:**
   ```
   Migration Complete
   ==================
   Goal: {description}
   Duration: {time}

   Schema: {migrated/skipped}
   Data: {migrated/skipped}
   Config files updated: {N}
   Type check: PASS/FAIL
   Build: PASS/FAIL
   Tests: PASS/FAIL

   Rollback: git stash pop OR git revert HEAD
   Full log: MIGRATION_LOG.md
   ```

6. Do NOT push to remote. Do NOT delete the git tag/stash.

## Safety Rules

| Rule | Why |
|------|-----|
| Never modify source database destructively | Source is the fallback if destination fails |
| Never log secrets to MIGRATION_LOG.md | Log files get committed |
| Always create rollback checkpoint first | One command to undo everything |
| Verify destination connectivity before writing | Don't write config pointing to unreachable service |
| Never push to remote | User decides when migration is ready to ship |
| Stop if data loss is possible | Ask user instead of risking irreversible damage |

## What This Skill Does NOT Do

- Delete source databases or services (you decommission manually)
- Push to remote or deploy
- Modify production environment variables without Vercel CLI confirmation
- Migrate data larger than what fits in a single pg_dump (flag and ask)
- Handle multi-region or distributed system migrations (too complex for autonomous execution)
