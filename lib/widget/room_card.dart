import 'package:companyproject/model/room_model.dart';
import 'package:flutter/material.dart';


class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final VoidCallback? onAllocate;
  final VoidCallback? onDeallocate;
  final VoidCallback? onDelete;

  const RoomCard({
    super.key,
    required this.room,
    this.onTap,
    this.onAllocate,
    this.onDeallocate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: room.isAllocated
              ? Colors.orange.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with room number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.meeting_room,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Room ${room.roomNumber}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 16),

              // Room details
              _buildDetailRow(
                context,
                Icons.people,
                'Capacity',
                '${room.capacity} ${room.capacity == 1 ? 'Person' : 'Persons'}',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                Icons.ac_unit,
                'AC',
                room.hasAC ? 'Available' : 'Not Available',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                Icons.bathroom,
                'Attached Washroom',
                room.hasAttachedWashroom ? 'Yes' : 'No',
              ),

              // Allocation info
              if (room.isAllocated) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Allocated to: ${room.allocatedTo}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Actions
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: onDelete,
                      tooltip: 'Delete Room',
                    ),
                  if (!room.isAllocated && onAllocate != null)
                    TextButton.icon(
                      onPressed: onAllocate,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Allocate'),
                    ),
                  if (room.isAllocated && onDeallocate != null)
                    TextButton.icon(
                      onPressed: onDeallocate,
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Deallocate'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
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

  Widget _buildStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: room.isAllocated
            ? Colors.orange.withOpacity(0.2)
            : Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: room.isAllocated ? Colors.orange : Colors.green,
          width: 1,
        ),
      ),
      child: Text(
        room.isAllocated ? 'Occupied' : 'Available',
        style: TextStyle(
          color: room.isAllocated ? Colors.orange[800] : Colors.green[800],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}