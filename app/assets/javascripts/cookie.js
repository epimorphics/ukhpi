const HMLR_COOKIE_POLICY = 'hmlr_cookie_policy'
const COOKIE_DURATION = 365

/**
 * Retrieve user preferences cookie
 * If user has accepted analytics, load analytics
 * If no preference is set, show cookie banner
 */
window.onload = function () {
  var userPreferences = getCookie(HMLR_COOKIE_POLICY)
  if (userPreferences) {
    var analyticsAccepted = JSON.parse(userPreferences).analytics

    if (analyticsAccepted) {
      loadAnalytics()
    }
  } else {
    showBanner(true)
  }
}

/**
 * standard function for setting a cookie with an expiry length in days
 * @param {string} key
 * @param {string} value
 * @param {number} duration in days
 */
function setCookie (key, value, duration) {
  var date = new Date()
  date.setTime(date.getTime() + duration * 24 * 60 * 60 * 1000)
  var expires = 'expires=' + date.toUTCString()
  document.cookie = key + '=' + value + ';' + expires + ';path=/'
}

/**
 * retrieves a cookie's value by name
 * @param {string} name
 * @returns {string} the value of the cookie
 */
function getCookie (name) {
  var key = name + '='
  var decodedCookie = decodeURIComponent(document.cookie)
  var cookieList = decodedCookie.split(';')
  for (var i = 0; i < cookieList.length; i++) {
    var cookie = cookieList[i]
    while (cookie.charAt(0) == ' ') {
      cookie = cookie.substring(1)
    }
    if (cookie.indexOf(key) == 0) {
      return cookie.substring(key.length, cookie.length)
    }
  }
  return ''
}

/**
 * Set analytics acceptance cookie to true
 */
function acceptCookie () {
  acceptAnalytics(true)
}

/**
 * Set analytics acceptance cookie to false
 */
function rejectCookie () {
  acceptAnalytics(false)
}

/**
 * Toggle visibility of cookie banner in the UI
 * @param {boolean} bool
 */
function showBanner (bool) {
  var cookieBanner = document.querySelector('#cookie-banner')

  if (bool) {
    cookieBanner.setAttribute('style', 'display:block')
  } else {
    cookieBanner.setAttribute('style', 'display:none')
  }
}

/**
 * Set analytics cookie and if true load analytics
 * @param {boolean} bool
 */
function acceptAnalytics (bool) {
  var preferences = { analytics: bool }

  setCookie(HMLR_COOKIE_POLICY, JSON.stringify(preferences), COOKIE_DURATION)
  showBanner(false)

  if (bool) {
    loadAnalytics()
  }
}

/**
 * Code snip for initialising Google Tag Manager requires
 * gtag js.
 */
function loadAnalytics () {
  // do something
  window.dataLayer = window.dataLayer || []
  function gtag () {
    dataLayer.push(arguments)
  }
  gtag('js', new Date())
  gtag('config', 'UA-21165003-6', { anonymize_ip: true })
}
