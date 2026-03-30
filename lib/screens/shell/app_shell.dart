import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/design_tokens.dart';
import '../bundles/bundles_screen.dart';
import '../checkout/cart_screen.dart';
import '../home/home_screen.dart';
import '../my_esims/my_esims_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    BundlesScreen(),
    CartScreen(),
    MyEsimsScreen(),
  ];

  void _onTabSelected(int i) {
    if (i == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<TabSwitchNotification>(
      onNotification: (n) {
        _onTabSelected(n.index);
        return true;
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            animationDuration: const Duration(milliseconds: 400),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.public_outlined),
                selectedIcon: Icon(Icons.public),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Bundles',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.sim_card_outlined),
                selectedIcon: Icon(Icons.sim_card),
                label: 'My eSIMs',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
