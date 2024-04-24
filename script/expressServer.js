const express = require('express');
const redis = require('redis');
const app = express();
const port = 3010;

// Create a Redis client
const client = redis.createClient({
    url: 'redis://localhost:6379' // Default Redis URL
});
client.connect();

// Endpoint to get contract addresses from Redis
app.get('/api/contract-addresses', async (req, res) => {
    try {
        const data = await client.get('couponui');
        if (data) {
            const addresses = JSON.parse(data); // Parse the JSON string from Redis
            res.json(addresses); // Send parsed JSON as response
        } else {
            res.status(404).send('No contract addresses found in Redis');
        }
    } catch (error) {
        console.error('Failed to fetch from Redis', error);
        res.status(500).send('Error fetching from Redis');
    }
});

app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
});
