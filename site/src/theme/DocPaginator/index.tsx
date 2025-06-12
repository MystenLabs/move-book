// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import React, { type ReactNode } from 'react';
import clsx from 'clsx';
import { translate } from '@docusaurus/Translate';
import PaginatorNavLink from '@theme/PaginatorNavLink';
import type { Props } from '@theme/DocPaginator';

/**
 * Replaces default buttons with icons.
 * Swizzled part.
 */
export default function DocPaginator(props: Props): ReactNode {
  const { className, previous, next } = props;
  return (
    <nav
      className={clsx(className, 'pagination-nav')}
      aria-label={translate({
        id: 'theme.docs.paginator.navAriaLabel',
        message: 'Docs pages',
        description: 'The ARIA label for the docs pagination',
      })}>
      {previous && (
        <PaginatorNavLink
          title={<>
            <i className="fa fa-angle-left" />
            <span className="pagination-nav__label">{previous.title}</span>{" "}
          </>}
          permalink={previous.permalink}
        />
      )}
      {next && (
        <PaginatorNavLink
          title={<>
            <span className="pagination-nav__label">{next.title}</span>{" "}
            <i className="fa fa-angle-right" />
          </>}
          permalink={next.permalink}
          isNext
        />
      )}
    </nav>
  );
}
