/*
 * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ignore_for_file: public_member_api_docs

class ReedSolomonEncoder {
  ReedSolomonEncoder(this.gf) {
    polynomes = <GFPoly>[
      GFPoly(gf, <int>[1])
    ];
  }

  GaloisField gf;
  List<GFPoly> polynomes;

  GFPoly getPolynomial(int degree) {
    if (degree >= polynomes.length) {
      var last = polynomes[polynomes.length - 1];
      for (var d = polynomes.length; d <= degree; d++) {
        final next =
            last.multiply(GFPoly(gf, <int>[1, gf.aLogTbl[d - 1 + gf.base]]));
        polynomes.add(next);
        last = next;
      }
    }
    return polynomes[degree];
  }

  List<int> encode(List<int> data, int eccCount) {
    final generator = getPolynomial(eccCount);
    var info = GFPoly(gf, data);
    info = info.multByMonominal(eccCount, 1);
    final remainder = info.divide(generator)[1];

    final result = List<int>.filled(eccCount, 0);
    final numZero = eccCount - remainder.coefficients.length;
    result.setAll(numZero, remainder.coefficients);
    return result;
  }
}

class GaloisField {
  // Creates a new galois field
  GaloisField(int pp, this.size, this.base) {
    aLogTbl = List<int>.filled(size, 0);
    logTbl = List<int>.filled(size, 0);

    var x = 1;
    for (var i = 0; i < size; i++) {
      aLogTbl[i] = x;
      x = x * 2;
      if (x >= size) {
        x = (x ^ pp) & (size - 1);
      }
    }

    for (var i = 0; i < size; i++) {
      logTbl[aLogTbl[i]] = i;
    }
  }

  int size;
  int base;
  List<int> aLogTbl;
  List<int> logTbl;

  GFPoly zero() {
    return GFPoly(this, <int>[0]);
  }

// AddOrSub add or substract two numbers
  int addOrSub(int a, int b) {
    return a ^ b;
  }

// Multiply multiplys two numbers
  int multiply(int a, int b) {
    if (a == 0 || b == 0) {
      return 0;
    }
    return aLogTbl[(logTbl[a] + logTbl[b]) % (size - 1)];
  }

// Divide divides two numbers
  int divide(int a, int b) {
    if (b == 0) {
      throw Exception('divide by zero');
    } else if (a == 0) {
      return 0;
    }
    return aLogTbl[(logTbl[a] - logTbl[b]) % (size - 1)];
  }

  int invers(int num) {
    return aLogTbl[(size - 1) - logTbl[num]];
  }
}

class GFPoly {
  GFPoly(this.gf, this.coefficients) {
    while (coefficients.length > 1 && coefficients[0] == 0) {
      coefficients = coefficients.sublist(1);
    }
  }

  factory GFPoly.monominalPoly(GaloisField field, int degree, int coeff) {
    if (coeff == 0) {
      return field.zero();
    }
    final result = List<int>.filled(degree + 1, 0);
    result[0] = coeff;
    return GFPoly(field, result);
  }

  GaloisField gf;
  List<int> coefficients;

  int getDegree() {
    return coefficients.length - 1;
  }

  bool zero() {
    return coefficients[0] == 0;
  }

  // returns the coefficient of x ^ degree
  int getCoefficient(int degree) {
    return coefficients[getDegree() - degree];
  }

  GFPoly addOrSubstract(GFPoly other) {
    if (zero()) {
      return other;
    } else if (other.zero()) {
      return this;
    }
    var smallCoeff = coefficients;
    var largeCoeff = other.coefficients;
    if (smallCoeff.length > largeCoeff.length) {
      final swap = largeCoeff;
      largeCoeff = smallCoeff;
      smallCoeff = swap;
    }
    final sumDiff = List<int>.filled(largeCoeff.length, 0);
    final lenDiff = largeCoeff.length - smallCoeff.length;
    sumDiff.setAll(0, largeCoeff.sublist(0, lenDiff));
    for (var i = lenDiff; i < largeCoeff.length; i++) {
      sumDiff[i] = gf.addOrSub(smallCoeff[i - lenDiff], largeCoeff[i]);
    }
    return GFPoly(gf, sumDiff);
  }

  GFPoly multByMonominal(int degree, int coeff) {
    if (coeff == 0) {
      return gf.zero();
    }
    final size = coefficients.length;
    final result = List<int>.filled(size + degree, 0);
    for (var i = 0; i < size; i++) {
      result[i] = gf.multiply(coefficients[i], coeff);
    }
    return GFPoly(gf, result);
  }

  GFPoly multiply(GFPoly other) {
    if (zero() || other.zero()) {
      return gf.zero();
    }
    final aCoeff = coefficients;
    final aLen = aCoeff.length;
    final bCoeff = other.coefficients;
    final bLen = bCoeff.length;
    final product = List<int>.filled(aLen + bLen - 1, 0);
    for (var i = 0; i < aLen; i++) {
      final ac = aCoeff[i];
      for (var j = 0; j < bLen; j++) {
        final bc = bCoeff[j];
        product[i + j] = gf.addOrSub(product[i + j], gf.multiply(ac, bc));
      }
    }
    return GFPoly(gf, product);
  }

  List<GFPoly> divide(GFPoly other) {
    var quotient = gf.zero();
    var remainder = this;
    final fld = gf;
    final denomLeadTerm = other.getCoefficient(other.getDegree());
    final inversDenomLeadTerm = fld.invers(denomLeadTerm);
    while (remainder.getDegree() >= other.getDegree() && !remainder.zero()) {
      final degreeDiff = remainder.getDegree() - other.getDegree();
      final scale = fld.multiply(
          remainder.getCoefficient(remainder.getDegree()), inversDenomLeadTerm);
      final term = other.multByMonominal(degreeDiff, scale);
      final itQuot = GFPoly.monominalPoly(fld, degreeDiff, scale);
      quotient = quotient.addOrSubstract(itQuot);
      remainder = remainder.addOrSubstract(term);
    }
    return <GFPoly>[quotient, remainder];
  }
}
