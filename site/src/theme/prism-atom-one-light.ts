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

const baseTheme = prismThemes.oneLight;

baseTheme.styles.push({
  types: ['entity'],
  style: { color: '#C18401' },
});

baseTheme.styles.push({
  types: ['const-name'],
  style: { color: '#383A42' },
});

baseTheme.styles.push({
  types: ['error-const'],
  style: { color: '#E45649' },
});

baseTheme.styles.push({
  types: ['support'],
  style: { color: '#0184BC' },
});

export default baseTheme as PrismTheme;
