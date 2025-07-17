import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/expandable_text_component.dart';
import 'package:blisso_mobile/components/popup_component.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class PaySubsriptionScreen extends StatefulWidget {
  final String code;
  final String name;
  final double rwPrice;
  final String usdPrice;
  final int months;
  final String currency;
  const PaySubsriptionScreen(
      {super.key,
      required this.code,
      required this.name,
      required this.rwPrice,
      required this.usdPrice,
      required this.months,
      required this.currency});

  @override
  State<PaySubsriptionScreen> createState() => _PaySubsriptionScreenState();
}

class _PaySubsriptionScreenState extends State<PaySubsriptionScreen> {
  String selectedOption = '';
  int index = 0;

  @override
  Widget build(BuildContext context) {
    bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    return SafeArea(
        child: Scaffold(
          backgroundColor: isLightTheme ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isLightTheme ? Colors.white : Colors.black,
        title: const Text('Payment'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_left)),
      ),
      body: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExpandableTextComponent(
                text:
                    'Payment for ${widget.name} with amount: ${widget.currency == 'RWF' ? widget.rwPrice : widget.usdPrice} ${widget.currency}'),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: ExpandableTextComponent(
                  text: 'Please Select one of the options'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedOption = 'card';
                      });
                    },
                    child: Card(
                      color: selectedOption == 'card'
                          ? Colors.green
                          : isLightTheme
                              ? Colors.grey[100]
                              : Colors.grey[700],
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(Icons.card_giftcard_outlined),
                            Text('Pay By Card')
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.currency == 'RWF')
                    InkWell(
                      onTap: () {
                        setState(() {
                          selectedOption = 'momo';
                        });
                      },
                      child: Card(
                        color: selectedOption == 'momo'
                            ? Colors.green
                            : isLightTheme
                                ? Colors.grey[100]
                                : Colors.grey[700],
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(Icons.card_giftcard_outlined),
                              Text('Pay By Mobile Money')
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: ButtonComponent(
                  text: 'Submit',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  onTap: () => selectedOption == 'card'
                      ? Routemaster.of(context)
                          .replace('/homepage/card')
                      : showPopupComponent(
                          context: context,
                          icon: Icons.close,
                          message: 'This option is not yet implemented')),
            )
          ],
        ),
      ),
    ));
  }
}
