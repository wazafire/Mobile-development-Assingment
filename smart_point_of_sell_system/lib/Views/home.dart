import 'package:flutter/material.dart';
import 'package:smart_point_of_sell_system/Views/product_list.dart';
import 'cart.dart';
import 'products_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Mpepo Kitchen"),
        backgroundColor: Colors.deepOrange,
        actions: [
          // Cart button on top right
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Meals
              CategoryCard(
                icon: Icons.restaurant,
                title: "Main Meals",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(category: 'main_meals'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Drinks
              CategoryCard(
                icon: Icons.local_drink,
                title: "Drinks",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(category: 'drinks'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Side Dishes
              CategoryCard(
                icon: Icons.fastfood,
                title: "Side Dishes",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsPage(category: 'side_dishes'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const CategoryCard(
      {super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[100],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        leading: Icon(icon, size: 40, color: Colors.deepOrange),
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
        onTap: onTap,
      ),
    );
  }
}
