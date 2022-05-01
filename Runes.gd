extends Node
class_name Runes

const VOWEL_LINES = [
    'TLOuter',
    'TROuter',
    'Left',
    'BLOuter',
    'BROuter',
]

const CONSONANT_LINES = [
    'Center',
    'TCenter',
    'BCenter',
    'TLInner',
    'TRInner',
    'BLInner',
    'BRInner',
]

const CONSONANTS = [
    {
        'display': 'k',
        'lines': [
            'TCenter',
            'Center',
            'TRInner',
            'BRInner',
        ],
    },
    {
        'display': 'r',
        'lines': [
            'TCenter',
            'Center',
            'BCenter', # MAYBE?
            'TRInner',
        ],
    },
    {
        'display': 's',
        'lines': [
            'TCenter',
            'Center',
            'BCenter',
            'TRInner',
            'BLInner',
        ],
    },
    {
        'display': 'p',
        'lines': [
            'Center',
            'BCenter', # MAYBE?
            'TRInner',
        ],
    },
    {
        'display': 'th',
        'lines': [
            'TCenter',
            'Center',
            'BCenter',
            'BLInner',
            'BRInner',
        ],
    },
    {
        'display': 'th',
        'lines': [
            'TCenter',
            'Center',
            'BCenter',
            'TLInner',
            'TRInner',
        ],
    },
    {
        'display': 'd',
        'lines': [
            'TCenter',
            'Center',
            'BLInner',
            'BRInner',
        ],
    },
    {
        'display': 'l',
        'lines': [
            'TCenter',
            'Center',
            'BCenter',
        ],
    },
    {
        'display': 'g',
        'lines': [
            'Center',
            'BCenter',
            'TRInner',
            'BRInner',
        ],
    },
    {
        'display': 'n',
        'lines': [
            'TLInner',
            'BLInner',
            'BRInner',
        ],
    },
    {
        'display': 't',
        'lines': [
            'Center',
            'BCenter',
            'TLInner',
            'TRInner',
        ],
    },
    {
        'display': 'm',
        'lines': [
            'BLInner',
            'BRInner',
        ],
    },
    {
        'display': 'f',
        'lines': [
            'TRInner',
            'Center',
            'BCenter',
            'BLInner',
        ],
    },
    {
        'display': 'w',
        'lines': [
            'TLInner',
            'TRInner',
        ],
    },
    {
        'display': 'b',
        'lines': [
            'TCenter',
            'Center',
            'BRInner',
        ],
    },
    {
        'display': 'v',
        'lines': [
            'TCenter',
            'Center',
            'BRInner',
            'TLInner',
        ],
    },
    {
        'display': 'h',
        'lines': [
            'TCenter',
            'Center',
            'BRInner',
            'BCenter',
        ],
    },
    {
        'display': 'tch',
        'lines': [
            'BCenter',
            'Center',
            'TLInner',
        ],
    },
    {
        'display': 'ng',
        'lines': [
            'TCenter',
            'Center',
            'BCenter',
            'TLInner',
            'TRInner',
            'BLInner',
            'BRInner',
        ],
    },
    {
        'display': 'dg',
        'lines': [
            'TCenter',
            'Center',
            'BLInner',
        ],
    },
    {
        'display': 'sh',
        'lines': [
            'Center',
            'BCenter',
            'TLInner',
            'TRInner',
            'BLInner',
            'BRInner',
        ],
    },
    {
        'display': 'dsh',
        'lines': [
            'TCenter',
            'Center',
            'TLInner',
            'TRInner',
            'BLInner',
            'BRInner',
        ],
    },
    {
        'display': 'y',
        'lines': [
            'TCenter',
            'Center',
            'BCenter',
            'TLInner',
        ],
    },
    {
        'display': 's',
        'lines': [
            'TCenter',
            'Center',
            'BCenter',
            'TLInner',
            'BRInner',
        ],
    },
]

