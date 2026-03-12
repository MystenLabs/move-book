// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// Docusaurus plugin that generates AI-friendly documentation:
// - Individual .md files per page (with code includes resolved)
// - llms.txt: structured index with links to individual pages
// - llms-full.txt: single concatenated file for large-context models
//
// Follows the llms.txt specification (https://llmstxt.org/).

import fs from 'fs';
import path from 'path';
import yaml from 'yaml';
import type { Plugin } from '@docusaurus/types';

// Docusaurus runs from the site directory; repo root is one level up.
const ROOT = path.resolve(process.cwd(), '..');

interface SidebarItem {
  id?: string;
  label?: string;
  link?: { id: string; type: string };
  items?: SidebarItem[];
  enumerate?: boolean;
  type?: string;
}

interface Entry {
  id: string;
  label: string;
  depth: number;
  isCategory?: boolean;
}

interface ProcessedDoc {
  entry: Entry;
  description: string;
  resolved: string;
  urlPath: string;
}

function extractEntries(items: SidebarItem[], depth = 0): Entry[] {
  const entries: Entry[] = [];
  for (const item of items) {
    if (typeof item === 'string') {
      entries.push({ id: item, label: item, depth });
      continue;
    }
    const label = item.label || item.id || '';

    if (item.link && item.link.id) {
      entries.push({ id: item.link.id, label, depth, isCategory: true });
    } else if (item.id) {
      entries.push({ id: item.id, label, depth });
    }

    if (item.items) {
      entries.push(...extractEntries(item.items, depth + 1));
    }
  }
  return entries;
}

function parseFrontmatter(raw: string): { description: string; content: string } {
  let description = '';
  let content = raw;
  if (raw.startsWith('---')) {
    const end = raw.indexOf('---', 3);
    if (end !== -1) {
      const fm = raw.slice(3, end).trim();
      const match = fm.match(/description:\s*"([^"]+)"/);
      if (match) description = match[1];
      content = raw.slice(end + 3).trimStart();
    }
  }
  return { description, content };
}

const fileCache = new Map<string, string | null>();

function readCached(filePath: string): string | null {
  if (!fileCache.has(filePath)) {
    fileCache.set(filePath, fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf-8') : null);
  }
  return fileCache.get(filePath)!;
}

function extractAnchor(fileContent: string, anchor: string): string | null {
  const startMarker = `// ANCHOR: ${anchor}`;
  const endMarker = `// ANCHOR_END: ${anchor}`;
  const startIdx = fileContent.indexOf(startMarker);
  if (startIdx === -1) return null;
  const contentStart = fileContent.indexOf('\n', startIdx) + 1;
  const endIdx = fileContent.indexOf(endMarker, contentStart);
  if (endIdx === -1) return null;
  return fileContent.slice(contentStart, endIdx).trimEnd();
}

function resolveCodeIncludes(content: string): string {
  return content.replace(
    /^(```\w*)\s+(?:title="[^"]*"\s+)?file=(\S+?)(?:\s+anchor=(\S+))?\s*\n[\s\S]*?^```/gm,
    (match, fence, filePath, anchor) => {
      const absPath = path.join(ROOT, filePath);
      const fileContent = readCached(absPath);
      if (fileContent === null) {
        console.warn(`[llms-txt] Warning: code include not found: ${filePath}`);
        return match;
      }

      let code: string;
      if (anchor) {
        const extracted = extractAnchor(fileContent, anchor);
        if (extracted === null) {
          console.warn(`[llms-txt] Warning: anchor "${anchor}" not found in ${filePath}`);
          return match;
        }
        code = extracted;
      } else {
        code = fileContent;
      }

      return `${fence}\n${code}\n\`\`\``;
    },
  );
}

function processSidebar(sidebarPath: string, sourceDir: string, urlPrefix: string): ProcessedDoc[] {
  const sidebarContent = fs.readFileSync(sidebarPath, 'utf-8');
  const sidebar = yaml.parse(sidebarContent);
  const sidebarKey = Object.keys(sidebar)[0];
  const entries = extractEntries(sidebar[sidebarKey]);

  const docs: ProcessedDoc[] = [];

  for (const entry of entries) {
    const filePath = path.join(sourceDir, entry.id + '.md');
    if (!fs.existsSync(filePath)) {
      console.warn(`[llms-txt] Warning: ${filePath} not found, skipping`);
      continue;
    }

    const raw = fs.readFileSync(filePath, 'utf-8');
    const { description, content } = parseFrontmatter(raw);
    const resolved = resolveCodeIncludes(content);
    const urlPath = `${urlPrefix}${entry.id}`;

    docs.push({ entry, description, resolved, urlPath });
  }

  return docs;
}

function mkdirp(dir: string) {
  fs.mkdirSync(dir, { recursive: true });
}

function generateFiles(outDir: string) {
  console.log('[llms-txt] Generating AI-friendly documentation...');

  const bookDocs = processSidebar(
    path.join(ROOT, 'book', 'sidebar.yml'),
    path.join(ROOT, 'book'),
    '/',
  );
  const refDocs = processSidebar(
    path.join(ROOT, 'reference', 'sidebar.yml'),
    path.join(ROOT, 'reference'),
    '/reference/',
  );

  const allDocs = [...bookDocs, ...refDocs];

  // Write individual .md files
  for (const doc of allDocs) {
    const mdPath = path.join(outDir, doc.urlPath + '.md');
    mkdirp(path.dirname(mdPath));
    fs.writeFileSync(mdPath, doc.resolved);
  }
  console.log(`[llms-txt] Generated ${allDocs.length} individual .md files`);

  // Build index lines
  const buildIndexLine = (doc: ProcessedDoc) => {
    const indent = '  '.repeat(doc.entry.depth);
    const desc = doc.description ? `: ${doc.description}` : '';
    return `${indent}- [${doc.entry.label}](${doc.urlPath}.md)${desc}`;
  };

  // llms.txt
  const llmsTxt = `# The Move Book

> A comprehensive guide to the Move programming language on Sui.

The Move Book covers the Move language fundamentals, Sui object model, advanced programmability patterns, and testing. The Move Reference provides formal language specification.

## Move Language

- [Move language syntax (EBNF grammar)](/move.ebnf)
- [Move semantics](/move-semantics.md)
- [Best practices](/guides/code-quality-checklist.md)
- [Full book content for large-context models](/llms-full.txt)

## Book

${bookDocs.map(buildIndexLine).join('\n')}

## Reference

${refDocs.map(buildIndexLine).join('\n')}

`;

  fs.writeFileSync(path.join(outDir, 'llms.txt'), llmsTxt);
  console.log('[llms-txt] Built llms.txt');

  // llms-full.txt
  const fullTxt = [
    '# The Move Book\n',
    ...bookDocs.map((d) => d.resolved),
    '\n# The Move Reference\n',
    ...refDocs.map((d) => d.resolved),
  ].join('\n\n---\n\n');

  fs.writeFileSync(path.join(outDir, 'llms-full.txt'), fullTxt);
  console.log('[llms-txt] Built llms-full.txt');
}

export default function pluginLlmsTxt(): Plugin {
  return {
    name: 'docusaurus-plugin-llms-txt',

    // Generate into static/ so files are served in both dev and production.
    // Docusaurus copies static/ to the build output automatically.
    async loadContent() {
      const staticDir = path.join(process.cwd(), 'static');
      generateFiles(staticDir);
    },
  };
}
