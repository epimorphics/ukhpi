import Vue from 'vue';
import Vuex from 'vuex';
import * as types from './mutation-types';
import getUkhpiData from './server-comms';

Vue.use(Vuex);

const debug = process.env.NODE_ENV !== 'production';

/* Vuex's recommended style breaks an Airbnb eslint rule, so disable it for this file */
/* eslint-disable no-param-reassign, no-multi-spaces */

function updateQueryResults(state) {
  const userSelections = {
    location: state.location.uri,
    fromDate: state.fromDate,
    toDate: state.toDate,
  };

  getUkhpiData(userSelections);
}

export const mutations = {
  [types.INITIALISE](state, initialState) {
    state.location = initialState.location;
    state.fromDate = initialState.fromDate;
    state.toDate = initialState.toDate;

    updateQueryResults(state);
  },

  [types.SET_LOCATION](state, location) {
    state.location = location;
    updateQueryResults(state);
  },

  [types.SET_FROM_DATE](state, fromDate) {
    state.fromDate = fromDate;
    updateQueryResults(state);
  },

  [types.SET_TO_DATE](state, toDate) {
    state.toDate = toDate;
    updateQueryResults(state);
  },

  [types.SET_UKHPI_QUERY_RESULTS](state, queryResults) {
    state.queryResults = queryResults;
  },
};

export const getters = {
  initialised: state => !!state.location,
};

export const actions = {
};

export default new Vuex.Store({
  strict: debug,
  state: {
    location: null,
    fromDate: null,
    toDate: null,
    queryResults: null,
  },
  mutations,
  getters,
  actions,
});
