import 'package:flutter/material.dart';
import 'seller_my_products_screen.dart';
import 'seller_sales_screen.dart';
import '../profile_screen.dart';

class SellerMainNavigationScreen extends StatefulWidget {
  const SellerMainNavigationScreen({super.key});

  @override
  State<SellerMainNavigationScreen> createState() =>
      _SellerMainNavigationScreenState();
}

class _SellerMainNavigationScreenState
    extends State<SellerMainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SellerMyProductsScreen(),
    SellerSalesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'My Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'My Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
