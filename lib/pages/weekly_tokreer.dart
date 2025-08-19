import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../firebase/firebase_api.dart';

class WeeklyTakareerPage extends StatefulWidget {
  const WeeklyTakareerPage({super.key});

  @override
  State<WeeklyTakareerPage> createState() => _WeeklyTakareerPageState();
}

class _WeeklyTakareerPageState extends State<WeeklyTakareerPage> {
  final DataBaseService _databaseService = DataBaseService();
  
  // Data state
  List<Map<String, dynamic>> weeklyTakareerList = [];
  bool isLoading = false;

  // Theme colors matching other pages
  static const Color creamColor = Colors.white;
  static const Color tealColor = Color(0xFF129990);
  static const Color darkTealColor = Color(0xFF096B68);
  static const Color lightTealColor = Color(0xFF90D1CA);

  @override
  void initState() {
    super.initState();
    _loadWeeklyTakareer();
  }

  Future<void> _loadWeeklyTakareer() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final weeklyTakareer = await _databaseService.getTakareerThisWeek();
      if (!mounted) return;
      
      setState(() {
        weeklyTakareerList = weeklyTakareer;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في تحميل نشاطات الأسبوع: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      });
    }
  }

  Widget _buildWeeklyTakareerCard(Map<String, dynamic> takareer, int index) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: lightTealColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: tealColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: tealColor,
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Text(
                takareer['title'] ?? 'بدون عنوان',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildWeeklySummaryText() {
    if (weeklyTakareerList.isEmpty) {
      return 'لا توجد نشاطات لهذا الأسبوع';
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('🗒 التقرير الأسبوعي لفرقة علي الأكبر (ع):');
    buffer.writeln('');

    for (int i = 0; i < weeklyTakareerList.length; i++) {
      final takareer = weeklyTakareerList[i];
      buffer.writeln('${i + 1}. ${takareer['title'] ?? 'بدون عنوان'}');
      buffer.writeln('   المكان: ${takareer['place'] ?? 'غير محدد'}');
      buffer.writeln('   اليوم: ${takareer['day'] ?? 'غير محدد'}');
      buffer.writeln('   التاريخ: ${takareer['date'] ?? 'غير محدد'}');
      buffer.writeln('   العدد: ${takareer['number'] ?? 'غير محدد'}');
      
      // Add line space between takareer (except for the last one)
      if (i < weeklyTakareerList.length - 1) {
        buffer.writeln('');
      }
    }

    buffer.writeln('');
    buffer.writeln('والله ولي التوفيق...🌼');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      backgroundColor: creamColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Beautiful header section matching other pages
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [tealColor, darkTealColor],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(isSmallScreen ? 20 : 30),
                    bottomRight: Radius.circular(isSmallScreen ? 20 : 30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkTealColor.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'نشاطات الأسبوع',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                          ),
                          child: Icon(
                            Icons.calendar_view_week,
                            size: isSmallScreen ? 24 : 32,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20, 
                        vertical: isSmallScreen ? 12 : 16
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.today,
                            color: Colors.white.withOpacity(0.9),
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 12),
                          Expanded(
                            child: Text(
                              'نشاطات هذا الأسبوع',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content area
              if (isLoading)
                Container(
                  margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
                  padding: EdgeInsets.all(isSmallScreen ? 40 : 60),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(tealColor),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: tealColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (weeklyTakareerList.isEmpty)
                Container(
                  margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            color: lightTealColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 40 : 50),
                          ),
                          child: Icon(
                            Icons.calendar_view_week,
                            size: isSmallScreen ? 60 : 80,
                            color: tealColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 24),
                        Text(
                          'لا توجد نشاطات هذا الأسبوع',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: tealColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 12),
                        Text(
                          'لم يتم العثور على أي نشاطات محددة لهذا الأسبوع',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List header
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [tealColor.withOpacity(0.1), lightTealColor.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                          border: Border.all(color: lightTealColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                              decoration: BoxDecoration(
                                color: tealColor,
                                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                              ),
                              child: Icon(
                                Icons.list,
                                color: Colors.white,
                                size: isSmallScreen ? 18 : 20,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 10 : 12),
                            Text(
                              'نشاطات الأسبوع (${weeklyTakareerList.length})',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: tealColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                                             // Weekly takareer list
                       ListView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: weeklyTakareerList.length,
                         itemBuilder: (context, index) {
                           return _buildWeeklyTakareerCard(weeklyTakareerList[index], index);
                         },
                       ),
                       SizedBox(height: 20),
                       // Summary text field
                       Container(
                         padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                           border: Border.all(color: lightTealColor.withOpacity(0.5), width: 1.5),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.05),
                               spreadRadius: 1,
                               blurRadius: 10,
                               offset: const Offset(0, 2),
                             ),
                           ],
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             isSmallScreen
                                 ? Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Row(
                                         children: [
                                           Container(
                                             padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                             decoration: BoxDecoration(
                                               color: tealColor.withOpacity(0.2),
                                               borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                             ),
                                             child: Icon(
                                               Icons.summarize,
                                               color: tealColor,
                                               size: isSmallScreen ? 18 : 20,
                                             ),
                                           ),
                                           SizedBox(width: isSmallScreen ? 10 : 12),
                                           Text(
                                             'ملخص النشاطات الأسبوعية',
                                             style: TextStyle(
                                               fontSize: isSmallScreen ? 16 : 18,
                                               fontWeight: FontWeight.bold,
                                               color: tealColor,
                                             ),
                                           ),
                                         ],
                                       ),
                                       SizedBox(height: 8),
                                       Align(
                                         alignment: Alignment.centerRight,
                                         child: TextButton.icon(
                                           onPressed: () async {
                                             final text = _buildWeeklySummaryText();
                                             await Clipboard.setData(ClipboardData(text: text));
                                             if (!mounted) return;
                                             ScaffoldMessenger.of(context).showSnackBar(
                                               SnackBar(
                                                 content: const Text('تم نسخ الملخص إلى الحافظة'),
                                                 backgroundColor: tealColor,
                                                 behavior: SnackBarBehavior.floating,
                                                 shape: RoundedRectangleBorder(
                                                   borderRadius: BorderRadius.circular(10),
                                                 ),
                                               ),
                                             );
                                           },
                                           icon: const Icon(Icons.copy, color: Colors.white),
                                           label: const Text('نسخ', style: TextStyle(color: Colors.white)),
                                           style: TextButton.styleFrom(
                                             backgroundColor: tealColor,
                                             padding: EdgeInsets.symmetric(
                                               horizontal: isSmallScreen ? 12 : 16,
                                               vertical: isSmallScreen ? 8 : 10,
                                             ),
                                             shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                             ),
                                           ),
                                         ),
                                       ),
                                     ],
                                   )
                                 : Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: [
                                       Row(
                                         children: [
                                           Container(
                                             padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                             decoration: BoxDecoration(
                                               color: tealColor.withOpacity(0.2),
                                               borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                             ),
                                             child: Icon(
                                               Icons.summarize,
                                               color: tealColor,
                                               size: isSmallScreen ? 18 : 20,
                                             ),
                                           ),
                                           SizedBox(width: isSmallScreen ? 10 : 12),
                                           Text(
                                             'ملخص النشاطات الأسبوعية',
                                             style: TextStyle(
                                               fontSize: isSmallScreen ? 16 : 18,
                                               fontWeight: FontWeight.bold,
                                               color: tealColor,
                                             ),
                                           ),
                                         ],
                                       ),
                                       TextButton.icon(
                                         onPressed: () async {
                                           final text = _buildWeeklySummaryText();
                                           await Clipboard.setData(ClipboardData(text: text));
                                           if (!mounted) return;
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(
                                               content: const Text('تم نسخ الملخص إلى الحافظة'),
                                               backgroundColor: tealColor,
                                               behavior: SnackBarBehavior.floating,
                                               shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(10),
                                               ),
                                             ),
                                           );
                                         },
                                         icon: const Icon(Icons.copy, color: Colors.white),
                                         label: const Text('نسخ', style: TextStyle(color: Colors.white)),
                                         style: TextButton.styleFrom(
                                           backgroundColor: tealColor,
                                           padding: EdgeInsets.symmetric(
                                             horizontal: isSmallScreen ? 12 : 16,
                                             vertical: isSmallScreen ? 8 : 10,
                                           ),
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                             SizedBox(height: 16),
                             Container(
                               width: double.infinity,
                               padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                               decoration: BoxDecoration(
                                 color: Colors.grey.shade50,
                                 borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                                 border: Border.all(color: Colors.grey.shade300),
                               ),
                               child: SelectableText(
                                 _buildWeeklySummaryText(),
                                 style: TextStyle(
                                   fontSize: isSmallScreen ? 14 : 16,
                                   color: Colors.black87,
                                   height: 1.6,
                                   fontFamily: 'Arial',
                                 ),
                                 textDirection: TextDirection.rtl,
                               ),
                             ),
                           ],
                         ),
                       ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
