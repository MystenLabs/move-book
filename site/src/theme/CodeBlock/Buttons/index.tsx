import React, { type ReactNode } from 'react';
import clsx from 'clsx';

import CopyButton from './CopyButton';
import WordWrapButton from './WordWrapButton';
import RenderButton from './RenderButton';
import PlayButton from './BuildButton';
import type { Props } from '@theme/CodeBlock/Buttons';

import styles from './styles.module.css';
import { useCodeBlockContext } from '@docusaurus/theme-common/internal';

// Code block buttons are not server-rendered on purpose
// Adding them to the initial HTML is useless and expensive (due to JSX SVG)
// They are hidden by default and require React  to become interactive
export default function CodeBlockButtons({ className }: Props): ReactNode {
  const ctx = useCodeBlockContext();

  console.log(metadata);

  return (
    <div className={clsx(className, styles.buttonGroup)}>
      <PlayButton />
      <RenderButton />
      <WordWrapButton />
      <CopyButton />
    </div>
  );
}
