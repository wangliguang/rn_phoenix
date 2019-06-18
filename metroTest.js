const http = require('http');
const Metro = require('metro');
const co = require('co');

co(function *() {
  const config = yield Metro.loadConfig();

  console.log('config', config);

  yield Metro.runBuild(config, {
    entry: 'index.js',
    out: 'bundle.js',
  });
})