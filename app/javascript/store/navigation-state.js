/**
 * Helpers to save the current navigation state to the browser URL
 */

import _ from 'lodash';
import QueryString from 'query-string';
import Moment from 'moment';
import store from './index';
import { REINITIALISE } from './mutation-types';

/** Mappers from store state to navigation state */
const navigationStateFields = {
  location: state => ({ location: state.location.uri }),
  fromDate: state => ({ from: Moment(state.fromDate).format('YYYY-MM-DD') }),
  toDate: state => ({ to: Moment(state.toDate).format('YYYY-MM-DD') }),
  compareIndicator: state => ({ in: state.compareIndicator }),
  compareStatistic: state => ({ st: state.compareStatistic }),
  compareLocations: state => ({ location: state.compareLocations.map(location => location.gss) }),
};

/**
 * Calculate an object representing the current navigation state
 * @return The current navigation state as an object
 */
function currentNavigationState(state) {
  const navState = {}; // just the relevant parts of the Vuex state
  const urlState = {}; // relevant state variables translated to URL query string form

  _.forEach(state, (value, key) => {
    if (!_.isEmpty(value) && navigationStateFields[key]) {
      Object.assign(navState, { [key]: value });
      Object.assign(urlState, navigationStateFields[key](state));
    }
  });

  const queryStr = QueryString.stringify(urlState, { arrayFormat: 'bracket' });

  return {
    navState,
    url: `${window.location.pathname}?${queryStr}`,
  };
}

/**
 * Push the current navigation state onto the window history
 * @param  {[type]} state [description]
 * @return {[type]}       [description]
 */
export function pushNavigationState(state, replace = false) {
  const { navState, url } = currentNavigationState(state);

  if (window.history && !_.isEqual(window.history.state, navState)) {
    if (replace) {
      window.history.replaceState(navState, 'ukhpi navigation', url);
    } else {
      window.history.pushState(navState, 'ukhpi navigation', url);
    }
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
