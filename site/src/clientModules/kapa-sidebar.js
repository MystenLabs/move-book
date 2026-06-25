// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// Injects the Kapa widget script with all configuration (including
// data-color-scheme-selector which Docusaurus strips due to nested quotes),
// then detects sidebar open/close and toggles .kapa-sidebar-open on <html>.

if (typeof window !== "undefined") {
  // Inject the Kapa widget script tag with all attributes
  const script = document.createElement("script");
  script.src = "https://widget.kapa.ai/kapa-widget.bundle.js";
  script.async = true;
  const attrs = {
    "data-website-id": "de266438-2cd4-4ed5-9633-a1c6b931dd7d",
    "data-project-name": "Move Book",
    "data-project-color": "#298DFF",
    "data-button-hide": "true",
    "data-view-mode": "sidebar",
    "data-modal-title": "Ask Move AI",
    "data-modal-ask-ai-input-placeholder": "Ask me anything about Move!",
    "data-modal-example-questions": "How do I define a struct in Move?,What are abilities in Move?,How do I publish a Move package?,What are dynamic fields?",
    "data-modal-overlay-hidden": "true",
    "data-modal-lock-scroll": "false",
    "data-color-scheme-selector": "[data-theme='dark']",
  };
  for (const [key, value] of Object.entries(attrs)) {
    script.setAttribute(key, value);
  }
  document.head.appendChild(script);

  // Sidebar open/close detection
  const OPEN_CLASS = "kapa-sidebar-open";
  let kapaOpen = false;
  let hookedRef = null;

  function syncClass() {
    document.documentElement.classList.toggle(OPEN_CLASS, kapaOpen);
  }

  function hookKapa() {
    if (!window.Kapa || !window.Kapa.open || window.Kapa.open === hookedRef) return;

    const origOpen = window.Kapa.open;
    const origClose = window.Kapa.close;

    window.Kapa.open = function (...args) {
      kapaOpen = true;
      syncClass();
      return origOpen.apply(this, args);
    };

    window.Kapa.close = function (...args) {
      kapaOpen = false;
      syncClass();
      return origClose.apply(this, args);
    };

    hookedRef = window.Kapa.open;
  }

  // Check if Kapa sidebar is covering the right side of the viewport
  function isSidebarVisible() {
    const x = window.innerWidth - 50;
    const y = window.innerHeight / 2;
    const el = document.elementFromPoint(x, y);
    if (!el) return false;
    const docRoot = document.getElementById("__docusaurus");
    if (docRoot && docRoot.contains(el)) return false;
    if (el === document.body || el === document.documentElement) return false;
    return true;
  }

  // Navigation hooks for SPA
  const origPush = history.pushState.bind(history);
  const origReplace = history.replaceState.bind(history);
  history.pushState = function (...args) {
    const r = origPush(...args);
    syncClass();
    return r;
  };
  history.replaceState = function (...args) {
    const r = origReplace(...args);
    syncClass();
    return r;
  };
  window.addEventListener("popstate", syncClass);

  // Poll every 300ms
  setInterval(() => {
    hookKapa();

    const visible = isSidebarVisible();
    if (visible && !kapaOpen) {
      kapaOpen = true;
    } else if (!visible && kapaOpen) {
      kapaOpen = false;
    }
    syncClass();
  }, 300);
}
