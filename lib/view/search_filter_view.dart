import 'package:companyproject/model/room_filter_model.dart';
import 'package:companyproject/viewmodel/room_viewmodel.dart';
import 'package:companyproject/widget/empty_state.dart';
import 'package:companyproject/widget/loading_indicator.dart';
import 'package:companyproject/widget/room_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SearchFilterView extends StatefulWidget {
  const SearchFilterView({super.key});

  @override
  State<SearchFilterView> createState() => _SearchFilterViewState();
}

class _SearchFilterViewState extends State<SearchFilterView> {
  final _minCapacityController = TextEditingController();
  bool? _requiresAC;
  bool? _requiresWashroom;
  bool _showOnlyAvailable = false;

  @override
  void dispose() {
    _minCapacityController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filter = RoomFilter(
      minCapacity: _minCapacityController.text.isNotEmpty
          ? int.tryParse(_minCapacityController.text)
          : null,
      requiresAC: _requiresAC,
      requiresAttachedWashroom: _requiresWashroom,
      showOnlyAvailable: _showOnlyAvailable ? true : null,
    );

    context.read<RoomViewModel>().applyFilters(filter);
  }

  void _clearFilters() {
    setState(() {
      _minCapacityController.clear();
      _requiresAC = null;
      _requiresWashroom = null;
      _showOnlyAvailable = false;
    });
    context.read<RoomViewModel>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter Rooms'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // Filter Panel
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Filter Options',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Minimum Capacity
                  Text(
                    'Minimum Capacity',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _minCapacityController,
                    decoration: InputDecoration(
                      hintText: 'Enter min capacity',
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),

                  // AC Requirement
                  Text(
                    'Air Conditioning',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTriStateDropdown(
                    value: _requiresAC,
                    onChanged: (value) {
                      setState(() => _requiresAC = value);
                    },
                    icon: Icons.ac_unit,
                  ),
                  const SizedBox(height: 20),

                  // Washroom Requirement
                  Text(
                    'Attached Washroom',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTriStateDropdown(
                    value: _requiresWashroom,
                    onChanged: (value) {
                      setState(() => _requiresWashroom = value);
                    },
                    icon: Icons.bathroom,
                  ),
                  const SizedBox(height: 20),

                  // Show Only Available
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: CheckboxListTile(
                      title: const Text('Only Available Rooms'),
                      subtitle: const Text('Hide occupied rooms'),
                      secondary: const Icon(Icons.check_circle_outline),
                      value: _showOnlyAvailable,
                      onChanged: (value) {
                        setState(() => _showOnlyAvailable = value ?? false);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.search),
                    label: const Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Active Filters Info
                  Consumer<RoomViewModel>(
                    builder: (context, viewModel, child) {
                      if (!viewModel.hasActiveFilters) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Active Filters',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${viewModel.filteredRooms.length} room(s) found',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Results Area
          Expanded(
            child: Consumer<RoomViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const LoadingIndicator(message: 'Searching rooms...');
                }

                if (viewModel.filteredRooms.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'No Rooms Found',
                    message: viewModel.hasActiveFilters
                        ? 'No rooms match your search criteria. Try adjusting your filters.'
                        : 'Use the filter panel to search for rooms.',
                    action: viewModel.hasActiveFilters
                        ? ElevatedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Filters'),
                    )
                        : null,
                  );
                }

                return _buildResultsGrid(viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriStateDropdown({
    required bool? value,
    required ValueChanged<bool?> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<bool?>(
        value: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: const [
          DropdownMenuItem(
            value: null,
            child: Text('Any'),
          ),
          DropdownMenuItem(
            value: true,
            child: Text('Required'),
          ),
          DropdownMenuItem(
            value: false,
            child: Text('Not Required'),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResultsGrid(RoomViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Results',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${viewModel.filteredRooms.length} room(s) found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => viewModel.loadRooms(),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Results Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                  ? 2
                  : 1;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: viewModel.filteredRooms.map((room) {
                  final cardWidth =
                      (constraints.maxWidth - (16 * (crossAxisCount - 1))) /
                          crossAxisCount;
                  return SizedBox(
                    width: cardWidth,
                    child: RoomCard(room: room),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}