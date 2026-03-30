import 'package:flutter/material.dart';

import '../../widgets/empty_state.dart';
import '../../widgets/gradient_header.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'Cart',
            subtitle: 'Review your selected plans',
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message:
                  'Browse plans or bundles and add\none to get started.',
              actionLabel: 'Browse Plans',
              onAction: () {
                TabSwitchNotification(0).dispatch(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TabSwitchNotification extends Notification {
  final int index;
  const TabSwitchNotification(this.index);
}
