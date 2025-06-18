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
    // <svg viewBox="0 0 24 24" {...props}>
    //   <path
    //     fill="currentColor"
    //     d="M19,21H8V7H19M19,5H8A2,2 0 0,0 6,7V21A2,2 0 0,0 8,23H19A2,2 0 0,0 21,21V7A2,2 0 0,0 19,5M16,1H4A2,2 0 0,0 2,3V17H4V3H16V1Z"
    //   />
    // </svg>
  );
}
