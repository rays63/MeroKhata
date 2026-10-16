import 'package:flutter/material.dart';

import 'app/app.dart';

export 'app/app.dart' show PaisaFlowBootstrap;
export 'data/app_store.dart';
export 'data/import_parser.dart';
export 'data/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PaisaFlowBootstrap());
}
