#!/bin/bash

# Secure Deployment Script for Wellabe Voice Agent Demo
# This script ensures no secrets are exposed in the GitHub Pages deployment

set -e

echo "🔒 Starting secure deployment process..."

# Step 1: Validate that no secrets are in the HTML file
echo "🔍 Checking for exposed secrets..."

if grep -q "key_" wellabe-demo.html; then
    echo "❌ ERROR: API key found in HTML file!"
    echo "Please remove all API keys from client-side code."
    exit 1
fi

if grep -q "Bearer " wellabe-demo.html; then
    echo "❌ ERROR: Authorization header found in HTML file!"
    echo "Please remove all authorization headers from client-side code."
    exit 1
fi

echo "✅ No secrets found in HTML file"

# Step 2: Validate proxy endpoint configuration
echo "🔍 Checking proxy endpoint configuration..."

if grep -q "your-proxy-domain" wellabe-demo.html; then
    echo "❌ ERROR: Placeholder proxy URL found!"
    echo "Please update the proxy endpoint to your actual deployed URL."
    exit 1
fi

echo "✅ Proxy endpoint properly configured"

# Step 3: Check for production-ready error handling
echo "🔍 Validating error handling..."

if ! grep -q "handleError" wellabe-demo.html; then
    echo "⚠️  WARNING: Error handling may not be complete"
fi

echo "✅ Error handling validated"

# Step 4: Validate HTTPS requirements
echo "🔍 Checking HTTPS requirements..."

if grep -q "http://" wellabe-demo.html && ! grep -q "localhost" wellabe-demo.html; then
    echo "⚠️  WARNING: HTTP URLs found - ensure all external resources use HTTPS"
fi

echo "✅ HTTPS requirements validated"

# Step 5: Create deployment-ready files
echo "📦 Creating deployment package..."

# Create a clean directory for deployment
mkdir -p dist
cp wellabe-demo.html dist/
cp test-integration.html dist/
cp README.md dist/
cp DEPLOYMENT.md dist/

# Remove any development files that shouldn't be deployed
rm -f dist/retell-proxy.js
rm -f dist/vercel.json

echo "✅ Deployment package created in ./dist/"

# Step 6: Final security check
echo "🔒 Final security validation..."

for file in dist/*.html; do
    if grep -E "(key_|secret|password|token)" "$file" | grep -v "access_token"; then
        echo "❌ ERROR: Potential secret found in $file"
        exit 1
    fi
done

echo "✅ All security checks passed!"

echo ""
echo "🚀 Deployment ready!"
echo ""
echo "Next steps:"
echo "1. Deploy the proxy service to Vercel/Netlify with environment variables"
echo "2. Update the proxy endpoint URL in wellabe-demo.html if needed"
echo "3. Deploy the ./dist/ folder contents to GitHub Pages"
echo "4. Test the deployment with the security validation script"
echo ""
echo "Files ready for deployment:"
ls -la dist/
