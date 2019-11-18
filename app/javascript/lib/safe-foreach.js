/**
 * Call forEach in a way that doesn't blow up IE11
 * This weirdness with slice is because IE11 doesn't do forEach on the return
 * value from querySelectorAll. See:
 * https://stackoverflow.com/questions/412447/for-each-javascript-support-in-ie
 */
export default function safeForEach (nodes, fn) {
  [].slice.call(nodes).forEach(fn)
}
