import Axios from 'axios'

/**
 * Get the current version of the application
 * @returns {Promise<string|null>} The current version of the application
 */
export default async function getAppVersion () {
  try {
    if (window.sessionStorage.getItem('currentAppRelease')) {
      return window.sessionStorage.getItem('currentAppRelease')
    }
    const response = await Axios.get('/version')
    const { version } = response.data
    console.debug(`Current Application Version: ${version}`)
    window.sessionStorage.setItem('currentAppRelease', version)
    return version
  } catch (error) {
    console.error('Failed to get current version', error)
    return null
  }
}
