// Serverless function for handling RetellAI API calls
// This can be deployed to Vercel, Netlify, or similar platforms to handle CORS

export default async function handler(req, res) {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // Handle preflight requests
    if (req.method === 'OPTIONS') {
        res.status(200).end();
        return;
    }

    // Only allow POST requests for creating web calls
    if (req.method !== 'POST') {
        res.status(405).json({ error: 'Method not allowed' });
        return;
    }

    try {
        const { agent_id, metadata } = req.body;
        
        // Validate required fields
        if (!agent_id) {
            res.status(400).json({ error: 'agent_id is required' });
            return;
        }

        // Make request to RetellAI API
        const response = await fetch('https://api.retellai.com/v2/create-web-call', {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${process.env.RETELL_API_KEY}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                agent_id,
                metadata: {
                    ...metadata,
                    proxy_timestamp: new Date().toISOString()
                }
            })
        });

        if (!response.ok) {
            const errorData = await response.text();
            console.error('RetellAI API error:', response.status, errorData);
            res.status(response.status).json({ 
                error: 'RetellAI API error',
                details: errorData 
            });
            return;
        }

        const data = await response.json();
        res.status(200).json(data);

    } catch (error) {
        console.error('Proxy error:', error);
        res.status(500).json({ 
            error: 'Internal server error',
            message: error.message 
        });
    }
}
