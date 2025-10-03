import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/screens/explore/user_card.dart';
import 'package:blisso_mobile/services/matching/matching_service_provider.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/permissions/permission_provider.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class MatchingRecommendations extends ConsumerStatefulWidget {
  const MatchingRecommendations({super.key});

  @override
  ConsumerState<MatchingRecommendations> createState() =>
      _MatchingRecommendationsState();
}

class _MatchingRecommendationsState
    extends ConsumerState<MatchingRecommendations> {
  final Map<String, bool> _loadingStates = {};
  final int _previewItemLimit = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(matchingServiceProviderImpl).data == null) {
        ref.read(matchingServiceProviderImpl.notifier).getMatchingScores();
      }
    });
  }

  void _loadProfile(Map<String, dynamic> user) async {
    final username = user['username'];
    
    setState(() {
      _loadingStates[username] = true;
    });

    try {
      final profileRef = ref.read(anyProfileServiceProviderImpl.notifier);
      await profileRef.getAnyProfile(username);

      final targetProfile = ref.read(targetProfileProvider.notifier);
      final profileData = ref.read(anyProfileServiceProviderImpl);

      targetProfile.updateTargetProfile(
          TargetProfileModel.fromMap(profileData.data as Map<String, dynamic>));

      if (mounted) {
        Routemaster.of(context).push('/homepage/target-profile');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to load profile');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStates.remove(username);
        });
      }
    }
  }

  int _getItemCount(List<dynamic> data, bool canViewRecommendations) {
    if (canViewRecommendations) {
      return data.length;
    } else {
      return data.length > _previewItemLimit ? _previewItemLimit : data.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingServiceProviderImpl);
    final canViewRecommendations = ref.watch(permissionProviderImpl.select(
      (value) => value['can_view_matching_recommendations'] == true,
    ));

    if (matchingState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBar(context, matchingState.error!);
      });
    }

    if (matchingState.isLoading || matchingState.data == null) {
      return const LoadingScreen();
    }

    final data = matchingState.data!;
    final itemCount = _getItemCount(data, canViewRecommendations);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 0.1,
          mainAxisSpacing: 0.1,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          final user = data[index];
          final username = user['username'];
          final isLoading = _loadingStates[username] == true;
          
          return UserCard(
            user: user,
            isLoading: isLoading,
            isPreview: !canViewRecommendations,
            onTap: canViewRecommendations ? () => _loadProfile(user) : null,
          );
        },
      ),
    );
  }
}