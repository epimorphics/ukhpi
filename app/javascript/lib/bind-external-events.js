/* Handle events for components outside the Vue component tree */
/* eslint-disable no-param-reassign */

import bus from './event-bus'
import safeForEach from './safe-foreach'

/** Prevent default behaviour of event, with support for IE which just has to be different! */
function eventPreventDefault (event) {
  if (event.preventDefault) {
    event.preventDefault()
  } else {
    event.returnValue = false
  }
}

function handleShowHideClick (event) {
  eventPreventDefault(event)
  // notify Vue
  let node = event.target
  while (!node.id) {
    node = node.parentElement
  }

  const closing = node.classList.contains('o-data-view--open')
  bus.$emit('open-close-data-view', { id: node.id, closing })

  return false
}

function bindShowHideDataView () {
  const nodes = document.querySelectorAll('.o-data-view__hide-action')

  // this weirdness with slice is because IE11 doesn't do forEach on the return
  // value from querySelectorAll
  safeForEach(nodes, (node) => {
    node.setAttribute('href', '#')
    node.addEventListener('click', handleShowHideClick, false)
  })
}

function handleLocationClick (event) {
  // notify Vue
  bus.$emit('change-location')

  eventPreventDefault(event)
  return false
}

function bindChangeLocationLink () {
  const nodes = document.querySelectorAll('.o-data-view__location')

  safeForEach(nodes, (node) => {
    node.setAttribute('href', '#')
    node.addEventListener('click', handleLocationClick, false)
  })
}

export default function bindExternalEvents () {
  bindShowHideDataView()
  bindChangeLocationLink()
}
