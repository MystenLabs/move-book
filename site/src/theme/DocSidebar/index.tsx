// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, useState, type ReactNode } from 'react';
import DocSidebar from '@theme-original/DocSidebar';
import type DocSidebarType from '@theme/DocSidebar';
import type { WrapperProps } from '@docusaurus/types';
import { useLocation } from '@docusaurus/router';

type Props = WrapperProps<typeof DocSidebarType>;

/**
 * Adds a smooth scroll to the active sidebar link.
 * Includes on-page links, not just initial loading.
 * @param props
 * @returns
 */
export default function DocSidebarWrapper(props: Props): ReactNode {
  const location = useLocation();
  const [isFirstRender, setIsFirstRender] = useState(true);

  // swizzled part;
  useEffect(() => {
    const active = document.querySelector('.menu__link--active');
    const container = document.querySelector('.menu');

    if (!active || !container) return;

    const containerRect = container.getBoundingClientRect();
    const activeRect = active.getBoundingClientRect();

    const isOutOfView =
      activeRect.top < containerRect.top ||
      activeRect.bottom > containerRect.bottom;

    if (isOutOfView) {
      container.scrollTo({
        top: activeRect.top - containerRect.top,
        behavior: isFirstRender ? 'instant' : 'smooth',
      });
    }

    setIsFirstRender(false);
  }, [location.pathname]);

  return (
    <>
      <DocSidebar {...props} />
    </>
  );
}
