import 'package:flutter/material.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:upgrader/upgrader.dart';

class CustomUpgradeAlert extends UpgradeAlert {
  CustomUpgradeAlert({super.key, super.upgrader, super.child});
  @override
  UpgradeAlertState createState() => CustomUpgradeAlertState();
}

class CustomUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    double width = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          key: key,
          backgroundColor: AppColors.fillColor,
          insetPadding: const EdgeInsets.all(15.0),
          title: Text('New Update Available!', style: Theme.of(context).textTheme.titleSmall),
          content: Text(message, style: Theme.of(context).textTheme.displaySmall),
          actions: <Widget>[
            if (!CommonFunction.forceUpdateEnabled)
              ElevatedButton(
                style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.3, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
                child: const Text('LATER'),
                onPressed: () => Navigator.pop(context),
              ),
            ElevatedButton(
              style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.36, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.redColor)),
              child: const Text('UPGRADE'),
              onPressed: () => onUserUpdated(context, !widget.upgrader.blocked()),
            ),
          ],
        );
      },
    );
  }
}
