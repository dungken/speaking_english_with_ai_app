import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/responsive_layout.dart';

/// A section displaying quick access items in a grid layout.
/// This component provides rapid navigation to frequently used features.
///
/// Implements a responsive grid that adapts based on screen size and orientation
/// to maintain an optimal user experience across different devices.
class QuickAccessSection extends StatelessWidget {
  final bool isDarkMode;

  const QuickAccessSection({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleSize = ResponsiveLayout.getTitleTextSize(context);

    return Column(
      children: [
        _buildSectionHeader(context, titleSize),
        SizedBox(height: ResponsiveLayout.getSpacing(context)),
        _buildQuickAccessGrid(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, double titleSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
        TextButton.icon(
          onPressed: () => context.push('/quick-access'),
          icon: Icon(
            Icons.grid_view_rounded,
            size: 16,
            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
          ),
          label: Text(
            'See All',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    // Determine grid parameters based on screen size and orientation
    final orientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size;
    final screenType = ResponsiveLayout.getScreenType(context);

    // Determine optimal number of columns based on screen type
    int columns;
    if (orientation == Orientation.portrait) {
      // Portrait mode columns
      columns =
          screenType == ScreenType.extraSmall || screenType == ScreenType.small
              ? 3 // Smaller phones show 3 columns
              : 4; // Larger phones show 4 columns
    } else {
      // Landscape mode columns
      columns = screenType == ScreenType.tablet
          ? 8 // Tablets can show more columns
          : 6; // Phones in landscape show 6 columns
    }

    // Calculate spacing based on screen size
    final spacing = ResponsiveLayout.getSpacing(context);

    // Quick access items to display
    final quickAccessItems = [
      _QuickAccessData(
        icon: Icons.book_rounded,
        label: 'Dictionary',
        route: '/dictionary',
      ),
      _QuickAccessData(
        icon: Icons.emoji_events_rounded,
        label: 'Achievements',
        route: '/achievements',
      ),
      _QuickAccessData(
        icon: Icons.flag_rounded,
        label: 'Set Goals',
        route: '/goals',
      ),
      _QuickAccessData(
        icon: Icons.history_rounded,
        label: 'History',
        route: '/history',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal child aspect ratio based on available width
        final calculatedAspectRatio = _calculateAspectRatio(
          constraints.maxWidth,
          columns,
          spacing,
        );

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: calculatedAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickAccessItems.length,
          itemBuilder: (context, index) {
            final item = quickAccessItems[index];
            return _buildQuickAccessItem(
              context,
              icon: item.icon,
              label: item.label,
              route: item.route,
            );
          },
        );
      },
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    // Adjust icon and text sizes based on screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = ResponsiveLayout.getScreenType(context);

    // Adjust icon container size based on screen width
    final iconContainerSize = screenType == ScreenType.extraSmall
        ? 32.0
        : screenType == ScreenType.small
            ? 36.0
            : 40.0;

    // Adjust icon size based on container
    final iconSize = iconContainerSize * 0.5;

    // Smaller text on smaller screens
    final fontSize = screenType == ScreenType.extraSmall
        ? 10.0
        : screenType == ScreenType.small
            ? 11.0
            : 12.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color:
                      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculate the optimal aspect ratio based on available width
  double _calculateAspectRatio(
    double availableWidth,
    int columns,
    double spacing, {
    double defaultRatio = 0.85,
  }) {
    // Calculate item width
    final totalSpacing = spacing * (columns - 1);
    final itemWidth = (availableWidth - totalSpacing) / columns;

    // For very small items, make them more square
    if (itemWidth < 80) {
      return 1.0;
    }
    // For small items, reduce height slightly
    else if (itemWidth < 100) {
      return 0.95;
    }
    // For medium items, use default ratio
    else if (itemWidth < 120) {
      return defaultRatio;
    }
    // For larger items, make them more rectangular
    else {
      return 0.75;
    }
  }
}

/// Data class to hold Quick Access item information
class _QuickAccessData {
  final IconData icon;
  final String label;
  final String route;

  _QuickAccessData({
    required this.icon,
    required this.label,
    required this.route,
  });
}
