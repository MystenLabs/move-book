/*
// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0
*/

/**
 * Deterministic docs audit pipeline.
 *
 * Usage:
 *   node scripts/audit-docs.mjs                  # JSON to stdout
 *   node scripts/audit-docs.mjs --summary        # compact table to stderr
 *   node scripts/audit-docs.mjs --only-failures  # only pages with issues
 */

import fs from 'fs';
import path from 'path';
import { execFileSync } from 'child_process';
import { fileURLToPath } from 'url';
import matter from 'gray-matter';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SITE_ROOT = path.resolve(__dirname, '..');
const CONTENT_ROOTS = [
  path.resolve(SITE_ROOT, '..', 'book'),
  path.resolve(SITE_ROOT, '..', 'reference'),
];
const REPO_ROOT = path.resolve(SITE_ROOT, '..');

function globMd(dir) {
  const results = [];
  function walk(d) {
    for (const entry of fs.readdirSync(d, { withFileTypes: true })) {
      const full = path.join(d, entry.name);
      if (entry.isDirectory()) {
        if (['node_modules', '.docusaurus', 'build', 'dist'].includes(entry.name)) continue;
        walk(full);
      } else if (entry.name.endsWith('.md') && entry.name !== 'README.md') {
        results.push(full);
      }
    }
  }
  walk(dir);
  return results;
}

function stripCodeBlocks(text) {
  return text.replace(/```[\s\S]*?```/g, '').replace(/`[^`\n]+`/g, '');
}

function stripFrontmatter(raw) {
  return raw.replace(/^---[\s\S]*?---\n?/, '');
}

function countWords(text) {
  const cleaned = stripCodeBlocks(stripFrontmatter(text));
  const words = cleaned.match(/[a-zA-Z0-9]+/g);
  return words ? words.length : 0;
}

function getHeadings(body) {
  const headings = [];
  for (const line of body.split('\n')) {
    const m = line.match(/^(#{1,6})\s+(.*)$/);
    if (m) headings.push({ level: m[1].length, text: m[2].trim() });
  }
  return headings;
}

function getGitLastModified(filePath) {
  try {
    const ts = execFileSync('git', ['log', '-1', '--format=%at', '--', filePath], {
      cwd: REPO_ROOT, encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'],
    }).trim();
    if (!ts) return null;
    return new Date(parseInt(ts, 10) * 1000);
  } catch { return null; }
}

function daysSince(date) {
  if (!date) return null;
  return Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24));
}

function runBaseChecks(filePath, raw, data, body) {
  const lastModified = getGitLastModified(filePath);
  const staleDays = daysSince(lastModified);
  const wordCount = countWords(raw);
  const required = ['title', 'description', 'keywords'];
  const missing = required.filter(f => !data[f]);
  const frontmatter = { pass: missing.length === 0, missing };
  const fences = body.match(/^```/gm) || [];
  const codeFences = { pass: fences.length % 2 === 0, count: fences.length };
  const todos = [];
  const lines = body.split('\n');
  for (let i = 0; i < lines.length; i++) {
    if (/\b(TODO|FIXME|HACK|PLACEHOLDER|XXX)\b/i.test(lines[i])) {
      todos.push({ line: i + 1, text: lines[i].trim() });
    }
  }
  const issues = [];
  if (!frontmatter.pass) issues.push(`Missing frontmatter: ${frontmatter.missing.join(', ')}`);
  if (!codeFences.pass) issues.push(`Unclosed code fence (${codeFences.count} backtick lines)`);
  if (todos.length > 0) issues.push(`${todos.length} TODO/FIXME marker(s)`);
  if (wordCount < 50) issues.push(`Very short page (${wordCount} words)`);

  const hasQuestions = Array.isArray(data.questions) && data.questions.length > 0;
  const hasAnswer = typeof data.answer === 'string' && data.answer.trim().length > 0;

  return { frontmatter, lastModified: lastModified ? lastModified.toISOString().slice(0, 10) : null,
    staleDays, wordCount, codeFences, todos, issues,
    geo: { hasQuestions, questionCount: hasQuestions ? data.questions.length : 0, hasAnswer },
  };
}

