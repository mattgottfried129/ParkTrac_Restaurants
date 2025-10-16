import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/firestore_service.dart';
import '../theme/colors.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  String? _filterResort;
  final _searchController = TextEditingController();
  bool _isOffline = false; // Track Firestore connection state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Restaurants'),
        backgroundColor: AppColors.wdw,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Filters',
            onPressed: () {
              setState(() {
                _filterResort = null;
                _searchController.clear();
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: _showAddRestaurantDialog,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              width: double.infinity,
              color: Colors.redAccent,
              padding: const EdgeInsets.all(8),
              child: const Center(
                child: Text(
                  'Offline Mode – showing cached data',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<Restaurant>>(
              stream: FirestoreService.streamRestaurants(),
              builder: (context, snapshot) {
                List<Restaurant> restaurants = [];
                _isOffline = false;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  restaurants = FirestoreService.getLocalRestaurants();
                  _isOffline = true;
                } else if (snapshot.hasError) {
                  restaurants = FirestoreService.getLocalRestaurants();
                  _isOffline = true;
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  restaurants = snapshot.data!;
                } else {
                  restaurants = FirestoreService.getLocalRestaurants();
                  _isOffline = true;
                }

                final filtered = restaurants.where((r) {
                  final matchesResort =
                      _filterResort == null || r.resort.trim() == _filterResort;
                  final matchesSearch = r.name
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                  return matchesResort && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No restaurants found.'),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final r = filtered[i];
                    final isWDW = r.resort.toLowerCase() == 'wdw';
                    final accent = isWDW ? AppColors.wdw : AppColors.uni;

                    return Dismissible(
                      key: ValueKey(r.name),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        await FirestoreService.deleteRestaurant(r.name);
                        setState(() {});
                      },
                      child: Card(
                        color: AppColors.cream,
                        elevation: 3,
                        shadowColor: AppColors.shadow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            r.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: accent,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r.location} • ${r.type}',
                                  style: const TextStyle(
                                      color: AppColors.textDark)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Heather:',
                                          style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 4),
                                      _buildEditableStars(r, true),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Matt:',
                                          style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 4),
                                      _buildEditableStars(r, false),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              r.visited
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: r.visited ? AppColors.gold : Colors.grey,
                            ),
                            onPressed: () async {
                              r.visited = !r.visited;
                              await FirestoreService.updateRestaurant(r);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// --- Build editable star ratings ---
  Widget _buildEditableStars(Restaurant r, bool isHeather) {
    final rating = isHeather ? r.ratingHeather : r.ratingMatt;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = rating >= starValue;
        return IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          iconSize: 18,
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? AppColors.gold : Colors.grey,
          ),
          onPressed: () async {
            setState(() {
              if (filled && rating == starValue) {
                if (isHeather) {
                  r.ratingHeather = 0;
                } else {
                  r.ratingMatt = 0;
                }
              } else {
                if (isHeather) {
                  r.ratingHeather = starValue.toDouble();
                } else {
                  r.ratingMatt = starValue.toDouble();
                }
              }
            });
            await FirestoreService.updateRestaurant(r);
          },
        );
      }),
    );
  }

  /// --- Filter/Search bar ---
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cream,
                labelText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String?>(
            value: _filterResort,
            hint: const Text('Filter'),
            items: const [
              DropdownMenuItem(value: 'WDW', child: Text('Walt Disney World')),
              DropdownMenuItem(
                  value: 'Universal', child: Text('Universal Orlando')),
            ],
            onChanged: (v) => setState(() => _filterResort = v),
          ),
        ],
      ),
    );
  }

  /// --- Add restaurant dialog ---
  void _showAddRestaurantDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final typeController = TextEditingController();
    String resortValue = 'WDW';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add New Restaurant',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: typeController,
              decoration:
              const InputDecoration(labelText: 'Type (Quick, Table, etc)'),
            ),
            DropdownButtonFormField<String>(
              initialValue: resortValue,
              items: const [
                DropdownMenuItem(
                    value: 'WDW', child: Text('Walt Disney World')),
                DropdownMenuItem(
                    value: 'Universal', child: Text('Universal Orlando')),
              ],
              onChanged: (v) => resortValue = v ?? 'WDW',
              decoration: const InputDecoration(labelText: 'Resort'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final newRestaurant = Restaurant(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                    type: typeController.text.trim(),
                    resort: resortValue,
                  );
                  await FirestoreService.addRestaurant(newRestaurant);
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
