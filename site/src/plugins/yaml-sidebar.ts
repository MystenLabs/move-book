// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import * as yaml from 'yaml';
import fs from 'fs';
import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

/**
 * Loads a sidebar from a YAML file and returns a SidebarsConfig object.
 * Docusaurus will error out if the sidebar is not valid.
 *
 * @param yamlPath - The path to the YAML file.
 * @returns A SidebarsConfig object.
 */
export function loadSidebarsFromYaml(yamlPath: string): SidebarsConfig {
  const sidebars: SidebarsConfig = {};

  // Read all YAML files in the directory
  const yamlContent = fs.readFileSync(yamlPath, 'utf8');
  const sidebarConfig = yaml.parse(yamlContent);
  Object.assign(sidebars, sidebarConfig);

  return sidebars;
}
