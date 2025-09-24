import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../wigdets/bottom_nav.dart'; // Fixed import path

// Model for ride history
class RideHistory {
  final String id;
  final double amount;
  final DateTime dateTime;
  final int duration; // in minutes
  final double rating;
  final String pickupLocation;
  final String dropoffLocation;
  final List<String> passengerNames;
  final int passengerCount;
  final String carModel;
  final String plateNumber;
  final double distance; // in km

  RideHistory({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.duration,
    required this.rating,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.passengerNames,
    required this.passengerCount,
    required this.carModel,
    required this.plateNumber,
    required this.distance,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 1; // History tab is at index 1

  // Sample data - replace with actual API call
  final List<RideHistory> _rides = [
    RideHistory(
      id: '1',
      amount: 12.50,
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      duration: 15,
      rating: 5.0,
      pickupLocation: 'Mlimani City Mall',
      dropoffLocation: 'University of Dar es Salaam',
      passengerNames: ['James Mwakili', 'Sarah Mushi'],
      passengerCount: 2,
      carModel: 'Toyota Corolla',
      plateNumber: 'T 123 ABC',
      distance: 8.5,
    ),
    RideHistory(
      id: '2',
      amount: 15.75,
      dateTime: DateTime.now().subtract(const Duration(hours: 4)),
      duration: 20,
      rating: 4.8,
      pickupLocation: 'Kariakoo Market',
      dropoffLocation: 'Masaki Peninsula',
      passengerNames: ['John Doe'],
      passengerCount: 1,
      carModel: 'Honda Fit',
      plateNumber: 'T 456 DEF',
      distance: 12.3,
    ),
    RideHistory(
      id: '3',
      amount: 18.00,
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      duration: 25,
      rating: 5.0,
      pickupLocation: 'Julius Nyerere Airport',
      dropoffLocation: 'Posta Mpya',
      passengerNames: ['Jane Smith', 'Ali Hassan'],
      passengerCount: 2,
      carModel: 'Nissan Note',
      plateNumber: 'T 789 GHI',
      distance: 15.7,
    ),
    RideHistory(
      id: '4',
      amount: 14.20,
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      duration: 18,
      rating: 5.0,
      pickupLocation: 'Mwenge',
      dropoffLocation: 'Ubungo Bus Terminal',
      passengerNames: ['Grace Mushi'],
      passengerCount: 1,
      carModel: 'Suzuki Swift',
      plateNumber: 'T 321 JKL',
      distance: 9.2,
    ),
    RideHistory(
      id: '5',
      amount: 22.50,
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
      duration: 30,
      rating: 4.9,
      pickupLocation: 'Mikocheni',
      dropoffLocation: 'Tegeta',
      passengerNames: ['Peter Mwaipopo', 'Anna Eric'],
      passengerCount: 2,
      carModel: 'Toyota Vitz',
      plateNumber: 'T 654 MNO',
      distance: 18.5,
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to different screens based on tab
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Stay on history screen
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final rideDate = DateTime(date.year, date.month, date.day);

    if (rideDate == today) {
      return 'Today';
    } else if (rideDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  Map<String, List<RideHistory>> _groupRidesByDate() {
    final Map<String, List<RideHistory>> grouped = {};

    for (var ride in _rides) {
      final dateLabel = _getDateLabel(ride.dateTime);
      if (!grouped.containsKey(dateLabel)) {
        grouped[dateLabel] = [];
      }
      grouped[dateLabel]!.add(ride);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Ride History',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHistory,
        color: AppColors.primaryBlue,
        child: _buildRidesList(),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Future<void> _refreshHistory() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Fetch updated ride history from API
    setState(() {});
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter History', style: AppTextStyles.headingMedium),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Last 7 days'),
              onTap: () {
                // TODO: Implement filter
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Last 30 days'),
              onTap: () {
                // TODO: Implement filter
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Custom range'),
              onTap: () {
                // TODO: Implement date picker
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRidesList() {
    if (_rides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No rides yet',
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ride history will appear here',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final groupedRides = _groupRidesByDate();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedRides.length,
      itemBuilder: (context, index) {
        final dateLabel = groupedRides.keys.elementAt(index);
        final rides = groupedRides[dateLabel]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            _buildDateHeader(dateLabel),
            const SizedBox(height: 12),
            ...rides.map(
              (ride) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRideItem(ride),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(String date) {
    return Text(
      date,
      style: AppTextStyles.headingMedium.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRideItem(RideHistory ride) {
    return GFCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      elevation: 2,
      content: InkWell(
        onTap: () => _showRideDetails(ride),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Ride details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TZS ${ride.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              ride.rating.toString(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('h:mm a').format(ride.dateTime)} • ${ride.duration} min • ${ride.distance} km',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${ride.pickupLocation} → ${ride.dropoffLocation}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRideDetails(RideHistory ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Text('Ride Details', style: AppTextStyles.headingMedium),
              const SizedBox(height: 20),

              // Amount and rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TZS ${ride.amount.toStringAsFixed(2)}',
                        style: AppTextStyles.headingLarge.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'EEEE, MMM d, y • h:mm a',
                        ).format(ride.dateTime),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          ride.rating.toString(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Trip details
              _buildDetailRow('Distance', '${ride.distance} km'),
              _buildDetailRow('Duration', '${ride.duration} minutes'),
              const Divider(height: 32),

              // Locations
              _buildLocationRow(
                Icons.radio_button_checked,
                'Pickup',
                ride.pickupLocation,
                Colors.green, // Fixed color reference
              ),
              const SizedBox(height: 16),
              _buildLocationRow(
                Icons.location_on,
                'Drop-off',
                ride.dropoffLocation,
                Colors.red, // Fixed color reference
              ),
              const Divider(height: 32),

              // Driver details
              Text(
                'Passenger Details',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Number of Passengers',
                ride.passengerCount.toString(),
              ),
              ...ride.passengerNames.map(
                (name) => _buildDetailRow('Passenger', name),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement receipt download
                      },
                      icon: const Icon(Icons.receipt),
                      label: const Text('Receipt'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.primaryBlue),
                        foregroundColor: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement help
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text('Get Help'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String location,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(location, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
