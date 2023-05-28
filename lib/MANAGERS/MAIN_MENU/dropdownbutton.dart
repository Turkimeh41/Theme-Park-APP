import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:final_project/MANAGERS/MAIN_MENU/dropdownitem.dart';
import 'package:final_project/Model/activity.dart';
import 'package:final_project/USERS/Provider/activites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DropDownMenuButtonActivity extends StatefulWidget {
  const DropDownMenuButtonActivity({super.key});

  @override
  State<DropDownMenuButtonActivity> createState() => _DropDownMenuButtonActivityState();
}

class _DropDownMenuButtonActivityState extends State<DropDownMenuButtonActivity> {
  late FocusNode dropdownFocus;
  @override
  void initState() {
    dropdownFocus = FocusNode();
    dropdownFocus.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final insActivites = Provider.of<Activites>(context);
    final activityList = insActivites.activites;
    return DropdownButtonFormField2<Activity>(
      focusNode: dropdownFocus,
      decoration: const InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          disabledBorder: OutlineInputBorder(borderSide: BorderSide.none)),
      items: [for (int i = 0; i < activityList.length; i++) DropdownMenuItem<Activity>(value: activityList[i], child: DropDownItemActivity(activity: activityList[i]))],
      value: insActivites.selectedActivity,
      onChanged: (activity) => insActivites.selectActivity(activity!),
      buttonStyleData: ButtonStyleData(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black26,
          ),
          color: Colors.white,
        ),
        elevation: 4,
      ),
      iconStyleData: IconStyleData(
        icon: dropdownFocus.hasFocus ? const Icon(Icons.play_arrow_rounded) : Transform.rotate(angle: 90 * pi / 180, child: const Icon(Icons.play_arrow_rounded)),
        iconSize: 23,
        iconEnabledColor: Colors.amber,
        iconDisabledColor: Colors.grey,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        offset: const Offset(-12, -3),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: const MaterialStatePropertyAll(Colors.amber),
          radius: const Radius.circular(40),
          thickness: MaterialStateProperty.all<double>(6),
          thumbVisibility: MaterialStateProperty.all<bool>(true),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 80,
      ),
    );
  }
}
