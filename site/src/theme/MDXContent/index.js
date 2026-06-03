// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import React from "react";
import { MDXProvider } from "@mdx-js/react";
import MDXComponents from "@theme/MDXComponents";
import AgentPrompt from "../../shared/components/AgentPrompt";

export default function MDXContent({ children }) {
  const components = {
    ...MDXComponents,
    AgentPrompt,
  };
  return <MDXProvider components={components}>{children}</MDXProvider>;
}
