import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme.dart';
import '../services/route_services.dart';
import '../routes/route.dart';

class PickLocationDialog extends StatefulWidget {
  const PickLocationDialog({super.key});

  @override
  State<PickLocationDialog> createState() => _PickLocationDialogState();
}

class _PickLocationDialogState extends State<PickLocationDialog> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _routingService = RoutingApiService();

  PlaceResult? _selectedPickup;
  PlaceResult? _selectedDropoff;

  List<PlaceResult> _pickupSuggestions = [];
  List<PlaceResult> _dropoffSuggestions = [];

  bool _isSearchingPickup = false;
  bool _isSearchingDropoff = false;
  bool _showPickupResults = false;
  bool _showDropoffResults = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _searchPickup(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _pickupSuggestions = [];
        _showPickupResults = false;
      });
      return;
    }

    setState(() {
      _isSearchingPickup = true;
      _showPickupResults = true;
    });

    try {
      final results = await _routingService.searchPlaces(query, size: 10);
      if (mounted) {
        setState(() {
          _pickupSuggestions = results;
          _isSearchingPickup = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingPickup = false;
          _pickupSuggestions = [];
        });
        _showError('Pickup search failed: ${e.toString()}');
      }
    }
  }

  Future<void> _searchDropoff(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _dropoffSuggestions = [];
        _showDropoffResults = false;
      });
      return;
    }

    setState(() {
      _isSearchingDropoff = true;
      _showDropoffResults = true;
    });

    try {
      final results = await _routingService.searchPlaces(query, size: 10);
      if (mounted) {
        setState(() {
          _dropoffSuggestions = results;
          _isSearchingDropoff = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingDropoff = false;
          _dropoffSuggestions = [];
        });
        _showError('Dropoff search failed: ${e.toString()}');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectPickup(PlaceResult place) {
    setState(() {
      _selectedPickup = place;
      _pickupController.text = place.label;
      _showPickupResults = false;
      _pickupSuggestions = [];
    });
  }

  void _selectDropoff(PlaceResult place) {
    setState(() {
      _selectedDropoff = place;
      _dropoffController.text = place.label;
      _showDropoffResults = false;
      _dropoffSuggestions = [];
    });
  }

  void _showRoute() {
    if (_selectedPickup == null || _selectedDropoff == null) {
      _showError('Please select both pickup and dropoff locations');
      return;
    }

    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoutes.rides,
      arguments: {
        'start': LatLng(_selectedPickup!.lat, _selectedPickup!.lng),
        'end': LatLng(_selectedDropoff!.lat, _selectedDropoff!.lng),
        'start_address': _selectedPickup!.label,
        'end_address': _selectedDropoff!.label,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Search fields and results
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildPickupField(),
                      const SizedBox(height: 16),
                      _buildDropoffField(),
                      if (_showPickupResults || _showDropoffResults) ...[
                        const SizedBox(height: 16),
                        if (_showPickupResults) _buildPickupResults(),
                        if (_showDropoffResults) _buildDropoffResults(),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Map button
            _buildMapButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            'Your route',
            style: AppTextStyles.headingMedium.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showPickupResults
              ? AppColors.primaryBlue
              : AppColors.primaryBlue.withOpacity(0.2),
          width: _showPickupResults ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.circle_outlined,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _pickupController,
              onChanged: _searchPickup,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Pickup location',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                border: InputBorder.none,
                suffixIcon: _isSearchingPickup
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _pickupController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _pickupController.clear();
                          setState(() {
                            _selectedPickup = null;
                            _pickupSuggestions = [];
                            _showPickupResults = false;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_pickupController.text.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Map',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.location_pin,
                  color: AppColors.primaryBlue,
                ),
                onPressed: () {
                  // Could implement manual pin on map
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropoffField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showDropoffResults
              ? AppColors.primaryBlue
              : AppColors.primaryBlue.withOpacity(0.2),
          width: _showDropoffResults ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.search, color: AppColors.textSecondary, size: 24),
          ),
          Expanded(
            child: TextField(
              controller: _dropoffController,
              onChanged: _searchDropoff,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Dropoff location',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                border: InputBorder.none,
                suffixIcon: _isSearchingDropoff
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _dropoffController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _dropoffController.clear();
                          setState(() {
                            _selectedDropoff = null;
                            _dropoffSuggestions = [];
                            _showDropoffResults = false;
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (_dropoffController.text.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Map',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.location_pin,
                  color: AppColors.primaryBlue,
                ),
                onPressed: () {
                  // Could implement manual pin on map
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPickupResults() {
    if (_pickupSuggestions.isEmpty && !_isSearchingPickup) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No results found',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _pickupSuggestions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppColors.backgroundLight),
        itemBuilder: (context, index) {
          final place = _pickupSuggestions[index];
          return _buildPlaceItem(place, () => _selectPickup(place));
        },
      ),
    );
  }

  Widget _buildDropoffResults() {
    if (_dropoffSuggestions.isEmpty && !_isSearchingDropoff) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No results found',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dropoffSuggestions.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppColors.backgroundLight),
        itemBuilder: (context, index) {
          final place = _dropoffSuggestions[index];
          return _buildPlaceItem(place, () => _selectDropoff(place));
        },
      ),
    );
  }

  Widget _buildPlaceItem(PlaceResult place, VoidCallback onTap) {
    // Calculate distance (placeholder - could use actual distance)
    final distance = '${(place.confidence * 10).toStringAsFixed(1)} km';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.clock,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.label.split(',').first,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.subtitle.isNotEmpty ? place.subtitle : place.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              distance,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapButton() {
    final canProceed = _selectedPickup != null && _selectedDropoff != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: canProceed ? _showRoute : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canProceed
                  ? AppColors.primaryBlue
                  : AppColors.textSecondary.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Show Route',
              style: AppTextStyles.button.copyWith(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
