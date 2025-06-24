import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/services/matching/matching_service_provider.dart';
import 'package:blisso_mobile/services/models/target_profile_model.dart';
import 'package:blisso_mobile/services/profile/any_profile_service_provider.dart';
import 'package:blisso_mobile/services/profile/target_profile_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  String? _loadingUsername;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(matchingServiceProviderImpl).data == null) {
        ref.read(matchingServiceProviderImpl.notifier).getMatchingScores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingServiceProviderImpl);

    if (matchingState.error != null) {
      showSnackBar(context, matchingState.error!);
    }

    if (matchingState.isLoading || matchingState.data == null) {
      return const LoadingScreen();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: matchingState.data.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          final user = matchingState.data[index];
          final isLoadingCard = _loadingUsername == user['username'];

          return InkWell(
            onTap: () async {
              setState(() {
                _loadingUsername = user['username'];
              });

              try {
                final profileRef =
                    ref.read(anyProfileServiceProviderImpl.notifier);
                await profileRef.getAnyProfile(user['username']);

                final targetProfile = ref.read(targetProfileProvider.notifier);
                final profileData = ref.read(anyProfileServiceProviderImpl);

                targetProfile.updateTargetProfile(TargetProfileModel.fromMap(
                    profileData.data as Map<String, dynamic>));

                if (mounted) {
                  Routemaster.of(context).push('/homepage/target-profile');
                }
              } catch (e) {
                showSnackBar(context, 'Failed to load profile');
              } finally {
                if (mounted) {
                  setState(() {
                    _loadingUsername = null;
                  });
                }
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: user['profile_picture_url']!,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: GlobalColors.primaryColor,
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Overlay
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),

                  // Score at top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user['score']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Nickname at bottom
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        user['nickanme'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Loading overlay for this card
                  if (isLoadingCard)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
