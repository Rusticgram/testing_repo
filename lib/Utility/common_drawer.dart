import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/delete_account.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: Column(
      children: [
        const SizedBox(height: 50.0),
        _drawerHeader(context),
        _menuCard(context, onTap: () => RouteManager(context).accountPage(), imageName: AppAssets.accountIcon, title: "Account"),
        if (context.watch<OrderDetailsCubit>().state.orderDetails.orderStatusCode >= 3)
          _menuCard(context, onTap: () => RouteManager(context).orderDetailsPage(true), imageName: AppAssets.orderIcon, title: "Order Tracking"),
        if (context.watch<OrderDetailsCubit>().state.orderDetails.paymentDetails.paymentStatus)
          _menuCard(context, onTap: () => RouteManager(context).serviceSummaryPage(), imageName: AppAssets.invoiceIcon, title: "Service Summary"),
        _menuCard(
          context,
          onTap: () => showDialog(context: context, builder: (cont) => const CustomerSupportDialog()),
          imageName: "",
          icon: Icons.support_agent_rounded,
          title: "Customer Support",
        ),
        _menuCard(context, onTap: () => RouteManager(context).bugReportPage(), imageName: "", icon: Icons.bug_report_outlined, title: "Report Bug"),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () async {
              CommonFunction.logout(accountCubit: context.read<AccountCubit>(), orderDetailsCubit: context.read<OrderDetailsCubit>());
              if (context.mounted) RouteManager(context).loginPage();
            },
            child: const Text("SIGN OUT"),
          ),
        ),
        Padding(padding: const EdgeInsets.all(10.0), child: const DeleteAccount()),
        const SizedBox(height: 20.0),
      ],
    ),
  );

  Widget _drawerHeader(BuildContext context) => BlocBuilder<AccountCubit, AccountState>(
    builder: (context, state) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ListTile(
          leading: Container(
            width: 42.0,
            height: 42.0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: const BoxDecoration(color: Color(0xFFFC6600), shape: BoxShape.circle),
            child: ExtendedImage.memory(
              state.profilePic,
              loadStateChanged: (progressState) {
                if (progressState.extendedImageLoadState == LoadState.loading || progressState.extendedImageLoadState == LoadState.failed) {
                  return Image.asset(AppAssets.defaultProfileIcon, fit: BoxFit.fill);
                }
                return null;
              },
              fit: BoxFit.fill,
            ),
          ),
          trailing: IconButton(
            onPressed: () => RouteManager(context).popBack(),
            icon: const Icon(Icons.close, size: 24.0, color: AppColors.primaryColor),
          ),
          title: Text(state.name, style: Theme.of(context).textTheme.titleSmall),
          subtitle: Text(state.mobile, style: Theme.of(context).textTheme.labelSmall!.copyWith(color: AppColors.primaryColor)),
        ),
      );
    },
  );

  Widget _menuCard(BuildContext context, {required String imageName, IconData? icon, required String title, required Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        selected: true,
        leading: _leadingIcon(imageName: imageName, icon: icon),
        onTap: onTap,
        title: Text(title, style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }

  Widget _leadingIcon({String imageName = "", IconData? icon}) {
    if (icon != null) {
      return Icon(icon, size: 25.0);
    }
    return SvgPicture.asset(imageName, width: 22.0, height: 22.0);
  }
}
