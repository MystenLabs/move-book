import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import mdbookAnchorCode from './src/plugins/mdbook-anchor-code';
import prismAtomOneDark from './src/theme/prism-atom-one-dark';
import prismAtomOneLight from './src/theme/prism-atom-one-light';

export default {
  title: 'The Move Book',
  tagline:
    'First book about the Move programming language and the Move VM. Move documentation, Move tutorials, and language reference.',
  favicon: 'favicon.svg',

  // Future compatibility flags.
  future: { v4: true },

  url: 'https://move-book.com',
  baseUrl: '/',

  // GitHub pages deployment config.
  organizationName: 'MystenLabs',
  projectName: 'move-book',

  // Relax or throw on broken links, options are: 'warn', 'throw'.
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'throw',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  plugins: [
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'reference',
        path: './../reference',
        routeBasePath: '/reference',
        sidebarPath: './sidebar-reference.ts',
        sidebarCollapsible: false,
        breadcrumbs: false,
        remarkPlugins: [mdbookAnchorCode],
      },
    ],
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'book',
        path: './../book',
        exclude: ['./../reference/**'],
        routeBasePath: '/',
        sidebarPath: './sidebar-book.ts',
        sidebarCollapsible: false,
        breadcrumbs: false,
        numberPrefixParser: false,
        remarkPlugins: [mdbookAnchorCode],
      },
    ],
    [
      '@docusaurus/plugin-google-gtag',
      {
        trackingID: 'G-B1E7R0BHX4',
        anonymizeIP: true,
      },
    ],
    // Sets up HTTP redirects for old pages.
    // Use standard `from` and `to` fields to specify the redirect.
    // Notes:
    // - for folder index, add trailing slash `/`
    // - html rewrites are already handled by the configuration
    [
      '@docusaurus/plugin-client-redirects',
      {
        fromExtensions: ['html'],
        redirects: [
          { from: '/guides/coding-conventions', to: '/guides/code-quality-checklist' },
          { from: '/introduction/foreword', to: '/foreword' },
          { from: '/introduction/getting-started', to: '/before-we-begin/' },
          { from: '/syntax-basics/index', to: '/move-basics/' },
          { from: '/syntax-basics/concept', to: '/move-basics/module' },
          { from: '/syntax-basics/comments', to: '/move-basics/comments' },
          { from: '/syntax-basics/expression', to: '/move-basics/expression' },
          { from: '/syntax-basics/module', to: '/move-basics/importing-modules' },
          { from: '/syntax-basics/constants', to: '/move-basics/constants' },
          { from: '/syntax-basics/function', to: '/move-basics/function' },
          { from: '/advanced-topics/index', to: '/programmability/' },
          {
            from: '/advanced-topics/types-with-abilities/index',
            to: '/move-basics/abilities-introduction',
          },
          {
            from: '/advanced-topics/ownership-and-scope',
            to: '/move-basics/ownership-and-scope',
          },
          { from: '/advanced-topics/understanding-generics', to: '/move-basics/generics' },
          {
            from: '/advanced-topics/advanced-topics/managing-collections-with-vectors',
            to: '/move-basics/vector',
          },
          {
            from: [
              '/resources/index',
              '/resources/signer-type',
              '/resources/what-is-resource',
              '/resources/resource-by-example/index',
              '/resources/resource-by-example/storing-new-resource',
              '/resources/resource-by-example/access-resource-with-borrow',
              '/resources/resource-by-example/destroy-resource',
              '/resources/resource-by-example/further-steps',
            ],
            to: '/',
          },
          { from: '/tutorials/index', to: '/' },
          { from: '/tutorials/erc20', to: '/' },
          { from: '/translations', to: '/' },
        ],
      },
    ],
  ],
  themes: [
    [
      '@docusaurus/theme-classic',
      {
        customCss: ['./src/css/custom.css', './src/fonts/fonts.css', './src/css/code.css'],
      },
    ],
    [
      // See https://github.com/easyops-cn/docusaurus-search-local
      '@easyops-cn/docusaurus-search-local',
      {
        // `hashed` is recommended as long-term-cache of index file is possible.
        hashed: false,
        docsRouteBasePath: '/',
        searchResultLimits: 10,
        searchBarShortcutHint: false,
        blogDir: [],
        docsDir: ['./../book', './../reference'],
        language: ['en'],
        explicitSearchResultPath: true,
        highlightSearchTermsOnTargetPage: false,
      },
    ],
  ],

  stylesheets: [
    {
      href: 'https://fonts.googleapis.com/css2?family=Rubik:wght@300&amp;display=swap',
      type: 'text/css',
    },
    {
      href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css',
      type: 'text/css',
    },
  ],

  themeConfig: {
    titleDelimiter: '+',
    // searchParameters: {
    //   // Add analytics tags to the search results
    // },
    colorMode: {
      disableSwitch: false,
    },
    metadata: [
      {
        name: 'algolia-site-verification',
        content: 'BCA21DA2879818D2',
      },
    ],
    navbar: {
      items: [
        {
          to: '/',
          label: 'Move Book',
          position: 'left',
          activeBasePath: '/',
          activeBaseRegex: '^/(?!reference).*',
        },
        {
          to: '/reference',
          label: 'Move Reference',
          position: 'left',
          activeBasePath: '/reference',
        },
        {
          type: 'search',
          position: 'right',
        },
        {
          href: 'https://github.com/MystenLabs/move-book',
          position: 'right',
          html: '<i class="fab fa-github"></i>', // 👈 icon here
        },
      ],
    },
    // footer: {
    //   style: 'dark',
    //   links: [
    //     {
    //       title: 'Docs',
    //       items: [
    //         {
    //           label: 'Tutorial',
    //           to: '/docs/intro',
    //         },
    //       ],
    //     },
    //     {
    //       title: 'Community',
    //       items: [
    //         {
    //           label: 'Stack Overflow',
    //           href: 'https://stackoverflow.com/questions/tagged/docusaurus',
    //         },
    //         {
    //           label: 'Discord',
    //           href: 'https://discordapp.com/invite/docusaurus',
    //         },
    //         {
    //           label: 'X',
    //           href: 'https://x.com/docusaurus',
    //         },
    //       ],
    //     },
    //     {
    //       title: 'More',
    //       items: [
    //         {
    //           label: 'Blog',
    //           to: '/blog',
    //         },
    //         {
    //           label: 'GitHub',
    //           href: 'https://github.com/facebook/docusaurus',
    //         },
    //       ],
    //     },
    //   ],
    //   copyright: `Copyright © ${new Date().getFullYear()} My Project, Inc. Built with Docusaurus.`,
    // },
    prism: {
      additionalLanguages: ['ini', 'toml', 'bash'],
      theme: prismAtomOneLight,
      darkTheme: prismAtomOneDark,
      magicComments: [
        {
          className: 'error-comment',
          line: 'highlight-error',
          block: {
            start: 'highlight-error-start',
            end: 'highlight-error-end',
          },
        },
      ],
    },
    breadcrumbs: false,
  } satisfies Preset.ThemeConfig,
} satisfies Config;
