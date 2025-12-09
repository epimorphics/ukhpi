import Vue from 'vue/dist/vue.esm'
import Router from 'vue-router'
import SingleLocation from '@/components/single-location.vue'
import CompareLocations from '@/components/compare-locations.vue'

Vue.use(Router)

// # This is a workaround to avoid the issue of Vue Router not being able to handle
// # relative URLs correctly when using Rails' asset pipeline.
const relativeUrlRoot = window.ukhpi.root_path || ''

export default new Router({
  routes: [
    {
      path: `${relativeUrlRoot}/browse`,
      name: 'single-location',
      component: SingleLocation,
    },
    {
      path: `${relativeUrlRoot}/compare`,
      name: 'compare-locations',
      component: CompareLocations,
    },
  ],
  mode: 'history',
})
