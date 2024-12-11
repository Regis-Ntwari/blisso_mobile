import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/screens/home/components/post_card_component.dart';
import 'package:flutter/material.dart';

class HomeComponent extends StatefulWidget {
  final List<dynamic>? profiles;
  const HomeComponent({super.key, required this.profiles});

  @override
  State<HomeComponent> createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return widget.profiles == null
        ? const LoadingScreen()
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (context, index) => PostCardComponent(
                    profile: widget.profiles![index],
                  ),
                  itemCount: widget.profiles!.length,
                ),
              ),
            ],
          );
  }
}
