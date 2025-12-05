import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Response/api.dart';
import 'package:rusticgram/Route/route_manager.dart';

class CommonErrorDialog extends StatelessWidget {
  const CommonErrorDialog({super.key, required this.content, this.onPressed});

  final String? content;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.fillColor,
      title: SvgPicture.asset(AppAssets.errorIcon),
      content: Text(content ?? "Something Went Wrong. Please Try Again", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      actions: [
        ElevatedButton(
          onPressed: () {
            onPressed?.call();
            RouteManager(context).popBack();
          },
          child: const Text("OKAY"),
        ),
      ],
    );
  }
}

class AccountStatusDialog extends StatelessWidget {
  const AccountStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.fillColor,
      title: SvgPicture.asset(AppAssets.errorIcon),
      content: Text("Your account is currently inactive. To reactivate it, please contact us for assistance.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      actions: [
        InkWell(
          onTap: () => CommonFunction.openingExternalWebPage(API.reactivateURL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Contact Us",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.body7Color, color: AppColors.body7Color),
              ),
              Padding(padding: const EdgeInsets.only(left: 10.0), child: SvgPicture.asset(AppAssets.whatsappIcon)),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomerSupportDialog extends StatelessWidget {
  const CustomerSupportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: AppColors.fillColor,
      insetPadding: const EdgeInsets.all(15.0),
      title: Text("Customer Support", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
      actionsAlignment: MainAxisAlignment.center,
      content: Text(
        "You can easily reach us on WhatsApp for any queries just send us a message, and we'll be happy to assist you!",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        ElevatedButton(
          onPressed: () => CommonFunction.openingExternalWebPage(API.customerSupport),
          style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.3, 50.0))),
          child: const Text("CHAT"),
        ),
        const SizedBox(width: 20.0),
        ElevatedButton(
          onPressed: () => RouteManager(context).popBack(),
          style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(width * 0.32, 50.0)), backgroundColor: WidgetStatePropertyAll(AppColors.grey)),
          child: Text("CANCEL"),
        ),
      ],
    );
  }
}

class DownloadStatus extends StatelessWidget {
  const DownloadStatus({super.key, required this.title, required this.content});

  final String title;

  final String content;

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.fillColor,
    title: Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
    actionsAlignment: MainAxisAlignment.center,
    content: Text(content, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
  );
}

class OrderCancelled extends StatelessWidget {
  const OrderCancelled({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.fillColor,
      title: Text("Order Cancelled", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
      content: Text("Your Order have been cancelled", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
      actions: [ElevatedButton(onPressed: () => RouteManager(context).homePage(), child: const Text("OKAY"))],
    );
  }
}
