/** @return True if we were able to set the given key/value pair in session storage */
export default function setSessionStore(key, value) {
  try {
    window.sessionStorage.setItem(key, value)
    return true
  } catch {
    // Storage unavailable or quota exceeded
    return false
  }
}
