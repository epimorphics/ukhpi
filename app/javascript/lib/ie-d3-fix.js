/* This is a fix for an issued reported under IE Edge sometimes. Sentry
 report reads something like:

    TypeErrorapp/javascript/presenters/data-graph in createScales
    errorObject doesn't support property or method 'slice'

 This proposed fix via: https://github.com/Microsoft/ChakraCore/issues/1415#issuecomment-287888807
*/
import * as Sentry from '@sentry/browser'

if (window && window.navigator && window.navigator.userAgent && /Edge\/1[0-4]\./.test(window.navigator.userAgent)) {
  // Fix for bug in Microsoft Edge: https://github.com/Microsoft/ChakraCore/issues/1415#issuecomment-246424339
  Sentry.captureMessage('Applying function.call fix for Microsoft Edge <= 14')
  /* eslint-disable no-extend-native */
  Function.prototype.call = function ieEdgeCallFix (t, ...args) {
    return this.apply(t, Array.prototype.slice.apply(args, [1]))
  }
}
