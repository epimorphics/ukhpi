/**
 * Helpers to save the current navigation state to the browser URL
 */

import _ from 'lodash';
import store from './index';
import { REINITIALISE } from './mutation-types';

/** Mappers from store state to navigation state */
const navigationStateFields = {
  location: state => ({ location: state.location && state.location.uri }),
};

/**
 * Given a key and value, serialise as a URL parameter. The wrinkle here is that
 * array-valued keys are serialised as `key[]=v0&key[]=v1`
 * @param  {[type]} key   [description]
 * @param  {[type]} value [description]
 * @return {[String]} Serialize key-value as URL param(s)
 */
function serialiseKeyValue(key, value) {
  if (_.isArray(value)) {
    const multiKey = encodeURIComponent(`${key}[]`);
    return value.map(v => `${multiKey}=${encodeURIComponent(v)}`).join('&');
  }

  return `${key}=${encodeURIComponent(value)}`;
}

function serialiseState(state) {
  return _.map(state, (value, key) => serialiseKeyValue(key, value)).join('&');
}

/**
 * Calculate an object representing the current navigation state
 * @return The current navigation state as an object
 */
function currentNavigationState(state) {
  const navState = _.pick(state, Object.keys(navigationStateFields));
  const serialState = {};

  _.forEach(state, (value, key) => {
    if (navigationStateFields[key]) {
      Object.assign(serialState, navigationStateFields[key](state));
    }
  });

  return {
    navState,
    url: `${window.location.pathname}?${serialiseState(serialState)}`,
  };
}

/**
 * Push the current navigation state onto the window history
 * @param  {[type]} state [description]
 * @return {[type]}       [description]
 */
export function pushNavigationState(state) {
  const { navState, url } = currentNavigationState(state);

  if (window.history && window.history.state !== navState) {
    window.history.pushState(navState, 'ukhpi navigation', url);
  }
}

/**
 * Handler user-initiated browser back event. Use the navigation state to
 * re-init the Vuex store.
 * @return {[type]} [description]
 */
function onPopState(event) {
  store.commit(REINITIALISE, event.state);
}

/**
 * Set up a handler for browser back events.
 * @return {[type]} [description]
 */
export function initialiseNavigationState() {
  window.onpopstate = onPopState;
}
