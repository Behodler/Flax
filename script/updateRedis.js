const fs = require('fs');
const redis = require('redis');

async function updateRedis() {
  const client = redis.createClient();
  await client.connect();

  // Read addresses.json
  const output = JSON.parse(fs.readFileSync('./output/addresses.json', 'utf-8'));

  const addresses = JSON.parse(output.logs[0])
  // Set Redis key "couponui" with the contents of addresses.json
  await client.set('couponui', JSON.stringify(addresses));

  console.log('Updated Redis with contract addresses.');
  const value = await client.get("couponui")
  const parsey = JSON.parse(value)
  if (JSON.stringify(parsey) !== JSON.stringify(addresses)) {
    throw "loss of JSON"
  } else
    console.log("JSON successfully stored to redis.")
  await client.quit();
}

updateRedis().catch(console.error);
