/**
 * A simple global events bus. To use:
 *
 * ```
 * import bus from '../lib/event-bus';
 * ...
 * bus.$emit(eventType, eventArg)
 * ```
 */

import Vue from 'vue/dist/vue.esm'

const bus = new Vue()
export default bus
