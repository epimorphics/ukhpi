/*
  Copyright (c) 2012 Eric S. Theise
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to
* deal in the Software without restriction, including without limitation the
* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
* sell copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
* IN THE SOFTWARE.
*/

import L from 'leaflet';

L.Rrose = L.Popup.extend({

  /* eslint-disable no-underscore-dangle */
  _initLayout() {
    const prefix = 'leaflet-rrose';
    const container = L.DomUtil.create('div', `${prefix} ${this.options.className} leaflet-zoom-animated`);
    this.rrose = {};
    this._container = container;

    let closeButton;
    let wrapper;

    // Set the pixel distances from the map edges at which popups are too close and
    // need to be re-oriented.
    const xBound = 80;
    const yBound = 80;

    // Determine the alternate direction to pop up; north mimics Leaflet's
    // default behavior, so we initialize to that.
    this.options.position = 'n';

    // Then see if the point is too far north...
    const yDiff = yBound - this._map.latLngToContainerPoint(this._latlng).y;
    if (yDiff > 0) {
      this.options.position = 's';
    }
    // or too far east...
    let xDiff = this._map.latLngToContainerPoint(this._latlng).x -
      (this._map.getSize().x - xBound);
    if (xDiff > 0) {
      this.options.position += 'w';
    } else {
    // or too far west.
      xDiff = xBound - this._map.latLngToContainerPoint(this._latlng).x;
      if (xDiff > 0) {
        this.options.position += 'e';
      }
    }

    // Create the necessary DOM elements in the correct order. Pure 'n' and 's'
    // conditions need only one class for styling, others need two.
    if (/s/.test(this.options.position)) {
      this._tipContainer = L.DomUtil.create('div', `${prefix}-tip-container` +
        ` ${prefix}-tip-container-${this.options.position}`, container);
      wrapper = L.DomUtil.create('div', `${prefix}-content-wrapper` +
        ` ${prefix}-content-wrapper-${this.options.position}`, container);
      this._wrapper = wrapper;
    } else {
      wrapper = L.DomUtil.create('div', `${prefix}-content-wrapper` +
        ` ${prefix}-content-wrapper-${this.options.position}`, container);
      this._wrapper = wrapper;
      this._tipContainer = L.DomUtil.create('div', `${prefix}-tip-container` +
        ` ${prefix}-tip-container-${this.options.position}`, container);
    }

    this._tip = L.DomUtil.create('div', `${prefix}-tip` +
      ` ${prefix}-tip-${this.options.position}`, this._tipContainer);
    L.DomEvent.disableClickPropagation(wrapper);
    this._contentNode = L.DomUtil.create('div', `${prefix}-content`, wrapper);
    L.DomEvent.on(this._contentNode, 'mousewheel', L.DomEvent.stopPropagation);

    if (this.options.closeButton) {
      closeButton = L.DomUtil.create('a', `${prefix}-close-button`, this._wrapper);
      this._closeButton = closeButton;
      closeButton.href = '#close';
      closeButton.innerHTML = '&#215;';

      L.DomEvent.on(closeButton, 'click', this._onCloseButtonClick, this);
    }
  },

  _updatePosition() {
    const pos = this._map.latLngToLayerPoint(this._latlng);
    const is3d = L.Browser.any3d;
    const { offset } = this.options;

    if (is3d) {
      L.DomUtil.setPosition(this._container, pos);
    }

    if (/s/.test(this.options.position)) {
      this._containerBottom = (-this._container.offsetHeight + offset.y) -
        (is3d ? 0 : pos.y);
    } else {
      this._containerBottom = -offset.y - (is3d ? 0 : pos.y);
    }

    if (/e/.test(this.options.position)) {
      this._containerLeft = offset.x + (is3d ? 0 : pos.x);
    } else if (/w/.test(this.options.position)) {
      this._containerLeft = -Math.round(this._containerWidth) + offset.x +
        (is3d ? 0 : pos.x);
    } else {
      this._containerLeft = -Math.round(this._containerWidth / 2) +
        offset.x + (is3d ? 0 : pos.x);
    }

    this._container.style.bottom = `${this._containerBottom}px`;
    this._container.style.left = `${this._containerLeft}px`;
  },

});
