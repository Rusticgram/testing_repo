import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:rusticgram/Bloc/Account/account_cubit.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:go_router/go_router.dart';
import 'package:rusticgram/Route/page_name.dart';

extension RouteManager on BuildContext {
  void landingPage() => goNamed(PageName.landingScreen);

  void dynamicLinkNavigation({required OrderDetailsCubit orderDetailsCubit, required AccountCubit accountCubit}) {
    bool isDeeplinkNavigation = false;
    FlutterBranchSdk.listSession().listen(
      (data) async {
        final bool clicked = data.containsKey("+clicked_branch_link") && data['+clicked_branch_link'] == true;
        final bool isFirstSession = data['+is_first_session'] == true;
        String source = data['~feature'] ?? "";
        String medium = data['~channel'] ?? "";
        String campaign = data['~campaign'] ?? "";

        if (clicked) {
          if (userDetailsModel.userDetails.id.isNotEmpty) {
            await firebaseAnalytics.logCampaignDetails(
              source: source,
              medium: medium,
              campaign: campaign,
              parameters: {"mobile": phoneNumber, "user_id": userDetailsModel.userDetails.id, "linkInstallation": isFirstSession},
            );
            final path = data['\$deeplink_path'] ?? '';
            // Centralised navigation
            switch (path) {
              case "orderDetails":
                isDeeplinkNavigation = true;
                orderDetailsPage(false); // or use context.push()
                break;
              case "gallery":
                isDeeplinkNavigation = true;
                galleryPage();
                break;
              default:
                {
                  CommonFunction.recordingError(
                    exception: Exception(),
                    stack: StackTrace.empty,
                    functionName: "dynamicLinkNavigation()",
                    error: "Something went wrong when opening dynamic link",
                    input: data,
                  );
                }
            }
          } else {
            await firebaseAnalytics.logCampaignDetails(source: source, medium: medium, campaign: campaign, parameters: {"linkInstallation": isFirstSession});
          }
        }
      },
      onError: (exception, stack) {
        CommonFunction.recordingError(exception: exception, stack: stack, functionName: "dynamicLinkNavigation()", error: "Something went wrong when opening dynamic link", input: "");
      },
    );

    if (!isDeeplinkNavigation) {
      checkingExistingOrder(orderDetailsCubit: orderDetailsCubit, accountCubit: accountCubit);
    }
  }

  Future<void> checkingExistingOrder({required OrderDetailsCubit orderDetailsCubit, required AccountCubit accountCubit}) async {
    if (CommonFunction.maintainceEnabled) {
      goNamed(PageName.maintainceScreen);
    } else {
      if (firebaseAuth.currentUser != null && userDetailsModel.userDetails.id.isNotEmpty && userDetailsModel.userDetails.profileStatus) {
        if (orderDetailsCubit.state.orderDetails.id.isNotEmpty && orderDetailsCubit.state.orderDetails.orderStatusCode != 6) {
          if (orderDetailsCubit.state.orderDetails.orderStatusCode >= 3) {
            goNamed(PageName.gallaryScreen);
          } else {
            goNamed(PageName.orderDetailScreen);
          }
        } else {
          homePage();
        }
      }
    }
  }

  void loginPage() => goNamed(PageName.loginScreen);

  void signInPage() => pushNamed(PageName.signUpScreen);

  void homePage() => goNamed(PageName.homeScreen);

  void howWeWorkPage() => pushNamed(PageName.howWeWorkScreen);

  void accountPage() {
    popBack();
    pushNamed(PageName.accountScreen);
  }

  void scheduleOrderPage() => pushNamed(PageName.scheduleOrderScreen);

  void orderDetailsPage(bool fromGalleryPage) {
    if (fromGalleryPage) {
      CommonFunction.fromGalleryPage = fromGalleryPage;
      popBack();
      pushNamed(PageName.orderDetailScreen);
    } else {
      goNamed(PageName.orderDetailScreen);
    }
  }

  void galleryPage() => goNamed(PageName.gallaryScreen);

  void imageViewerPage(int index) {
    initialImageIndex = index;
    pushNamed(PageName.imageViewerScreen);
  }

  void serviceSummaryPage() {
    popBack();
    pushNamed(PageName.serviceSummaryScreen);
  }

  void bugReportPage() {
    popBack();
    pushNamed(PageName.bugReportScreen);
  }

  void popBack() => pop();
}
