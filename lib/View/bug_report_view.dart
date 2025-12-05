import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rusticgram/Bloc/BugReport/bug_report_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';

class BugReportView extends StatelessWidget {
  const BugReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BugReportCubit, BugReportState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                if (state.dataState != DataState.loading) {
                  RouteManager(context).popBack();
                }
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.body3Color),
            ),
            title: Text("Bug Report", style: Theme.of(context).textTheme.titleSmall),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _commonText(context, title: "Brand: ", value: state.brand),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: _commonText(context, title: "Model: ", value: state.model),
                ),
                _commonText(context, title: "OS Version: ", value: state.version),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: _commonText(context, title: "App Version: ", value: "6.0.2"),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text("Attach Screenshot (optional)", style: Theme.of(context).textTheme.titleSmall),
                //     IconButton(onPressed: BlocProvider.of<BugReportCubit>(context).uploadingScreenshots, icon: Icon(Icons.add, color: AppColors.primaryColor)),
                //   ],
                // ),
                // ListView.builder(
                //   shrinkWrap: true,
                //   itemCount: state.screenshots.length,
                //   physics: const NeverScrollableScrollPhysics(),
                //   itemBuilder:
                //       (BuildContext context, int index) => Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 10.0),
                //         child: ListTile(
                //           leading: Image.file(File(state.screenshots[index].path)),
                //           title: Text(state.screenshots[index].name),
                //           trailing: IconButton(onPressed: () => BlocProvider.of<BugReportCubit>(context).removeScreenshot(index), icon: Icon(Icons.close)),
                //         ),
                //       ),
                // ),
                Text("Describe the problem in your own words: ", style: Theme.of(context).textTheme.titleSmall),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: CustomTextField(
                    controller: BlocProvider.of<BugReportCubit>(context).bugExplinationController,
                    focusNode: BlocProvider.of<BugReportCubit>(context).bugExplinationNode,
                    textInputType: TextInputType.text,
                    errorText: state.commentError,
                    maxLines: 6,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _submittingBugReport(context, state: state),
                  child: state.dataState == DataState.loading ? Center(child: CircularProgressIndicator()) : Text("SUBMIT BUG REPORT"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _commonText(BuildContext context, {required String title, required String value}) => Row(
    children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall),
      Text(value, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16)),
    ],
  );

  Future<void> _submittingBugReport(BuildContext context, {required BugReportState state}) async {
    if (state.dataState != DataState.loading) {
      bool isSubmitted = await BlocProvider.of<BugReportCubit>(context).submittingBug();
      if (isSubmitted && context.mounted) {
        _successAlertDialog(context);
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) RouteManager(context).popBack();
        });
      } else if (context.mounted && state.dataState == DataState.failure) {
        showDialog(
          context: context,
          builder: (ctx) => CommonErrorDialog(content: state.errorMessage),
        );
      }
    }
  }

  void _successAlertDialog(BuildContext context) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.fillColor,
      insetPadding: const EdgeInsets.all(10.0),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.verifiedIcon, width: 120.0, height: 120.0),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text("Bug Reported Successfully", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
              child: Text("Bug submitted successfully. We appreciate your help in making things better!", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    ),
  );
}
