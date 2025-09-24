# Wellabe Voice Agent Demo

This demo integrates RetellAI Voice Agent into Wellabe's customer support experience, showcasing both text and voice interaction capabilities.

## Features

- **Voice Agent Integration**: Talk directly with Samantha, Wellabe's AI voice agent
- **Fallback Text Chat**: Seamless fallback to text chat when voice is unavailable
- **Real-time Status Indicators**: Visual feedback for connection status
- **Error Handling**: Robust error handling with user-friendly messages
- **CORS Solutions**: Multiple strategies for GitHub Pages deployment

## Quick Start

1. **Direct Usage**: Open `wellabe-demo.html` in a web browser
2. **GitHub Pages**: Deploy to GitHub Pages (see CORS solutions below)
3. **Local Development**: Serve with any local web server

## CORS Solutions for GitHub Pages

Since GitHub Pages serves static files and RetellAI API requires server-side calls, here are three solutions:

### Option 1: Deploy Proxy Function (Recommended)

1. **Deploy to Vercel**:
   ```bash
   # Install Vercel CLI
   npm i -g vercel
   
   # Deploy the proxy
   vercel --prod
   ```

2. **Update HTML**: Replace `your-proxy-domain.vercel.app` in the HTML with your actual Vercel domain

3. **Environment Variables**: Set `RETELL_API_KEY` in Vercel dashboard

### Option 2: Use CORS Proxy Services

The demo includes fallback CORS proxies:
- `api.allorigins.win` (primary fallback)
- `cors-anywhere.herokuapp.com` (secondary fallback)

**Note**: These are public services with rate limits and reliability concerns.

### Option 3: Backend Integration

For production use, integrate with your existing backend:

```javascript
// Example backend endpoint
app.post('/api/retell-call', async (req, res) => {
    const response = await fetch('https://api.retellai.com/v2/create-web-call', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${process.env.RETELL_API_KEY}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(req.body)
    });
    
    const data = await response.json();
    res.json(data);
});
```

## Configuration

### RetellAI Credentials

Current demo uses these credentials (configured in HTML):
- **Agent ID**: `agent_57d5ff27b5134a353952f6da7d`
- **API Key**: `key_f9d04ea5b028416d6f8f258d4f6d`
- **LLM ID**: `llm_19dda6f510cf338f0e4c08329157`

### Agent Configuration

The voice agent (Samantha) is configured with:
- **Voice**: Marissa (11labs)
- **Model**: GPT-5-mini with high priority
- **Language**: English (US)
- **Personality**: Warm, empathetic customer service representative
- **Goal**: Schedule appointments with human specialists

## File Structure

```
├── wellabe-demo.html          # Main demo page with voice integration
├── retell-proxy.js           # Serverless proxy function
├── vercel.json              # Vercel deployment configuration
└── README.md               # This file
```

## Technical Implementation

### Voice Agent Class

The `WellabeVoiceAgent` class handles:
- RetellAI SDK initialization
- Call state management
- Error handling and fallbacks
- UI updates and status indicators

### Key Methods

- `startCall()`: Initiates voice conversation
- `endCall()`: Terminates active conversation
- `createWebCall()`: Handles API calls with fallbacks
- `handleError()`: Manages error states and fallbacks

### Event Handling

- `conversationStarted`: Updates UI to show active call
- `conversationEnded`: Resets UI to ready state
- `error`: Displays error messages and fallbacks

## Deployment Instructions

### GitHub Pages

1. **Upload Files**: Add all files to your GitHub repository
2. **Enable Pages**: Go to Settings > Pages > Deploy from branch
3. **Configure CORS**: Choose one of the CORS solutions above
4. **Test**: Visit your GitHub Pages URL

### Vercel (for proxy)

1. **Install Vercel CLI**: `npm i -g vercel`
2. **Deploy**: Run `vercel` in the project directory
3. **Set Environment**: Add `RETELL_API_KEY` in Vercel dashboard
4. **Update HTML**: Replace proxy URL with your Vercel domain

### Netlify

1. **Drag & Drop**: Upload files to Netlify
2. **Functions**: Deploy `retell-proxy.js` as Netlify function
3. **Environment**: Set `RETELL_API_KEY` in site settings

## Testing

### Voice Features

1. Click "Talk to Samantha" button
2. Allow microphone permissions
3. Speak naturally with the agent
4. Click to end conversation

### Fallback Features

1. If voice fails, text chat option appears
2. Error messages provide clear feedback
3. Status indicators show connection state

## Troubleshooting

### Common Issues

1. **CORS Errors**: Use proxy solution or backend integration
2. **Microphone Permissions**: Ensure HTTPS and user permissions
3. **API Rate Limits**: Implement proper rate limiting in production
4. **Network Issues**: Fallback mechanisms handle connectivity problems

### Debug Mode

Enable console logging to see detailed connection attempts:
```javascript
// Check browser console for detailed logs
console.log('RetellAI integration status');
```

## Production Considerations

1. **Security**: Never expose API keys in client-side code
2. **Rate Limiting**: Implement proper rate limiting
3. **Error Tracking**: Add error monitoring (Sentry, etc.)
4. **Analytics**: Track usage and conversion metrics
5. **Accessibility**: Ensure voice features are accessible

## Support

For technical issues:
- Check browser console for error messages
- Verify microphone permissions
- Test with different browsers
- Review CORS configuration

For RetellAI specific issues:
- Check RetellAI documentation
- Verify agent configuration
- Test API credentials
