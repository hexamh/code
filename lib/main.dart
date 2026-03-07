import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/app/router.dart';
import 'package:myapp/app/theme.dart';
import 'package:myapp/domain/syntax/language_registry.dart';
import 'package:myapp/presentation/providers/settings_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the highlight language registry once at startup.
  LanguageRegistry.initialize();

  runApp(
    const ProviderScope(
      child: CodeEditorApp(),
    ),
  );
}

class CodeEditorApp extends ConsumerWidget {
  const CodeEditorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Code Editor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
