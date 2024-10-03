// import 'package:chatty/constant/app_color.dart';
// import 'package:chatty/controllers/appwrite_controllers.dart';
// import 'package:chatty/providers/user_data_provider.dart';
// import 'package:chatty/widgets/app_dialogs.dart';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _PhoneLoginState();
// }

// class _PhoneLoginState extends State<Login> {
//   final _formKey = GlobalKey<FormState>();
//   final _formKey1 = GlobalKey<FormState>();

//   TextEditingController _phoneNumberController = TextEditingController();
//   TextEditingController _otpController = TextEditingController();

//   String countryCode = "+233";

//   void handleOtpSubmit(String userId, BuildContext context) {
//     if (_formKey1.currentState!.validate()) {
//       AppDialogs.showLoading();
//       loginWithOtp(otp: _otpController.text, userId: userId).then((value) {
//         AppDialogs.dismissDialog();
//         if (value) {
//           // setting and saving data locally
//           Provider.of<UserDataProvider>(context, listen: false)
//               .setUserId(userId);
//           Provider.of<UserDataProvider>(context, listen: false)
//               .setUserPhone(countryCode + _phoneNumberController.text);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Container(
//                 width: MediaQuery.of(context).size.width * 0.7,
//                 child: Text("Login successful!"),
//               ),
//               backgroundColor: Colors.green,
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).size.height * 0.8,
//                 left: 16.0,
//                 right: 16.0,
//               ),
//             ),
//           );
//           Future.delayed(Duration(seconds: 2), () {
//             Navigator.pushNamedAndRemoveUntil(
//                 context, "/update", (route) => false,
//                 arguments: {"title": "add"});
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Container(
//                 width: MediaQuery.of(context).size.width * 0.7,
//                 child: Text("Login failed!"),
//               ),
//               backgroundColor: AppColors.redColor,
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).size.height * 0.8,
//                 left: 16.0,
//                 right: 16.0,
//               ),
//             ),
//           );
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           width: double.infinity,
//           child: Column(
//             children: [
//               Expanded(
//                 child: Image.asset(
//                   "assets/images/chat.png",
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         margin: EdgeInsets.only(left: 35),
//                         child: Text(
//                           "Welcome to JustLive 👋",
//                           style: TextStyle(
//                               fontSize: 28, fontWeight: FontWeight.w300),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 40),
//                     Form(
//                       key: _formKey,
//                       child: TextFormField(
//                         controller: _phoneNumberController,
//                         keyboardType: TextInputType.phone,
//                         validator: (value) {
//                           if (value!.length != 10)
//                             return "Invalid phone number";
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                           prefixIcon: CountryCodePicker(
//                             onChanged: (value) {
//                               print(value.dialCode);
//                               countryCode = value.dialCode!;
//                             },
//                             initialSelection: "GH",
//                           ),
//                           labelText: "Enter your phone number",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     SizedBox(
//                       height: 50,
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         child: Text('Send OTP'),
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             createPhoneSession(
//                                     phone: countryCode +
//                                         _phoneNumberController.text)
//                                 .then((value) {
//                               if (value != "login_error") {
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => AlertDialog(
//                                     title: Text("OTP verification"),
//                                     content: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Form(
//                                           key: _formKey1,
//                                           child: TextFormField(
//                                             keyboardType: TextInputType.number,
//                                             controller: _otpController,
//                                             validator: (value) {
//                                               if (value!.length != 6)
//                                                 return "Invalid OTP";
//                                               return null;
//                                             },
//                                             decoration: InputDecoration(
//                                               labelText:
//                                                   "Enter the 6 digit OTP",
//                                               border: OutlineInputBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     actions: [
//                                       TextButton(
//                                         onPressed: () {
//                                           handleOtpSubmit(value, context);
//                                         },
//                                         child: Text("Submit"),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }
//                             });
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.7,
//                                   child: Text("Failed to send OTP!!"),
//                                 ),
//                                 backgroundColor: AppColors.redColor,
//                                 behavior: SnackBarBehavior.floating,
//                                 margin: EdgeInsets.only(
//                                   bottom:
//                                       MediaQuery.of(context).size.height * 0.1,
//                                   left: 16.0,
//                                   right: 16.0,
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.backgroundColor,
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:chatty/constant/app_color.dart';
import 'package:chatty/controllers/appwrite_controllers.dart';
import 'package:chatty/providers/user_data_provider.dart';
import 'package:chatty/widgets/app_dialogs.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  String countryCode = "+233";

  void handleOtpSubmit(String userId, BuildContext context) {
    if (_formKey1.currentState!.validate()) {
      AppDialogs.showLoading();
      loginWithOtp(otp: _otpController.text, userId: userId).then((value) {
        AppDialogs.dismissDialog();
        if (value) {
          // setting and saving data locally
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserId(userId);
          Provider.of<UserDataProvider>(context, listen: false)
              .setUserPhone(countryCode + _phoneNumberController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text("Login successful!"),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.8,
                left: 16.0,
                right: 16.0,
              ),
            ),
          );
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pushNamedAndRemoveUntil(
                context, "/update", (route) => false,
                arguments: {"title": "add"});
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text("Login failed!"),
              ),
              backgroundColor: AppColors.redColor,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.8,
                left: 16.0,
                right: 16.0,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  "assets/images/chat.png",
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: 35),
                        child: Text(
                          "Welcome to JustLive 👋",
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: CountryCodePicker(
                              onChanged: (value) {
                                setState(() {
                                  countryCode = value.dialCode!;
                                });
                              },
                              initialSelection: "GH",
                              showFlag: true,
                              showDropDownButton: true,
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,

                              favorite: ["+233"],
                              alignLeft: true,
                              padding:
                                  EdgeInsets.zero, // Adjust padding as needed
                            ),
                          ),

                          Expanded(

                            child: TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value!.isEmpty || value.length < 6)
                                  return "Invalid phone number";
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Phone number",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Send OTP'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            createPhoneSession(
                                    phone: countryCode +
                                        _phoneNumberController.text)
                                .then((value) {
                              if (value != "login_error") {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("OTP verification"),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Form(
                                          key: _formKey1,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: _otpController,
                                            validator: (value) {
                                              if (value!.length != 6)
                                                return "Invalid OTP";
                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Enter the 6 digit OTP",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          handleOtpSubmit(value, context);
                                        },
                                        child: Text("Submit"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: Text("Failed to send OTP!!"),
                                ),
                                backgroundColor: AppColors.redColor,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.1,
                                  left: 16.0,
                                  right: 16.0,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

