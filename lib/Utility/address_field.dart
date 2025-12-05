import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rusticgram/Bloc/AddressField/address_field_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/auto_complete_field.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';

class AddressField extends StatelessWidget {
  const AddressField({super.key, this.showButton = false});

  final bool showButton;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressFieldCubit, AddressFieldState>(
      listener: (context, state) {
        if (state.dataState == DataState.failure) showDialog(context: context, builder: (ctx) => CommonErrorDialog(content: state.errorMessage));
      },
      builder: (context, state) {
        return Stack(
          alignment: AlignmentDirectional.center,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            ImageFiltered(
              enabled: state.addressState == AddressState.loading,
              imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoCompleteField(
                      controller: BlocProvider.of<AddressFieldCubit>(context).flatController,
                      focusNode: BlocProvider.of<AddressFieldCubit>(context).flatFocus,
                      labelText: "Flat, House no., Building, Company, Apartment",
                      onChanged: BlocProvider.of<AddressFieldCubit>(context).autocompleteDebounceable,
                      onTap: (address) => BlocProvider.of<AddressFieldCubit>(context).fetchingPlaceDetails(address),
                      errorText: state.flatMessage,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: CustomTextField(
                        controller: BlocProvider.of<AddressFieldCubit>(context).areaController,
                        focusNode: BlocProvider.of<AddressFieldCubit>(context).areaFocus,
                        textInputType: TextInputType.streetAddress,
                        labelText: "Area, Street, Sector, Village",
                        errorText: state.areaMessage,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    CustomTextField(
                      controller: BlocProvider.of<AddressFieldCubit>(context).townController,
                      focusNode: BlocProvider.of<AddressFieldCubit>(context).townFocus,
                      textInputType: TextInputType.streetAddress,
                      labelText: "Town/City",
                      errorText: state.townMessage,
                      textCapitalization: TextCapitalization.words,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: CustomTextField(
                        controller: BlocProvider.of<AddressFieldCubit>(context).pincodeController,
                        focusNode: BlocProvider.of<AddressFieldCubit>(context).pincodeFocus,
                        textInputType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        labelText: "PIN Code",
                        errorText: state.pincodeMessage,
                        maxLength: 6,
                      ),
                    ),
                    CustomTextField(
                      controller: BlocProvider.of<AddressFieldCubit>(context).stateController,
                      focusNode: BlocProvider.of<AddressFieldCubit>(context).stateFocus,
                      textInputType: TextInputType.streetAddress,
                      labelText: "State",
                      errorText: state.stateMessage,
                      textCapitalization: TextCapitalization.words,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: CustomTextField(
                        controller: BlocProvider.of<AddressFieldCubit>(context).countryController,
                        focusNode: BlocProvider.of<AddressFieldCubit>(context).countryFocus,
                        textInputType: TextInputType.streetAddress,
                        labelText: "Country",
                        errorText: state.countryMessage,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    CustomTextField(
                      controller: BlocProvider.of<AddressFieldCubit>(context).landmarkController,
                      focusNode: BlocProvider.of<AddressFieldCubit>(context).landmarkFocus,
                      textInputType: TextInputType.streetAddress,
                      labelText: "Landmark",
                      errorText: state.landmarkMessage,
                      textCapitalization: TextCapitalization.words,
                    ),
                    if (showButton)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (state.dataState != DataState.loading) {
                              bool isUpdated = await BlocProvider.of<AddressFieldCubit>(context).updatingAddress();
                              if (context.mounted && isUpdated) RouteManager(context).popBack();
                            }
                          },
                          child: state.dataState == DataState.loading ? const Center(child: CircularProgressIndicator()) : const Text("SAVE"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (state.addressState == AddressState.loading) CircularProgressIndicator(strokeWidth: 5, color: AppColors.primaryColor),
          ],
        );
      },
    );
  }
}
