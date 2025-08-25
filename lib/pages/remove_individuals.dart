import 'package:flutter/material.dart';
import '../firebase/firebase_api.dart';

class ManageIndividualsPage extends StatefulWidget {
  const ManageIndividualsPage({Key? key}) : super(key: key);

  @override
  State<ManageIndividualsPage> createState() => _ManageIndividualsPageState();
}

class _ManageIndividualsPageState extends State<ManageIndividualsPage> {
  final DataBaseService _databaseService = DataBaseService();
  final Map<String, bool> _selectedById = {};
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _individuals = [];
  List<Map<String, dynamic>> _filteredIndividuals = [];
  bool _isLoading = true;
  bool _isDeleting = false;

  // Theme colors matching the app style
  static const Color creamColor = Colors.white;
  static const Color tealColor = Color(0xFF129990);
  static const Color darkTealColor = Color(0xFF096B68);
  static const Color lightTealColor = Color(0xFF90D1CA);

  @override
  void initState() {
    super.initState();
    _loadIndividuals();
    _searchController.addListener(_filterIndividuals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterIndividuals() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredIndividuals = _individuals;
      } else {
        _filteredIndividuals = _individuals
            .where((individual) => 
                individual['name'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadIndividuals() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _databaseService.getAllIndividuals();
      if (!mounted) return;
      setState(() {
        _individuals = data;
        _filteredIndividuals = data;
        _selectedById.clear();
        for (final person in data) {
          final id = person['id'] as String?;
          if (id != null) {
            _selectedById[id] = false;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading individuals: $e')),
        );
      }
    }
  }

  int _taskCountOf(Map<String, dynamic> person) {
    final tasks = person['taskNumbers'];
    if (tasks is List) return tasks.length;
    return 0;
  }

  List<String> get _selectedIds => _selectedById.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList(growable: false);

  Future<void> _deleteSelected() async {
    final ids = _selectedIds;
    if (ids.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No individuals selected')),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete selected?'),
        content: Text('This will delete ${ids.length} individual(s). This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() {
      _isDeleting = true;
    });

    try {
      await _databaseService.deleteIndividuals(ids);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${ids.length} individual(s)')),
        );
      }
      await _loadIndividuals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Individuals',
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
            onPressed: _loadIndividuals,
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
            : _buildTableCard(),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          color: Colors.transparent,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isDeleting ? null : _deleteSelected,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.red.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete_forever),
              label: Text(_isDeleting ? 'Deleting...' : 'Delete Selected (${_selectedIds.length})'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: lightTealColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Individuals (${_filteredIndividuals.length}/${_individuals.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkTealColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search individuals by name...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.search, color: tealColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: tealColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Select')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Tasks')),
                  ],
                  rows: _filteredIndividuals.map((person) {
                    final String id = person['id'] ?? '';
                    final String name = person['name'] ?? 'Unknown';
                    final int tasks = _taskCountOf(person);
                    final bool selected = _selectedById[id] ?? false;
                    return DataRow(
                      selected: selected,
                      cells: [
                        DataCell(
                          Checkbox(
                            value: selected,
                            onChanged: (v) {
                              setState(() {
                                _selectedById[id] = v ?? false;
                              });
                            },
                          ),
                        ),
                        DataCell(Text(name)),
                        DataCell(Text(tasks.toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


