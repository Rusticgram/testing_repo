import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_drawer.dart';
import 'package:rusticgram/Utility/custom_upgrader.dart';
import 'package:upgrader/upgrader.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: const CommonDrawer(),
    appBar: AppBar(
      leadingWidth: 65.0,
      leading: Builder(
        builder: (subContext) => Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              onPressed: Scaffold.of(subContext).openDrawer,
              style: const ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(50.0, 50.0))),
              icon: SvgPicture.asset(AppAssets.menuIcon),
            ),
          ),
        ),
      ),
    ),
    body: CustomUpgradeAlert(
      upgrader: Upgrader(durationUntilAlertAgain: const Duration(hours: 1)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 10.0), child: Image.asset(AppAssets.startOrderImage)),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "Preserving Generational Memories for Generations to Come",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(onPressed: () => RouteManager(context).scheduleOrderPage(), child: const Text("SCHEDULE A PICKUP")),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: TextButton(onPressed: () => RouteManager(context).howWeWorkPage(), child: const Text("How we work?")),
            ),
          ],
        ),
      ),
    ),
  );
}
