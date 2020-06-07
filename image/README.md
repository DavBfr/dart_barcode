# barcode_image

Barcode generation library for Dart that can generate barcodes using the [pub:image](https://pub.dev/packages/image) library.

Live example with Flutter Web: <https://davbfr.github.io/dart_barcode/>

---

[![Buy Me A Coffee](https://bmc-cdn.nyc3.digitaloceanspaces.com/BMC-button-images/custom_images/orange_img.png "Buy Me A Coffee")](https://www.buymeacoffee.com/JORBmbw9h "Buy Me A Coffee")

## Dart usage

```dart
// Create an image
final image = Image(300, 120);

// Fill it with a solid color (white)
fill(image, getColor(255, 255, 255));

// Draw the barcode
drawBarcode(image, Barcode.code128(), 'Test', font: arial_24);

// Save the image
File('test.png').writeAsBytesSync(encodePng(image));
```

<img alt="Barcode" src="https://raw.githubusercontent.com/DavBfr/dart_barcode/master/img/test.png">

## Command line usage

Install the `barcode` command

```shell
pub global activate barcode_image
```

run it

```shell
barcode
```

or

```shell
pub run barcode_image:barcode
```
