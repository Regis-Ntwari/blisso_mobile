import 'package:blisso_mobile/screens/home/components/profile/snap/added_target_snaps_provider.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/snapshot.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetSnapshotTab extends ConsumerStatefulWidget {
  final List<Snapshot> snapshots;

  const TargetSnapshotTab({super.key, required this.snapshots});

  @override
  ConsumerState<TargetSnapshotTab> createState() => _SnapshotTabState();
}

class _SnapshotTabState extends ConsumerState<TargetSnapshotTab> {
  Future<void> showScaleDialog(Snapshot snap) async {
    double scale = 5;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Scale for ${snap.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return Slider(
                    value: scale,
                    min: 1,
                    max: 10,
                    activeColor: GlobalColors.primaryColor,
                    divisions: 9,
                    label: scale.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        scale = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                ref.read(addedTargetSnapsProviderImpl.notifier).addSnapshot({
                  'lifesnapshot_id': snap.id,
                  'name': snap.name,
                  'sub_category': snap.subCategory,
                  'category': snap.category,
                  'target_scale': scale.toInt(),
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.brightnessOf(context) == Brightness.light;
    final addedSnaps = ref.watch(addedTargetSnapsProviderImpl);
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.snapshots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (context, index) {
        final snap = widget.snapshots[index];
        var isSelected = false;

        for (var i in addedSnaps) {
          if (i['lifesnapshot_id'] == snap.id) {
            isSelected = true;
          }
        }

        return GestureDetector(
          onTap: () {
            if (isSelected) {
              ref.read(addedTargetSnapsProviderImpl.notifier).removeSnapshot(snap.id);
            } else {
              showScaleDialog(snap);
            }
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
                      color: isLightTheme ? Colors.black : Colors.white,
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
