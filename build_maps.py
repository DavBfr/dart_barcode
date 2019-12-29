#!/bin/env python3
# Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


def code39():
    C39 = {
        '0': '101001101101', '1': '110100101011', '2': '101100101011', '3': '110110010101',
        '4': '101001101011', '5': '110100110101', '6': '101100110101', '7': '101001011011',
        '8': '110100101101', '9': '101100101101', 'A': '110101001011', 'B': '101101001011',
        'C': '110110100101', 'D': '101011001011', 'E': '110101100101', 'F': '101101100101',
        'G': '101010011011', 'H': '110101001101', 'I': '101101001101', 'J': '101011001101',
        'K': '110101010011', 'L': '101101010011', 'M': '110110101001', 'N': '101011010011',
        'O': '110101101001', 'P': '101101101001', 'Q': '101010110011', 'R': '110101011001',
        'S': '101101011001', 'T': '101011011001', 'U': '110010101011', 'V': '100110101011',
        'W': '110011010101', 'X': '100101101011', 'Y': '110010110101', 'Z': '100110110101',
        '-': '100101011011', '.': '110010101101', ' ': '100110101101', '$': '100100100101',
        '/': '100100101001', '+': '100101001001', '%': '101001001001',
    }

    misc = {
        'StartStop': '100101101101',
    }

    print('/// Code 39 conversion bits')
    print('static const Map<int, int> code39 = <int, int>{')
    for k, v in C39.items():
        print(f'{hex(ord(k))}: {hex(int(v[::-1], 2))}, // {k}')
    print('};\n')

    print('/// Code 39 misc bits')
    for name in misc:
        print(
            f'static const int code39{name} = {hex(int(misc[name][::-1], 2))};')
    print(f'static const int code39Len = 13;')


def code93():
    C93 = {
        '0': '100010100',    '1': '101001000',    '2': '101000100',    '3': '101000010',    '4': '100101000',
        '5': '100100100',    '6': '100100010',    '7': '101010000',    '8': '100010010',    '9': '100001010',
        'A': '110101000',    'B': '110100100',    'C': '110100010',    'D': '110010100',    'E': '110010010',
        'F': '110001010',    'G': '101101000',    'H': '101100100',    'I': '101100010',    'J': '100110100',
        'K': '100011010',    'L': '101011000',    'M': '101001100',    'N': '101000110',    'O': '100101100',
        'P': '100010110',    'Q': '110110100',    'R': '110110010',    'S': '110101100',    'T': '110100110',
        'U': '110010110',    'V': '110011010',    'W': '101101100',    'X': '101100110',    'Y': '100110110',
        'Z': '100111010',    '-': '100101110',    '.': '111010100',    ' ': '111010010',    '$': '111001010',
        '/': '101101110',    '+': '101110110',    '%': '110101110',
    }

    misc = {
        'Dollar': '100100110',
        'Percent': '111011010',
        'Slash': '111010110',
        'Plus': '100110010',
        'StartStop': '101011110',
        'ReverseStop': '101111010',
    }

    print('/// Code 93 conversion bits')
    print('static const Map<int, int> code93 = <int, int>{')
    for k, v in C93.items():
        print(f'{hex(ord(k))}: {hex(int(v[::-1], 2))}, // {k}')
    i = -1
    for name in misc:
        print(f'{i}: code93{name},')
        i -= 1
    print('};\n')

    print('/// Code 93 misc bits')
    for name in misc:
        print(
            f'static const int code93{name} = {hex(int(misc[name][::-1], 2))};')
    print(f'static const int code93Len = 9;')


