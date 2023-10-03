import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualization/home.dart';
import 'package:visualization/login.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: '/home',
    pageBuilder: (context, state) => const MaterialPage(
      child: Home(),
    ),
  ),
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) => const MaterialPage(
      child: Login(),
    ),
  ),
]);
