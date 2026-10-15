const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const html = fs.readFileSync(
    path.join(__dirname, '../dashboard/index.html'), 'utf8'
);
const script = html.match(/<script>([\s\S]*?)<\/script>/)[1];

(async () => {
    for (const scenario of ['success', 'http404', 'offline', 'timeout', 'empty']) {
        const status = {textContent: 'Loading system status...'};
        let cleared = false;
        const context = {
            Date,
            AbortController,
            document: {getElementById: () => status},
            setTimeout: callback => {
                if (scenario === 'timeout') callback();
                return 1;
            },
            clearTimeout: () => { cleared = true; },
            fetch: async (url, options) => {
                assert.equal(options.cache, 'no-store');
                if (options.signal.aborted) {
                    const error = new Error('aborted');
                    error.name = 'AbortError';
                    throw error;
                }
                if (scenario === 'offline') throw new Error('Network unavailable');
                return {
                    ok: scenario !== 'http404',
                    status: scenario === 'http404' ? 404 : 200,
                    text: async () => scenario === 'empty' ? '' : 'CPU: 10%'
                };
            }
        };
        await vm.runInNewContext(script, context);
        assert.equal(cleared, true);
        if (scenario === 'success') {
            assert.equal(status.textContent, 'CPU: 10%');
        } else {
            assert.match(status.textContent, /Monitoring data unavailable/);
            assert.doesNotMatch(status.textContent, /Loading system status/);
        }
        if (scenario === 'http404') assert.match(status.textContent, /HTTP 404/);
        if (scenario === 'timeout') assert.match(status.textContent, /Request timed out/);
        console.log(`PASS: dashboard ${scenario}`);
    }
})().catch(error => {
    console.error(error);
    process.exitCode = 1;
});
