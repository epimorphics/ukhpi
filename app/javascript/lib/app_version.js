import Axios from 'axios'

/**
 * Get the current version of the application
 * @returns {Promise<string|null>} The current version of the application
 */
export default async function getAppVersion () {
  try {
    const response = await Axios.get('/version')
    console.debug(`Current Application Version: ${response.data.version}`)
    window.sessionStorage.setItem('currentAppRelease', response.data.version)
    return response.data.version
  } catch (error) {
    console.error('Failed to get current version', error)
    return null
  }
}
