import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nice_buttons/nice_buttons.dart';
import 'package:provider/provider.dart';
import 'package:final_project/Provider/user_provider.dart' as u;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  bool edit = false;
  late TextEditingController firstnameController;
  late FocusNode firstNameNode;
  late TextEditingController lastnameController;
  late FocusNode lastnameNode;
  late TextEditingController emailAddressController;
  late FocusNode emailAddressNode;
  late FocusNode phoneNode;
  late GlobalKey<FormState> formKey = GlobalKey();
  var maskFormatter = MaskTextInputFormatter(mask: '## ### ####');
  late AnimationController editController;
  late Animation<Color?> colorAnimation;
  late Animation<double> opacityAnimation;

  @override
  void initState() {
    final user = Provider.of<u.User>(context, listen: false);
    firstnameController = TextEditingController(text: user.first_name);
    lastnameController = TextEditingController(text: user.last_name);
    emailAddressController = TextEditingController(text: user.emailAddress);
    phoneNode = FocusNode();
    emailAddressNode = FocusNode();
    firstNameNode = FocusNode();
    lastnameNode = FocusNode();
    editController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    colorAnimation = ColorTween(begin: const Color.fromARGB(255, 230, 208, 205), end: Color.fromARGB(255, 221, 178, 171)).animate(editController);
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(editController);

    editController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<u.User>(context, listen: true);
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            Container(
                color: const Color.fromARGB(255, 243, 235, 235),
                width: dw,
                height: dh,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: ListView(children: [
                    Text(
                      'Personal Information',
                      style: GoogleFonts.signika(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: () => user.showSheetImage(context),
                              child: Stack(
                                children: [
                                  user.userImg_link == "null"
                                      ? const CircleAvatar(radius: 42, backgroundImage: AssetImage('assets/images/placeholder.png'))
                                      : CircleAvatar(
                                          radius: 42,
                                          backgroundImage: CachedNetworkImageProvider(user.userImg_link),
                                        ),
                                  const Positioned(
                                      bottom: 8,
                                      right: 1,
                                      child: Icon(
                                        size: 26,
                                        Icons.edit,
                                        color: Color.fromARGB(255, 3, 47, 83),
                                      ))
                                ],
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user.first_name} ${user.last_name}',
                                style: GoogleFonts.signika(color: Colors.black, fontSize: 15.5),
                              ),
                              Text(
                                '@${user.username}',
                                style: GoogleFonts.signika(color: Colors.blue[600], fontWeight: FontWeight.bold, fontSize: 12),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            'Username',
                            style: GoogleFonts.signika(color: Colors.black, fontSize: 15.5),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            width: dw * 0.9,
                            height: 45,
                            child: TextFormField(
                              style: GoogleFonts.signika(color: const Color.fromARGB(255, 116, 114, 114), fontSize: 16),
                              initialValue: user.username,
                              enabled: false,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 230, 208, 205),
                                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none)),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // FIRST NAME

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Text(
                                    'First name',
                                    style: GoogleFonts.signika(color: Colors.black, fontSize: 15.5),
                                  ),
                                ),
                                SizedBox(
                                    height: 45,
                                    width: dw * 0.4,
                                    child: TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (_) {
                                        if (firstnameController.text.isEmpty) {
                                          return 'Please fill in the First name field.';
                                        }
                                        return null;
                                      },
                                      style: GoogleFonts.signika(color: edit ? Colors.black : const Color.fromARGB(255, 116, 114, 114), fontSize: 16),
                                      controller: firstnameController,
                                      enabled: edit,
                                      decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          filled: true,
                                          fillColor: colorAnimation.value,
                                          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none)),
                                    )),
                              ],
                            ),
                            // LAST NAME

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5.0),
                                  child: Text(
                                    'Last name',
                                    style: GoogleFonts.signika(color: Colors.black, fontSize: 15.5),
                                  ),
                                ),
                                SizedBox(
                                    width: dw * 0.4,
                                    height: 45,
                                    child: TextFormField(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (_) {
                                        if (lastnameController.text.isEmpty) {
                                          return 'Please fill in the Last name field.';
                                        }
                                        return null;
                                      },
                                      style: GoogleFonts.signika(color: edit ? Colors.black : const Color.fromARGB(255, 116, 114, 114), fontSize: 16),
                                      controller: lastnameController,
                                      enabled: edit,
                                      decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          filled: true,
                                          fillColor: colorAnimation.value,
                                          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none)),
                                    )),
                              ],
                            ),
                          ],
                        ),

                        // EMAIL

                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0, top: 25),
                          child: Text(
                            'Email Address',
                            style: GoogleFonts.signika(color: Colors.black, fontSize: 15.5),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(bottom: 35),
                            width: dw * 0.9,
                            height: 45,
                            child: TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (_) {
                                if (emailAddressController.text.isEmpty) {
                                  return 'Invalid, The email field can\'t be empty';
                                }
                                if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailAddressController.text)) {
                                  return 'Invalid, Recheck your email format.';
                                }
                                return null;
                              },
                              style: GoogleFonts.signika(color: edit ? Colors.black : const Color.fromARGB(255, 116, 114, 114), fontSize: 16),
                              controller: emailAddressController,
                              enabled: edit,
                              decoration: InputDecoration(
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: colorAnimation.value,
                                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
                            )),

                        // PHONE

                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            'Phone',
                            style: GoogleFonts.signika(color: Colors.black, fontSize: 15.5),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            width: dw * 0.9,
                            height: 45,
                            child: TextFormField(
                              initialValue: user.phone_number,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.signika(color: const Color.fromARGB(255, 116, 114, 114), fontSize: 16),
                              enabled: false,
                              decoration: InputDecoration(
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  prefix: Text(
                                    '+966  ',
                                    style: GoogleFonts.signika(color: const Color.fromARGB(255, 110, 30, 63), fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 230, 208, 205),
                                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none)),
                            )),
                        Center(
                            child: NiceButtons(
                          progress: false,
                          borderColor: const Color.fromARGB(255, 39, 4, 20),
                          startColor: const Color.fromARGB(255, 124, 17, 67),
                          endColor: const Color.fromARGB(255, 85, 9, 45),
                          gradientOrientation: GradientOrientation.Horizontal,
                          stretch: false,
                          width: dw * 0.56,
                          height: dh * 0.06,
                          onTap: (_) async {
                            setState(() {
                              edit = true;
                              editController.forward();
                            });
                          },
                          child: Text(
                            'Edit',
                            style: GoogleFonts.acme(color: Colors.white, fontSize: 27),
                          ),
                        )),
                      ],
                    )
                  ]),
                )),
            Positioned(
                bottom: 20,
                child: FadeTransition(
                  opacity: opacityAnimation,
                  child: Visibility(
                    visible: edit,
                    child: Container(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        width: dw,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  firstnameController.text = user.first_name;
                                  lastnameController.text = user.last_name;
                                  emailAddressController.text = user.emailAddress;
                                });
                                await editController.reverse();
                                setState(() {
                                  edit = false;
                                });
                              },
                              mouseCursor: SystemMouseCursors.click,
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: const BoxDecoration(color: Color.fromARGB(255, 163, 32, 23), shape: BoxShape.circle),
                                child: const Icon(
                                  color: Colors.white,
                                  Icons.cancel_outlined,
                                  size: 32,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                bool isvalid = formKey.currentState!.validate();
                                if (!isvalid) {
                                  return;
                                }
                                try {
                                  log(emailAddressController.text);
                                  user.confirmEditDialog(context, firstnameController.text, lastnameController.text, emailAddressController.text);
                                } catch (error) {
                                  log('ERROR: $error');
                                }
                              },
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                child: const Icon(
                                  color: Colors.white,
                                  Icons.done,
                                  size: 32,
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
