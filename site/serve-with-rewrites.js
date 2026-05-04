/*
// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0
*/

/**
 * Local server that serves the Docusaurus build with proper headers
 * for markdown files, llms.txt, and content negotiation.
 *
 * Usage: node serve-with-rewrites.js [port]
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = process.argv[2] || 3001;
const BUILD_DIR = path.join(__dirname, 'build');
const BUILD_ROOT = path.resolve(BUILD_DIR);
const BUILD_ROOT_WITH_SEP = BUILD_ROOT.endsWith(path.sep) ? BUILD_ROOT : BUILD_ROOT + path.sep;
const CANONICAL_BUILD_ROOT = fs.realpathSync(BUILD_ROOT);
const CANONICAL_BUILD_ROOT_WITH_SEP = CANONICAL_BUILD_ROOT.endsWith(path.sep)
  ? CANONICAL_BUILD_ROOT
  : CANONICAL_BUILD_ROOT + path.sep;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.md': 'text/markdown; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
  '.ebnf': 'text/plain; charset=utf-8',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.pdf': 'application/pdf',
};

function getContentType(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  return MIME_TYPES[ext] || 'application/octet-stream';
}

function getCacheControl(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  if (ext === '.html' || ext === '.txt' || ext === '.md' || ext === '.ebnf') {
    return 'public, max-age=0, must-revalidate';
  }
  return 'public, max-age=3600';
}

/**
 * Checks whether the request Accept header includes text/markdown.
 */
function acceptsMarkdown(req) {
  const accept = req.headers['accept'] || '';
  return accept.includes('text/markdown');
}

function isCanonicalPathUnderBuildRoot(targetPath) {
  try {
    const realTarget = fs.realpathSync.native ? fs.realpathSync.native(targetPath) : fs.realpathSync(targetPath);
    const realBuildRoot = fs.realpathSync.native ? fs.realpathSync.native(BUILD_ROOT) : fs.realpathSync(BUILD_ROOT);
    const realBuildRootWithSep = realBuildRoot.endsWith(path.sep) ? realBuildRoot : realBuildRoot + path.sep;
    return realTarget === realBuildRoot || realTarget.startsWith(realBuildRootWithSep);
  } catch (e) {
    return false;
  }
}

function isSafeRequestPathname(pathname) {
  if (typeof pathname !== 'string' || pathname.length === 0) return false;
  if (!pathname.startsWith('/')) return false;
  if (pathname.includes('\0') || pathname.includes('\\')) return false;

  const segments = pathname.split('/');
  for (const segment of segments) {
    if (segment === '.' || segment === '..') return false;
  }

  return true;
}

function resolveUnderBuildDir(relativePath) {
  let decodedPath;
  try {
    decodedPath = decodeURIComponent(relativePath || '/');
  } catch (e) {
    return null;
  }

  const normalizedPath = decodedPath.replace(/\\/g, '/');
  const resolved = path.resolve(BUILD_ROOT, '.' + normalizedPath);
  if (resolved !== BUILD_ROOT && !resolved.startsWith(BUILD_ROOT_WITH_SEP)) {
    return null;
  }

  let canonicalResolved;
  try {
    canonicalResolved = fs.realpathSync(resolved);
  } catch (e) {
    return null;
  }

  if (
    canonicalResolved !== CANONICAL_BUILD_ROOT &&
    !canonicalResolved.startsWith(CANONICAL_BUILD_ROOT_WITH_SEP)
  ) {
    return null;
  }

  return canonicalResolved;
}

/**
 * Tries to resolve a markdown file for the given pathname.
 * Maps e.g. "/" -> "index.md", "/foreword" -> "foreword.md",
 * "/move-basics/module" -> "move-basics/module.md".
 */
function resolveMarkdownFile(pathname) {
  const clean = pathname.replace(/\/+$/, '') || '/';

  // Explicit allowlist validation to prevent path traversal and make
  // user-controlled path constraints obvious to static analysis.
  if (
    !clean.startsWith('/') ||
    clean.includes('\0') ||
    /(^|\/)\.\.(\/|$)/.test(clean) ||
    !/^\/[A-Za-z0-9._/-]*$/.test(clean)
  ) {
    return null;
  }

  if (clean === '/') {
    const candidate = resolveUnderBuildDir('/index.md');
    if (candidate && fs.existsSync(candidate)) return candidate;
    return null;
  }

  // Try <path>.md first, then <path>/index.md
  const asMd = resolveUnderBuildDir(clean + '.md');
  if (asMd && fs.existsSync(asMd)) return asMd;

  const asIndex = resolveUnderBuildDir(path.join(clean, 'index.md'));
  if (asIndex && fs.existsSync(asIndex)) return asIndex;

  return null;
}

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url);
  let pathname = parsedUrl.pathname;

  if (!isSafeRequestPathname(pathname)) {
    res.writeHead(400, { 'Content-Type': 'text/plain' });
    res.end('400 Bad Request');
    return;
  }

  // Content negotiation: serve markdown when Accept: text/markdown
  if (acceptsMarkdown(req)) {
    const mdFile = resolveMarkdownFile(pathname);
    if (mdFile) {
      const content = fs.readFileSync(mdFile);
      res.writeHead(200, {
        'Content-Type': 'text/markdown; charset=utf-8',
        'Content-Disposition': 'inline',
        'Cache-Control': 'public, max-age=0, must-revalidate',
      });
      res.end(content);
      return;
    }
  }

  // Resolve file path
  let filePath = resolveUnderBuildDir(pathname);
  if (!filePath) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    res.end('403 Forbidden');
    return;
  }

  if (!fs.existsSync(filePath)) {
    // Try index.html for directory-style routes
    const indexPath = resolveUnderBuildDir(path.join(pathname, 'index.html'));
    if (indexPath && fs.existsSync(indexPath)) {
      filePath = indexPath;
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
      return;
    }
  } else {
    let canonicalFilePath;
    try {
      canonicalFilePath = fs.realpathSync(filePath);
    } catch (e) {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('404 Not Found');
      return;
    }

    if (
      canonicalFilePath !== CANONICAL_BUILD_ROOT &&
      !canonicalFilePath.startsWith(CANONICAL_BUILD_ROOT_WITH_SEP)
    ) {
      res.writeHead(403, { 'Content-Type': 'text/plain' });
      res.end('403 Forbidden');
      return;
    }

    filePath = canonicalFilePath;

    if (fs.statSync(filePath).isDirectory()) {
      const directoryIndexPath = resolveUnderBuildDir(path.join(pathname, 'index.html'));
      if (!directoryIndexPath) {
        res.writeHead(403, { 'Content-Type': 'text/plain' });
        res.end('403 Forbidden');
        return;
      }
      filePath = directoryIndexPath;
    }
  }

  if (!fs.existsSync(filePath)) {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');
    return;
  }

  if (!isCanonicalPathUnderBuildRoot(filePath)) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    res.end('403 Forbidden');
    return;
  }

  const content = fs.readFileSync(filePath);
  res.writeHead(200, {
    'Content-Type': getContentType(filePath),
    'Content-Disposition': 'inline',
    'Cache-Control': getCacheControl(filePath),
  });
  res.end(content);
});

server.listen(PORT, () => {
  console.log(`Serving build at http://localhost:${PORT}/`);
});
