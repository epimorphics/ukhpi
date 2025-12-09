import postcssImport from 'postcss-import'
import postcssPresetEnv from 'postcss-preset-env'

/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: [
    postcssImport,
    postcssPresetEnv({
      autoprefixer: {
        flexbox: 'no-2009',
      },
      stage: 3,
    }),
  ],
}

export default config
