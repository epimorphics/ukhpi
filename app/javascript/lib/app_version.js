import { readFileSync } from 'fs'
import { join } from 'path'

/**
 * Get the application version from version.rb (Node.js only)
 *
 * This function synchronously reads and parses the version.rb file to extract
 * the application version. It's designed for use in Node.js environments like
 * Vite configuration files where synchronous operations are acceptable.
 *
 * The version format follows semantic versioning: MAJOR.MINOR.PATCH[.SUFFIX]
 * where SUFFIX is optional (e.g., "1.2.3" or "1.2.3.beta").
 *
 * @returns {string} The application version string (e.g., "1.2.3") or "0.0.0" on error
 * @throws {Error} If window object exists (browser environment detected)
 *
 * @example
 * // In vite.config.mts
 * import { getAppVersion } from './app/javascript/lib/app_version.js'
 * const version = getAppVersion() // "1.2.3"
 */
export function getAppVersion () {
  try {
    /** @type {string} Absolute path to version.rb file */
    const versionFilePath = join(process.cwd(), 'app/lib/version.rb')
    /** @type {string} Raw content of version.rb */
    const content = readFileSync(versionFilePath, 'utf-8')

    /** @type {RegExpMatchArray | null} Extract MAJOR version number */
    const majorMatch = content.match(/MAJOR\s*=\s*(\d+)/)
    /** @type {RegExpMatchArray | null} Extract MINOR version number */
    const minorMatch = content.match(/MINOR\s*=\s*(\d+)/)
    /** @type {RegExpMatchArray | null} Extract PATCH version number */
    const patchMatch = content.match(/PATCH\s*=\s*(\d+)/)
    /** @type {RegExpMatchArray | null} Extract optional SUFFIX (e.g., 'beta', 'rc1') */
    const suffixMatch = content.match(/SUFFIX\s*=\s*["']?(\w+)["']?/)

    if (!majorMatch || !minorMatch || !patchMatch) {
      throw new Error('Could not parse version from version.rb')
    }

    const major = majorMatch[1]
    const minor = minorMatch[1]
    const patch = patchMatch[1]
    const suffix = suffixMatch?.[1] && suffixMatch[1] !== 'nil' ? `.${suffixMatch[1]}` : ''

    return `${major}.${minor}.${patch}${suffix}`
  } catch (error) {
    console.error('Failed to get version from version.rb:', error)
    return '0.0.0'
  }
}

export default getAppVersion