def code128():
    C128 = (
        (' ', ' ', '00', '11011001100',),    ('!', '!', '01', '11001101100',),
        ('"', '"', '02', '11001100110',),    ('#', '#', '03', '10010011000',),
        ('$', '$', '04', '10010001100',),    ('%', '%', '05', '10001001100',),
        ('&', '&', '06', '10011001000',),    (r"'", r"'", '07', '10011000100',),
        ('(', '(', '08', '10001100100',),    (')', ')', '09', '11001001000',),
        ('*', '*', '10', '11001000100',),    ('+', '+', '11', '11000100100',),
        (',', ',', '12', '10110011100',),    ('-', '-', '13', '10011011100',),
        ('.', '.', '14', '10011001110',),    ('/', '/', '15', '10111001100',),
        ('0', '0', '16', '10011101100',),    ('1', '1', '17', '10011100110',),
        ('2', '2', '18', '11001110010',),    ('3', '3', '19', '11001011100',),
        ('4', '4', '20', '11001001110',),    ('5', '5', '21', '11011100100',),
        ('6', '6', '22', '11001110100',),    ('7', '7', '23', '11101101110',),
        ('8', '8', '24', '11101001100',),    ('9', '9', '25', '11100101100',),
        (':', ':', '26', '11100100110',),    (';', ';', '27', '11101100100',),
        ('<', '<', '28', '11100110100',),    ('=', '=', '29', '11100110010',),
        ('>', '>', '30', '11011011000',),    ('?', '?', '31', '11011000110',),
        ('@', '@', '32', '11000110110',),    ('A', 'A', '33', '10100011000',),
        ('B', 'B', '34', '10001011000',),    ('C', 'C', '35', '10001000110',),
        ('D', 'D', '36', '10110001000',),    ('E', 'E', '37', '10001101000',),
        ('F', 'F', '38', '10001100010',),    ('G', 'G', '39', '11010001000',),
        ('H', 'H', '40', '11000101000',),    ('I', 'I', '41', '11000100010',),
        ('J', 'J', '42', '10110111000',),    ('K', 'K', '43', '10110001110',),
        ('L', 'L', '44', '10001101110',),    ('M', 'M', '45', '10111011000',),
        ('N', 'N', '46', '10111000110',),    ('O', 'O', '47', '10001110110',),
        ('P', 'P', '48', '11101110110',),    ('Q', 'Q', '49', '11010001110',),
        ('R', 'R', '50', '11000101110',),    ('S', 'S', '51', '11011101000',),
        ('T', 'T', '52', '11011100010',),    ('U', 'U', '53', '11011101110',),
        ('V', 'V', '54', '11101011000',),    ('W', 'W', '55', '11101000110',),
        ('X', 'X', '56', '11100010110',),    ('Y', 'Y', '57', '11101101000',),
        ('Z', 'Z', '58', '11101100010',),    ('[', '[', '59', '11100011010',),
        ('\\', '\\', '60', '11101111010',),  (']', ']', '61', '11001000010',),
        ('^', '^', '62', '11110001010',),    ('_', '_', '63', '10100110000',),
        ('NUL', '`', '64', '10100001100',),  ('SOH', 'a', '65', '10010110000',),
        ('STX', 'b', '66', '10010000110',),  ('ETX', 'c', '67', '10000101100',),
        ('EOT', 'd', '68', '10000100110',),  ('ENQ', 'e', '69', '10110010000',),
        ('ACK', 'f', '70', '10110000100',),  ('BEL', 'g', '71', '10011010000',),
        ('BS', 'h', '72', '10011000010',),   ('HT', 'i', '73', '10000110100',),
        ('LF', 'j', '74', '10000110010',),   ('VT', 'k', '75', '11000010010',),
        ('FF', 'l', '76', '11001010000',),   ('CR', 'm', '77', '11110111010',),
        ('SO', 'n', '78', '11000010100',),   ('SI', 'o', '79', '10001111010',),
        ('DLE', 'p', '80', '10100111100',),  ('DC1', 'q', '81', '10010111100',),
        ('DC2', 'r', '82', '10010011110',),  ('DC3', 's', '83', '10111100100',),
        ('DC4', 't', '84', '10011110100',),  ('NAK', 'u', '85', '10011110010',),
        ('SYN', 'v', '86', '11110100100',),  ('ETB', 'w', '87', '11110010100',),
        ('CAN', 'x', '88', '11110010010',),  ('EM', 'y', '89', '11011011110',),
        ('SUB', 'z', '90', '11011110110',),
        ('ESC', '{', '91', '11110110110',),
        ('FS', '|', '92', '10101111000',),    ('GS', '}', '93', '10100011110',),
        ('RS', '~', '94', '10001011110',),    ('US', 'DEL', '95', '10111101000',),
        ('FNC3', 'FNC3', '96', '10111100010',),
        ('FNC2', 'FNC2', '97', '11110101000',),
        ('ShiftB', 'ShiftA', '98', '11110100010',),
        ('CodeC', 'CodeC', '99', '10111011110',),
        ('CodeB', 'FNC4', 'CodeB', '10111101110',),
        ('FNC4', 'CodeA', 'CodeA', '11101011110', 	),
        ('FNC1', 'FNC1', 'FNC1', '11110101110',),
    )

    misc = {
        'StartCodeA': '11010000100',
        'StartCodeB': '11010010000',
        'StartCodeC': '11010011100',
        'Stop': '11000111010',
        'ReverseStop': '11010111000',
        'StopPattern': '1100011101011',
    }

    names = {
        'NUL': 0x00,
        'SOH': 0x01,
        'STX': 0x02,
        'ETX': 0x03,
        'EOT': 0x04,
        'ENQ': 0x05,
        'ACK': 0x06,
        'BEL': 0x07,
        'BS': 0x08,
        'HT': 0x09,
        'LF': 0x0A,
        'VT': 0x0B,
        'FF': 0x0C,
        'CR': 0x0D,
        'SO': 0x0E,
        'SI': 0x0F,
        'DLE': 0x10,
        'DC1': 0x11,
        'DC2': 0x12,
        'DC3': 0x13,
        'DC4': 0x14,
        'NAK': 0x15,
        'SYN': 0x16,
        'ETB': 0x17,
        'CAN': 0x18,
        'EM': 0x19,
        'SUB': 0x1A,
        'ESC': 0x1B,
        'FS': 0x1C,
        'GS': 0x1D,
        'RS': 0x1E,
        'US': 0x1F,
        'DEL': 0x7F,
        'FNC1': -1,
        'FNC2': -2,
        'FNC3': -3,
        'FNC4': -4,
        'ShiftA': -5,
        'ShiftB': -6,
        'CodeA': -7,
        'CodeB': -8,
        'CodeC': -9,
    }

    print('/// Code 128 A')
    print('static const Map<int, int> code128A = <int, int>{')
    i = 0
    for a, b, c, v in C128:
        r = ord(a) if len(a) == 1 else names[a]
        if r >= 0:
            print(f'{hex(r)}: {hex(i)}, // {a}')
        else:
            print(f'code128{a}: {hex(i)}, // {a}')
        i += 1
    print('};\n')

    print('/// Code 128 B')
    print('static const Map<int, int> code128B = <int, int>{')
    i = 0
    for a, b, c, v in C128:
        r = ord(b) if len(b) == 1 else names[b]
        if r >= 0:
            print(f'{hex(r)}: {hex(i)}, // {b}')
        else:
            print(f'code128{b}: {hex(i)}, // {b}')
        i += 1
    print('};\n')

    print('/// Code 128 C')
    print('static const Map<int, int> code128C = <int, int>{')
    i = 0
    for a, b, c, v in C128:
        r = int(c) if len(c) == 2 else names[c]
        if r >= 0:
            print(f'{hex(r)}: {hex(i)}, // {c}')
        else:
            print(f'code128{c}: {hex(i)}, // {c}')
        i += 1
    print('};\n')

    print('/// Code 128 conversion bits')
    print('static const Map<int, int> code128 = <int, int>{')
    i = 0
    for a, b, c, v in C128:
        print(f'{hex(i)}: {hex(int(v[::-1], 2))}, // {a} | {b} | {c}')
        i += 1
    for name in misc:
        print(f'code128{name}: {hex(int(misc[name][::-1], 2))},')
    print('};\n')

    print('/// Code 128 misc bits')
    for name in misc:
        print(f'static const int code128{name} = {hex(i)};')
        i += 1
    for name in names:
        if names[name] < 0:
            print(f'static const int code128{name} = {names[name]};')
    print(f'static const int code128Len = 11;')


