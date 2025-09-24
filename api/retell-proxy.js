// Secure serverless function for handling RetellAI API calls
// Deploy to Vercel, Netlify, or similar platforms with environment variables
// SECURITY: Never expose API keys in client-side code

export default async function handler(req, res) {
    // Strict CORS configuration for production
    const allowedOrigins = [
        'https://jrsherlock.github.io',
        'https://wellabe-demo.vercel.app',
        'http://localhost:3000',
        'http://localhost:8000'
    ];

    const origin = req.headers.origin;
    if (allowedOrigins.includes(origin)) {
        res.setHeader('Access-Control-Allow-Origin', origin);
    }

    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Access-Control-Max-Age', '86400'); // 24 hours

    // Handle preflight requests
    if (req.method === 'OPTIONS') {
        res.status(200).end();
        return;
    }

    // Only allow POST requests
    if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method not allowed' });
        return;
    }

    // Validate environment variables
    if (!process.env.RETELL_API_KEY) {
        console.error('RETELL_API_KEY environment variable not set');
        res.status(500).json({ error: 'Server configuration error' });
        return;
    }

    try {
        const { agent_id, metadata, chat_id, message } = req.body;

        // Rate limiting check (basic implementation)
        const clientIP = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

        // Handle chat completion requests
        if (chat_id && message) {
            console.log(`Chat completion request from IP: ${clientIP} for chat: ${chat_id}`);

            const response = await fetch('https://api.retellai.com/create-chat-completion', {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${process.env.RETELL_API_KEY}`,
                    'Content-Type': 'application/json',
                    'User-Agent': 'Wellabe-Demo-Proxy/1.0'
                },
                body: JSON.stringify({
                    chat_id,
                    message
                })
            });

            if (!response.ok) {
                const errorData = await response.text();
                console.error('RetellAI Chat API error:', response.status, errorData);
                res.status(503).json({
                    error: 'Chat service temporarily unavailable',
                    retry_after: 30
                });
                return;
            }

            const data = await response.json();
            console.log(`Successful chat completion for: ${chat_id}`);

            res.status(200).json({
                response: data.response,
                chat_id: data.chat_id
            });
            return;
        }

        // Handle web call or chat creation requests
        if (!agent_id) {
            res.status(400).json({ error: 'agent_id is required' });
            return;
        }

        // Validate agent_id format (basic security check)
        if (!agent_id.startsWith('agent_') || agent_id.length < 20) {
            res.status(400).json({ error: 'Invalid agent_id format' });
            return;
        }

        console.log(`Request from IP: ${clientIP} for agent: ${agent_id}`);

        // Determine if this is a chat agent or voice agent based on metadata
        const isTextChat = metadata?.interaction_type === 'text_chat';

        let apiEndpoint, requestBody;

        if (isTextChat) {
            // Create chat session
            apiEndpoint = 'https://api.retellai.com/create-chat';
            requestBody = {
                agent_id,
                metadata: {
                    ...metadata,
                    proxy_timestamp: new Date().toISOString(),
                    client_ip: clientIP,
                    source: 'wellabe-demo'
                }
            };
        } else {
            // Create web call
            apiEndpoint = 'https://api.retellai.com/v2/create-web-call';
            requestBody = {
                agent_id,
                metadata: {
                    ...metadata,
                    proxy_timestamp: new Date().toISOString(),
                    client_ip: clientIP,
                    source: 'wellabe-demo'
                }
            };
        }

        const response = await fetch(apiEndpoint, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${process.env.RETELL_API_KEY}`,
                'Content-Type': 'application/json',
                'User-Agent': 'Wellabe-Demo-Proxy/1.0'
            },
            body: JSON.stringify(requestBody)
        });

        if (!response.ok) {
            const errorData = await response.text();
            console.error('RetellAI API error:', response.status, errorData);

            // Don't expose internal API errors to client
            res.status(503).json({
                error: isTextChat ? 'Chat service temporarily unavailable' : 'Voice service temporarily unavailable',
                retry_after: 30
            });
            return;
        }

        const data = await response.json();

        // Log successful calls for monitoring
        if (isTextChat) {
            console.log(`Successful chat created: ${data.chat_id}`);
            res.status(200).json({
                chat_id: data.chat_id,
                agent_id: data.agent_id
            });
        } else {
            console.log(`Successful web call created: ${data.call_id}`);
            res.status(200).json({
                call_id: data.call_id,
                access_token: data.access_token,
                agent_id: data.agent_id
            });
        }

    } catch (error) {
        console.error('Proxy error:', error);
        res.status(500).json({
            error: 'Internal server error'
            // Don't expose error details in production
        });
    }
}
