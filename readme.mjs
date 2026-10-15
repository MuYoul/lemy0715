// Regenerates README.md (GitHub profile-style intro) from projects.json: node readme.mjs
import { readFileSync, writeFileSync } from 'node:fs';
const d = JSON.parse(readFileSync(new URL('projects.json', import.meta.url)));
const site = 'https://lemy0715.mycsbot.com';
const rows = d.projects.map(p => `| ${p.url ? `[${p.title}](${p.url})` : p.title} | ${p.kind} | ${p.stack.join(', ')} | ${p.commits.toLocaleString()} |`);
const years = Object.entries(d.contributions).map(([y, n]) => `${y}: ${n.toLocaleString()}`).join(' · ');
writeFileSync(new URL('README.md', import.meta.url), `# ${d.name}

${d.pitch}

${d.summary}

- 포트폴리오: ${site}
- 크몽: ${d.kmong}
- 연락: ${d.email}

| 작업물 | 분야 | 기술 | 커밋 |
|---|---|---|---|
${rows.join('\n')}

GitHub 기여: ${years} (${d.contributionsNote})

<!-- README.md는 projects.json에서 만들어요. 고칠 때는 projects.json을 바꾸고 \`node readme.mjs\`를 실행해요. -->
`);
