import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/MANAGERS/Provider/manager_provider.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  late GlobalKey<FormState> formKey = GlobalKey();
  var maskFormatter = MaskTextInputFormatter(mask: '## ### ####');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<Manager>(context, listen: true);
    final dh = MediaQuery.of(context).size.height;
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Account', style: GoogleFonts.signika(color: Colors.white, fontSize: 18)),
      ),
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
                    Text('Manager Information', style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 30),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              child: manager.imgURL == null
                                  ? const CircleAvatar(radius: 42, backgroundImage: AssetImage('assets/images/placeholder.png'))
                                  : CircleAvatar(
                                      radius: 42,
                                      backgroundImage: CachedNetworkImageProvider(manager.imgURL!),
                                    ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${manager.first_name} ${manager.last_name}',
                                style: GoogleFonts.signika(color: Colors.black, fontSize: 15.5),
                              ),
                              Text(
                                '@${manager.username}',
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
                            )),
                        Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            width: dw * 0.9,
                            height: 45,
                            child: TextFormField(
                              style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
                              initialValue: manager.username,
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
                                      initialValue: manager.first_name,
                                      style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
                                      enabled: false,
                                      decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          filled: true,
                                          fillColor: const Color.fromARGB(255, 230, 208, 205),
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
                                      initialValue: manager.last_name,
                                      style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
                                      enabled: false,
                                      decoration: InputDecoration(
                                          errorMaxLines: 2,
                                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                          filled: true,
                                          fillColor: const Color.fromARGB(255, 230, 208, 205),
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
                              initialValue: manager.email,
                              style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
                              enabled: false,
                              decoration: InputDecoration(
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 230, 208, 205),
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
                              initialValue: manager.phone,
                              style: GoogleFonts.signika(color: Colors.black, fontSize: 16),
                              enabled: false,
                              decoration: InputDecoration(
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  prefix: Text(
                                    '+966  ',
                                    style: GoogleFonts.signika(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 230, 208, 205),
                                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none)),
                            )),
                      ],
                    )
                  ]),
                )),
          ],
        ),
      ),
    );
  }
}
