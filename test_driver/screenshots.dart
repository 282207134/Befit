import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  await integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (data) async {
      for (final image in data?['screenshots'] as List? ?? []) {
        final shot = image as Map<String, dynamic>;
        final file = File('docs/screenshots/${shot['screenshotName']}.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(List<int>.from(shot['bytes'] as List));
      }
    },
  );
}
