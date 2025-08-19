import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';
import 'leadboards.dart';
import 'manage_individuals.dart';
import 'takareer.dart';

class MainUserPage extends StatefulWidget {
  const MainUserPage({Key? key}) : super(key: key);

  @override
  State<MainUserPage> createState() => _MainUserPageState();
}

class _MainUserPageState extends State<MainUserPage> {
  int _selectedIndex = 0; // Default selected index (Home)

  // Theme colors matching the home page
  static const Color tealColor = Color(0xFF129990);
  static const Color darkTealColor = Color(0xFF096B68);
  static const Color lightTealColor = Color(0xFF90D1CA);

  // List of pages to display
  final List<Widget> _pages = [
    const HomePage(),
    const LeaderboardsPage(),
    const ManageIndividualsPage(),
    const TakareerPage(),
    const ProfilePage(),
  ];

  // List of bottom navigation items
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.leaderboard_rounded),
      label: 'Leaderboard',
    ),
    
    const BottomNavigationBarItem(
      icon: Icon(Icons.manage_accounts_rounded),
      label: 'Manage Individuals',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month_rounded),
      label: 'Takareer',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
    final isLargeScreen = screenSize.width >= 1200;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isSmallScreen ? 20 : (isMediumScreen ? 25 : 30)),
            topRight: Radius.circular(isSmallScreen ? 20 : (isMediumScreen ? 25 : 30)),
          ),
          boxShadow: [
            BoxShadow(
              color: darkTealColor.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: isSmallScreen ? 15 : (isMediumScreen ? 20 : 25),
              offset: Offset(0, isSmallScreen ? -3 : (isMediumScreen ? -4 : -5)),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: isSmallScreen ? 10 : (isMediumScreen ? 15 : 20),
              offset: Offset(0, isSmallScreen ? -2 : (isMediumScreen ? -3 : -4)),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: isSmallScreen ? 80 : (isMediumScreen ? 90 : 100),
            padding: EdgeInsets.only(
              left: isSmallScreen ? 16 : (isMediumScreen ? 24 : 32),
              right: isSmallScreen ? 16 : (isMediumScreen ? 24 : 32),
              top: isSmallScreen ? 8 : (isMediumScreen ? 12 : 16),
              bottom: isSmallScreen ? 16 : (isMediumScreen ? 20 : 24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _bottomNavItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 2 : (isMediumScreen ? 4 : 6),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : (isMediumScreen ? 10 : 14),
                        vertical: isSmallScreen ? 6 : (isMediumScreen ? 10 : 14),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? tealColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          isSmallScreen ? 14 : (isMediumScreen ? 18 : 22)
                        ),
                        border: Border.all(
                          color: isSelected 
                              ? tealColor.withOpacity(0.3)
                              : Colors.transparent,
                          width: isSmallScreen ? 1.0 : (isMediumScreen ? 1.5 : 2.0),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              isSmallScreen ? 4 : (isMediumScreen ? 6 : 8)
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? tealColor
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(
                                isSmallScreen ? 10 : (isMediumScreen ? 14 : 18)
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: tealColor.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: isSmallScreen ? 6 : (isMediumScreen ? 8 : 10),
                                  offset: Offset(0, isSmallScreen ? 1 : (isMediumScreen ? 2 : 3)),
                                ),
                              ] : null,
                            ),
                            child: Icon(
                              (item.icon as Icon).icon,
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                              size: isSmallScreen ? 18 : (isMediumScreen ? 22 : 26),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : (isMediumScreen ? 4 : 6)),
                          Flexible(
                            child: Text(
                              item.label!,
                              style: TextStyle(
                                color: isSelected ? tealColor : Colors.grey.shade600,
                                fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 13),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
