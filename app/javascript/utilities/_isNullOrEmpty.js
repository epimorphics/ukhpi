/**
 * @param {unknown} value - the value to check
 * @returns true if the value is not undefined, null, or empty
 */
export function isNullOrEmpty (value) {
  if (value instanceof Object) return Object.entries(value).length === 0
  return value === undefined || value === null || value === ''
}
