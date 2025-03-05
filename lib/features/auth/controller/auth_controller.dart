// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vc_testing/features/auth/repository/auth_repository.dart';
import 'package:vc_testing/models/user_model.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider);
  return authController.getUserData();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;
  AuthController({
    required this.authRepository,
    required this.ref,
  });

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  Future<void> signUpWithEmailAndPassword({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required File? profilePic,
  }) async {
    await authRepository.signUpWithEmailAndPassword(
      context: context,
      email: email,
      password: password,
      name: name,
      profilePic: profilePic,
      ref: ref,
    );
  }

  Future<void> signInWithEmailAndPassword({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    await authRepository.signInWithEmailAndPassword(
      context: context,
      email: email,
      password: password,
    );
  }

  // void saveUserDataToFirebase(
  //   BuildContext context,
  //   String name,
  //   File? profilePic,
  // ) {
  //   authRepository.saveUserDataToFirebase(
  //     name: name,
  //     profilePic: profilePic,
  //     ref: ref,
  //     context: context,
  //     email: authRepository.auth.currentUser!.email!,
  //     uid: authRepository.auth.currentUser!.uid,
  //   );
  // }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }
}