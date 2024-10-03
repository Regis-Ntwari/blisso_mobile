import 'package:flutter/material.dart';

class BiometricButtonComponent extends StatelessWidget {
  const BiometricButtonComponent({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
            shadowColor: Colors.black,
            fixedSize: Size(width * 0.90, height * 0.05),
            backgroundColor: Colors.white,
            foregroundColor: Colors.red),
        onPressed: () {},
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint),
            Text(
              'Login using Biometrics',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ));
  }
}
