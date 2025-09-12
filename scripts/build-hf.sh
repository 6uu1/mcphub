#!/bin/bash

# Build script optimized for Hugging Face Spaces
set -e

echo "🚀 Starting MCPHub build for Hugging Face Spaces..."

# Check if we're in HF Spaces environment
if [ "$HF_SPACE" = "1" ]; then
    echo "📦 Detected Hugging Face Spaces environment"
    export NODE_ENV=production
    export NODE_OPTIONS="--max-old-space-size=1024"
else
    echo "🔧 Local development build"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p /tmp/build-cache
mkdir -p dist

# Install dependencies with cache optimization
echo "📋 Installing dependencies..."
if [ -f "pnpm-lock.yaml" ]; then
    echo "Using pnpm lockfile..."
    pnpm install --frozen-lockfile --prefer-offline || {
        echo "⚠️  Lockfile install failed, trying regular install..."
        pnpm install
    }
else
    echo "No lockfile found, installing dependencies..."
    pnpm install
fi

# Build frontend with memory optimization
echo "🎨 Building frontend..."
cd frontend
export NODE_OPTIONS="--max-old-space-size=512"
pnpm build || {
    echo "❌ Frontend build failed"
    exit 1
}
cd ..

# Build backend
echo "⚙️  Building backend..."
export NODE_OPTIONS="--max-old-space-size=512"
pnpm backend:build || {
    echo "❌ Backend build failed"
    exit 1
}

# Verify build outputs
echo "✅ Verifying build outputs..."
if [ ! -d "frontend/dist" ]; then
    echo "❌ Frontend dist directory not found"
    exit 1
fi

if [ ! -d "dist" ]; then
    echo "❌ Backend dist directory not found"
    exit 1
fi

# Clean up temporary files for HF Spaces
if [ "$HF_SPACE" = "1" ]; then
    echo "🧹 Cleaning up for HF Spaces..."
    rm -rf /tmp/build-cache
    rm -rf node_modules/.cache
    rm -rf frontend/node_modules/.cache
    
    # Keep only essential files
    find . -name "*.map" -type f -delete || true
    find . -name "*.test.js" -type f -delete || true
    find . -name "*.test.ts" -type f -delete || true
fi

echo "✨ Build completed successfully!"
echo "📊 Build summary:"
echo "  - Frontend: $(du -sh frontend/dist | cut -f1)"
echo "  - Backend: $(du -sh dist | cut -f1)"

# Optional: Display version info for debugging
if [ -f "package.json" ]; then
    VERSION=$(node -p "require('./package.json').version")
    echo "  - Version: $VERSION"
fi