/** Communication with the back-end server after store updates */

import Axios from 'axios';
import store from './index';
import bus from '../lib/event-bus';
import Routes from '../lib/routes.js.erb';
import { SET_UKHPI_QUERY_RESULTS } from './mutation-types';
import QueryResults from '../models/query-results';
import setSessionStore from '../lib/session-store';

const QONSOLE_QUERY = 'qonsole.query';

/**
 * Report an error, both to the console and the global event bus
 */
function onError(error) {
  /* eslint-disable no-console */
  console.log('server notify failure');
  console.log(error);
  /* eslint-enable no-console */

  bus.$emit('server-notify-failure', error);
}

/** Get the query results from the server. @return The promise object */
function fetchQueryResults(userSelections) {
  return Axios.get(
    Routes.browsePath(),
    {
      params: userSelections,
      headers: {
        Accept: 'application/json',
      },
    },
  ).then((response) => {
    store.commit(SET_UKHPI_QUERY_RESULTS, new QueryResults(response.data));
  }).catch((error) => {
    onError(error);
  });
}

/** Get an explanation of the query from the server, and save it in the browser
 * session store for access by Qonsole.
 * @return The promise object */
function fetchQueryExplanation(userSelections) {
  return Axios.get(
    Routes.browsePath(),
    {
      params: Object.assign({ explain: true }, userSelections),
      headers: {
        Accept: 'application/json',
      },
    },
  ).then((response) => {
    setSessionStore(QONSOLE_QUERY, response.data.results.sparql);
  }).catch((error) => {
    onError(error);
  });
}

/**
 * Get the server data corresponding to an updated set of user selections
 * @param  {Object} userSelections Location and dates
 */
export default function getUkhpiData(userSelections, explain) {
  const promise = fetchQueryResults(userSelections);

  if (explain) {
    promise.then(() => {
      fetchQueryExplanation(userSelections);
    });
  }
}
