import 'package:flutter/material.dart';
import '../firebase/firebase_api.dart';

class LeaderboardsPage extends StatefulWidget {
  const LeaderboardsPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardsPage> createState() => _LeaderboardsPageState();
}

class _LeaderboardsPageState extends State<LeaderboardsPage> {
  final DataBaseService _databaseService = DataBaseService();
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;

  // Theme colors matching home.dart
  static const Color creamColor = Colors.white;
  static const Color tealColor = Color(0xFF129990);
  static const Color darkTealColor = Color(0xFF096B68);
  static const Color lightTealColor = Color(0xFF90D1CA);

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _databaseService.getLeaderboardData();
      if (!mounted) return;
      setState(() {
        _leaderboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading leaderboard: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: tealColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadLeaderboardData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tealColor,
              darkTealColor,
              creamColor,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _leaderboardData.isEmpty
                ? const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildLeaderboardTable(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: darkTealColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            size: 50,
            color: Colors.amber[600],
          ),
          const SizedBox(height: 10),
          Text(
            'لائحة السجل الكشفي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkTealColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${_leaderboardData.length} مشارك',
            style: TextStyle(
              fontSize: 16,
              color: tealColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: creamColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: darkTealColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _leaderboardData.length,
            itemBuilder: (context, index) {
              final user = _leaderboardData[index];
              final rank = index + 1;
              final taskCount = user['taskCount'] ?? 0;
              
              return _buildTableRow(user, rank, taskCount);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: lightTealColor.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              'المطالب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTealColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الكشفي',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTealColor,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'الترتيب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTealColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> user, int rank, int taskCount) {
    final isTopThree = rank <= 3;
    final rankColor = _getRankColor(rank);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isTopThree ? rankColor.withOpacity(0.1) : creamColor,
        borderRadius: BorderRadius.circular(10),
        border: isTopThree
            ? Border.all(color: rankColor.withOpacity(0.3), width: 2)
            : Border.all(color: lightTealColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Task count (النقاط)
          Expanded(
            child: Text(
              '$taskCount',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: tealColor,
              ),
            ),
          ),
          // User name (الكشفي)
          Expanded(
            flex: 2,
            child: Text(
              user['name'] ?? 'مستخدم غير معروف',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: darkTealColor,
              ),
            ),
          ),
          // Rank (الترتيب)
          SizedBox(
            width: 50,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: isTopThree ? rankColor : lightTealColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTopThree ? Colors.white : tealColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[600]!;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[600]!;
      default:
        return lightTealColor;
    }
  }
}
