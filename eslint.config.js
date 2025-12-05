// ESLint 9 Flat Config for UKHPI
// Migrated from legacy .eslintrc.js format
// See: https://eslint.org/docs/latest/use/configure/configuration-files

import js from '@eslint/js';
import pluginVue from 'eslint-plugin-vue';
import globals from 'globals';

export default [
  // ESLint recommended rules (replaces 'extends: standard' base)
  js.configs.recommended,

  // Vue 2 support (replaces eslint-plugin-html for .vue files)
  ...pluginVue.configs['flat/vue2-recommended'],

  // Global configuration (replaces env and parserOptions)
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
  },

  // Custom rules (migrated from .eslintrc.js)
  {
    rules: {
      // Allow debugger in development (replaces numeric severity with string)
      'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',

      // Relaxed Vue rules for existing codebase compatibility
      'vue/multi-word-component-names': 'off',
      'vue/no-v-html': 'warn',

      // Allow unused vars prefixed with underscore (common pattern)
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },

  // Ignore patterns (replaces .eslintignore file)
  {
    ignores: [
      'node_modules/**',
      'public/**',
      'tmp/**',
      'vendor/**',
      'coverage/**',
      'log/**',
      '*.min.js',
      'app/assets/builds/**',
      'app/assets/govuk_template*/**', // Vendor GOV.UK template files
    ],
  },
];
