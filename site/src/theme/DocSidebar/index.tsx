// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import React, { useEffect, type ReactNode } from 'react';
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

  // swizzled part;
  useEffect(() => {
    const el = document.querySelector('.menu__link--active');
    if (el && el.scrollIntoView) {
      el.scrollIntoView({ block: 'center', behavior: 'smooth' });
    }
  }, [location.pathname]);

  return (
    <>
      <DocSidebar {...props} />
    </>
  );
}
