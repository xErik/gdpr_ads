// import 'package:flutter/material.dart';

// import 'countdowntimer.dart';

// class DialogConfirmAd extends StatefulWidget {
//   final VoidCallback showAd;
//   final VoidCallback showNoAd;

//   const DialogConfirmAd(
//       {Key? key, required this.showAd, required this.showNoAd})
//       : super(key: key);

//   @override
//   DialogConfirmAdState createState() => DialogConfirmAdState();
// }

// class DialogConfirmAdState extends State<DialogConfirmAd> {
//   final CountdownTimer _countdownTimer = CountdownTimer(5);

//   DialogConfirmAdState({Key? key});

//   @override
//   void initState() {
//     _countdownTimer.addListener(() {
//       setState(() {}); // update the timer UI
//       if (_countdownTimer.isComplete) {
//         Navigator.pop(context);
//         widget.showAd();
//       }
//     });
//     _countdownTimer.start();

//     super.initState();
//   }

//   void _showNoAd(BuildContext context) {
//     widget.showNoAd.call();
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Watch a video'),
//       icon: const Icon(Icons.share),
//       content:
//           const Text('Watch an add and support this App, please. Thank you!'),
//       actions: [
//         TextButton(
//             onPressed: () => _showNoAd(context),
//             child: const Text('No thanks')),
//         TextButton(
//             onPressed: null,
//             child:
//                 Text('Video starting in ${_countdownTimer.timeLeft} seconds'))
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _countdownTimer.dispose();
//     super.dispose();
//   }
// }
