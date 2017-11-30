/* Handle events for components outside the Vue component tree */
/* eslint-disable no-param-reassign */

import bus from './event-bus';

/** Prevent default behaviour of event, with support for IE which just has to be different! */
function eventPreventDefault(event) {
  if (event.preventDefault) {
    event.preventDefault();
  } else {
    event.returnValue = false;
  }
}

/**
 * Call forEach in a way that doesn't blow up IE11
 * This weirdness with slice is because IE11 doesn't do forEach on the return
 * value from querySelectorAll. See:
 * https://stackoverflow.com/questions/412447/for-each-javascript-support-in-ie
 */
function ieSafeForEach(nodes, fn) {
  [].slice.call(nodes).forEach(fn);
}

function handleShowHideClick(event) {
  eventPreventDefault(event);
  // notify Vue
  let node = event.target;
  while (!node.id) {
    node = node.parentElement;
  }

  const closing = node.classList.contains('o-data-view--open');
  bus.$emit('open-close-data-view', { id: node.id, closing });

  return false;
}

function bindShowHideDataView() {
  const nodes = document.querySelectorAll('.o-data-view__hide-action');

  // this weirdness with slice is because IE11 doesn't do forEach on the return
  // value from querySelectorAll
  ieSafeForEach(nodes, (node) => {
    node.removeEventListener('click');
    node.addEventListener('click', handleShowHideClick, false);
  });
}

function handleLocationClick(event) {
  // notify Vue
  bus.$emit('change-location');

  eventPreventDefault(event);
  return false;
}

function bindChangeLocationLink() {
  const nodes = document.querySelectorAll('.o-data-view__location');

  ieSafeForEach(nodes, (node) => {
    node.removeEventListener('click');
    node.addEventListener('click', handleLocationClick, false);
  });
}

export default function bindExternalEvents() {
  bindShowHideDataView();
  bindChangeLocationLink();
}
