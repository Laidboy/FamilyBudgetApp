import 'dart:convert';

import 'package:family_budget/Page/account_edit_page.dart';
import 'package:family_budget/current_user_config.dart';
import 'package:family_budget/model/model.dart';
import 'package:family_budget/Page/chat_page.dart';
import 'package:family_budget/Page/forgot_password_page.dart';
import 'package:family_budget/Page/login_page.dart';
import 'package:family_budget/Page/registration_page.dart';
import 'package:family_budget/Theme/custom_theme.dart';
import 'package:family_budget/Theme/config.dart';
import 'package:family_budget/Page/home_page.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (await FamilyBudgetModel().initializeDB()) {
    //UserParam userParam = (await UserParam().getById(1)) ?? UserParam();
    //userParam.delete();
   // (await UserParam().select().toList()).forEach((element) {element.delete();});
    await CurrentUserConfig.userInit();
    /*userParam.avatar = base64Decode('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');
    userParam.name = 'Тест тестович очень длинный';
    userParam.save();*/
    //

    runApp(const App());
  } else {
    print('Failed to initialize DB');
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  createState() => _AppState();
}

class _AppState extends State {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: currentTheme.currentTheme,
      title: 'Семейный бюджет',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/chat': (context) => const ChatPage(),
        '/login': (context) => const LoginPage(),
        '/registration': (context) => const RegistrationPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/account_edit': (context) => const AccountEditPage(),
      },
    );
  }
}
