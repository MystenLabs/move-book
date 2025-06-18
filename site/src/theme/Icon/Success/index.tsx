import React, { type ReactNode } from 'react';
import type { Props } from '@theme/Icon/Success';

export default function IconSuccess(props: Props): ReactNode {
  return (
    <div {...props}>
      <i className={`fa fa-check code-icon`} />
    </div>
  );
}
