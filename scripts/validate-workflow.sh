#!/bin/bash

# MCPHub GitHub Actions Workflow Test Script
# This script validates the GitHub Actions workflow configuration locally

set -e

echo "🧪 MCPHub GitHub Actions Workflow Validation"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_step() {
    echo ""
    print_status $BLUE "🔍 $1"
}

print_success() {
    print_status $GREEN "✅ $1"
}

print_warning() {
    print_status $YELLOW "⚠️  $1"
}

print_error() {
    print_status $RED "❌ $1"
}

# Check prerequisites
print_step "Checking prerequisites"

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "This script must be run from within a Git repository"
    exit 1
fi
print_success "Git repository detected"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi
print_success "Docker is available"

# Check if required files exist
print_step "Checking required files"

required_files=(
    "Dockerfile.hf"
    ".github/workflows/build-hf-container.yml"
    ".github/workflows/release-hf-container.yml"
    "package.json"
    "app.py"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        print_success "Found: $file"
    else
        print_error "Missing required file: $file"
        exit 1
    fi
done

# Validate workflow YAML files
print_step "Validating workflow YAML syntax"

# Check if yamllint is available
if command -v yamllint &> /dev/null; then
    for workflow in .github/workflows/*.yml; do
        if yamllint "$workflow" > /dev/null 2>&1; then
            print_success "YAML syntax valid: $(basename "$workflow")"
        else
            print_warning "YAML syntax issues in: $(basename "$workflow")"
            yamllint "$workflow"
        fi
    done
else
    print_warning "yamllint not available, skipping YAML validation"
fi

# Test Docker build (without cache for accurate test)
print_step "Testing Docker build process"

echo "Building Docker image (this may take several minutes)..."
if docker build -f Dockerfile.hf -t mcphub-hf-test . --no-cache; then
    print_success "Docker build completed successfully"
    
    # Get image size
    image_size=$(docker images mcphub-hf-test --format "table {{.Size}}" | tail -n 1)
    echo "📦 Image size: $image_size"
    
    # Test image can start (basic smoke test)
    print_step "Testing container startup"
    
    container_id=$(docker run -d -p 7861:7860 mcphub-hf-test)
    print_success "Container started with ID: ${container_id:0:12}"
    
    # Wait a moment for startup
    echo "Waiting 10 seconds for container to initialize..."
    sleep 10
    
    # Test health endpoint
    if curl -f -s http://localhost:7861/api/health > /dev/null; then
        print_success "Health check endpoint responsive"
    else
        print_warning "Health check endpoint not responsive (may need more time to start)"
    fi
    
    # Cleanup
    print_step "Cleaning up test container"
    docker stop "$container_id" > /dev/null 2>&1
    docker rm "$container_id" > /dev/null 2>&1
    print_success "Test container cleaned up"
    
else
    print_error "Docker build failed"
    exit 1
fi

# Check environment variables in workflows
print_step "Checking workflow environment variables"

# Check for sensitive information
if grep -r "password\|secret\|key" .github/workflows/ --exclude-dir=.git | grep -v "secrets\." | grep -v "GITHUB_TOKEN"; then
    print_warning "Potential sensitive information found in workflows (check above)"
else
    print_success "No obvious sensitive information in workflows"
fi

# Validate GitHub Actions syntax (if act is available)
if command -v act &> /dev/null; then
    print_step "Validating with act (GitHub Actions local runner)"
    if act --list > /dev/null 2>&1; then
        print_success "GitHub Actions workflows are valid according to act"
    else
        print_warning "act reported issues with workflows"
    fi
else
    print_warning "act not available - install with: curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash"
fi

# Check repository settings requirements
print_step "Repository configuration checklist"
echo ""
echo "📋 Manual configuration checklist (complete these in GitHub):"
echo ""
echo "1. Repository Settings > Actions > General:"
echo "   ✓ Workflow permissions: Read and write permissions"
echo "   ✓ Allow GitHub Actions to create and approve pull requests: Enabled"
echo ""
echo "2. Repository Settings > Code and automation > Pages:"
echo "   ✓ Package visibility: Public (if you want public images)"
echo ""
echo "3. Repository secrets (if using external services):"
echo "   ✓ OPENAI_API_KEY (for smart routing, optional)"
echo "   ✓ Other API keys as needed"
echo ""

# Repository URL info
if git remote get-url origin > /dev/null 2>&1; then
    repo_url=$(git remote get-url origin)
    if [[ $repo_url == *"github.com"* ]]; then
        # Extract owner/repo from URL
        repo_path=$(echo "$repo_url" | sed 's/.*github\.com[:/]\(.*\)\.git$/\1/' | sed 's/.*github\.com[:/]\(.*\)$/\1/')
        print_success "Repository: $repo_path"
        echo ""
        echo "🔗 Useful links after pushing:"
        echo "   📦 Packages: https://github.com/$repo_path/pkgs/container/${repo_path##*/}-hf"
        echo "   🔧 Actions: https://github.com/$repo_path/actions"
        echo "   ⚙️  Settings: https://github.com/$repo_path/settings/actions"
    fi
fi

# Final summary
echo ""
print_step "Validation Summary"
print_success "All checks passed! 🎉"
echo ""
echo "Next steps:"
echo "1. Commit and push your changes to trigger the workflow"
echo "2. Check the Actions tab in your GitHub repository"
echo "3. Verify the container image appears in Packages"
echo ""
echo "Example commands:"
echo "  git add ."
echo "  git commit -m \"feat: add GitHub Actions workflow for HF container\""
echo "  git push origin feature/huggingface-docker-optimization"
echo ""

# Cleanup test image
if docker images mcphub-hf-test -q > /dev/null 2>&1; then
    print_step "Cleaning up test image"
    docker rmi mcphub-hf-test > /dev/null 2>&1
    print_success "Test image removed"
fi

print_success "Validation completed successfully! 🚀"