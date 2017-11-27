/** @return True if the window or session store is available */
function storageAvailable(type) {
  try {
    const storage = window[type];
    const x = '__storage_test__';
    storage.setItem(x, x);
    storage.removeItem(x);
    return true;
  } catch (e) {
    return false;
  }
}

/** @return True if we were able to set the given key/value pair in session storage */
export default function setSessionStore(key, value) {
  if (storageAvailable('sessionStorage')) {
    window.sessionStorage.setItem(key, value);
    return true;
  }
  return false;
}
