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

  url: 'https://move-book.com',
  baseUrl: '/',

  // GitHub pages deployment config.
  organizationName: 'MystenLabs',
  projectName: 'move-book',

  // TODO: circle back
  onBrokenLinks: 'throw',
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
        id: 'book',
        path: './../book',
        routeBasePath: '/',
        sidebarPath: './sidebar-book.ts',
        sidebarCollapsible: false,
        breadcrumbs: false,
        numberPrefixParser: false,
        remarkPlugins: [mdbookAnchorCode],
      },
    ],
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
  ],
  themes: [
    ['@docusaurus/theme-classic', { customCss: './src/css/custom.css' }],
    [
      // require.resolve("@easyops-cn/docusaurus-search-local"),
      '@easyops-cn/docusaurus-search-local',
      /** @type {import("@easyops-cn/docusaurus-search-local").PluginOptions} */
      ({
        // ... Your options.
        // `hashed` is recommended as long-term-cache of index file is possible.
        hashed: true,
        docsRouteBasePath: '/',
        docsDir: ['./../book', './../reference'],

        // For Docs using Chinese, it is recomended to set:
        language: ["en"],

        // If you're using `noIndex: true`, set `forceIgnoreNoIndex` to enable local index:
        // forceIgnoreNoIndex: true,
      }),
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
    // searchParameters: {
    //   // Add analytics tags to the search results
    // },
    colorMode: {
      disableSwitch: false,
    },
    navbar: {
      items: [
        { to: '/', label: 'Move Book', position: 'left', activeBasePath: '/' },
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
          href: 'https://github.com/your/repo',
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
    },
    breadcrumbs: false,
  } satisfies Preset.ThemeConfig,
};

export default config;
