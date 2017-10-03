/* Handle events for components outside the Vue component tree */
/* eslint-disable no-param-reassign */

import bus from './event-bus';

function handleShowHideClick(event) {
  // notify Vue
  let node = event.target;
  while (!node.id) {
    node = node.parentElement;
  }

  const closing = node.classList.contains('o-data-view--open');
  bus.$emit('open-close-data-view', { id: node.id, closing });

  // don't follow the link
  if (event.preventDefault) {
    event.preventDefault();
  }

  return false;
}

function bindShowHideDataView() {
  document
    .querySelectorAll('.o-data-view__hide-action')
    .forEach((node) => {
      node.onclick = handleShowHideClick;
    });
}

export default function bindExternalEvents() {
  bindShowHideDataView();
}
