import 'package:flutter/material.dart';
import '../firebase/firebase_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedName;
  String? selectedDocumentId;
  List<Map<String, dynamic>> individualNames = [];
  List<Map<String, dynamic>> filteredNames = [];
  List<Map<String, dynamic>> medals = []; // Store medals data
  bool isLoading = false;
  bool isSearching = false;
  bool isTasksSelected = true; // Toggle between Tasks and Medals
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode(); // Add this line

  // Theme colors
  static const Color creamColor = Colors.white;
  static const Color tealColor = Color(0xFF129990);
  static const Color darkTealColor = Color(0xFF096B68);
  static const Color lightTealColor = Color(0xFF90D1CA);

  @override
  void initState() {
    super.initState();
    _loadIndividuals();
    _loadMedals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure search field doesn't have focus when dependencies change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !isSearching) {
        searchFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose(); // Add this line
    super.dispose();
  }

  void _filterNames(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNames = individualNames;
        isSearching = false;
      } else {
        filteredNames = individualNames
            .where((individual) => individual['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        isSearching = true;
      }
    });
  }

  void _handleSearchFieldTap() {
    if (!isLoading) {
      setState(() {
        filteredNames = individualNames;
        isSearching = true;
      });
      // Only focus if user explicitly taps on the field
      searchFocusNode.requestFocus();
    }
  }

  Future<void> _loadIndividuals() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final individuals = await DataBaseService().getAllIndividuals();
      // print('individuals: $individuals');
      if (!mounted) return;
      
      setState(() {
        individualNames = individuals;
        filteredNames = individuals;
        isLoading = false;
      });
      
      // Ensure search field doesn't have focus after loading
      if (mounted) {
        searchFocusNode.unfocus();
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading individuals: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
             });
     }
   }
 
   Future<void> _loadMedals() async {
     if (!mounted) return;
     
     try {
       final medalsData = await DataBaseService().getAllMedals();
       if (!mounted) return;
       
       setState(() {
         medals = medalsData;
       });
     } catch (e) {
       if (!mounted) return;
       
       print('Error loading medals: $e');
     }
   }
 
   @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
    
    return Scaffold(
      backgroundColor: creamColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Beautiful header section
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
                  // Title
                  Text(
                    'السجل الكشفي',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  // Action buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Leaderboards button
                      Container(
                        margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/leaderboards');
                          },
                          icon: Icon(
                            Icons.emoji_events,
                            size: isSmallScreen ? 20 : 24,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Leaderboards',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                          ),
                        ),
                      ),
                      // Delete User button
                      Container(
                        margin: EdgeInsets.only(right: isSmallScreen ? 8 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/manage_individuals');
                          },
                          icon: Icon(
                            Icons.delete_forever,
                            size: isSmallScreen ? 20 : 24,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Delete User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                          ),
                        ),
                      ),
                      // Create button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
                        ),
                        child: TextButton.icon(
                          onPressed: () => _showCreateDialog(context),
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: isSmallScreen ? 20 : 24,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Create User',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                          ),
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
                           Icons.person_search,
                           color: Colors.white.withOpacity(0.9),
                           size: isSmallScreen ? 20 : 24,
                         ),
                         SizedBox(width: isSmallScreen ? 10 : 12),
                         Expanded(
                           child: Text(
                             'Select an individual to manage their scout record',
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
             
                          
                                        // Search and selection section
              Container(
                margin: EdgeInsets.all(isSmallScreen ? 12 : 20),
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
                           borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                         ),
                         child: Icon(
                           Icons.people,
                           color: tealColor,
                           size: isSmallScreen ? 20 : 24,
                         ),
                       ),
                       SizedBox(width: isSmallScreen ? 10 : 12),
                       Text(
                         'Select Individual',
                         style: TextStyle(
                           fontSize: isSmallScreen ? 18 : 20,
                           fontWeight: FontWeight.bold,
                           color: const Color(0xFF2D3748),
                         ),
                       ),
                     ],
                   ),
                   SizedBox(height: isSmallScreen ? 16 : 20),
                  
                                                                           // Enhanced search field with refresh button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: creamColor,
                              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
                              border: Border.all(color: lightTealColor.withOpacity(0.5)),
                            ),
                            child: TextField(
                              controller: searchController,
                              focusNode: searchFocusNode,
                              decoration: InputDecoration(
                                hintText: isLoading ? 'Loading individuals...' : 'Search or select an individual',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: tealColor,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                suffixIcon: selectedName != null
                                    ? Container(
                                        margin: EdgeInsets.all(isSmallScreen ? 6 : 8),
                                        decoration: BoxDecoration(
                                          color: tealColor,
                                          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.clear, 
                                            color: Colors.white,
                                            size: isSmallScreen ? 18 : 24,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedName = null;
                                              selectedDocumentId = null;
                                              searchController.clear();
                                              filteredNames = individualNames;
                                              isSearching = false;
                                            });
                                            // Unfocus the search field when clearing
                                            searchFocusNode.unfocus();
                                          },
                                        ),
                                      )
                                    : null,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 16 : 20, 
                                  vertical: isSmallScreen ? 12 : 16
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
                                  borderSide: BorderSide(color: tealColor, width: 2),
                                ),
                              ),
                              onChanged: _filterNames,
                              onTap: _handleSearchFieldTap,
                              readOnly: isLoading,
                              autofocus: false,
                              enableInteractiveSelection: true,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 8 : 12),
                        // Refresh button
                        Container(
                          decoration: BoxDecoration(
                            color: tealColor,
                            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
                            boxShadow: [
                              BoxShadow(
                                color: tealColor.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: isLoading ? null : _loadIndividuals,
                            icon: isLoading
                                ? SizedBox(
                                    width: isSmallScreen ? 20 : 24,
                                    height: isSmallScreen ? 20 : 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                            tooltip: 'Refresh data',
                          ),
                        ),
                      ],
                    ),
                  
                                     // Enhanced search results dropdown
                   if (isSearching && filteredNames.isNotEmpty)
                     Container(
                       margin: EdgeInsets.only(top: isSmallScreen ? 10 : 12),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.1),
                             spreadRadius: 1,
                             blurRadius: 10,
                             offset: const Offset(0, 4),
                           ),
                         ],
                       ),
                       constraints: BoxConstraints(
                         maxHeight: isSmallScreen ? 150 : 200,
                       ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredNames.length,
                        itemBuilder: (context, index) {
                          final individual = filteredNames[index];
                          final isSelected = selectedName == individual['name'];
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? lightTealColor.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected ? tealColor : lightTealColor.withOpacity(0.3),
                                child: Text(
                                  (individual['name'] as String).substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : tealColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                individual['name'] as String,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? tealColor : Colors.black87,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedName = individual['name'] as String;
                                  selectedDocumentId = individual['id'] as String;
                                  searchController.text = individual['name'] as String;
                                  isSearching = false;
                                });
                                // Unfocus the search field after selection
                                searchFocusNode.unfocus();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  
                                     // Enhanced selected name display
                   if (selectedName != null && !isSearching)
                     Container(
                       margin: EdgeInsets.only(top: isSmallScreen ? 12 : 16),
                       padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           colors: [lightTealColor.withOpacity(0.3), tealColor.withOpacity(0.1)],
                         ),
                         borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
                         border: Border.all(color: lightTealColor.withOpacity(0.5)),
                       ),
                       child: Column(
                         children: [
                           Row(
                             children: [
                               Container(
                                 padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                                 decoration: BoxDecoration(
                                   color: tealColor,
                                   borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                 ),
                                 child: Icon(
                                   Icons.person,
                                   color: Colors.white,
                                   size: isSmallScreen ? 20 : 24,
                                 ),
                               ),
                               SizedBox(width: isSmallScreen ? 12 : 16),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'Selected Individual',
                                       style: TextStyle(
                                         color: tealColor,
                                         fontSize: isSmallScreen ? 12 : 14,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                     Text(
                                       selectedName!,
                                       style: TextStyle(
                                         fontWeight: FontWeight.bold,
                                         fontSize: isSmallScreen ? 16 : 18,
                                         color: const Color(0xFF2D3748),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                           SizedBox(height: isSmallScreen ? 16 : 20),
                           // Toggle button for Tasks/Medals
                           Container(
                             decoration: BoxDecoration(
                               color: lightTealColor.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 15),
                               border: Border.all(color: lightTealColor.withOpacity(0.3)),
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 // Tasks button
                                 GestureDetector(
                                   onTap: () {
                                     setState(() {
                                       isTasksSelected = true;
                                     });
                                   },
                                   child: Container(
                                     padding: EdgeInsets.symmetric(
                                       horizontal: isSmallScreen ? 16 : 20,
                                       vertical: isSmallScreen ? 8 : 12,
                                     ),
                                     decoration: BoxDecoration(
                                       color: isTasksSelected ? tealColor : Colors.transparent,
                                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(
                                           Icons.task_alt,
                                           color: isTasksSelected ? Colors.white : tealColor,
                                           size: isSmallScreen ? 18 : 20,
                                         ),
                                         SizedBox(width: isSmallScreen ? 6 : 8),
                                         Text(
                                           'Tasks',
                                           style: TextStyle(
                                             color: isTasksSelected ? Colors.white : tealColor,
                                             fontSize: isSmallScreen ? 14 : 16,
                                             fontWeight: FontWeight.w600,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                                 // Medals button
                                 GestureDetector(
                                   onTap: () {
                                     setState(() {
                                       isTasksSelected = false;
                                     });
                                   },
                                   child: Container(
                                     padding: EdgeInsets.symmetric(
                                       horizontal: isSmallScreen ? 16 : 20,
                                       vertical: isSmallScreen ? 8 : 12,
                                     ),
                                     decoration: BoxDecoration(
                                       color: !isTasksSelected ? tealColor : Colors.transparent,
                                       borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(
                                           Icons.emoji_events,
                                           color: !isTasksSelected ? Colors.white : tealColor,
                                           size: isSmallScreen ? 18 : 20,
                                         ),
                                         SizedBox(width: isSmallScreen ? 6 : 8),
                                         Text(
                                           'Medals',
                                           style: TextStyle(
                                             color: !isTasksSelected ? Colors.white : tealColor,
                                             fontSize: isSmallScreen ? 14 : 16,
                                             fontWeight: FontWeight.w600,
                                           ),
                                         ),
                                       ],
                                     ),
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

                                                   // Content area with grid
              if (selectedName != null && isTasksSelected)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
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
                   children: [
                                           // Enhanced grid header
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [tealColor.withOpacity(0.1), lightTealColor.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isSmallScreen ? 16 : 20),
                            topRight: Radius.circular(isSmallScreen ? 16 : 20),
                          ),
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
                                Icons.grid_view,
                                color: Colors.white,
                                size: isSmallScreen ? 18 : 20,
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 10 : 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scout Record Grid',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 18 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: tealColor,
                                    ),
                                  ),
                                  Text(
                                    'Individual: $selectedName',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                     
                                                                 // Enhanced grid of 180 boxes
                       Container(
                         padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                         child: GridView.builder(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                             crossAxisCount: isSmallScreen ? 4 : (isMediumScreen ? 5 : 6),
                             crossAxisSpacing: isSmallScreen ? 8 : 12,
                             mainAxisSpacing: isSmallScreen ? 8 : 12,
                             childAspectRatio: 1.0,
                           ),
                           itemCount: 180,
                         itemBuilder: (context, index) {
                           final boxNumber = index + 1;
                           final hasTask = selectedDocumentId != null && 
                               individualNames.any((individual) => 
                                   individual['id'] == selectedDocumentId && 
                                   individual['taskNumbers'] != null &&
                                   (individual['taskNumbers'] as List).contains(boxNumber.toString()));
                           
                           return GestureDetector(
                             onTap: () => _onBoxTapped(boxNumber),
                             child: Container(
                               decoration: BoxDecoration(
                                 gradient: hasTask 
                                     ? LinearGradient(
                                         colors: [tealColor, darkTealColor],
                                         begin: Alignment.topLeft,
                                         end: Alignment.bottomRight,
                                       )
                                     : LinearGradient(
                                         colors: [Colors.white, creamColor],
                                         begin: Alignment.topLeft,
                                         end: Alignment.bottomRight,
                                       ),
                                 borderRadius: BorderRadius.circular(15),
                                 border: Border.all(
                                   color: hasTask ? Colors.transparent : lightTealColor.withOpacity(0.3),
                                   width: 1.5,
                                 ),
                                 boxShadow: [
                                   BoxShadow(
                                     color: hasTask 
                                         ? tealColor.withOpacity(0.3)
                                         : Colors.black.withOpacity(0.05),
                                     spreadRadius: 1,
                                     blurRadius: hasTask ? 8 : 4,
                                     offset: const Offset(0, 2),
                                   ),
                                 ],
                               ),
                                                               child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$boxNumber',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: hasTask ? Colors.white : tealColor,
                                        ),
                                      ),
                                      if (hasTask) ...[
                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Container(
                                          padding: EdgeInsets.all(isSmallScreen ? 3 : 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                          ),
                                          child: Icon(
                                            Icons.check_circle,
                                            size: isSmallScreen ? 12 : 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                             ),
                           );
                         },
                       ),
                     ),
                   ],
                 ),
               )
                               // Medals section with grid
                else if (selectedName != null && !isTasksSelected)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
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
                      children: [
                        // Medals grid header
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [tealColor.withOpacity(0.1), lightTealColor.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isSmallScreen ? 16 : 20),
                              topRight: Radius.circular(isSmallScreen ? 16 : 20),
                            ),
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
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 10 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Available Medals',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 18 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: tealColor,
                                      ),
                                    ),
                                    Text(
                                      'Individual: $selectedName',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Medals grid
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                          child: medals.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                                        decoration: BoxDecoration(
                                          color: lightTealColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(isSmallScreen ? 40 : 50),
                                        ),
                                        child: Icon(
                                          Icons.emoji_events,
                                          size: isSmallScreen ? 60 : 80,
                                          color: tealColor,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 20 : 24),
                                      Text(
                                        'No Medals Available',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 20 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: tealColor,
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 10 : 12),
                                      Text(
                                        'No medals have been created yet',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: Colors.grey.shade600,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isSmallScreen ? 2 : (isMediumScreen ? 3 : 4),
                                    crossAxisSpacing: isSmallScreen ? 12 : 16,
                                    mainAxisSpacing: isSmallScreen ? 12 : 16,
                                    childAspectRatio: 1.2,
                                  ),
                                  itemCount: medals.length,
                                  itemBuilder: (context, index) {
                                    final medal = medals[index];
                                    final medalName = medal['name'] ?? 'Medal ${index + 1}';
                                    final medalDescription = medal['description'] ?? 'No description available';
                                    
                                    // Check if this medal is already awarded to the selected individual
                                    final hasMedal = selectedDocumentId != null && 
                                        individualNames.any((individual) => 
                                            individual['id'] == selectedDocumentId && 
                                            individual['medals'] != null &&
                                            (individual['medals'] as List).contains(medalName));
                                    
                                    return GestureDetector(
                                      onTap: () => _onMedalTapped(medal['id'], medalName),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: hasMedal 
                                              ? LinearGradient(
                                                  colors: [tealColor, darkTealColor],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : LinearGradient(
                                                  colors: [Colors.white, creamColor],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: hasMedal ? Colors.transparent : lightTealColor.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: hasMedal 
                                                  ? tealColor.withOpacity(0.3)
                                                  : Colors.black.withOpacity(0.05),
                                              spreadRadius: 1,
                                              blurRadius: hasMedal ? 8 : 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                                                decoration: BoxDecoration(
                                                  color: hasMedal 
                                                      ? Colors.white.withOpacity(0.2)
                                                      : lightTealColor.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
                                                ),
                                                child: Icon(
                                                  Icons.emoji_events,
                                                  size: isSmallScreen ? 24 : 28,
                                                  color: hasMedal ? Colors.white : tealColor,
                                                ),
                                              ),
                                              SizedBox(height: isSmallScreen ? 8 : 10),
                                              Text(
                                                medalName,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: isSmallScreen ? 12 : 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: hasMedal ? Colors.white : tealColor,
                                                ),
                                              ),
                                              if (medalDescription != 'No description available') ...[
                                                SizedBox(height: isSmallScreen ? 4 : 6),
                                                Text(
                                                  medalDescription,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: isSmallScreen ? 10 : 12,
                                                    color: hasMedal 
                                                        ? Colors.white.withOpacity(0.8)
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                              if (hasMedal) ...[
                                                SizedBox(height: isSmallScreen ? 6 : 8),
                                                Container(
                                                  padding: EdgeInsets.all(isSmallScreen ? 4 : 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                                                  ),
                                                  child: Icon(
                                                    Icons.check_circle,
                                                    size: isSmallScreen ? 12 : 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  )
                                                   else
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
                            Icons.person_search,
                            size: isSmallScreen ? 60 : 80,
                            color: tealColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 24),
                        Text(
                          'Select an Individual',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: tealColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 10 : 12),
                        Text(
                          'Choose an individual from the dropdown above\nto view and manage their scout record',
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
                ),
             ],
           ),
         ),
       ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                   Icons.person_add, 
                   color: tealColor,
                   size: isDialogSmallScreen ? 20 : 24,
                 ),
               ),
               SizedBox(width: isDialogSmallScreen ? 10 : 12),
               Text(
                 'Create New Individual',
                 style: TextStyle(
                   fontSize: isDialogSmallScreen ? 18 : 20,
                 ),
               ),
             ],
           ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                                 TextFormField(
                   controller: nameController,
                   decoration: InputDecoration(
                     labelText: 'Name',
                     hintText: 'Enter individual name',
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
                       Icons.person, 
                       color: tealColor,
                       size: isDialogSmallScreen ? 20 : 24,
                     ),
                   ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await DataBaseService().createIndividual(nameController.text.trim());
                    Navigator.of(context).pop();
                    
                    await _loadIndividuals();
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Individual created successfully!'),
                            backgroundColor: tealColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    });
                  } catch (e) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating individual: ${e.toString()}'),
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
              },
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
                 'Create',
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

  Future<void> _onBoxTapped(int boxNumber) async {
    if (selectedName == null || selectedDocumentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an individual first'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      // Unfocus the search field before creating the task
      searchFocusNode.unfocus();
      
      await DataBaseService().createTask(
        boxNumber.toString(),
        selectedDocumentId!,
      );
      
      await _loadIndividuals();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task $boxNumber created for $selectedName!'),
            backgroundColor: tealColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating task: ${e.toString()}'),
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
 
   Future<void> _onMedalTapped(String medalId, String medalName) async {
     if (selectedName == null || selectedDocumentId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: const Text('Please select an individual first'),
           backgroundColor: Colors.orange,
           behavior: SnackBarBehavior.floating,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(10),
           ),
         ),
       );
       return;
     }
 
     try {
       // Unfocus the search field before creating the medal
       searchFocusNode.unfocus();
       
       await DataBaseService().createMedal(
         medalId,
         medalName,
         selectedDocumentId!,
       );
       
       await _loadIndividuals();
       
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Medal updated for $selectedName!'),
             backgroundColor: tealColor,
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(10),
             ),
           ),
         );
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error updating medal: ${e.toString()}'),
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
