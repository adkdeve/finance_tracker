import 'package:finance_recorder/screens/FriendsScreen.dart';
import 'package:finance_recorder/screens/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

String fName = '';
String lName = '';
String email = '';
String phoneNumber = '';
String nPassword = '';
String currentPassword = '';
File? image;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fName = prefs.getString('fName') ?? fName;
      lName = prefs.getString('lName') ?? lName;
      email = prefs.getString('email') ?? email;
      phoneNumber = prefs.getString('phoneNumber') ?? phoneNumber;
      currentPassword = prefs.getString('currentPassword') ?? " ";
      // Note: Loading image from file path (if saved) will be covered in EditProfilePage
      String? imagePath = prefs.getString('imagePath');
      if (imagePath != null) {
        image = File(imagePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null
                        ? FileImage(image!)
                        : const AssetImage("assets/avatar.jpg"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$fName $lName', // Display full name
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email, // Display email
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProfileOption(
                      icon: Icons.person,
                      title: 'Edit Profile',
                      onTap: () async {
                        final updatedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(
                              firstName: fName,
                              lastName: lName,
                              email: email,
                              currentImage: image,
                            ),
                          ),
                        );

                        if (updatedData != null) {
                          setState(() {
                            fName = updatedData['firstName'];
                            lName = updatedData['lastName'];
                            email = updatedData['email'];
                            image = updatedData['image'];
                          });
                        }
                      },
                    ),
                    // ProfileOption(
                    //   icon: Icons.lock,
                    //   title: 'Change Password',
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => const ChangePasswordPage()),
                    //     );
                    //   },
                    // ),
                    ProfileOption(
                      icon: Icons.receipt,
                      title: 'Transaction History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TransactionHistoryScreen()),
                        );
                      },
                    ),
                    ProfileOption(
                      icon: Icons.people,
                      title: 'Friends',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FriendsScreen()),
                        );
                      },
                    ),
                    ProfileOption(
                      icon: Icons.info,
                      title: 'About App',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutAppPage()),
                        );
                      },
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

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: theme.primaryColor),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 18,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final File? currentImage;

  const EditProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.currentImage,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();


  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fName', fName);
    await prefs.setString('lName', lName);
    await prefs.setString('email', email);
    await prefs.setString('phoneNumber', phoneNumber);
    if (image != null) {
      await prefs.setString('imagePath', image!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Edit Profile", style: TextStyle(color: Colors.white)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),  // Change back button icon color to white
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 75,
                      backgroundImage: image == null
                          ? const AssetImage("assets/avatar.jpg")
                          : FileImage(image!) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 20,
                      child: GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);

                          if (pickedFile != null) {
                            setState(() {
                              image = File(pickedFile.path);
                            });
                          } else {
                            toastification.show(
                              context: context,
                              type: ToastificationType.info,
                              style: ToastificationStyle.flat,
                              title: const Text('No Image Selected'),
                              description:
                              const Text('Please select an image to update.'),
                              autoCloseDuration: const Duration(seconds: 3),
                              alignment: Alignment.topRight,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // First Name Field
                TextFormField(
                  initialValue: fName,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "Please enter your first name";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    fName = value;
                  },
                ),
                const SizedBox(height: 16),
                // Last Name Field
                TextFormField(
                  initialValue: lName,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return "Please enter your last name";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    lName = value;
                  },
                ),
                const SizedBox(height: 16),
                // Email Field
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                          .hasMatch(value)) {
                        return "Please enter a valid email address";
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    email = value;
                  },
                ),
                const SizedBox(height: 16),
                // Phone Number Field
                TextFormField(
                  initialValue: phoneNumber,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                        return "Please enter a valid phone number";
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveProfileData();
                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        style: ToastificationStyle.flat,
                        title: const Text('Profile Updated'),
                        description: const Text('Your profile has been updated successfully.'),
                        autoCloseDuration: const Duration(seconds: 3),
                        alignment: Alignment.topRight,
                      );
                      Navigator.pop(context, {
                        'firstName': fName,
                        'lastName': lName,
                        'email': email,
                        'image': image,
                      });
                    } else {
                      toastification.show(
                        context: context,
                        type: ToastificationType.warning,
                        style: ToastificationStyle.flat,
                        title: const Text('Validation Error'),
                        description:
                        const Text('Please fill in all required fields correctly.'),
                        autoCloseDuration: const Duration(seconds: 3),
                        alignment: Alignment.topRight,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});
