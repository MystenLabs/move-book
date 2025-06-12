// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import { themes as prismThemes } from 'prism-react-renderer';
import { Language, PrismThemeEntry } from 'prism-react-renderer';

// Re-export PrismTheme from prism-react-renderer
export type PrismTheme = {
  plain: PrismThemeEntry;
  styles: Array<{
    types: string[];
    style: PrismThemeEntry;
    languages?: Language[];
  }>;
};

const baseTheme = prismThemes.oneDark;

baseTheme.styles.push({
  types: ['entity'],
  style: { color: '#E5C07B' },
});

baseTheme.styles.push({
  types: ['const-name'],
  style: { color: '#D19A66' },
});

baseTheme.styles.push({
  types: ['error-const'],
  style: { color: '#E06C75' },
});

baseTheme.styles.push({
  types: ['support'],
  style: { color: '#56B6C2' },
});

export default baseTheme as PrismTheme;
