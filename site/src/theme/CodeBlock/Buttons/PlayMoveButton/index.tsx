// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0
import React, { useCallback, useState, useRef, useEffect, type ReactNode } from 'react';
import clsx from 'clsx';

function getNearestCodeText(start: HTMLElement | null): string | null {
  let el: HTMLElement | null = start;
  while (el) {
    const codeEl = el.querySelector?.('pre code, code, pre') as HTMLElement | null;
    if (codeEl && codeEl.innerText) {
      return codeEl.innerText;
    }
    el = el.parentElement;
  }
  return null;
}

export default function PlayMoveButton(): ReactNode {
  const wrapperRef = useRef<HTMLButtonElement | null>(null);
  const [isMove, setIsMove] = useState(false);

  useEffect(() => {
    let el: HTMLElement | null = wrapperRef.current;
    while (el) {
      const code = el.querySelector?.("pre code[class*='language-move']") as HTMLElement | null;
      if (code) {
        setIsMove(true);
        return;
      }
      el = el.parentElement;
    }
  }, []);

  const handleClick = useCallback(() => {
    const code = getNearestCodeText(wrapperRef.current);
    if (!code) return;
    const url = `https://www.playmove.dev/#${encodeURIComponent(code)}`;
    window.open(url, '_blank', 'noopener');
  }, []);

  if (!isMove) {
    return <button ref={wrapperRef} type="button" style={{ display: 'none' }} />;
  }

  return (
    <button
      ref={wrapperRef}
      type="button"
      className="clean-btn"
      aria-label="Open in Move Playground"
      title="Open in Move Playground"
      onClick={handleClick}
    >
      <svg
        width="12"
        height="12"
        viewBox="0 0 24 24"
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
      >
        <polygon points="5,3 19,12 5,21" />
      </svg>
      <span style={{ marginLeft: 4, fontSize: '0.75rem' }}>Playground</span>
    </button>
  );
}
