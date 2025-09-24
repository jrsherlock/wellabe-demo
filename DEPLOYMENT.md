# Deployment Guide: Wellabe Voice Agent Demo

## GitHub Pages Deployment

### Step 1: Repository Setup

1. **Create Repository**:
   ```bash
   git init wellabe-voice-demo
   cd wellabe-voice-demo
   git add .
   git commit -m "Initial commit: Wellabe voice agent demo"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/wellabe-voice-demo.git
   git push -u origin main
   ```

2. **Enable GitHub Pages**:
   - Go to repository Settings
   - Scroll to "Pages" section
   - Select "Deploy from a branch"
   - Choose "main" branch
   - Click "Save"

### Step 2: CORS Solution Setup

#### Option A: Vercel Proxy (Recommended)

1. **Install Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

2. **Deploy Proxy**:
   ```bash
   vercel --prod
   ```

3. **Configure Environment**:
   - Go to Vercel dashboard
   - Select your project
   - Go to Settings > Environment Variables
   - Add: `RETELL_API_KEY` = `key_f9d04ea5b028416d6f8f258d4f6d`

4. **Update Demo**:
   - Edit `wellabe-demo.html`
   - Replace `your-proxy-domain.vercel.app` with your actual Vercel URL
   - Line ~294: Update the first endpoint in the `endpoints` array

#### Option B: Netlify Functions

1. **Create Netlify Account**: Sign up at netlify.com

2. **Deploy via Git**:
   - Connect your GitHub repository
   - Deploy automatically

3. **Add Function**:
   - Create `netlify/functions/retell-proxy.js`:
   ```javascript
   exports.handler = async (event, context) => {
     // Same logic as retell-proxy.js but adapted for Netlify
   };
   ```

4. **Environment Variables**:
   - Go to Site Settings > Environment Variables
   - Add: `RETELL_API_KEY` = `key_f9d04ea5b028416d6f8f258d4f6d`

#### Option C: Use Public CORS Proxies (Fallback)

The demo already includes fallback CORS proxies:
- `api.allorigins.win`
- `cors-anywhere.herokuapp.com`

**Note**: These have rate limits and may be unreliable for production use.

### Step 3: Testing Deployment

1. **Open Test Page**: Visit `https://YOUR_USERNAME.github.io/wellabe-voice-demo/test-integration.html`

2. **Run Tests**:
   - Click "Test SDK Loading"
   - Click "Test Web Call Creation"
   - Click "Test Voice Call" (requires microphone)

3. **Check Main Demo**: Visit `https://YOUR_USERNAME.github.io/wellabe-voice-demo/wellabe-demo.html`

### Step 4: Custom Domain (Optional)

1. **Add CNAME**:
   - Create `CNAME` file in repository root
   - Add your domain: `demo.wellabe.com`

2. **DNS Configuration**:
   - Add CNAME record pointing to `YOUR_USERNAME.github.io`

3. **HTTPS Certificate**:
   - GitHub Pages automatically provides SSL
   - Required for microphone access

## Production Deployment

### Backend Integration

For production use, integrate with your existing backend:

```javascript
// Express.js example
app.post('/api/retell-call', async (req, res) => {
  try {
    const response = await fetch('https://api.retellai.com/v2/create-web-call', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.RETELL_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        agent_id: req.body.agent_id,
        metadata: {
          ...req.body.metadata,
          user_id: req.user?.id, // Add user context
          session_id: req.sessionID
        }
      })
    });
    
    const data = await response.json();
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### Security Considerations

1. **API Key Protection**:
   - Never expose API keys in client-side code
   - Use environment variables
   - Implement rate limiting

2. **User Authentication**:
   - Add user authentication if needed
   - Track usage per user
   - Implement session management

3. **HTTPS Requirement**:
   - Voice features require HTTPS
   - Use valid SSL certificates
   - Test microphone permissions

### Monitoring & Analytics

1. **Error Tracking**:
   ```javascript
   // Add to your voice agent class
   window.addEventListener('error', (event) => {
     // Send to your error tracking service
     console.error('Global error:', event.error);
   });
   ```

2. **Usage Analytics**:
   ```javascript
   // Track voice agent usage
   analytics.track('voice_agent_started', {
     agent_id: this.agentId,
     timestamp: new Date().toISOString()
   });
   ```

3. **Performance Monitoring**:
   ```javascript
   // Monitor call quality
   this.retellClient.on('update', (update) => {
     if (update.latency) {
       // Track latency metrics
       analytics.track('voice_latency', {
         latency: update.latency,
         call_id: this.currentCallId
       });
     }
   });
   ```

## Troubleshooting

### Common Issues

1. **CORS Errors**:
   - Verify proxy deployment
   - Check environment variables
   - Test with browser dev tools

2. **Microphone Access**:
   - Ensure HTTPS deployment
   - Check browser permissions
   - Test on different devices

3. **API Rate Limits**:
   - Monitor usage in RetellAI dashboard
   - Implement client-side rate limiting
   - Add retry logic with backoff

### Debug Steps

1. **Check Console Logs**:
   ```javascript
   // Enable verbose logging
   localStorage.setItem('retell_debug', 'true');
   ```

2. **Test API Endpoints**:
   ```bash
   # Test your proxy
   curl -X POST https://your-proxy.vercel.app/api/retell-proxy \
     -H "Content-Type: application/json" \
     -d '{"agent_id":"agent_57d5ff27b5134a353952f6da7d"}'
   ```

3. **Verify Agent Configuration**:
   - Check RetellAI dashboard
   - Verify agent is active
   - Test with different browsers

### Performance Optimization

1. **Preload SDK**:
   ```html
   <link rel="preload" href="https://web.retellai.com/retell-web-client-js/retell-web-client.js" as="script">
   ```

2. **Optimize Loading**:
   ```javascript
   // Lazy load voice features
   const loadVoiceAgent = async () => {
     if (!window.RetellWebClient) {
       await import('https://web.retellai.com/retell-web-client-js/retell-web-client.js');
     }
     return new WellabeVoiceAgent();
   };
   ```

3. **Cache Management**:
   ```javascript
   // Cache web call tokens temporarily
   const cacheKey = `retell_token_${Date.now()}`;
   sessionStorage.setItem(cacheKey, accessToken);
   ```

## Support

For deployment issues:
- Check GitHub Pages status
- Verify DNS configuration
- Test with different browsers
- Review browser console errors

For RetellAI issues:
- Check API key validity
- Verify agent configuration
- Review RetellAI documentation
- Contact RetellAI support if needed
