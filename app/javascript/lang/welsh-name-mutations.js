/**
 * A subset of Welsh consonant mutations where we assume we're
 * dealing with proper nouns, like months or locations.
 */

const MUTATIONS = {
  yn: [
    [/^B(.*)/, 'M$1', 'ym'],
    [/^P(.*)/, 'Mh$1', 'ym'],
    [/^G(.*)/, 'Ng$1', 'yng'],
    [/^T(.*)/, 'Nh$1', 'yn'],
    [/^C(.*)/, 'Ngh$1', 'yng'],
    [/^D(.*)/, 'N$1', 'yn'],
    [/^M(.*)/, 'M$1', 'ym']
  ],
  i: [
    [/^M(.*)/, 'F$1', 'i'],
    [/^G(.*)/, '$1', 'i'],
    [/^T(.*)/, 'D$1', 'i'],
    [/^Rh(.*)/, 'R$1', 'i'],
    [/^B(.*)/, 'F$1', 'i'],
    [/^C(.*)/, 'G$1', 'i'],
    [/^D(.*)/, 'Dd$1', 'i'],
    [/^Ll(.*)/, '$1', 'i'],
    [/^P(.*)/, 'B$1', 'i']
  ],
  o: [
    [/^M(.*)/, 'F$1', 'o'],
    [/^G(.*)/, '$1', 'o'],
    [/^T(.*)/, 'D$1', 'o'],
    [/^Rh(.*)/, 'R$1', 'o'],
    [/^B(.*)/, 'F$1', 'o'],
    [/^C(.*)/, 'G$1', 'o'],
    [/^D(.*)/, 'Dd$1', 'o'],
    [/^Ll(.*)/, '$1', 'o'],
    [/^P(.*)/, 'B$1', 'o']
  ]
}

function mutateWelshName (name, preposition) {
  return mutate(name, preposition, MUTATIONS[preposition] || [])
}

function mutate (name, preposition, mutations) {
  for (const rule of mutations) {
    if (name.match(rule[0])) {
      return {
        name:
          name
            .replace(rule[0], rule[1])
            .replace(/^\w/, char => char.toLocaleUpperCase()),
        preposition: rule[2]
      }
    }
  }

  return { name, preposition }
}

export function mutateName (name, preposition, locale) {
  if (locale !== 'cy') {
    return { name, preposition }
  }

  return mutateWelshName(name, preposition)
}
