// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0
import * as React from "react";
import { useThemeConfig, ErrorCauseBoundary } from "@docusaurus/theme-common";
import {
  splitNavbarItems,
  useNavbarMobileSidebar,
} from "@docusaurus/theme-common/internal";
import NavbarItem from "@theme/NavbarItem";
import NavbarMobileSidebarToggle from "@theme/Navbar/MobileSidebar/Toggle";
import NavbarLogo from "@theme/Navbar/Logo";
import NavbarSearch from "@theme/Navbar/Search";
import NavbarColorModeToggle from "@theme/Navbar/ColorModeToggle";
import SearchBar from "@theme/SearchBar";

function useNavbarItems() {
  return useThemeConfig().navbar.items;
}

function useMobileSidebarSafe() {
  try {
    return useNavbarMobileSidebar();
  } catch {
    return { disabled: true, toggle: () => {} };
  }
}

function NavbarItems({ items }) {
  return (
    <>
      {items.map((item, i) => {
        // Skip the search item — we render SearchBar separately
        if (item.type === "search") return null;
        return (
          <ErrorCauseBoundary
            key={i}
            onError={(error) =>
              new Error(
                `A theme navbar item failed to render.
Please double-check the following navbar item (themeConfig.navbar.items) of your Docusaurus config:
${JSON.stringify(item, null, 2)}`,
                { cause: error },
              )
            }
          >
            <NavbarItem {...item} />
          </ErrorCauseBoundary>
        );
      })}
    </>
  );
}

function NavbarContentLayout({ left, right }) {
  return (
    <div className="navbar__inner">
      <div className="navbar__items">{left}</div>
      <div className="navbar__items navbar__items--right">{right}</div>
    </div>
  );
}

function KapaButton() {
  const handleClick = () => {
    if (typeof window !== "undefined" && window.Kapa) {
      window.Kapa.open();
    }
  };

  return (
    <button
      type="button"
      onClick={handleClick}
      className="kapa-trigger-btn"
    >
      <img src="/favicon.svg" alt="" width="23" height="23" />
      <span>Ask Move AI</span>
    </button>
  );
}

export default function NavbarContent() {
  const mobileSidebar = useMobileSidebarSafe();
  const items = useNavbarItems();
  const [leftItems, rightItems] = splitNavbarItems(items);

  return (
    <NavbarContentLayout
      left={
        <>
          {!mobileSidebar.disabled && <NavbarMobileSidebarToggle />}
          <NavbarLogo />
          <NavbarItems items={leftItems} />
        </>
      }
      right={
        <>
          <NavbarItems items={rightItems} />
          <NavbarColorModeToggle />
          <KapaButton />
          <NavbarSearch>
            <SearchBar />
          </NavbarSearch>
        </>
      }
    />
  );
}
