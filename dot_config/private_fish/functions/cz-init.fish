function cz-init --description "Setup cz-git commitizen in a Node.js project"
    if not test -f package.json
        echo "No package.json found. Not a Node.js project."
        return 1
    end

    # Detect package manager from lock file
    set pm ""
    set install_cmd ""
    set run_cmd ""

    if test -f bun.lockb; or test -f bun.lock
        set pm bun
        set install_cmd "bun add -d cz-git"
        set run_cmd "bun run commit"
    else if test -f pnpm-lock.yaml
        set pm pnpm
        set install_cmd "pnpm install -D cz-git"
        set run_cmd "pnpm commit"
    else if test -f yarn.lock
        set pm yarn
        set install_cmd "yarn add -D cz-git"
        set run_cmd "yarn commit"
    else if test -f package-lock.json
        set pm npm
        set install_cmd "npm install -D cz-git"
        set run_cmd "npm run commit"
    else
        echo "No lock file found. Defaulting to pnpm."
        set pm pnpm
        set install_cmd "pnpm install -D cz-git"
        set run_cmd "pnpm commit"
    end

    echo "Detected package manager: $pm"
    echo "Installing cz-git..."
    eval $install_cmd

    echo "Updating package.json..."
    node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));

pkg.scripts = pkg.scripts || {};
pkg.scripts.commit = 'git-cz';

pkg.config = pkg.config || {};
pkg.config.commitizen = {
  path: 'node_modules/cz-git',
  useEmoji: true
};

fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
console.log('package.json updated.');
"

    if not test -f .commitlintrc.js
        echo "Creating .commitlintrc.js..."
        echo '/** @type {import("cz-git").UserConfig} */
module.exports = {
  rules: {},
  prompt: {
    useEmoji: true,
  },
};' > .commitlintrc.js
    else
        echo ".commitlintrc.js already exists, skipping."
    end

    echo "Done. Use 'gz', 'git cz', or '$run_cmd' to commit."
end
