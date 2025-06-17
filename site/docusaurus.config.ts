import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import mdbookAnchorCode from './src/plugins/mdbook-anchor-code';
import prismAtomOneDark from './src/theme/prism-atom-one-dark';
import prismAtomOneLight from './src/theme/prism-atom-one-light';

const config: Config = {
  title: 'The Move Book',
  tagline:
    'First book about the Move programming language and the Move VM. Move documentation, Move tutorials and language reference',
  favicon: 'favicon.svg',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // TODO: Add forwarding from old pages to new pages.

  url: 'https://damirka.github.io',
  baseUrl: '/docusaurus-test/',

  // GitHub pages deployment config.
  organizationName: 'damirka',
  projectName: 'docusaurus-test',

  // TODO: circle back
  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',

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
        // anonymizeIP: true,
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
        hashed: true,
        docsRouteBasePath: '/',
        // docsDir: ['./../book', './../reference'],
        searchResultLimits: 10,
        searchBarShortcutHint: false,
        blogDir: [],
        language: ['en'],
        explicitSearchResultPath: true,
        highlightSearchTermsOnTargetPage: false, // looks ugly...
        searchContextByPaths: [
          { label: 'The Move Book', path: './../book' },
          { label: 'The Move Reference', path: './../reference' },
        ],
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
};

export default config;
