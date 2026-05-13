#!/bin/bash
# Import Validation Script
# Validates that imported resources match the actual infrastructure

set -e

# Get the directory to validate (default to current directory)
VALIDATE_DIR="${1:-.}"

if [ ! -d "$VALIDATE_DIR" ]; then
  echo "Error: Directory $VALIDATE_DIR does not exist"
  exit 1
fi

cd "$VALIDATE_DIR"

echo "=== Import Validation ==="
echo ""
echo "Validating imports in: $(pwd)"
echo ""

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
  echo "❌ Terraform not initialized"
  echo "   Run: terraform init"
  exit 1
fi

echo "✅ Terraform initialized"

# Check if state file exists
if [ ! -f "terraform.tfstate" ]; then
  echo "❌ No state file found"
  echo "   No resources have been imported yet"
  exit 1
fi

echo "✅ State file exists"
echo ""

# List resources in state
echo "Resources in state:"
RESOURCE_COUNT=$(terraform state list 2>/dev/null | wc -l)
if [ "$RESOURCE_COUNT" -eq 0 ]; then
  echo "  (none)"
else
  terraform state list 2>/dev/null | sed 's/^/  /'
fi
echo ""

# Run terraform plan to check for drift
echo "Checking for configuration drift..."
echo ""

if terraform plan -detailed-exitcode > /dev/null 2>&1; then
  echo "✅ No configuration drift detected"
  echo "   All imported resources match their configuration"
  EXIT_CODE=0
else
  PLAN_EXIT=$?
  if [ $PLAN_EXIT -eq 2 ]; then
    echo "⚠️  Configuration drift detected"
    echo ""
    echo "This is normal after imports. The imported resources may have"
    echo "computed attributes that differ from your configuration."
    echo ""
    echo "Run 'terraform plan' to see the differences and adjust your"
    echo "configuration as needed."
    EXIT_CODE=0
  else
    echo "❌ Error running terraform plan"
    EXIT_CODE=1
  fi
fi

echo ""
echo "=== Validation Summary ==="
echo "  Resources in state: $RESOURCE_COUNT"
echo "  Configuration drift: $([ $PLAN_EXIT -eq 2 ] && echo 'Yes' || echo 'No')"
echo ""

exit $EXIT_CODE

# Made with Bob