function evaluateGoalRequires(goal, body, data, headings) {
  if (!goal || !goal.requires) return null;
  const results = [];
  for (const req of goal.requires) {
    const result = { label: req.label || '(unlabeled)', pass: false };
    if (req.has_frontmatter) {
      const missing = req.has_frontmatter.filter(f => !data[f]);
      result.pass = missing.length === 0;
      result.detail = missing.length > 0 ? `missing: ${missing.join(', ')}` : 'all present';
    } else if (req.min_words !== undefined) {
      const wc = countWords(body);
      result.pass = wc >= req.min_words;
      result.detail = `${wc} words, need >= ${req.min_words}`;
    } else if (req.has_questions !== undefined) {
      const has = Array.isArray(data.questions) && data.questions.length > 0;
      result.pass = req.has_questions ? has : !has;
      result.detail = !has ? 'no questions field' : `${data.questions.length} question(s)`;
    } else if (req.has_answer !== undefined) {
      const has = typeof data.answer === 'string' && data.answer.trim().length > 0;
      result.pass = req.has_answer ? has : !has;
      result.detail = has ? `${data.answer.trim().length} chars` : 'no answer field';
    } else if (req.code_explanation_ratio !== undefined) {
      const totalWords = (body.match(/[a-zA-Z0-9]+/g) || []).length;
      const explanationWords = countWords(body);
      const ratio = totalWords > 0 ? explanationWords / totalWords : 1;
      result.pass = ratio >= req.code_explanation_ratio;
      result.detail = `ratio ${ratio.toFixed(2)}, need >= ${req.code_explanation_ratio}`;
    } else if (req.headings) {
      const missing = [];
      for (const h of req.headings) {
        const hPattern = h.pattern || h;
        const re = new RegExp(hPattern, 'i');
        if (!headings.some(hd => re.test(hd.text))) missing.push(hPattern);
      }
      result.pass = missing.length === 0;
      result.detail = missing.length > 0 ? `missing: ${missing.join(', ')}` : 'all present';
    } else if (req.pattern !== undefined && req.min !== undefined) {
      const re = new RegExp(req.pattern, 'gi');
      const matches = body.match(re) || [];
      result.pass = matches.length >= req.min;
      result.detail = `found ${matches.length}, need >= ${req.min}`;
    } else if (req.steps_present !== undefined) {
      const steps = (body.match(/^\d+\.\s/gm) || []).length;
      result.pass = steps >= req.steps_present;
      result.detail = `${steps} steps, need >= ${req.steps_present}`;
    }
    results.push(result);
  }
  return { description: goal.description || null, allPass: results.every(r => r.pass), checks: results };
}

function main() {
  const args = process.argv.slice(2);
  const showSummary = args.includes('--summary');
  const onlyFailures = args.includes('--only-failures');

  const files = CONTENT_ROOTS.flatMap(globMd);
  const allPages = files.map(filePath => {
    const raw = fs.readFileSync(filePath, 'utf8');
    const { data, content: body } = matter(raw);
    const relPath = path.relative(REPO_ROOT, filePath);
    return { filePath, relativePath: relPath, raw, data, body };
  });

  const pageResults = allPages.map(page => {
    const headings = getHeadings(page.body);
    const base = runBaseChecks(page.filePath, page.raw, page.data, page.body);
    const goal = evaluateGoalRequires(page.data.goal, page.body, page.data, headings);
    return { path: page.relativePath, title: page.data.title || null, base, goal };
  });

  const output = {
    summary: {
      totalPages: pageResults.length,
      pagesWithIssues: pageResults.filter(p => p.base.issues.length > 0).length,
      pagesWithGoal: pageResults.filter(p => p.goal !== null).length,
      pagesPassingGoal: pageResults.filter(p => p.goal?.allPass).length,
      pagesFailingGoal: pageResults.filter(p => p.goal && !p.goal.allPass).length,
      geo: {
        pagesWithQuestions: pageResults.filter(p => p.base.geo?.hasQuestions).length,
        pagesWithAnswer: pageResults.filter(p => p.base.geo?.hasAnswer).length,
        pagesWithBoth: pageResults.filter(p => p.base.geo?.hasQuestions && p.base.geo?.hasAnswer).length,
        pagesWithNeither: pageResults.filter(p => !p.base.geo?.hasQuestions && !p.base.geo?.hasAnswer).length,
      },
    },
    pages: onlyFailures
      ? pageResults.filter(p => p.base.issues.length > 0 || (p.goal && !p.goal.allPass))
      : pageResults,
  };

  console.log(JSON.stringify(output, null, 2));

  if (showSummary) {
    console.error('\n── Audit Summary ──────────────────────────────────────');
    console.error(`Total pages:       ${output.summary.totalPages}`);
    console.error(`Pages with issues: ${output.summary.pagesWithIssues}`);
    console.error(`Pages with goal:   ${output.summary.pagesWithGoal}`);
    console.error(`  Passing:         ${output.summary.pagesPassingGoal}`);
    console.error(`  Failing:         ${output.summary.pagesFailingGoal}`);
    const geo = output.summary.geo;
    console.error(`GEO/AEO readiness:`);
    console.error(`  With questions:  ${geo.pagesWithQuestions}`);
    console.error(`  With answer:     ${geo.pagesWithAnswer}`);
    console.error(`  With both:       ${geo.pagesWithBoth}`);
    console.error(`  With neither:    ${geo.pagesWithNeither}`);

    const goalFailures = pageResults.filter(p => p.goal && !p.goal.allPass);
    if (goalFailures.length > 0) {
      console.error('\nGoal checklist failures:');
      for (const p of goalFailures) {
        console.error(`  ${p.path}`);
        for (const check of p.goal.checks.filter(c => !c.pass)) {
          console.error(`    ✗ ${check.label}: ${check.detail}`);
        }
      }
    }
    console.error('──────────────────────────────────────────────────────\n');
  }

  process.exit((output.summary.pagesWithIssues > 0 || output.summary.pagesFailingGoal > 0) ? 1 : 0);
}

main();
