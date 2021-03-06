import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import * as types from './mutation-types'
import getUkhpiData from './server-comms'
import { initialiseNavigationState, pushNavigationState } from './navigation-state'
import bus from '../lib/event-bus'

Vue.use(Vuex)

const debug = process.env.NODE_ENV !== 'production'

/* Vuex's recommended style breaks an Airbnb eslint rule, so disable it for this file */
/* eslint-disable no-param-reassign, no-multi-spaces */

function updateSingleLocationResults (state) {
  const query = {
    location: state.location.uri,
    from: state.fromDate,
    to: state.toDate
  }

  getUkhpiData(query, { explain: true, action: types.SET_UKHPI_QUERY_RESULTS })
}

function updateMultipleLocationResults (state) {
  const baseQuery = {
    from: state.fromDate,
    to: state.toDate
  }

  const baseOptions = {
    action: types.ADD_COMPARISON_RESULTS,
    explain: false
  }

  state.compareResults = {}

  return state.compareLocations.reduce((promise, location) => {
    const query = Object.assign({ location: location.uri }, baseQuery)
    const options = Object.assign({ locationGss: location.gss }, baseOptions)

    return promise.then(() => {
      getUkhpiData(query, options)
    })
  }, Promise.resolve())
    .then(() => {
      bus.$emit('compare-results-updated')
    })
}

function updateQueryResults (state) {
  const updateFn = state.location ? updateSingleLocationResults : updateMultipleLocationResults
  return updateFn(state)
}

export const mutations = {
  [types.INITIALISE] (state, initialState) {
    Object.assign(state, initialState)

    initialiseNavigationState()
    pushNavigationState(state, true)
    updateQueryResults(state)
  },

  [types.REINITIALISE] (state, initialState) {
    Object.assign(state, initialState)

    updateQueryResults(state)
  },

  [types.SET_LOCATION] (state, location) {
    state.location = location
    pushNavigationState(state)
    updateQueryResults(state)
  },

  [types.SET_DATES] (state, { from: fromDate, to: toDate }) {
    state.fromDate = fromDate
    state.toDate = toDate
    pushNavigationState(state)
    updateQueryResults(state)
  },

  [types.SET_UKHPI_QUERY_RESULTS] (state, queryResults) {
    state.queryResults = queryResults.results
  },

  [types.SELECT_STATISTIC] (state, stat) {
    state.selectedStatistics = Object.assign(
      {},
      state.selectedStatistics,
      { [stat.slug]: stat.isSelected }
    )
  },

  [types.SET_COMPARE_LOCATIONS] (state, locations) {
    state.compareLocations = locations
    pushNavigationState(state)
    updateQueryResults(state)
  },

  [types.SET_COMPARE_STATISTIC] (state, statistic) {
    state.compareStatistic = statistic
    pushNavigationState(state)
    updateQueryResults(state)
  },

  [types.SET_COMPARE_INDICATOR] (state, indicator) {
    state.compareIndicator = indicator
    pushNavigationState(state)
    updateQueryResults(state)
  },

  [types.ADD_COMPARISON_RESULTS] (state, results) {
    state.compareResults = Object.assign(
      {},
      state.compareResults,
      { [results.locationGss]: results.results }
    )
  }
}

export const getters = {
}

export const actions = {
}

export default new Vuex.Store({
  strict: debug,
  state: {
    location: null,
    fromDate: null,
    toDate: null,
    queryResults: null,
    selectedStatistics: {},
    compareLocations: [],
    compareStatistic: null,
    compareIndicator: null,
    compareResults: null
  },
  mutations,
  getters,
  actions
})
