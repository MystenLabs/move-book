// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import fs from 'fs';
import path from 'path';
import { visit } from 'unist-util-visit';
import type { Plugin } from 'unified';
import type { Root } from 'mdast';

interface Options {
  rootDir?: string;
}

const plugin: Plugin<[Options?], Root> = ({ rootDir = process.cwd() } = {}) => {
  return (tree, file) => {
    visit(tree, 'code', (node) => {
      if (!node.meta) return;

      const match = node.meta.match(/file=(\S+)/);
      if (!match) return;

      const anchorMatch = node.meta.match(/anchor=(\S+)/);
      if (!anchorMatch) return;

      let [filePathWithAnchor] = match.slice(1);
      let [anchor] = anchorMatch.slice(1);

      const absPath = path.resolve(rootDir, filePathWithAnchor);
      if (!fs.existsSync(absPath)) {
        throw new Error(`File not found: ${absPath}`);
      }

      let content = fs.readFileSync(absPath, 'utf-8');

      if (anchor) {
        const startMarker = new RegExp(`//\\s*ANCHOR:\\s*${anchor}`);
        const endMarker = new RegExp(`//\\s*ANCHOR_END:\\s*${anchor}`);

        const lines = content.split('\n');
        const start = lines.findIndex((line) => startMarker.test(line));
        if (start === -1) {
          throw new Error(`Anchor "${anchor}" not found in ${absPath}`);
        }

        const end = lines.findIndex((line, i) => i > start && endMarker.test(line));
        if (end === -1) {
          throw new Error(`No end anchor for "${anchor}" in ${absPath}`);
        }

        const snippet = lines
          .slice(start + 1, end)
          .filter((e) => !e.includes('// ANCHOR_END') && !e.includes('// ANCHOR'));

        // Strip the common leading indentation, so a snippet anchored inside a
        // function body renders flush-left instead of jumping to the right.
        // Relative (nested) indentation is preserved; blank lines are ignored
        // when measuring and left empty in the output.
        const indent = Math.min(
          ...snippet
            .filter((line) => line.trim().length > 0)
            .map((line) => line.match(/^[ \t]*/)![0].length),
        );
        content = snippet
          .map((line) => (line.trim().length > 0 ? line.slice(indent) : ''))
          .join('\n');
      }

      node.value = node.value + content;
    });
  };
};

export default plugin;
