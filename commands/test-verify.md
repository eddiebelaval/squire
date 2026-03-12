# Test and Verify

You are executing the **test-verify** workflow - runs tests and verifies the application works.

## Pre-computed Context

```bash
# Detect project type
HAS_PACKAGE_JSON=$(test -f package.json && echo "yes" || echo "no")
HAS_PYPROJECT=$(test -f pyproject.toml && echo "yes" || echo "no")
HAS_SETUP_PY=$(test -f setup.py && echo "yes" || echo "no")
HAS_CARGO_TOML=$(test -f Cargo.toml && echo "yes" || echo "no")
HAS_GO_MOD=$(test -f go.mod && echo "yes" || echo "no")
HAS_MAKEFILE=$(test -f Makefile && echo "yes" || echo "no")

# Node.js detection
TEST_SCRIPT=$(cat package.json 2>/dev/null | jq -r '.scripts.test // "none"')
TYPECHECK_SCRIPT=$(cat package.json 2>/dev/null | jq -r '.scripts["type-check"] // .scripts.typecheck // "none"')
LINT_SCRIPT=$(cat package.json 2>/dev/null | jq -r '.scripts.lint // "none"')
BUILD_SCRIPT=$(cat package.json 2>/dev/null | jq -r '.scripts.build // "none"')
HAS_PLAYWRIGHT=$(test -f playwright.config.ts && echo "yes" || echo "no")
HAS_VITEST=$(grep -q "vitest" package.json 2>/dev/null && echo "yes" || echo "no")
HAS_JEST=$(grep -q "jest" package.json 2>/dev/null && echo "yes" || echo "no")

# Python detection
HAS_PYTEST=$(pip list 2>/dev/null | grep -q pytest && echo "yes" || echo "no")
HAS_MYPY=$(pip list 2>/dev/null | grep -q mypy && echo "yes" || echo "no")
HAS_RUFF=$(pip list 2>/dev/null | grep -q ruff && echo "yes" || echo "no")

# Shell detection
SHELL_SCRIPTS=$(find . -maxdepth 2 -name "*.sh" -type f 2>/dev/null | head -5)
HAS_SHELLCHECK=$(command -v shellcheck >/dev/null 2>&1 && echo "yes" || echo "no")
```

**Project Type Detection:**
- Node.js: $HAS_PACKAGE_JSON | Python: $HAS_PYPROJECT / $HAS_SETUP_PY | Rust: $HAS_CARGO_TOML | Go: $HAS_GO_MOD

**Node.js:** Test=$TEST_SCRIPT | TypeCheck=$TYPECHECK_SCRIPT | Lint=$LINT_SCRIPT | Build=$BUILD_SCRIPT | Playwright=$HAS_PLAYWRIGHT | Vitest=$HAS_VITEST | Jest=$HAS_JEST
**Python:** Pytest=$HAS_PYTEST | Mypy=$HAS_MYPY | Ruff=$HAS_RUFF
**Shell:** Scripts=$SHELL_SCRIPTS | Shellcheck=$HAS_SHELLCHECK

## User Intent

$ARGUMENTS

## Project Type Auto-Detection

Determine project type from pre-computed context:
- **Node.js/TypeScript** if $HAS_PACKAGE_JSON = "yes" (default)
- **Python** if $HAS_PYPROJECT = "yes" or $HAS_SETUP_PY = "yes"
- **Shell/Bash** if shell scripts found and no package.json/pyproject.toml
- **Rust** if $HAS_CARGO_TOML = "yes"
- **Go** if $HAS_GO_MOD = "yes"
- **Makefile** if $HAS_MAKEFILE = "yes" and no other match

Run the workflow matching the detected project type.

---

## Node.js/TypeScript Workflow

### Phase 1: Static Analysis
Run in parallel where possible:

1. **Type Check** (if TypeScript project)
```bash
npm run type-check || npx tsc --noEmit
```

2. **Lint Check**
```bash
npm run lint
```

### Phase 2: Unit/Integration Tests
```bash
npm test
```

If specific test file requested in $ARGUMENTS:
```bash
npm test -- [file-pattern]
```

### Phase 3: E2E Tests (if Playwright exists)
```bash
npx playwright test
```

For specific test:
```bash
npx playwright test [test-name]
```

### Phase 4: Build Verification
```bash
npm run build
```

### Phase 5: Visual Verification (if requested or if UI changes)
Use Playwright MCP to:
1. Start dev server if not running
2. Navigate to relevant pages
3. Take screenshots
4. Verify UI renders correctly

---

## Python Workflow

### Phase 1: Static Analysis
Run in parallel where possible:

1. **Type Check** (if mypy available)
```bash
mypy . --ignore-missing-imports
```

2. **Lint Check** (prefer ruff, fallback to flake8)
```bash
ruff check . || flake8 .
```

### Phase 2: Unit/Integration Tests
```bash
pytest -v
```

If specific test file requested in $ARGUMENTS:
```bash
pytest -v [file-pattern]
```

### Phase 3: Build Verification
```bash
python -m py_compile [main-file] || python -c "import [package]"
```

---

## Shell/Bash Workflow

### Phase 1: Static Analysis
```bash
shellcheck *.sh scripts/*.sh
```

### Phase 2: Functional Tests
Run any test scripts found:
```bash
bash tests/test_*.sh || bash test.sh
```

### Phase 3: Syntax Check
```bash
bash -n [each .sh file]
```

---

## Rust Workflow

### Phase 1: Static Analysis
```bash
cargo clippy -- -D warnings
```

### Phase 2: Tests
```bash
cargo test
```

### Phase 3: Build
```bash
cargo build
```

---

## Go Workflow

### Phase 1: Static Analysis
```bash
go vet ./...
```

### Phase 2: Tests
```bash
go test ./...
```

### Phase 3: Build
```bash
go build ./...
```

## Reporting

After each phase, report:
```
Phase 1 (Static Analysis): PASS/FAIL
  - TypeScript: X errors
  - ESLint: X warnings, X errors

Phase 2 (Tests): PASS/FAIL
  - X tests passed
  - X tests failed
  - X tests skipped

Phase 3 (E2E): PASS/FAIL (if applicable)
  - X specs passed

Phase 4 (Build): PASS/FAIL
  - Build time: Xs

Overall: PASS/FAIL
```

## Quick Modes

If $ARGUMENTS contains:
- "quick" or "fast": Only run type-check + lint (skip tests)
- "unit": Only run unit tests
- "e2e": Only run Playwright tests
- "build": Only verify build
- "all" or empty: Full verification

## Error Handling

On failure:
1. Capture full error output
2. Identify the failing test/check
3. Show relevant code context
4. Suggest fix if obvious

Do NOT proceed to later phases if earlier phases fail (unless user says "continue anyway").

## Integration with Playwright MCP

For visual verification:
```
1. browser_navigate to localhost:3000 (or dev server URL)
2. browser_snapshot to capture page state
3. browser_take_screenshot for visual record
4. Compare with expected behavior
```
