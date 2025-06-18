import React, { useCallback, useState, useRef, useEffect, type ReactNode } from 'react';
import clsx from 'clsx';
import html2canvas from 'html2canvas';
import { translate } from '@docusaurus/Translate';
import { useCodeBlockContext } from '@docusaurus/theme-common/internal';
import Button from '@theme/CodeBlock/Buttons/Button';
import type { Props } from '@theme/CodeBlock/Buttons/CopyButton';
import IconSuccess from '@theme/Icon/Success';
import IconImage from '../../../Icon/Image';

import styles from './styles.module.css';

function title() {
  return translate({
    id: 'theme.CodeBlock.render',
    message: 'Render as image',
    description: 'The render button label on code blocks',
  });
}

function ariaLabel(isCopied: boolean) {
  return isCopied
    ? translate({
      id: 'theme.CodeBlock.rendered',
      message: 'Rendered',
      description: 'The rendered button label on code blocks',
    })
    : translate({
      id: 'theme.CodeBlock.renderButtonAriaLabel',
      message: 'Render as image',
      description: 'The ARIA label for render code blocks button',
    });
}

function useRenderButton() {
  const {
    metadata: { code },
  } = useCodeBlockContext();
  const copyTimeout = useRef<number | undefined>(undefined);
  const [isRendered, setIsRendered] = useState(false);

  const renderCode = useCallback(
    (buttonElement: HTMLDivElement) => {
      const codeBlockElement = buttonElement.parentNode.parentNode.firstChild as HTMLDivElement;
      const codeInnerElement = codeBlockElement.firstChild as HTMLDivElement;

      // add a signature element to the code block
      const elem = document.createElement('p');
      elem.style.marginTop = '10px';
      elem.style.marginBottom = '0';
      elem.className = 'token comment';
      elem.textContent = `// Sample from the Move Book: ${window.location.href}`;
      codeInnerElement.appendChild(elem);

      html2canvas(codeBlockElement, { scale: 2 }).then((canvas) => {
        // remove the signature element
        codeInnerElement.removeChild(elem);

        canvas.toBlob((blob) => {
          if (!blob) return;

          const url = URL.createObjectURL(blob);
          window.open(url, '_blank');

          setIsRendered(true);

          // Optional: revoke the object URL after some time
          setTimeout(() => URL.revokeObjectURL(url), 60_000);
        }, 'image/png');
      });
    },
    [code],
  );

  useEffect(() => () => window.clearTimeout(copyTimeout.current), []);

  return { renderCode, isRendered };
}

export default function RenderButton({ className }: Props): ReactNode {
  const { renderCode, isRendered } = useRenderButton();
  const codeBlockElement = useRef<HTMLDivElement>(null);

  return (
    <Button
      ref={codeBlockElement}
      aria-label={ariaLabel(isRendered)}
      title={title()}
      className={clsx(className, styles.copyButton, isRendered && styles.copyButtonCopied)}
      onClick={() => renderCode(codeBlockElement.current)}
    >
      <span className={styles.copyButtonIcons} aria-hidden="true">
        <IconImage className={styles.copyButtonIcon} />
        <IconSuccess className={styles.copyButtonSuccessIcon} />
      </span>
    </Button>
  );
}
