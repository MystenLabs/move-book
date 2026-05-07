const BOT_PATTERNS =
  /bot|crawler|spider|crawling|headless|puppet|phantom|selenium|playwright|archiver|fetcher|slurp|mediapartners/i;

function detectVisitorType() {
  const ua = navigator.userAgent || '';
  if (BOT_PATTERNS.test(ua)) return 'agent';
  if (navigator.webdriver) return 'agent';
  return 'human';
}

export function onRouteDidUpdate({ location }) {
  if (typeof window === 'undefined' || typeof window.plausible !== 'function')
    return;

  window.plausible('pageview', {
    props: { visitor_type: detectVisitorType() },
  });
}
