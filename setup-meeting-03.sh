#!/usr/bin/env bash
# DevOps · מפגש 3 · יוצר את פרויקט ה-Starter ב-~/devops-course/meeting-03-ci
set -e
P=~/devops-course/meeting-03-ci
if [ -e "$P" ]; then echo "STOP: $P already exists. Nothing was changed."; exit 1; fi
mkdir -p "$P/src" "$P/tests" "$P/.github/workflows"
cd "$P"

cat > src/__init__.py <<'EOF'
EOF

cat > src/app.py <<'EOF'
"""A tiny app for the CI lab: two functions we can test."""


def add(a, b):
    """Return the sum of a and b."""
    return a + b


def health():
    """Return the service status."""
    return "ok"
EOF

cat > tests/test_app.py <<'EOF'
from src.app import add, health


def test_add():
    assert add(2, 3) == 5


def test_health():
    assert health() == "ok"
EOF

cat > requirements.txt <<'EOF'
pytest==8.3.3
ruff==0.6.9
EOF

cat > .gitignore <<'EOF'
.venv/
__pycache__/
.pytest_cache/
.ruff_cache/
reports/
EOF

cat > README.md <<'EOF'
# meeting03-ci

DevOps course, meeting 3: Build, Test and Continuous Integration.

Local checks:

    python -m compileall src tests
    python -m ruff check .
    python -m pytest -q
EOF

cat > .github/workflows/ci.yml <<'EOF'
name: CI
on:
  pull_request:
    branches: [main]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Build (syntax check)
        run: python -m compileall src tests
      - name: Lint
        run: python -m ruff check .
      - name: Unit tests
        run: python -m pytest -q --junitxml=reports/pytest.xml
      - name: Upload test report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: pytest-report
          path: reports/pytest.xml
EOF

python3 -m venv .venv
. .venv/bin/activate
python -m pip install -q --upgrade pip
python -m pip install -q -r requirements.txt
echo "----- Build -----";  python -m compileall -q src tests && echo "Build OK"
echo "----- Lint -----";   python -m ruff check .
echo "----- Tests -----";  python -m pytest -q
echo
echo "READY: $P"
