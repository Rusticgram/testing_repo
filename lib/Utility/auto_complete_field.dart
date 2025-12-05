import 'package:flutter/material.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Utility/custom_text_field.dart';
import 'package:rusticgram/Utility/debouncer.dart';

// ignore: must_be_immutable
class AutoCompleteField extends StatelessWidget {
  AutoCompleteField({super.key, required this.controller, required this.focusNode, required this.onChanged, required this.labelText, required this.errorText, required this.onTap});

  TextEditingController controller;
  FocusNode focusNode;
  final Debounceable<Iterable<String>, TextEditingValue> onChanged;
  final String labelText;
  final String errorText;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) => RawAutocomplete<String>(
    textEditingController: controller,
    focusNode: focusNode,
    optionsBuilder: onChanged,
    fieldViewBuilder:
        (context, flatController, flatFocus, onFieldSubmitted) => CustomTextField(
          controller: controller,
          focusNode: focusNode,
          textInputType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          labelText: labelText,
          errorText: errorText,
        ),
    optionsViewBuilder: (context, onSelected, prediction) {
      List<String> options = prediction.toList();
      return Align(
        alignment: Alignment.topLeft,
        child: Card(
          color: AppColors.fillColor,
          margin: const EdgeInsets.only(right: 20.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            padding: EdgeInsets.zero,
            itemBuilder:
                (BuildContext context, int index) => ListTile(
                  onTap: () {
                    focusNode.unfocus();
                    onTap(options[index]);
                  },
                  title: Text(options[index], style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500)),
                ),
          ),
        ),
      );
    },
  );
}
