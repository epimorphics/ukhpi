import _ from 'lodash';
import { locations } from '../data/locations-data';

const locationsIndex = {
  country: {},
  la: {},
  region: {},
  county: {},
};

let indexInitialised = false;

/** Which inddex should this location go into? */
function locationIndexType(location) {
  const name = location.labels.en;

  switch (location.type) {
    case 'http://data.ordnancesurvey.co.uk/ontology/admingeo/EuropeanRegion':
      return (name === 'England' || name.match(/(wales|scotland|ireland)/i)) ? 'country' : 'region';

    case 'http://data.ordnancesurvey.co.uk/ontology/admingeo/County':
      return 'county';

    default:
      // assume all other types are synonyms for local authority
      return 'la';
  }
}

/** Create an inverted index of names to locations, that we can use in search */
function indexLocations() {
  _.each(Object.values(locations), (location) => {
    const name = location.labels.en;
    locationsIndex[locationIndexType(location)][name] = location;
  });
}

/** Ensure the index is updated, but set a flag so that the work is only done once */
function indexedLocations() {
  if (!indexInitialised) {
    indexLocations();
    indexInitialised = true;
  }

  return locationsIndex;
}

/** @return The types of location that we know about */
export function locationTypes() {
  return _.keys(locationsIndex);
}

/** @return The locations of a given type */
export function locationsOfType(locationType) {
  return indexedLocations()[locationType];
}

/** @return Locations whose name matches the given string */
export function locationsNamed(locationType, locationName) {
  const candidates = _.values(locationsOfType(locationType));
  const candidateNames = candidates.map(candidate => candidate.labels.en);
  const regex = new RegExp(locationName, 'i');
  return candidateNames.filter(name => name.match(regex));
}

/** @return the location matching the given name */
export function locationNamed(locationType, locationName) {
  return locationsOfType(locationType)[locationName];
}

/** @return The first feature to match the given location name */
export function findLocationNamed(locationName) {
  const matcher = new RegExp(locationName, 'i');
  let result = null;

  _.find(indexedLocations(), (typedLocations, locationType) =>
    _.find(typedLocations, (location) => {
      if (matcher.match(location.labels.en)) {
        result = { location, locationType };
      }
      return result;
    }));

  return result;
}
