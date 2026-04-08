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
  const llmsTxtDirective = '> For the complete documentation index, see [llms.txt](https://move-book.com/llms.txt)\n\n';
  for (const doc of allDocs) {
    const mdPath = path.join(outDir, doc.urlPath + '.md');
    mkdirp(path.dirname(mdPath));
    fs.writeFileSync(mdPath, llmsTxtDirective + doc.resolved);
  }
  console.log(`[llms-txt] Generated ${allDocs.length} individual .md files`);

  // Build index lines
  const siteUrl = 'https://move-book.com';
  const buildIndexLine = (doc: ProcessedDoc) => {
    const indent = '  '.repeat(doc.entry.depth);
    const desc = doc.description ? `: ${doc.description}` : '';
    return `${indent}- [${doc.entry.label}](${siteUrl}${doc.urlPath}.md)${desc}`;
  };

  // llms.txt
  const llmsTxt = `# The Move Book

> A comprehensive guide to the Move programming language on Sui.

The Move Book covers the Move language fundamentals, Sui object model, advanced programmability patterns, and testing. The Move Reference provides formal language specification.

## Move Language

- [Move language syntax (EBNF grammar)](${siteUrl}/move.ebnf)
- [Move semantics](${siteUrl}/move-semantics.md)
- [Best practices](${siteUrl}/guides/code-quality-checklist.md)
- [Full book content for large-context models](${siteUrl}/llms-full.txt)

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

    injectHtmlTags() {
      return {
        postBodyTags: [
          `<a href="/llms.txt" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap">llms.txt</a>`,
        ],
      };
    },

    configureWebpack() {
      const staticDir = path.join(process.cwd(), 'static');
      const bookDir = path.join(ROOT, 'book');
      const refDir = path.join(ROOT, 'reference');

      return {
        devServer: {
          historyApiFallback: false,
          setupMiddlewares(middlewares: any[]) {
            // Set cache headers and content types for all responses
            middlewares.unshift({
              name: 'agent-friendly-headers',
              middleware: (req: any, res: any, next: any) => {
                const url = req.url?.split('?')[0] || '';

                // Cache headers for all content
                res.setHeader('Cache-Control', 'public, max-age=0, must-revalidate');

                if (url.endsWith('.md')) {
                  res.setHeader('Content-Type', 'text/markdown; charset=utf-8');
                  res.setHeader('Content-Disposition', 'inline');
                } else if (url.endsWith('.txt') || url.endsWith('.ebnf')) {
                  res.setHeader('Content-Type', 'text/plain; charset=utf-8');
                  res.setHeader('Content-Disposition', 'inline');
                }
                next();
              },
            });

            // Return 404 for non-existent pages (prevent SPA fallback)
            middlewares.push({
              name: 'proper-404',
              middleware: (req: any, res: any, next: any) => {
                const url = req.url?.split('?')[0] || '';

                // Skip assets, hot-reload, and known static extensions
                if (
                  url.startsWith('/__') ||
                  url.startsWith('/assets/') ||
                  url.includes('hot-update') ||
                  url.endsWith('.js') ||
                  url.endsWith('.css') ||
                  url.endsWith('.map') ||
                  url.endsWith('.json') ||
                  url.endsWith('.svg') ||
                  url.endsWith('.png') ||
                  url.endsWith('.ico') ||
                  url.endsWith('.woff') ||
                  url.endsWith('.woff2')
                ) {
                  return next();
                }

                // Check if it's a known static file
                if (url.endsWith('.md') || url.endsWith('.txt') || url.endsWith('.ebnf')) {
                  const filePath = path.join(staticDir, url);
                  if (!fs.existsSync(filePath)) {
                    res.statusCode = 404;
                    res.end('Not found');
                    return;
                  }
                  return next();
                }

                // Check if it's a known doc page (has a matching .md or directory)
                const cleanUrl = url.replace(/\/$/, '') || '/index';
                const segments = cleanUrl.replace(/^\//, '');

                // Check book and reference directories
                const bookFile = path.join(bookDir, segments + '.md');
                const refFile = path.join(refDir, segments + '.md');
                const bookIndex = path.join(bookDir, segments, 'index.md');
                const refIndex = path.join(refDir, segments, 'index.md');

                const exists =
                  fs.existsSync(bookFile) ||
                  fs.existsSync(refFile) ||
                  fs.existsSync(bookIndex) ||
                  fs.existsSync(refIndex) ||
                  url === '/' ||
                  url === '';

                if (!exists) {
                  res.statusCode = 404;
                  res.setHeader('Content-Type', 'text/html; charset=utf-8');
                  res.end('<html><body><h1>404 - Page Not Found</h1></body></html>');
                  return;
                }

                // Known page — rewrite to index.html for SPA routing
                req.url = '/index.html';
                next();
              },
            });

            return middlewares;
          },
        },
      };
    },
  };
}
