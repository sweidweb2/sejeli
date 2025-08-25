import 'package:flutter/material.dart';
import '../firebase/firebase_api.dart';
import 'weekly_tokreer.dart';

class TakareerPage extends StatefulWidget {
  const TakareerPage({super.key});

  @override
  State<TakareerPage> createState() => _TakareerPageState();
}

class _TakareerPageState extends State<TakareerPage> {
  final DataBaseService _databaseService = DataBaseService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  // Theme colors matching home.dart
  static const Color creamColor = Colors.white;
  static const Color tealColor = Color(0xFF129990);
  static const Color darkTealColor = Color(0xFF096B68);
  static const Color lightTealColor = Color(0xFF90D1CA);

  // Arabic days
  final List<String> arabicDays = [
    'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
  ];

  String? selectedDay;
  DateTime? selectedDate;
  
  // Data state
  List<Map<String, dynamic>> takareerList = [];
  List<Map<String, dynamic>> filteredTakareerList = [];
  bool isLoading = false;
  
  // Filter state
  String selectedFilter = 'all'; // 'all', 'today', 'week', 'month'

  @override
  void initState() {
    super.initState();
    _loadTakareer();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _dayController.dispose();
    _dateController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadTakareer() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final takareer = await _databaseService.getAllTakareer();
      if (!mounted) return;
      
      setState(() {
        takareerList = takareer;
        _applyFilter();
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
              content: Text('خطأ في تحميل النشاطات: ${e.toString()}'),
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
  
  void _applyFilter() {
    if (selectedFilter == 'all') {
      filteredTakareerList = List.from(takareerList);
      return;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    filteredTakareerList = takareerList.where((takareer) {
      try {
        // Parse the date from the takareer
        final dateStr = takareer['date'] as String?;
        if (dateStr == null || dateStr.isEmpty) return false;
        
        // Parse date in DD/MM/YYYY format
        final parts = dateStr.split('/');
        if (parts.length != 3) return false;
        
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final takareerDate = DateTime(year, month, day);
        
        switch (selectedFilter) {
          case 'today':
            return takareerDate.isAtSameMomentAs(today);
          case 'week':
            final weekStart = today.subtract(Duration(days: today.weekday - 1));
            final weekEnd = weekStart.add(const Duration(days: 6));
            return takareerDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                   takareerDate.isBefore(weekEnd.add(const Duration(days: 1)));
          case 'month':
            return takareerDate.year == today.year && takareerDate.month == today.month;
          default:
            return true;
        }
      } catch (e) {
        // If date parsing fails, don't include in filtered results
        return false;
      }
    }).toList();
  }
  
  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: tealColor,
              onPrimary: Colors.white,
              surface: creamColor,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _showAddTakareerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dialogScreenSize = MediaQuery.of(context).size;
        final isDialogSmallScreen = dialogScreenSize.width < 600;
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isDialogSmallScreen ? 16 : 20)
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isDialogSmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: lightTealColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isDialogSmallScreen ? 8 : 10),
                ),
                child: Icon(
                  Icons.event_note, 
                  color: tealColor,
                  size: isDialogSmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isDialogSmallScreen ? 10 : 12),
              Text(
                'إضافة جديد',
                style: TextStyle(
                  fontSize: isDialogSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      hintText: 'أدخل عنوان النشاط',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: lightTealColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: tealColor, width: 2),
                      ),
                      floatingLabelStyle: TextStyle(color: tealColor),
                      prefixIcon: Icon(
                        Icons.title, 
                        color: tealColor,
                        size: isDialogSmallScreen ? 20 : 24,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال العنوان';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                  SizedBox(height: isDialogSmallScreen ? 16 : 20),
                  TextFormField(
                    controller: _placeController,
                    decoration: InputDecoration(
                      labelText: 'المكان',
                      hintText: 'أدخل المكان',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: lightTealColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: tealColor, width: 2),
                      ),
                      floatingLabelStyle: TextStyle(color: tealColor),
                      prefixIcon: Icon(
                        Icons.location_on, 
                        color: tealColor,
                        size: isDialogSmallScreen ? 20 : 24,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال المكان';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isDialogSmallScreen ? 16 : 20),
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: InputDecoration(
                      labelText: 'اليوم',
                      hintText: 'اختر اليوم',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: lightTealColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: tealColor, width: 2),
                      ),
                      floatingLabelStyle: TextStyle(color: tealColor),
                      prefixIcon: Icon(
                        Icons.calendar_today, 
                        color: tealColor,
                        size: isDialogSmallScreen ? 20 : 24,
                      ),
                    ),
                    items: arabicDays.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDay = newValue;
                        _dayController.text = newValue ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء اختيار اليوم';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isDialogSmallScreen ? 16 : 20),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'التاريخ',
                      hintText: 'اختر التاريخ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: lightTealColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: tealColor, width: 2),
                      ),
                      floatingLabelStyle: TextStyle(color: tealColor),
                      prefixIcon: Icon(
                        Icons.calendar_month, 
                        color: tealColor,
                        size: isDialogSmallScreen ? 20 : 24,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today, color: tealColor),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء اختيار التاريخ';
                      }
                      return null;
                    },
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: isDialogSmallScreen ? 16 : 20),
                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'العدد',
                      hintText: 'أدخل العدد',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: lightTealColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                        borderSide: BorderSide(color: tealColor, width: 2),
                      ),
                      floatingLabelStyle: TextStyle(color: tealColor),
                      prefixIcon: Icon(
                        Icons.numbers, 
                        color: tealColor,
                        size: isDialogSmallScreen ? 20 : 24,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال العدد';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'الرجاء إدخال عدد صحيح';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: tealColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDialogSmallScreen ? 10 : 12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDialogSmallScreen ? 20 : 24, 
                  vertical: isDialogSmallScreen ? 10 : 12
                ),
              ),
              child: Text(
                'إضافة',
                style: TextStyle(
                  fontSize: isDialogSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _titleController.clear();
    _placeController.clear();
    _dayController.clear();
    _dateController.clear();
    _numberController.clear();
    setState(() {
      selectedDay = null;
      selectedDate = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _databaseService.createTakareer(
          title: _titleController.text.trim(),
          place: _placeController.text.trim(),
          day: _dayController.text.trim(),
          date: _dateController.text.trim(),
          number: _numberController.text.trim(),
        );
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إنشاء النشاط بنجاح!'),
              backgroundColor: tealColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          // Close dialog and clear form
          Navigator.of(context).pop();
          _clearForm();
          
          // Reload the takareer list
          await _loadTakareer();
          _applyFilter();
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إنشاء النشاط: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildTakareerCard(Map<String, dynamic> takareer, int index) {
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
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Row(
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
                       fontWeight: FontWeight.bold,
                       color: Colors.black87,
                     ),
                   ),
                 ),
                 SizedBox(width: isSmallScreen ? 8 : 12),
                 Container(
                   decoration: BoxDecoration(
                     color: Colors.red.withOpacity(0.08),
                     borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                   ),
                   child: IconButton(
                     tooltip: 'حذف',
                     onPressed: () async {
                       final String? id = takareer['id'] as String?;
                       if (id == null || id.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: const Text('تعذر تحديد المعرف للحذف'),
                             backgroundColor: Colors.red,
                           ),
                         );
                         return;
                       }
                       final confirm = await showDialog<bool>(
                         context: context,
                         builder: (context) {
                           final screenSize = MediaQuery.of(context).size;
                           final isDialogSmall = screenSize.width < 600;
                           return AlertDialog(
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(isDialogSmall ? 16 : 20),
                             ),
                             title: Row(
                               children: [
                                 Icon(Icons.delete_outline, color: Colors.red.shade600),
                                 const SizedBox(width: 8),
                                 const Text('تأكيد الحذف'),
                               ],
                             ),
                             content: const Text('هل تريد حذف هذا النشاط؟ لا يمكن التراجع عن هذه العملية.'),
                             actions: [
                               TextButton(
                                 onPressed: () => Navigator.of(context).pop(false),
                                 child: Text('إلغاء', style: TextStyle(color: Colors.grey.shade700)),
                               ),
                               ElevatedButton.icon(
                                 onPressed: () => Navigator.of(context).pop(true),
                                 icon: const Icon(Icons.delete_outline),
                                 label: const Text('حذف'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.red.shade600,
                                   foregroundColor: Colors.white,
                                 ),
                               ),
                             ],
                           );
                         },
                       );
                       if (confirm != true) return;
                       try {
                         await _databaseService.deleteTakareer(id);
                         if (!mounted) return;
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: const Text('تم حذف النشاط بنجاح!'),
                             backgroundColor: Colors.red.shade600,
                             behavior: SnackBarBehavior.floating,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(10),
                             ),
                           ),
                         );
                         await _loadTakareer();
                       } catch (e) {
                         if (!mounted) return;
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text('حدث خطأ أثناء الحذف: $e'),
                             backgroundColor: Colors.red,
                             behavior: SnackBarBehavior.floating,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(10),
                             ),
                           ),
                         );
                       }
                     },
                     icon: Icon(
                       Icons.delete_outline,
                       color: Colors.red.shade600,
                       size: isSmallScreen ? 20 : 22,
                     ),
                   ),
                 ),
               ],
             ),
             SizedBox(height: isSmallScreen ? 12 : 16),
             Row(
               children: [
                 // Left column: Place and Day
                 Expanded(
                   child: Column(
                     children: [
                       _buildInfoRow(
                         Icons.location_on,
                         'المكان:',
                         takareer['place'] ?? 'غير محدد',
                         isSmallScreen,
                       ),
                       SizedBox(height: isSmallScreen ? 8 : 12),
                       _buildInfoRow(
                         Icons.calendar_today,
                         'اليوم:',
                         takareer['day'] ?? 'غير محدد',
                         isSmallScreen,
                       ),
                     ],
                   ),
                 ),
                 SizedBox(width: isSmallScreen ? 16 : 24),
                 // Right column: Date and Number
                 Expanded(
                   child: Column(
                     children: [
                       _buildInfoRow(
                         Icons.calendar_month,
                         'التاريخ:',
                         takareer['date'] ?? 'غير محدد',
                         isSmallScreen,
                       ),
                       SizedBox(height: isSmallScreen ? 8 : 12),
                       _buildInfoRow(
                         Icons.numbers,
                         'العدد:',
                         takareer['number'] ?? 'غير محدد',
                         isSmallScreen,
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isSmallScreen) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 16 : 18,
          color: tealColor,
        ),
        SizedBox(width: isSmallScreen ? 6 : 8),
        Expanded(
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(String filter, String label, IconData icon) {
    final isSelected = selectedFilter == filter;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return GestureDetector(
      onTap: () => _onFilterChanged(filter),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? tealColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
          border: Border.all(
            color: isSelected ? tealColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: tealColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 16 : 18,
              color: isSelected ? Colors.white : tealColor,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : tealColor,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
              // Beautiful header section matching home.dart
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
                           'النشاطات',
                           style: TextStyle(
                             fontSize: isSmallScreen ? 22 : 28,
                             fontWeight: FontWeight.bold,
                             color: Colors.white,
                           ),
                         ),
                         Row(
                           children: [
                             // Weekly Report Button
                             Container(
                               margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                               child: ElevatedButton.icon(
                                 onPressed: () {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                       builder: (context) => const WeeklyTakareerPage(),
                                     ),
                                   );
                                 },
                                 icon: Icon(
                                   Icons.calendar_view_week,
                                   size: isSmallScreen ? 18 : 20,
                                   color: Colors.white,
                                 ),
                                 label: Text(
                                   'التقرير الإسبوعي',
                                   style: TextStyle(
                                     fontSize: isSmallScreen ? 12 : 14,
                                     fontWeight: FontWeight.w600,
                                     color: Colors.white,
                                   ),
                                 ),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.white.withOpacity(0.2),
                                   foregroundColor: Colors.white,
                                   elevation: 0,
                                   padding: EdgeInsets.symmetric(
                                     horizontal: isSmallScreen ? 12 : 16,
                                     vertical: isSmallScreen ? 8 : 10,
                                   ),
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
                                   ),
                                 ),
                               ),
                             ),
                             // Add Button
                             Container(
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.2),
                                 borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 50),
                               ),
                               child: IconButton(
                                 onPressed: _showAddTakareerDialog,
                                 icon: Icon(
                                   Icons.add_circle_outline,
                                   size: isSmallScreen ? 24 : 32,
                                   color: Colors.white,
                                 ),
                                 tooltip: 'إضافة نشاط جديد',
                               ),
                             ),
                           ],
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
                            Icons.event_note,
                            color: Colors.white.withOpacity(0.9),
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 12),
                          Expanded(
                            child: Text(
                              'إدارة النشاطات',
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
              
                             // Filter section
               Container(
                 margin: EdgeInsets.only(
                   top: isSmallScreen ? 16 : 20,
                   left: isSmallScreen ? 12 : 20,
                   right: isSmallScreen ? 12 : 20,
                 ),
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          decoration: BoxDecoration(
                            color: lightTealColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: tealColor,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 12),
                        Text(
                          'تصفية النشاطات',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 20),
                    Wrap(
                      spacing: isSmallScreen ? 8 : 12,
                      runSpacing: isSmallScreen ? 8 : 12,
                      children: [
                        _buildFilterChip('all', 'الكل', Icons.all_inclusive),
                        _buildFilterChip('today', 'اليوم', Icons.today),
                        _buildFilterChip('week', 'هذا الأسبوع', Icons.view_week),
                        _buildFilterChip('month', 'هذا الشهر', Icons.calendar_month),
                      ],
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
              else if (filteredTakareerList.isEmpty)
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
                            Icons.event_note,
                            size: isSmallScreen ? 60 : 80,
                            color: tealColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 24),
                        Text(
                          selectedFilter == 'all' ? 'لا توجد نشاطات بعد' : 'لا توجد نشاطات في هذا الفترة',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: tealColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 12),
                        Text(
                          selectedFilter == 'all' 
                              ? 'اضغط على زر الإضافة أعلاه لإنشاء أول نشاط'
                              : 'جرب تغيير الفلتر أو إضافة نشاط جديد',
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
                              'قائمة النشاطات (${filteredTakareerList.length}/${takareerList.length})',
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
                      // Takareer list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTakareerList.length,
                        itemBuilder: (context, index) {
                          return _buildTakareerCard(filteredTakareerList[index], index);
                        },
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
