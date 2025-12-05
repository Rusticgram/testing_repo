import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/Maintain/maintain_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:rusticgram/Response/api.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Route/route_manager.dart';

class MaintainceView extends StatelessWidget {
  const MaintainceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MaintainCubit, MaintainState>(
        listener: (_, state) {
          if (firebaseAuth.currentUser != null) {
            RouteManager(context).checkingExistingOrder(orderDetailsCubit: context.read<OrderDetailsCubit>(), accountCubit: context.read<AccountCubit>());
          } else {
            RouteManager(context).landingPage();
          }
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.all(20.0), child: SvgPicture.asset(AppAssets.errorIcon)),
              Text("Application is under maintanence so reach out us through WhatsApp", textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: InkWell(
                  onTap: () => CommonFunction.openingExternalWebPage(API.maintainceOrderURL),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
