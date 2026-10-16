// Static checks on .claude/settings.json. Claude Code only reports bad rules as startup
// warnings, so catch the common mistakes here.
import { readFileSync, existsSync } from 'node:fs';

const problems = [];
const settings = JSON.parse(readFileSync('.claude/settings.json', 'utf8'));
const { allow = [], ask = [], deny = [] } = settings.permissions ?? {};

for (const rule of [...allow, ...ask, ...deny]) {
  if (!/^(Bash|Read|Edit|WebFetch)\(.+\)$/.test(rule)) problems.push(`unexpected rule shape: ${rule}`);
  // Path rules for these tools are accepted but never consulted.
  if (/^(Write|Glob|NotebookEdit|MultiEdit)\(/.test(rule)) problems.push(`ignored rule: ${rule}`);
}
for (const rule of allow) {
  if (deny.includes(rule) || ask.includes(rule)) problems.push(`rule in allow and ask/deny: ${rule}`);
}

for (const [event, groups] of Object.entries(settings.hooks ?? {})) {
  for (const { hooks = [] } of groups) {
    for (const { command = '' } of hooks) {
      const script = command.match(/\$\{CLAUDE_PROJECT_DIR\}\/([^"\s]+)/)?.[1];
      if (!script) problems.push(`${event} hook doesn't use \${CLAUDE_PROJECT_DIR}: ${command}`);
      else if (!existsSync(script)) problems.push(`${event} hook script missing: ${script}`);
    }
  }
}

if (settings.enabledPlugins?.['superpowers@claude-plugins-official'] !== true) {
  problems.push('superpowers plugin not enabled');
}

if (problems.length) {
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
