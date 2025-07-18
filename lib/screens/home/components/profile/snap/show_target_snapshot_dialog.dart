import 'package:blisso_mobile/screens/home/components/profile/snap/added_target_snaps_provider.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/new_target_snap.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/snapshot.dart';
import 'package:blisso_mobile/screens/home/components/profile/snap/target_snapshot_tab.dart';
import 'package:blisso_mobile/services/profile/my_profile_service_provider.dart';
import 'package:blisso_mobile/services/snapshots/snapshot_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showTargetSnapshotDialog(BuildContext context, WidgetRef ref) async {
  if (ref.read(snapshotServiceProviderImpl).data == null) {
    await ref.read(snapshotServiceProviderImpl.notifier).getLifeSnapshots();
  }
  final snapshots = ref.watch(snapshotServiceProviderImpl).data;

  final addedSnaps = ref.read(addedTargetSnapsProviderImpl);

  final Map<String, List<Snapshot>> grouped = {};
  for (var snap in snapshots) {
  if (!addedSnaps.contains(snap['id'])) {
    grouped.putIfAbsent(snap['sub_category'], () => []).add(
      Snapshot(
        id: snap['id'],
        category: snap['category'],
        subCategory: snap['sub_category'],
        name: snap['name'],
      ),
    );
  }
}
  final subCategories = grouped.keys.toList();

  showDialog(
    context: context,
    builder: (context) {
      final snapshotWatch = ref.watch(snapshotServiceProviderImpl);
      return DefaultTabController(
        length: subCategories.length,
        child: AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  indicatorColor: GlobalColors.primaryColor,
                  labelColor: GlobalColors.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: subCategories.map((sub) => Tab(text: sub)).toList(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: subCategories.map((sub) {
                      return TargetSnapshotTab(snapshots: grouped[sub]!);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: GlobalColors.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newSnaps = ref.read(newTargetSnapProviderImpl);
                await ref
                    .read(snapshotServiceProviderImpl.notifier)
                    .addTargetSnapshot(newSnaps);

                for(var sn in newSnaps) {
                  ref.read(myProfileServiceProviderImpl.notifier).addTargetSnapshot(sn);
                }

                Navigator.of(context).pop();
              },
              child: snapshotWatch.isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.green,
                    )
                  : const Text(
                      "Submit",
                      style: TextStyle(color: Colors.green),
                    ),
            ),
          ],
        ),
      );
    },
  );
}
