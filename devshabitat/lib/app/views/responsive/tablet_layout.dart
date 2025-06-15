import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';

class TabletLayout extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? navigationRail;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const TabletLayout({
    Key? key,
    required this.child,
    this.appBar,
    this.navigationRail,
    this.floatingActionButton,
    this.backgroundColor,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExtended = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              extended: isExtended,
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: Theme.of(context).colorScheme.surface,
              useIndicator: true,
              indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              selectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              unselectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: Padding(
                padding: ResponsiveHelper.getAdaptivePadding(context),
                child: child,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
    );
  }
}
