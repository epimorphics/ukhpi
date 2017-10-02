/** Communication with the back-end server after store updates */

import Axios from 'axios';
import store from './index';
import bus from '../lib/event-bus';
import serverRoutes from './server-routes.js.erb';
import { SET_UKHPI_QUERY_RESULTS } from './mutation-types';
import QueryResults from '../models/query-results';

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

/**
 * Get the server data corresponding to an updated set of user selections
 * @param  {Object} userSelections Location and dates
 */
export default function getUkhpiData(userSelections) {
  Axios.get(
    serverRoutes.browsePath,
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