//
//   @override
//   _ChangePasswordPageState createState() => _ChangePasswordPageState();
// }
//
// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   Future<void> _savePassword() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('currentPassword', nPassword);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Change Password",
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: theme.primaryColor,
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: "Current Password",
//                       border: OutlineInputBorder(),
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Please enter your current password";
//                       }
//                       if (value != currentPassword) {
//                         return "Current password is incorrect";
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: "New Password",
//                       border: OutlineInputBorder(),
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (currentPassword.isEmpty) {
//                         return "Please enter your current password first";
//                       }
//                       if (value != null && value.isNotEmpty) {
//                         if (value.length < 6) {
//                           return "Password must be at least 6 characters long";
//                         }
//                       }
//                       return null;
//                     },
//                     onChanged: (value) {
//                       nPassword = value;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: "Confirm Password",
//                       border: OutlineInputBorder(),
//                     ),
//                     obscureText: true,
//                     validator: (value) {
//                       if (value != null && value.isNotEmpty) {
//                         if (value != nPassword) {
//                           return "Passwords do not match";
//                         }
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.primaryColor,
//                     ),
//                     onPressed: () async {
//                       await _savePassword();
//                       if (_formKey.currentState!.validate()) {
//                         toastification.show(
//                           context: context,
//                           type: ToastificationType.success,
//                           style: ToastificationStyle.flat,
//                           title: const Text('Password Changed'),
//                           description: const Text(
//                               'Your password has been changed successfully.'),
//                           autoCloseDuration: const Duration(seconds: 3),
//                           alignment: Alignment.topRight,
//                         );
//                         currentPassword = nPassword;
//                         Navigator.pop(context);
//                       } else {
//                         toastification.show(
//                           context: context,
//                           type: ToastificationType.error,
//                           style: ToastificationStyle.flat,
//                           title: const Text('Password Change Failed'),
//                           description:
//                           const Text('Please check the fields and try again.'),
//                           autoCloseDuration: const Duration(seconds: 3),
//                           alignment: Alignment.topRight,
//                         );
//                       }
//                     },
//                     child: const Text("Change Password",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.info,
                size: 100,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'App Name: Finance Tracker',
              style: theme.textTheme.titleLarge, // Replaced headline6 with titleLarge
            ),
            const SizedBox(height: 10),
            Text(
              'Version: 1.0.0',
              style: theme.textTheme.bodyLarge?.copyWith( // Replaced bodyText1 with bodyLarge
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'About This App',
              style: theme.textTheme.titleLarge?.copyWith( // Replaced headline6 with titleLarge
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This app allows users to manage their profile, view transaction history, connect with friends, and more. It’s designed to enhance your experience by providing easy-to-use tools and features all in one place.',
              style: theme.textTheme.bodyMedium, // Replaced bodyText2 with bodyMedium
            ),
            const SizedBox(height: 20),
            Text(
              'Developer Info',
              style: theme.textTheme.titleLarge?.copyWith( // Replaced headline6 with titleLarge
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Developed by ADK Dev. If you have any questions, feel free to reach out at alee0066.aka@gmail.com.',
              style: theme.textTheme.bodyMedium, // Replaced bodyText2 with bodyMedium
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Thank you for using our app!',
                style: theme.textTheme.bodyLarge?.copyWith( // Replaced bodyText1 with bodyLarge
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

