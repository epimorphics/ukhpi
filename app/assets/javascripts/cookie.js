const HMLR_COOKIE_POLICY = 'hmlr_cookie_policy'
const COOKIE_DURATION = 365
const GA_TRACKING_ID = document.documentElement.dataset.gaId // passed from Rails to JS via Data Attributes
GA_TRACKING_ID !== undefined && delete document.documentElement.dataset.gaId // Remove the ga_id data attribute
const inProduction = document.documentElement.dataset.railsEnv === 'production'
inProduction !== undefined && delete document.documentElement.dataset.railsEnv // Remove the rails_env data attribute

/**
 * Retrieve user preferences cookie
 * @description This function checks if the user has already set their cookie preferences.
 * If the user has set their preferences, it checks if they have accepted analytics.
 * If the user has accepted analytics, it loads the analytics script.
 * If the user has not set their preferences, it shows the cookie banner.
 * The function is called when the window loads.
 */
window.onload = function () {
  const userPreferences = getCookie(HMLR_COOKIE_POLICY)
  if (userPreferences) {
    const analyticsAccepted = JSON.parse(userPreferences).analytics

    if (analyticsAccepted) {
      loadAnalytics(inProduction)
    }
  } else {
    showBanner(true)
  }
}

/**
 * Standard function for setting a cookie with an expiry length in days
 * @param {string} key
 * @param {string} value
 * @param {number} duration in days
 * @returns {void}
 * @description This function sets a cookie with the specified key, value, and duration.
 * It first creates a new Date object and sets its time to the current time plus the specified duration in milliseconds.
 * It then formats the expiration date to a UTC string.
 * Finally, it sets the cookie with the specified key and value, along with the expiration date and path.
 * The cookie is set to expire after the specified duration in days.
 */
function setCookie (key, value, duration) {
  const date = new Date()
  date.setTime(date.getTime() + duration * 24 * 60 * 60 * 1000)
  const expires = 'expires=' + date.toUTCString()
  document.cookie = key + '=' + value + ';' + expires + ';path=/'
}

/**
 * Retrieves a cookie's value by name
 * @param {string} name
 * @returns {string} the value of the cookie or an empty string if not found
 * @description This function retrieves the value of a cookie by its name.
 * It first decodes the cookie string and splits it into individual cookies.
 * It then iterates through the list of cookies and checks if the cookie name matches the specified name.
 * If a match is found, it returns the value of the cookie.
 * If no match is found, it returns an empty string.
 */
function getCookie (name) {
  const key = name + '='
  const decodedCookie = decodeURIComponent(document.cookie)
  const cookieList = decodedCookie.split(';')
  for (let i = 0; i < cookieList.length; i++) {
    let cookie = cookieList[i]
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
 * @returns {void}
 * @description This function sets the analytics acceptance cookie to true.
 * called from app/views/common/_cookie_banner.html.haml
 */
// eslint-disable-next-line no-unused-vars
function acceptCookie () {
  acceptAnalytics(true)
}

/**
 * Set analytics acceptance cookie to false
 * @returns {void}
 * @description This function sets the analytics acceptance cookie to false.
 * called from app/views/common/_cookie_banner.html.haml
 */
// eslint-disable-next-line no-unused-vars
function rejectCookie () {
  acceptAnalytics(false)
}

/**
 * Toggle visibility of cookie banner in the UI
 * @param {boolean} bool
 * @returns {void}
 * @description This function shows or hides the cookie banner based on the boolean value.
 * If the boolean value is true, the cookie banner is shown.
 * If the boolean value is false, the cookie banner is hidden.
 * The function uses the `setAttribute` method to set the display style of the cookie banner.
 * The cookie banner is identified by its ID 'cookie-banner'.
 */
function showBanner (bool) {
  const cookieBanner = document.getElementById('cookie-banner')
  if (!cookieBanner) return // If the cookie banner is not found, exit the function
  if (bool) {
    cookieBanner.setAttribute('style', 'display:block')
  } else {
    cookieBanner.setAttribute('style', 'display:none')
  }
}

/**
 * Set analytics cookie and if true load analytics
 * @param {boolean} bool
 * @returns {void}
 * @description This function sets the analytics cookie to the specified boolean value.
 * It also shows or hides the cookie banner based on the boolean value.
 * If the boolean value is true, it loads the analytics script.
 * If the boolean value is false, it does not load the analytics script.
 */
function acceptAnalytics (bool) {
  const preferences = { analytics: bool }

  setCookie(HMLR_COOKIE_POLICY, JSON.stringify(preferences), COOKIE_DURATION)
  showBanner(false)

  if (bool) {
    loadAnalytics(inProduction)
  }
}

/**
 * Load Google Analytics script asynchronously
 * @returns {Promise<void>}
 * @description This function loads the Google Analytics script asynchronously.
 * It creates a script element, sets its source to the Google Analytics URL,
 * and appends it to the document head.
 * It also handles errors that may occur during the loading process.
 * The function returns a promise that resolves when the script is loaded successfully.
 * If there is an error loading the script, the promise is rejected.
 * The script is loaded asynchronously to avoid blocking the rendering of the page.
 * The function also logs messages to the console to indicate the status of the script loading process.
 * The script is loaded from the Google Tag Manager URL with the specified tracking ID.
 */
function loadGoogleAnalyticsScript () {
  return new Promise((resolve, reject) => {
    // Create the script element for Google Analytics
    const script = document.createElement('script')
    script.async = true
    script.src = `https://www.googletagmanager.com/gtag/js?id=${GA_TRACKING_ID}`
    script.onerror = reject // Reject the promise if there is an error loading the script
    script.onload = resolve // Resolve the promise when the script is loaded
    document.head.appendChild(script) // Append the script to the document head if loaded successfully
    script.addEventListener('load', () => {
      !inProduction && console.log('Google Analytics script loaded successfully')
    })
    script.addEventListener('error', () => {
      console.error('Error loading Google Analytics script')
    })
  })
}

/**
* Function to send data to Google Analytics
* @param {...*} arguments - The arguments to be sent to Google Analytics.
* @description This function is used to send data to Google Analytics.
* It pushes the arguments to the dataLayer array, which is used by Google Tag Manager.
* It is defined as a global function so that it can be called from anywhere in the code.
*/
function gtag () {
  const dataLayer = window.dataLayer || []
  dataLayer.push(arguments)
}

/**
 * Code snip for initialising Google Tag Manager, requires gtag js.
 * @param {boolean} inProduction
 * @returns {Promise<void>}
 * @description This function loads the Google Analytics script and initializes Google Analytics.
 * It checks if the environment is production before loading the script.
 * If the environment is not production, it skips the initialization.
 * It also handles errors that may occur during the loading process.
 * Finally, it removes the `rails_env` data attribute from the document once loaded.
 */
const loadAnalytics = async (inProduction = false) => {
  try {
    // Check if the environment is production
    if (!inProduction) {
      console.log('Not in production, skipping Google Analytics initialization')
      console.debug('Google Analytics ID:', GA_TRACKING_ID)
      return
    }
    await loadGoogleAnalyticsScript() // Wait for GA script to load
    // Initialize Google Analytics
    gtag('js', new Date())
    gtag('config', GA_TRACKING_ID, { anonymize_ip: true })
  } catch (error) {
    console.error('Error loading Google Analytics:', error)
  }
}
