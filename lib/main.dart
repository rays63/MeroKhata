import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';

export 'app/app.dart' show PaisaFlowBootstrap;
export 'data/app_store.dart';
export 'data/import_parser.dart';
export 'data/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Phone portrait only; layouts aren't designed for landscape.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PaisaFlowBootstrap());
}
