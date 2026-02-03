import 'package:companyproject/model/room_model.dart';
import 'package:companyproject/viewmodel/room_viewmodel.dart';
import 'package:companyproject/widget/empty_state.dart';
import 'package:companyproject/widget/loading_indicator.dart';
import 'package:companyproject/widget/room_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ViewRoomsView extends StatefulWidget {
  const ViewRoomsView({super.key});

  @override
  State<ViewRoomsView> createState() => _ViewRoomsViewState();
}

class _ViewRoomsViewState extends State<ViewRoomsView> {
  String _selectedView = 'grid'; // 'grid' or 'table'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Rooms'),
        centerTitle: true,
        actions: [
          // View Toggle
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'grid',
                  icon: Icon(Icons.grid_view),
                  label: Text('Grid'),
                ),
                ButtonSegment(
                  value: 'table',
                  icon: Icon(Icons.table_chart),
                  label: Text('Table'),
                ),
              ],
              selected: {_selectedView},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedView = newSelection.first;
                });
              },
            ),
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RoomViewModel>().loadRooms();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<RoomViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.filteredRooms.isEmpty) {
            return const LoadingIndicator(message: 'Loading rooms...');
          }

          if (viewModel.filteredRooms.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.meeting_room_outlined,
              title: 'No Rooms Found',
              message: viewModel.hasActiveFilters
                  ? 'No rooms match your filter criteria. Try adjusting your filters.'
                  : 'No rooms available. Add your first room to get started.',
              action: viewModel.hasActiveFilters
                  ? ElevatedButton.icon(
                onPressed: () {
                  viewModel.clearFilters();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
              )
                  : null,
            );
          }

          return _selectedView == 'grid'
              ? _buildGridView(viewModel)
              : _buildTableView(viewModel);
        },
      ),
    );
  }

  Widget _buildGridView(RoomViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.loadRooms(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1200
                ? 3
                : constraints.maxWidth > 800
                ? 2
                : 1;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: viewModel.filteredRooms.map((room) {
                final cardWidth = (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;
                return SizedBox(
                  width: cardWidth,
                  child: RoomCard(
                    room: room,
                    onDelete: room.isAllocated
                        ? null
                        : () => _confirmDelete(context, room, viewModel),
                    onDeallocate: room.isAllocated
                        ? () => _confirmDeallocate(context, room, viewModel)
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTableView(RoomViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Room No.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Capacity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'AC',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Washroom',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Allocated To',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: viewModel.filteredRooms.map((room) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        room.roomNumber,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text('${room.capacity}')),
                    DataCell(
                      Icon(
                        room.hasAC ? Icons.check_circle : Icons.cancel,
                        color: room.hasAC ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    DataCell(
                      Icon(
                        room.hasAttachedWashroom
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: room.hasAttachedWashroom ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    DataCell(
                      _buildStatusChip(room.isAllocated),
                    ),
                    DataCell(
                      Text(
                        room.allocatedTo ?? '-',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (room.isAllocated)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.orange,
                              onPressed: () =>
                                  _confirmDeallocate(context, room, viewModel),
                              tooltip: 'Deallocate',
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () =>
                                  _confirmDelete(context, room, viewModel),
                              tooltip: 'Delete',
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isAllocated) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAllocated
            ? Colors.orange.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAllocated ? Colors.orange : Colors.green,
          width: 1,
        ),
      ),
      child: Text(
        isAllocated ? 'Occupied' : 'Available',
        style: TextStyle(
          color: isAllocated ? Colors.orange[800] : Colors.green[800],
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      Room room,
      RoomViewModel viewModel,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete Room ${room.roomNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.deleteRoom(room.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Room ${room.roomNumber} deleted successfully'
                  : 'Failed to delete room',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _confirmDeallocate(
      BuildContext context,
      Room room,
      RoomViewModel viewModel,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text('Confirm Deallocation'),
          ],
        ),
        content: Text(
          'Are you sure you want to deallocate Room ${room.roomNumber} from ${room.allocatedTo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deallocate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.deallocateRoom(room.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Room ${room.roomNumber} deallocated successfully'
                  : 'Failed to deallocate room',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}