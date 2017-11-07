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
    from: state.fromDate,
    to: state.toDate,
  };

  getUkhpiData(userSelections, true);
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

  [types.SET_DATES](state, { from: fromDate, to: toDate }) {
    state.fromDate = fromDate;
    state.toDate = toDate;
    updateQueryResults(state);
  },

  [types.SET_UKHPI_QUERY_RESULTS](state, queryResults) {
    state.queryResults = queryResults;
  },

  [types.SELECT_STATISTIC](state, stat) {
    Vue.set(state.selectedStatistics, stat.slug, stat.selected);
  },
};

export const getters = {
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
    selectedStatistics: {},
  },
  mutations,
  getters,
  actions,
});
