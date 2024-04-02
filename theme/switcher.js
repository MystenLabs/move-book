/**
 * Adds a "switcher" link to the navigation menu that allows the user to switch
 * between move-book.com and move-book.com/reference; this is a general
 * convenience feature which improves the user experience for users who are
 * interested in both the book and the reference.
 *
 * The file is included in both themes (book and reference) so that the switcher
 * is available in both themes. The switcher is only displayed in the book theme
 * if the user is currently viewing the book theme, and vice versa.
 */
'use strict';

// Add the switcher link to the navigation menu (no jquery)
document.addEventListener('DOMContentLoaded', function() {
  let currentUrl = window.location.href;
  let isBook = !currentUrl.includes('/reference');
  let switcherText = isBook ? 'Go to Reference' : 'Go to Book';
  let switcherHref = isBook ? '/reference' : '/';

  let parent = document.querySelector('.left-buttons');
  let switcherLink = document.createElement('a');
  switcherLink.id = 'switcher-link';
  switcherLink.classList.add('icon-button');
  switcherLink.classList.add('switcher-link');
  switcherLink.type = 'button';
  switcherLink.href = switcherHref;
  switcherLink.title = 'Switch between book and reference';
  switcherLink.setAttribute('aria-label', 'Switch between book and reference');
  switcherLink.setAttribute('aria-expanded', 'false');
  switcherLink.setAttribute('aria-controls', 'switcher');
  switcherLink.innerHTML = switcherText;
  parent.appendChild(switcherLink);
});
