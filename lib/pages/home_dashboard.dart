import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class HomeDashboard extends StatelessWidget {
  final AppUser user;

  const HomeDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(child: Text("Welcome, ${user.name ?? user.email}!")),
    );
  }
}
