import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../models/restaurant.dart';
import '../services/firestore_service.dart';
import '../services/hive_boxes.dart';
import '../theme/colors.dart'; // Ensure AppColors is imported

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isOnline = true;
  bool _showBanner = false;
  bool _isSyncing = false;
  String _bannerText = '';
  Timer? _bannerTimer;
  DateTime? _lastSynced;
  StreamSubscription? _firestoreSub;

  @override
  void initState() {
    super.initState();
    _initFirestoreConnectionListener();
  }

  void _initFirestoreConnectionListener() {
    _firestoreSub = FirebaseFirestore.instance.snapshotsInSync().listen((_) {
      _updateStatus(true);
    }, onError: (_) {
      _updateStatus(false);
    });
  }

  void _updateStatus(bool online) {
    if (online != _isOnline) {
      setState(() {
        _isOnline = online;
        _lastSynced = DateTime.now();
        _bannerText = online
            ? '🟢 Online – Connected to Firestore • Last synced: ${_formatTime(_lastSynced!)}'
            : '🔴 Offline Mode – Showing Cached Data';
        _showBanner = true;
      });

      _bannerTimer?.cancel();
      _bannerTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showBanner = false);
      });
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  Future<void> _syncNow(BuildContext context) async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    _showSnack(context, '🔄 Syncing data to Firestore...', AppColors.gold, 2500);

    try {
      await FirestoreService.syncLocalToCloud();
      setState(() => _lastSynced = DateTime.now());
      _showSnack(context, '✅ Sync complete!', AppColors.wdw, 1800);
    } catch (e) {
      _showSnack(context, '⚠️ Sync failed: $e', Colors.red.shade700, 3000);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showSnack(BuildContext context, String text, Color color, int ms) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
              color: AppColors.white, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: ms),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 6,
      ),
    );
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = HiveBoxes.restaurants;
    final localList = box.values.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Restaurant Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.wdw,
        foregroundColor: AppColors.white,
        actions: [
          if (_isOnline)
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
                  : const Icon(Icons.sync),
              tooltip: 'Sync Now',
              onPressed: _isSyncing ? null : () => _syncNow(context),
            ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Restaurant>>(
            stream: FirestoreService.streamRestaurants(),
            builder: (context, snapshot) {
              final onlineList = snapshot.data ?? [];
              final restaurants =
              _isOnline && onlineList.isNotEmpty ? onlineList : localList;

              final wdwCount = restaurants
                  .where((r) => r.resort.toLowerCase() == 'wdw')
                  .length;
              final uniCount = restaurants
                  .where((r) => r.resort.toLowerCase() == 'universal')
                  .length;

              final wdwVisited = restaurants
                  .where((r) =>
              r.resort.toLowerCase() == 'wdw' && (r.visited ?? false))
                  .length;
              final uniVisited = restaurants
                  .where((r) =>
              r.resort.toLowerCase() == 'universal' &&
                  (r.visited ?? false))
                  .length;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildSummaryCard(
                        "Walt Disney World", wdwVisited, wdwCount, AppColors.wdw),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                        "Universal Orlando", uniVisited, uniCount, AppColors.uni),
                  ],
                ),
              );
            },
          ),

          // ✨ Shimmer Notification Strip (temporary)
          AnimatedSlide(
            duration: const Duration(milliseconds: 400),
            offset: _showBanner ? Offset.zero : const Offset(0, -1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showBanner ? 1 : 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Shimmer.fromColors(
                  baseColor: AppColors.gold.withOpacity(0.9),
                  highlightColor: AppColors.cream,
                  period: const Duration(seconds: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Text(
                      _bannerText,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, int visited, int total, Color color) {
    final percent = total == 0 ? 0 : (visited / total * 100);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$visited of $total visited",
                  style: TextStyle(color: color),
                ),
                Text(
                  "${percent.toStringAsFixed(0)}%",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
