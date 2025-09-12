#!/bin/bash

# MCPHub Hugging Face Spaces Deployment Script
# This script prepares the repository for HF Spaces deployment

set -e

echo "🤗 Preparing MCPHub for Hugging Face Spaces deployment..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the project root."
    exit 1
fi

# Create HF Spaces specific files if they don't exist
echo "📋 Setting up Hugging Face Spaces configuration..."

# Copy the HF Spaces README if it doesn't exist
if [ ! -f "README.md" ] || [ "$1" == "--force-readme" ]; then
    if [ -f "README.hf.spaces.md" ]; then
        cp "README.hf.spaces.md" "README.md"
        echo "✅ Copied HF Spaces README.md"
    else
        echo "⚠️  HF Spaces README template not found"
    fi
fi

# Ensure app.py exists and is executable
if [ -f "app.py" ]; then
    chmod +x app.py
    echo "✅ app.py is ready"
else
    echo "❌ app.py not found"
    exit 1
fi

# Copy HF environment config if it exists
if [ -f ".env.hf" ] && [ ! -f ".env" ]; then
    cp ".env.hf" ".env"
    echo "✅ Copied HF Spaces environment configuration"
fi

# Validate Dockerfile.hf
if [ -f "Dockerfile.hf" ]; then
    echo "✅ Dockerfile.hf found"
    
    # Check if it has the required HF Spaces configurations
    if grep -q "USER user" "Dockerfile.hf" && grep -q "EXPOSE 7860" "Dockerfile.hf"; then
        echo "✅ Dockerfile.hf has required HF Spaces configurations"
    else
        echo "⚠️  Dockerfile.hf might be missing some HF Spaces requirements"
    fi
else
    echo "❌ Dockerfile.hf not found"
    exit 1
fi

# Create a .gitignore for HF Spaces if needed
if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
*.tsbuildinfo

# Environment files
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Cache directories
.cache/
.parcel-cache/

# Temporary files
*.tmp
*.temp
EOF
    echo "✅ Created .gitignore for HF Spaces"
fi

echo ""
echo "🎉 HF Spaces deployment preparation completed!"
echo ""
echo "📋 Next steps:"
echo "1. Copy this repository to your HF Spaces repository"
echo "2. Set environment variables in HF Spaces settings:"
echo "   - ADMIN_USERNAME (optional)"
echo "   - ADMIN_PASSWORD (optional)"
echo "   - AMAP_MAPS_API_KEY (if using Amap)"
echo "   - SLACK_BOT_TOKEN (if using Slack)"
echo "   - OPENAI_API_KEY (if using smart routing)"
echo "3. Your Space will be available at: https://your-username-your-space-name.hf.space"
echo ""
echo "🔗 Useful links:"
echo "   - HF Spaces Docs: https://huggingface.co/docs/hub/spaces"
echo "   - MCPHub GitHub: https://github.com/samanhappy/mcphub"
echo ""