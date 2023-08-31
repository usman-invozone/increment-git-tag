const core = require('@actions/core')
const exec = require('@actions/exec')

async function run() {
    try {
        const versionType = core.getInput('version-type');
        const src = __dirname;

        core.setOutput('new-version', 'this is testing')
        // await exec.exec(`${src}/git_update.sh -v ${versionType}`)
    } catch(err) {
        core.setFailed(err.message);
    }
}

run();
