import React, { type ReactNode } from 'react';

/**
 * Replace default icon with FontAwesome icon.
 */
export default function IconCopy(): ReactNode {
  return (
    <div>
      <i className={`fa fa-copy code-icon`} />
    </div>
  );
}
