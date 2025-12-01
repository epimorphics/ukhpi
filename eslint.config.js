import { defineConfig } from 'eslint/config'
import globals from 'globals'
import vueParser from 'vue-eslint-parser'
import js from '@eslint/js'
import tseslint from 'typescript-eslint'

import pluginVue from 'eslint-plugin-vue'
import stylistic from '@stylistic/eslint-plugin'

export default defineConfig([
  // global ignores for generated/output directories
  { ignores: ['./public/**', './node_modules/**', './.yarn/**', './coverage/**'] },

  // base config — apply to JS/TS/Vue source files
  js.configs.recommended,
  ...tseslint.configs.strict,
  ...pluginVue.configs['flat/vue2-strongly-recommended'],
  stylistic.configs.recommended,
  ...tseslint.configs.stylistic,

  // Ensure SFCs use the Vue parser with TypeScript for <script setup lang="ts"> blocks
  {
    files: ['**/*.vue'],
    languageOptions: {
      // runtime parser for Vue single-file components
      parser: vueParser,
      parserOptions: {
        // use the TypeScript parser for <script lang="ts"> blocks
        parser: tseslint.parser,
        extraFileExtensions: ['.vue'],
        ecmaVersion: 'latest',
        sourceType: 'module',
      },
    },
  },

  {
    // catch all language options / globals for all linted files
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
  },
  {
    name: 'custom-ts',
    rules: {
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports', fixStyle: 'separate-type-imports' }],
    },
  },
  {
    name: 'custom-vue',
    rules: {
      'vue/block-order': ['error', { order: ['template', 'script', 'style'] }],
      'vue/component-name-in-template-casing': [
        'warn',
        'PascalCase',
        { registeredComponentsOnly: false },
      ],
      'vue/custom-event-name-casing': [
        'error',
        'camelCase',
        {
          /* Allow custom events to be namespaced with a colon */
          ignores: ['/^[a-z]+(?:-[a-z]+)*:[a-z]+(?:-[a-z]+)*$/'],
        },
      ],
      'vue/define-emits-declaration': ['error', 'type-based'],
      'vue/define-props-declaration': ['error', 'type-based'],
      'vue/html-button-has-type': [
        'error',
        { button: true, submit: true, reset: true },
      ],
      'vue/no-boolean-default': ['error', 'default-false'],
      'vue/no-empty-component-block': 'error',
      'vue/no-required-prop-with-default': 'error',
      'vue/no-root-v-if': 'error',
      'vue/prefer-separate-static-class': 'error',
    },
  },
  {
    name: 'custom-stylistic',
    rules: {
      '@stylistic/array-bracket-newline': [
        'warn',
        { multiline: true, minItems: null },
      ],
      '@stylistic/array-element-newline': ['warn', 'consistent'],
      '@stylistic/arrow-parens': ['warn', 'always'],
      '@stylistic/brace-style': ['error', '1tbs', { allowSingleLine: true }],
      '@stylistic/comma-dangle': ['error', 'always-multiline'],
      '@stylistic/dot-location': ['warn', 'property'],
      '@stylistic/function-call-argument-newline': ['error', 'consistent'],
      '@stylistic/function-paren-newline': ['warn', 'multiline-arguments'],
      '@stylistic/implicit-arrow-linebreak': 'warn',
      '@stylistic/indent-binary-ops': 'warn',
      '@stylistic/indent': ['error', 2],
      '@stylistic/lines-between-class-members': [
        'error',
        'always',
        { exceptAfterSingleLine: true },
      ],
      '@stylistic/max-statements-per-line': ['warn', { max: 2 }],
      '@stylistic/member-delimiter-style': [
        'error',
        {
          multiline: { delimiter: 'none', requireLast: false },
          singleline: { delimiter: 'comma', requireLast: false },
          multilineDetection: 'brackets',
        },
      ],
      '@stylistic/multiline-comment-style': 'off',
      '@stylistic/multiline-ternary': ['error', 'always-multiline'],
      '@stylistic/newline-per-chained-call':
        'warn' /** TODO: review this rule */,
      '@stylistic/no-confusing-arrow': [
        'warn',
        { onlyOneSimpleParam: true },
      ] /** TODO: review this rule */,
      '@stylistic/no-trailing-spaces': 'warn',
      '@stylistic/object-curly-spacing': ['error', 'always'],
      '@stylistic/object-property-newline': [
        'error',
        { allowAllPropertiesOnSameLine: true },
      ],
      '@stylistic/operator-linebreak': ['warn', 'before'],
      '@stylistic/padded-blocks': ['warn', 'never'],
      '@stylistic/quote-props': ['error', 'as-needed'],
      '@stylistic/quotes': ['error', 'single'],
      '@stylistic/semi': ['error', 'never'],
      '@stylistic/spaced-comment': 'warn',
      '@stylistic/type-generic-spacing': 'warn',
    },
  },
  {
    files: ['app/frontend/pages/**/*.vue', 'app/frontend/layouts/**/*.vue'],
    rules: {
      // allow single-word component names for our pages/layouts directories
      'vue/multi-word-component-names': 'off',
    },
  },
])
