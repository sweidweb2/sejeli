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
  bool isLoading = false;
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  // Theme colors
  static const Color creamColor = Colors.white;
  static const Color tealColor = Color(0xFF129990);
  static const Color darkTealColor = Color(0xFF096B68);
  static const Color lightTealColor = Color(0xFF90D1CA);

  @override
  void initState() {
    super.initState();
    _loadIndividuals();
  }

  @override
  void dispose() {
    searchController.dispose();
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

  Future<void> _loadIndividuals() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final individuals = await DataBaseService().getAllIndividuals();
      print('individuals: $individuals');
      if (!mounted) return;
      
      setState(() {
        individualNames = individuals;
        filteredNames = individuals;
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
              content: Text('Error loading individuals: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'السجل الكشفي',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          onPressed: () => _showCreateDialog(context),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            size: 32,
                            color: Colors.white,
                          ),
                          tooltip: 'Create New',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_search,
                          color: Colors.white.withOpacity(0.9),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select an individual to manage their scout record',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
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
               margin: const EdgeInsets.all(20),
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: lightTealColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.people,
                          color: tealColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Select Individual',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Enhanced search field
                  Container(
                    decoration: BoxDecoration(
                      color: creamColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: lightTealColor.withOpacity(0.5)),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: isLoading ? 'Loading individuals...' : 'Search or select an individual',
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: tealColor,
                        ),
                        suffixIcon: selectedName != null
                            ? Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: tealColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      selectedName = null;
                                      selectedDocumentId = null;
                                      searchController.clear();
                                      filteredNames = individualNames;
                                      isSearching = false;
                                    });
                                  },
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onChanged: _filterNames,
                      onTap: () {
                        if (!isLoading) {
                          setState(() {
                            filteredNames = individualNames;
                            isSearching = true;
                          });
                        }
                      },
                      readOnly: isLoading,
                    ),
                  ),
                  
                  // Enhanced search results dropdown
                  if (isSearching && filteredNames.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
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
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  
                  // Enhanced selected name display
                  if (selectedName != null && !isSearching)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [lightTealColor.withOpacity(0.3), tealColor.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: lightTealColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: tealColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Individual',
                                  style: TextStyle(
                                    color: tealColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  selectedName!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF2D3748),
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
             if (selectedName != null)
               Container(
                 margin: const EdgeInsets.symmetric(horizontal: 20),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(20),
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
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           colors: [tealColor.withOpacity(0.1), lightTealColor.withOpacity(0.1)],
                         ),
                         borderRadius: const BorderRadius.only(
                           topLeft: Radius.circular(20),
                           topRight: Radius.circular(20),
                         ),
                       ),
                       child: Row(
                         children: [
                           Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: tealColor,
                               borderRadius: BorderRadius.circular(10),
                             ),
                             child: const Icon(
                               Icons.grid_view,
                               color: Colors.white,
                               size: 20,
                             ),
                           ),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(
                                   'Scout Record Grid',
                                   style: TextStyle(
                                     fontSize: 20,
                                     fontWeight: FontWeight.bold,
                                     color: tealColor,
                                   ),
                                 ),
                                 Text(
                                   'Individual: $selectedName',
                                   style: TextStyle(
                                     fontSize: 16,
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
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
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
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                         color: hasTask ? Colors.white : tealColor,
                                       ),
                                     ),
                                     if (hasTask) ...[
                                       const SizedBox(height: 4),
                                       Container(
                                         padding: const EdgeInsets.all(4),
                                         decoration: BoxDecoration(
                                           color: Colors.white.withOpacity(0.2),
                                           borderRadius: BorderRadius.circular(10),
                                         ),
                                         child: Icon(
                                           Icons.check_circle,
                                           size: 14,
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
                 margin: const EdgeInsets.all(20),
                 padding: const EdgeInsets.all(40),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(20),
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
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           color: lightTealColor.withOpacity(0.2),
                           borderRadius: BorderRadius.circular(50),
                         ),
                         child: Icon(
                           Icons.person_search,
                           size: 80,
                           color: tealColor,
                         ),
                       ),
                       const SizedBox(height: 24),
                       Text(
                         'Select an Individual',
                         style: TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: tealColor,
                         ),
                       ),
                       const SizedBox(height: 12),
                       Text(
                         'Choose an individual from the dropdown above\nto view and manage their scout record',
                         textAlign: TextAlign.center,
                         style: TextStyle(
                           fontSize: 16,
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
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightTealColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_add, color: tealColor),
              ),
              const SizedBox(width: 12),
              const Text('Create New Individual'),
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: lightTealColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: tealColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.person, color: tealColor),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Create'),
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
}
