import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_secret_notes/presentation/screens/screens.dart';
import 'package:flutter_secret_notes/presentation/providers/local_auth/local_auth_providers.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {

  final localAuthNotifier = ValueNotifier<LocalAuthStatus>(LocalAuthStatus.loading);

  ref
    ..onDispose(localAuthNotifier.dispose)
    ..listen(
      localAuthProvider,
      (_, next) {
        localAuthNotifier.value = next.status;
      },
    );

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
      final authState = ref.watch(localAuthProvider).status;

      // print(state.fullPath);

      if (authState == LocalAuthStatus.notAuthenticated) {
        // TODO: guardar Last Route
        return '/locked';
      }

      if (authState == LocalAuthStatus.authenticated && state.fullPath == '/locked') {
        // TODO: usar last route
        return '/home';
      }

      return null;
    },
  );
}

@riverpod
class LastRoute extends _$LastRoute {
  @override
  String build() {
    return '/home';
  }

  void changeValue(String newValue) {
    state = newValue;

    // At this point we can use any type of local storage to save the last
    // visited route so we can return straight there if the app finishes and
    // it is opened again.
  }
}