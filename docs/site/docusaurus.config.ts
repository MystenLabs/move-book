import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import path from 'path';
import type * as Preset from '@docusaurus/preset-classic';
import remarkCodeImport from 'remark-code-import';
import mdbookAnchorCode from './src/plugins/mdbook-anchor-code';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

const remarkCodeImportOptions = {
  rootDir: path.resolve(__dirname),
  // allowImportingFromOutside: true,
  // preserveTrailingNewline: true,
  // removeRedundantIndentations: true,
  // async: true,
};

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
        sidebarPath: './sidebars.ts',
        sidebarCollapsible: false,
        breadcrumbs: false,
        // remarkPlugins: [[remarkCodeImport, remarkCodeImportOptions], mdbookAnchorCode],
        remarkPlugins: [mdbookAnchorCode],
      },
    ],
    // [
    //   '@docusaurus/plugin-content-docs',
    //   {
    //     id: 'reference',
    //     path: './../reference',
    //     routeBasePath: '/reference',
    //     sidebarPath: './sidebar-reference.ts',
    //     sidebarCollapsible: false,
    //     breadcrumbs: false,
    //     remarkPlugins: [remarkCodeImport],
    //   },
    // ],
  ],
  themes: [['@docusaurus/theme-classic', { customCss: './src/css/custom.css' }]],

  stylesheets: [
    {
      href: 'https://fonts.googleapis.com/css2?family=Rubik:wght@300&amp;display=swap',
      type: 'text/css',
    },
    {
      href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css',
      type: 'text/css',
    },
    {
      // finish the theme
      href: 'src/css/prism.css',
      type: 'text/css',
    },
  ],

  // presets: [
  //   [
  //     'classic',
  //     {
  //       docs: {
  //         routeBasePath: '/',
  //         sidebarPath: './sidebars.ts',
  //         editUrl: 'https://github.com/MystenLabs/move-book/tree/main',
  //       },
  //     },
  //     //   blog: {
  //     //     showReadingTime: true,
  //     //     feedOptions: {
  //     //       type: ['rss', 'atom'],
  //     //       xslt: true,
  //     //     },
  //     //     // Please change this to your repo.
  //     //     // Remove this to remove the "edit this page" links.
  //     //     editUrl:
  //     //       'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
  //     //     // Useful options to enforce blogging best practices
  //     //     onInlineTags: 'warn',
  //     //     onInlineAuthors: 'warn',
  //     //     onUntruncatedBlogPosts: 'warn',
  //     //   },
  //     //   theme: {
  //     //     customCss: './src/css/custom.css',
  //     //   },
  //     // } satisfies Preset.Options,
  //   ],
  // ],

  themeConfig: {
    colorMode: {
      disableSwitch: false,
    },
    navbar: {
      // title: 'The Move Book',
      // logo: {
      //   alt: 'Move Book Logo',
      //   src: 'img/favicon.svg',
      // },
      items: [
        // {
        //   type: 'docSidebar',
        //   sidebarId: 'bookSidebar',
        //   position: 'left',
        //   label: 'The Move Book',
        // },
        { to: '/', label: 'Move Book', position: 'left' },
        { to: '/reference', label: 'Move Reference', position: 'left' },
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
      additionalLanguages: ['ini', 'toml'],
      theme: prismThemes.oneLight,
      darkTheme: prismThemes.oneDark,
    },
    breadcrumbs: false,
  } satisfies Preset.ThemeConfig,
};

export default config;
