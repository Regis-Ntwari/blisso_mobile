import 'package:blisso_mobile/screens/home/components/profile/snap/added_snaps_provider.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnapshotTab extends ConsumerStatefulWidget {
  final List<Snapshot> snapshots;

  const SnapshotTab({super.key, required this.snapshots});

  @override
  ConsumerState<SnapshotTab> createState() => _SnapshotTabState();
}

class _SnapshotTabState extends ConsumerState<SnapshotTab> {

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.snapshots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // change to 3 if you want tighter layout
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) {
        final snap = widget.snapshots[index];
        final isSelected = ref.read(addedSnapsProviderImpl).contains(snap.id);

        return GestureDetector(
          onTap: () {
            setState(() {
              ref.read(addedSnapsProviderImpl.notifier).addSnapshot(snap.id);
              // if (isSelected) {
              //   selectedIds.remove(snap.id);
              // } else {
              //   selectedIds.add(snap.id);
              // }
            });
          },
          child: Stack(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                elevation: 3,
                child: Center(
                  child: Text(
                    snap.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              if (isSelected)
                const Positioned(
                  top: 5,
                  right: 5,
                  child: Icon(
                    Icons.verified,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