const VOWELS = [
    {
        'display': 'uh',
        'lines': [
            'TLOuter',
            'TROuter'
        ],
    },
    {
        'display': 'a',
        'lines': [
            'TLOuter',
            'TROuter',
            'Left',
        ],
    },
    {
        'display': 'o',
        'lines': [
            'TLOuter',
            'Left',
        ],
    },
    {
        'display': 'e/i',
        'lines': [
            'BLOuter',
            'BROuter',
        ],
    },
    {
        'display': 'eh',
        'lines': [
            'Left',
            'BLOuter',
            'BROuter',
        ],
    },
    {
        'display': 'u',
        'lines': [
            'Left',
            'BLOuter',
        ],
    },
    {
        'display': 'ee',
        'lines': [
            'TLOuter',
            'Left',
            'BLOuter',
            'BROuter',
        ],
    },
    {
        'display': 'oo',
        'lines': [
            'TLOuter',
            'TROuter',
            'Left',
            'BLOuter',
        ],
    },
    {
        'display': 'er',
        'lines': [
            'TROuter',
            'Left',
            'BLOuter',
            'BROuter',
        ],
    },
    {
        'display': 'or',
        'lines': [
            'TLOuter',
            'TROuter',
            'Left',
            'BROuter',
        ],
    },
    {
        'display': 'ar',
        'lines': [
            'TLOuter',
            'TROuter',
            'BLOuter',
            'BROuter',
        ],
    },
    {
        'display': 'ere',
        'lines': [
            'TLOuter',
            'Left',
            'BROuter',
        ],
    },
    {
        'display': 'ere',
        'lines': [
            'Left',
            'BROuter',
        ],
    },
    {
        'display': 'ey',
        'lines': [
            'TLOuter',
        ],
    },
    {
        'display': 'i',
        'lines': [
            'TROuter',
        ],
    },
    {
        'display': 'oi',
        'lines': [
            'BLOuter',
        ],
    },
    {
        'display': 'ow',
        'lines': [
            'BROuter',
        ],
    },
    {
        'display': 'o',
        'lines': [
            'TLOuter',
            'TROuter',
            'Left',
            'BLOuter',
            'BROuter',
        ],
    },
]


class RuneParseResult:
    var vowel = null
    var consonant = null
    var vowel_unknown = false
    var consonant_unknown = false
    var swap = false

    func _to_string():
        var parts = []

        if consonant != null:
            parts.append(consonant.display)
        elif consonant_unknown:
            parts.append('?')

        if vowel != null:
            parts.append(vowel.display)
        elif vowel_unknown:
            parts.append('?')

        if swap:
            parts.invert()
        
        var string = ''
        for part in parts:
            string += part
        return string


static func parse(line_names):
    var consonant_lines = []
    var vowel_lines = []
    var swap = false
    var has_base = false

    for line in line_names:
        if line in CONSONANT_LINES:
            consonant_lines.append(line)
        elif line in VOWEL_LINES:
            vowel_lines.append(line)
        elif line == 'Swap':
            swap = true
        elif line == 'Base':
            has_base = true
        
    if !has_base:
        return null
    
    var result = RuneParseResult.new()

    if !consonant_lines.empty():
        result.consonant = _find_rune_in(CONSONANTS, consonant_lines)
        result.consonant_unknown = result.consonant == null
    if !vowel_lines.empty():
        result.vowel = _find_rune_in(VOWELS, vowel_lines)
        result.vowel_unknown = result.vowel == null
    
    if result.consonant == null && result.vowel == null:
        return null

    result.swap = swap
    return result


static func _find_rune_in(rune_set, line_names):
    for rune in rune_set:
        if rune.lines.size() == line_names.size():
            var all_match = true
            for line in rune.lines:
                if !line_names.has(line):
                    all_match = false
                    break
            
            if !all_match:
                continue
            
            return rune
    return null
            