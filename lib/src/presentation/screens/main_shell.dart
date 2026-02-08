/// NYAnime Mobile - Main Shell
///
/// Main app shell with bottom navigation bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/watchlist')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Sync nav index with current route
    final routeIndex = _calculateSelectedIndex(context);
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    // Keep index in sync with route
    if (selectedIndex != routeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedNavIndexProvider.notifier).state = routeIndex;
      });
    }

    return Scaffold(
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: routeIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          ref.read(selectedNavIndexProvider.notifier).state = index;

          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/watchlist');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
