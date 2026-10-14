import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme/app_theme.dart';
import 'shell.dart';

class PaisaFlowBootstrap extends StatefulWidget {
  const PaisaFlowBootstrap({super.key});

  @override
  State<PaisaFlowBootstrap> createState() => _PaisaFlowBootstrapState();
}

class _PaisaFlowBootstrapState extends State<PaisaFlowBootstrap> {
  final store = AppStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          title: 'Paisa Flow',
          debugShowCheckedModeBanner: false,
          themeMode: store.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: store.isLoaded ? const AppShell() : const _Loading(),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
