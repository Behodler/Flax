const fs = require('fs');
const redis = require('redis');

async function updateRedis() {
  const client = redis.createClient();
  await client.connect();

  // Read addresses.json
  const addresses = fs.readFileSync('addresses.json', 'utf-8');

  // Set Redis key "couponui" with the contents of addresses.json
  await client.set('couponui', addresses);

  console.log('Updated Redis with contract addresses.');
  await client.quit();
}

updateRedis().catch(console.error);
