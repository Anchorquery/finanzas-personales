const http = require('http');

const req = http.request({
  hostname: '127.0.0.1',
  port: 8055,
  path: '/graphql',
  method: 'POST',
  headers: {'Content-Type': 'application/json'}
}, res => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => console.log(JSON.stringify(JSON.parse(data), null, 2)));
});

req.write(JSON.stringify({query: 'query { __type(name: "create_organization_members_input") { inputFields { name type { name kind ofType { name kind } } } } }'}));
req.end();
