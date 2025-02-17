import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secret_notes/config/router/app_router.dart';
import 'package:flutter_secret_notes/presentation/providers/providers.dart';

void main() => runApp(
      const ProviderScope(child: MyApp()),
    );

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize providers
    ref.read(permissionsProvider.notifier).checkPermissions();
    ref.read(notesProvider.notifier).loadCurrentPage();
    ref.read(lastVisitedNotesProvider.notifier).getLastVisitedNotes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.invalidate(localAuthProvider);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Secret Notes',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey
      ),
    );
  }
}
