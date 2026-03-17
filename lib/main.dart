import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_view_model.dart';
import 'services/order_service.dart';

const Color _primaryColor = Color(0xFF1565C0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo dữ liệu đơn hàng từ SharedPreferences
  await OrderService.loadOrders();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp(
        title: 'TH4 Commerce',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
          scaffoldBackgroundColor: Colors.grey.shade50,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