def ean13():
    misc = {
        'StartEnd': '101',
        'Center': '01010',
        'EndUpcE': '010101',
    }

    digits = (
        # Digit, L-code, G-code ,R-code
        ('0', '0001101', '0100111', '1110010'),
        ('1', '0011001', '0110011', '1100110'),
        ('2', '0010011', '0011011', '1101100'),
        ('3', '0111101', '0100001', '1000010'),
        ('4', '0100011', '0011101', '1011100'),
        ('5', '0110001', '0111001', '1001110'),
        ('6', '0101111', '0000101', '1010000'),
        ('7', '0111011', '0010001', '1000100'),
        ('8', '0110111', '0001001', '1001000'),
        ('9', '0001011', '0010111', '1110100'),
    )

    first = (
        # First digit, First group of 6 digits, Last group of 6 digits
        ('0', 'LLLLLL', 'RRRRRR'),
        ('1', 'LLGLGG', 'RRRRRR'),
        ('2', 'LLGGLG', 'RRRRRR'),
        ('3', 'LLGGGL', 'RRRRRR'),
        ('4', 'LGLLGG', 'RRRRRR'),
        ('5', 'LGGLLG', 'RRRRRR'),
        ('6', 'LGGGLL', 'RRRRRR'),
        ('7', 'LGLGLG', 'RRRRRR'),
        ('8', 'LGLGGL', 'RRRRRR'),
        ('9', 'LGGLGL', 'RRRRRR'),
    )

    upce = (
        ('0', 'EEEOOO', 'OOOEEE'),
        ('1', 'EEOEOO', 'OOEOEE'),
        ('2', 'EEOOEO', 'OOEEOE'),
        ('3', 'EEOOOE', 'OOEEEO'),
        ('4', 'EOEEOO', 'OEOOEE'),
        ('5', 'EOOEEO', 'OEEOOE'),
        ('6', 'EOOOEE', 'OEEEOO'),
        ('7', 'EOEOEO', 'OEOEOE'),
        ('8', 'EOEOOE', 'OEOEEO'),
        ('9', 'EOOEOE', 'OEEOEO '),
    )

    print('/// EAN 13 conversion bits')
    print('static const Map<int, List<int>> ean = <int, List<int>>{')
    for d, l, g, r in digits:
        print(
            f'{hex(ord(d))}: <int>[{hex(int(l[::-1], 2))}, {hex(int(g[::-1], 2))}, {hex(int(r[::-1], 2))}],')
    print('};\n')

    print('/// EAN 13 first digit')
    print('static const Map<int, int> eanFirst = <int, int>{')
    for d, f, s in first:
        v = 0
        i = 0
        for k in f:
            v += 1 << i if k == 'G' else 0
            i += 1
        print(f'{hex(ord(d))}: {hex(v)}, // {f}')
    print('};\n')

    print('/// UPC-A to UPC-E conversion')
    print('static const Map<int, int> upce = <int, int>{')
    for d, f, s in upce:
        v = 0
        i = 0
        for k in f:
            v += 1 << i if k == 'O' else 0
            i += 1
        print(f'{hex(ord(d))}: {hex(v)}, // {f} | {s}')
    print('};\n')

    print('/// EAN misc bits')
    for name in misc:
        print(f'static const int ean{name} = {hex(int(misc[name][::-1], 2))};')


if __name__ == '__main__':
    print('/*')
    print(' * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>')
    print(' *')
    print(' * Licensed under the Apache License, Version 2.0 (the "License");')
    print(' * you may not use this file except in compliance with the License.')
    print(' * You may obtain a copy of the License at')
    print(' *')
    print(' *     http://www.apache.org/licenses/LICENSE-2.0')
    print(' *')
    print(' * Unless required by applicable law or agreed to in writing, software')
    print(' * distributed under the License is distributed on an "AS IS" BASIS,')
    print(' * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.')
    print(' * See the License for the specific language governing permissions and')
    print(' * limitations under the License.')
    print(' */')
    print('')
    print('// ignore_for_file: omit_local_variable_types')
    print('')
    print('class BarcodeMaps {')

    code39()
    code93()
    code128()
    ean13()

    print('}')
