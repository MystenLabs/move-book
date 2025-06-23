import React, { useCallback, useState, useRef, useEffect, type ReactNode } from 'react';
import clsx from 'clsx';
import { translate } from '@docusaurus/Translate';
import { useCodeBlockContext } from '@docusaurus/theme-common/internal';
import Button from '@theme/CodeBlock/Buttons/Button';
import type { Props } from '@theme/CodeBlock/Buttons/CopyButton';
import IconSuccess from '@theme/Icon/Success';
import IconPlay from '../../../Icon/Play';
import AnsiToHtml from 'ansi-to-html';

import styles from './styles.module.css';

function title() {
  return translate({
    id: 'theme.CodeBlock.build',
    message: 'Build',
    description: 'The build button label on code blocks',
  });
}

function ariaLabel(isCopied: boolean) {
  return isCopied
    ? translate({
      id: 'theme.CodeBlock.built',
      message: 'Built',
      description: 'The build button label on code blocks',
    })
    : translate({
      id: 'theme.CodeBlock.buildButtonAriaLabel',
      message: 'Build',
      description: 'The ARIA label for build code blocks button',
    });
}

function usePlayButton() {
  const ctx = useCodeBlockContext();
  const [isFetched, setIsFetched] = useState(false);
  const [isFetching, setIsFetching] = useState(false);
  const [result, setResult] = useState<{ stdout: string; stderr: string } | null>(null);
  const metadata = ctx.metadata;

  const renderCode = useCallback(
    async (button: HTMLDivElement) => {
      if (isFetching) return;

      console.log(ctx);

      setIsFetching(true);

      const result = await fetch('https://api.playmove.dev/build', {
        method: 'POST',
        mode: 'cors',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          name: 'book',
          build_type: 'Test',
          sources: { book: metadata.code },
          tests: {},
        }),
      }).catch((error) => {
        console.error(error);
        return null;
      });

      setIsFetching(false);
      setIsFetched(true);

      if (result) {
        const { stdout, stderr } = await result.json();
        const parent = button.parentNode.parentNode as HTMLDivElement;
        parent.appendChild(document.createElement('hr'));
        const elem = document.createElement('pre');

        const convert = new AnsiToHtml({
          colors: {
            0: '#282c34', // black
            1: '#e06c75', // red
            2: '#98c379', // green
            3: '#e5c07b', // yellow
            4: '#61afef', // blue
            5: '#c678dd', // magenta
            6: '#56b6c2', // cyan
            7: '#abb2bf', // white (light gray)

            8: '#5c6370',  // bright black (gray)
            9: '#e06c75',  // bright red
            10: '#98c379', // bright green
            11: '#e5c07b', // bright yellow
            12: '#61afef', // bright blue
            13: '#c678dd', // bright magenta
            14: '#56b6c2', // bright cyan
            15: '#ffffff'  // bright white
          }
        });
        const html = convert.toHtml(stdout + stderr);

        elem.style.marginTop = '10px';
        // elem.className = 'result-content';
        elem.innerHTML = html;
        parent.appendChild(elem);
      }
    },
    [metadata.code],
  );

  return { renderCode, isFetched, isFetching, result };
}

function IconLoading() {
  return (
    <div>
      <i className="fa fa-spinner animate-spin code-icon" />
    </div>
  );
}

export default function BuildButton({ className }: Props): ReactNode {
  const { renderCode, isFetching, isFetched } = usePlayButton();
  const codeBlockElement = useRef<HTMLDivElement>(null);
  const [showSuccess, setShowSuccess] = useState(false);

  useEffect(() => {
    if (isFetched) {
      setShowSuccess(true);
      setTimeout(() => setShowSuccess(false), 1000);
    }
  }, [isFetched]);

  return (
    <Button
      ref={codeBlockElement}
      aria-label={ariaLabel(isFetched)}
      title={title()}
      className={clsx(className, styles.copyButton, isFetched && styles.copyButtonCopied)}
      onClick={() => renderCode(codeBlockElement.current)}
    >
      <span className={styles.copyButtonIcons} aria-hidden="true">
        {!isFetching && !showSuccess && <IconPlay />}
        {isFetching && <IconLoading />}
        {showSuccess && <IconSuccess />}
      </span>
    </Button>
  );
}
