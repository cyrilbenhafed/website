/* ============================================
   benhafed.com — main.js
   ============================================ */

// ---- State ----
let currentLang  = localStorage.getItem('cb-lang')  || 'fr';
let currentTheme = localStorage.getItem('cb-theme') || 'light';

// ---- Init ----
document.addEventListener('DOMContentLoaded', () => {
  applyTheme(currentTheme);
  applyLang(currentLang);
  initNav();
});

// ---- Theme ----
function toggleTheme() {
  currentTheme = currentTheme === 'light' ? 'dark' : 'light';
  applyTheme(currentTheme);
  localStorage.setItem('cb-theme', currentTheme);
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  currentTheme = theme;
}

// ---- Language ----
function setLang(lang) {
  if (lang !== 'fr' && lang !== 'en') return;
  currentLang = lang;
  localStorage.setItem('cb-lang', lang);
  applyLang(lang);
}

function applyLang(lang) {
  // Set html lang attribute
  document.documentElement.lang = lang;

  // Translate all [data-fr] / [data-en] elements
  document.querySelectorAll('[data-fr]').forEach(el => {
    const text = el.getAttribute(`data-${lang}`);
    if (text !== null) {
      // Use innerHTML for elements that may contain <br>
      if (text.includes('<br>') || text.includes('<')) {
        el.innerHTML = text;
      } else {
        el.textContent = text;
      }
    }
  });

  // Update lang button states
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });

  // Dispatch event for pages with custom translation needs
  document.dispatchEvent(new CustomEvent('langChanged', { detail: { lang } }));
}

// ---- Nav scroll ----
function initNav() {
  const navbar = document.getElementById('navbar');
  if (!navbar) return;

  window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 20);
  }, { passive: true });
}

// ---- Mobile menu ----
function toggleMenu() {
  const menu = document.getElementById('mobileMenu');
  if (menu) menu.classList.toggle('open');
}

// Close mobile menu on link click
document.addEventListener('click', (e) => {
  if (e.target.classList.contains('mobile-link')) {
    const menu = document.getElementById('mobileMenu');
    if (menu) menu.classList.remove('open');
  }
});

// ---- Smooth anchor scroll ----
document.addEventListener('click', (e) => {
  const link = e.target.closest('a[href^="#"]');
  if (!link) return;
  const target = document.querySelector(link.getAttribute('href'));
  if (target) {
    e.preventDefault();
    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
});
