/// <reference types="vite/client" />

/**
 * Global constants injected by Vite at build time
 *
 * These constants are replaced with their actual values during the build process
 * via Vite's `define` configuration option. They have zero runtime cost as they're
 * compiled to string literals.
 */

/**
 * Application version string injected at build time from version.rb
 *
 * This constant is set by the Vite configuration which reads version.rb during
 * the build process. The value is embedded directly into the compiled JavaScript,
 * making it available without any file system access or HTTP requests.
 *
 * @example "1.2.3"
 * @example "1.2.3.beta"
 */
declare const __APP_VERSION__: string
