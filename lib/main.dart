import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finance/controller/transaction_controller.dart';
import 'package:finance/screen/home_screen.dart';
import 'package:finance/screen/main_screen.dart';
import 'package:finance/screen/transactions_screen.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

Future init () async {
  Get.put(TransactionController(), permanent: true);

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner : false ,
      initialRoute: '/main',
      getPages: [
        GetPage(name: "/main", page: () => MainScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/transactions', page: () => TransactionsScreen()),

      ],
    );
  }
}

























