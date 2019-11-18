import _ from 'lodash'
import { locations } from '../data/locations-data'

const locationsList = _.values(locations)

const locationsIndex = {
  country: {},
  la: {},
  region: {},
  county: {}
}

const exceptions = {
  'Sheffield City Region': 'Sheffield',
  'Liverpool City Region': 'Liverpool',
  'Tees Valley': null,
  'Cambridgeshire and Peterborough': null,
  'West of England': null,
  'Kingston upon Hull, City of': 'City of Kingston upon Hull',
  'Herefordshire, County of': 'Herefordshire',
  'Bristol, City of': 'City of Bristol',
  'Aberdeen City': 'City of Aberdeen',
  'Dundee City': 'City of Dundee',
  'Glasgow City': 'City of Glasgow',
  'Outline of Northern Ireland': 'Northern Ireland'
}

const UK_COUNTRIES = /(wales|scotland|ireland|great britain|united kingdom)/i

let indexInitialised = false

/** Which inddex should this location go into? */
export function locationIndexType (location) {
  const name = location.labels.en

  switch (location.type) {
    case 'http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion':
      return (name === 'England' || name.match(UK_COUNTRIES)) ? 'country' : 'region'

    case 'http://data.ordnancesurvey.co.uk/ontology/admingeo/County':
      return 'county'

    default:
      // assume all other types are synonyms for local authority
      return 'la'
  }
}

/** Create an inverted index of names to locations, that we can use in search */
function indexLocations () {
  _.each(Object.values(locations), (location) => {
    const name = location.labels.en
    locationsIndex[locationIndexType(location)][name] = location
  })
}

/** Ensure the index is updated, but set a flag so that the work is only done once */
function indexedLocations () {
  if (!indexInitialised) {
    indexLocations()
    indexInitialised = true
  }

  return locationsIndex
}

/** @return The types of location that we know about */
export function locationTypes () {
  return _.keys(locationsIndex)
}

/** @return The locations of a given type */
export function locationsOfType (locationType) {
  return indexedLocations()[locationType]
}

/** @return Locations whose name matches the given string */
export function locationsNamed (locationName) {
  if (!locationName || locationName.length <= 1) {
    return null
  }

  const regex = new RegExp(locationName, 'i')
  return locationsList.filter(location => location.labels.en.match(regex))
}

/** @return the location matching the given name */
export function locationNamed (locationName) {
  const matchedLocations = locationsNamed(locationName)
  return (matchedLocations && matchedLocations.length === 1) ? matchedLocations[0] : null
}

/** @return The first feature to match the given location name */
export function findLocationNamed (locationName) {
  const normalisedName = exceptions[locationName] || locationName
  const matcher = new RegExp(`^${normalisedName}$`, 'i')
  let result = null

  _.find(indexedLocations(), (typedLocations, locationType) =>
    _.find(typedLocations, (location) => {
      if (matcher.test(location.labels.en)) {
        result = { location, locationType }
      }
      return result
    }))

  return result
}

/** @return The first feature to match the given ID */
export function findLocationById (id, prop = 'gss') {
  let result = null

  _.find(indexedLocations(), (typedLocations, locationType) =>
    _.find(typedLocations, (location) => {
      if (location[prop] === id) {
        result = { location, locationType }
      }
      return result
    }))

  return result
}
