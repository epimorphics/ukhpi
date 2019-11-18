/** Meta-knowledge that we have about the UKHPI data cube. Includes:
 * * which combinations of indicators and statistics are not available
 */
import _ from 'lodash'

const unavailableStatInd = [
  { statistic: 'det', indicator: 'vol' },
  { statistic: 'sem', indicator: 'vol' },
  { statistic: 'ter', indicator: 'vol' },
  { statistic: 'fla', indicator: 'vol' },
  { statistic: 'ftb', indicator: 'vol' },
  { statistic: 'foo', indicator: 'vol' }
]

/**
 * Return true if the given combination of statistic and indicator is not available
 * @param  {String} stat Statistic slug
 * @param  {String} ind  Indicator slug
 * @return {Boolean}      True if indicator+statistic combination is not available
 */
export default function unavailable (stat, ind) {
  return !!_.find(unavailableStatInd, { statistic: stat, indicator: ind })
}
