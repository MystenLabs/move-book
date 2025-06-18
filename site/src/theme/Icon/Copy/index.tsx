import React, { type ReactNode } from 'react';
import type { Props } from '@theme/Icon/Copy';

/**
 * Replace default icon with FontAwesome icon.
 */
export default function IconCopy(props: Props): ReactNode {
  return (
    <div {...props}>
      <i className={`fa fa-copy code-icon`} />
    </div>
  );
}
