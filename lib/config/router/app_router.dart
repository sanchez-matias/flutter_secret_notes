import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_secret_notes/presentation/screens/screens.dart';
import 'package:flutter_secret_notes/presentation/providers/local_auth/local_auth_providers.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {

  final localAuthNotifier = ValueNotifier<LocalAuthStatus>(LocalAuthStatus.notAuthenticated);
  final lastRoute = ValueNotifier<String>('/home');

  ref
    ..onDispose(localAuthNotifier.dispose)
    ..listen(
      localAuthProvider,
      (previous, next) {
        if (previous == next) return;
        localAuthNotifier.value = next.status;
    });

  return GoRouter(
    initialLocation: '/locked',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'note/:id',
            builder: (context, state) {
              final param = state.pathParameters['id'];
              if (param == null) return const NoteScreen(noteId: -1);

              return NoteScreen(noteId: int.parse(param));
            },
          ),

          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/locked',
        builder: (context, state) => const LockedScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) => '/locked',
      ),
    ],

    refreshListenable: localAuthNotifier,
    redirect: (context, state) {
      final authState = localAuthNotifier.value;

      // print('Path: ${state.uri.path}');
      // print('Last Route: ${lastRoute.value}');
      // print('-----------------------');

      if (authState == LocalAuthStatus.notAuthenticated) {
        return '/locked';
      }

      if (authState == LocalAuthStatus.authenticated && state.fullPath == '/locked') {
        return lastRoute.value;
      }

      lastRoute.value = state.uri.path;
      return null;
    },
  );
}
