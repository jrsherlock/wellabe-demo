#!/bin/bash

# Production Setup Script for Wellabe Voice Agent Demo
# This script sets up a secure production deployment

set -e

echo "🚀 Setting up production deployment for Wellabe Voice Agent Demo"
echo "================================================================"

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed."
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is required but not installed."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Step 1: Install Vercel CLI
echo "📦 Installing Vercel CLI..."
npm install -g vercel

# Step 2: Validate security
echo "🔒 Running security validation..."
chmod +x deploy-secure.sh
./deploy-secure.sh

# Step 3: Deploy proxy to Vercel
echo "🌐 Deploying secure proxy to Vercel..."
echo ""
echo "IMPORTANT: When prompted by Vercel:"
echo "1. Link to existing project or create new one"
echo "2. Choose 'wellabe-demo' as project name"
echo "3. Confirm deployment settings"
echo ""
read -p "Press Enter to continue with Vercel deployment..."

vercel --prod

# Get the deployment URL
echo ""
echo "📝 Please copy your Vercel deployment URL from above"
echo "It should look like: https://wellabe-demo-abc123.vercel.app"
echo ""
read -p "Enter your Vercel deployment URL: " VERCEL_URL

# Validate URL format
if [[ ! $VERCEL_URL =~ ^https://.*\.vercel\.app$ ]]; then
    echo "❌ Invalid Vercel URL format. Please ensure it starts with https:// and ends with .vercel.app"
    exit 1
fi

# Step 4: Set environment variable
echo "🔑 Setting up environment variables..."
echo ""
echo "Setting RETELL_API_KEY environment variable..."
vercel env add RETELL_API_KEY production

# Step 5: Update HTML with correct proxy URL
echo "🔧 Updating HTML with your proxy URL..."
PROXY_ENDPOINT="${VERCEL_URL}/api/retell-proxy"

# Update the proxy endpoint in the HTML file
sed -i.bak "s|https://wellabe-demo-proxy.vercel.app/api/retell-proxy|${PROXY_ENDPOINT}|g" wellabe-demo.html

echo "✅ Updated proxy endpoint to: ${PROXY_ENDPOINT}"

# Step 6: Redeploy with environment variables
echo "🔄 Redeploying with environment variables..."
vercel --prod

# Step 7: Test the proxy endpoint
echo "🧪 Testing proxy endpoint..."
node validate-security.js

# Step 8: Prepare for GitHub Pages
echo "📦 Preparing files for GitHub Pages deployment..."

# Create deployment directory
mkdir -p github-pages-deploy
cp wellabe-demo.html github-pages-deploy/index.html
cp test-integration.html github-pages-deploy/
cp README.md github-pages-deploy/
cp SECURITY.md github-pages-deploy/
cp DEPLOYMENT.md github-pages-deploy/

# Create a simple index redirect if needed
cat > github-pages-deploy/wellabe-demo.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0; url=./index.html">
    <title>Redirecting...</title>
</head>
<body>
    <p>Redirecting to <a href="./index.html">Wellabe Voice Agent Demo</a>...</p>
</body>
</html>
EOF

echo "✅ GitHub Pages files prepared in ./github-pages-deploy/"

# Step 9: Git setup and push
echo "📤 Setting up Git repository..."

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    git branch -M main
fi

# Add files
git add .
git commit -m "Production deployment: Secure proxy configuration"

# Check if remote exists
if ! git remote get-url origin &> /dev/null; then
    echo ""
    echo "🔗 Git remote not configured."
    echo "Please add your GitHub repository as origin:"
    echo "git remote add origin https://github.com/jrsherlock/wellabe-demo.git"
    echo ""
    read -p "Press Enter after adding the remote..."
fi

# Push to GitHub
echo "📤 Pushing to GitHub..."
git push origin main

# Step 10: GitHub Pages setup instructions
echo ""
echo "🎉 Production setup complete!"
echo "=============================="
echo ""
echo "Next steps to enable GitHub Pages:"
echo "1. Go to https://github.com/jrsherlock/wellabe-demo"
echo "2. Click Settings → Pages"
echo "3. Select 'Deploy from a branch'"
echo "4. Choose 'main' branch"
echo "5. Click 'Save'"
echo ""
echo "Your demo will be available at:"
echo "https://jrsherlock.github.io/wellabe-demo/"
echo ""
echo "🔒 Security Summary:"
echo "✅ API key secured in Vercel environment variables"
echo "✅ Proxy endpoint configured: ${PROXY_ENDPOINT}"
echo "✅ No secrets in GitHub Pages deployment"
echo "✅ HTTPS enforced for all communications"
echo "✅ Error handling sanitized"
echo ""
echo "🧪 To validate your deployment:"
echo "node validate-security.js https://jrsherlock.github.io/wellabe-demo/"
echo ""
echo "📚 Documentation:"
echo "- Security guide: ./SECURITY.md"
echo "- Deployment guide: ./DEPLOYMENT.md"
echo "- Project README: ./README.md"
