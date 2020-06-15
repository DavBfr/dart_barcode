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

/// Supported barcode types
enum BarcodeType {
  /// ITF14 Barcode
  CodeITF14,

  /// EAN 13 barcode
  CodeEAN13,

  /// EAN 8 barcode
  CodeEAN8,

  /// EAN 5 barcode
  CodeEAN5,

  /// EAN 2 barcode
  CodeEAN2,

  /// ISBN barcode
  CodeISBN,

  /// Code 39 barcode
  Code39,

  /// Code 93 barcode
  Code93,

  /// UPC-A barcode
  CodeUPCA,

  /// UPC-E barcode
  CodeUPCE,

  /// Code 128 barcode
  Code128,

  /// GS1-128 barcode
  GS128,

  /// Telepen Barcode
  Telepen,

  /// QR Code
  QrCode,

  /// Codabar
  Codabar,

  /// Pdf417
  PDF417,

  /// Datamatrix
  DataMatrix,

  /// Aztec
  Aztec,

  /// RM4SCC
  Rm4scc,

  /// Interleaved 2 of 5 (ITF)
  Itf,
}
