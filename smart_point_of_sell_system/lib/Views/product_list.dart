import 'package:flutter/material.dart';
import 'cart.dart';
import 'cart_page.dart';
import 'get_cart.dart';

class ProductsPage extends StatelessWidget {
  final String category;

  const ProductsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> products = [];

    if (category == 'main_meals') {
      products = [
        {'name': 'Nshima with Chikanda (African polony)', 'price': 30},
        {'name': 'Nshima with Grilled Fish', 'price': 50},
        {'name': 'Nshima with Ifisashi (vegetable peanut stew)', 'price': 35},
        {'name': 'Nshima with Beef Stew', 'price': 45},
        {'name': 'Fried Kapenta with Nshima', 'price': 40},
        {'name': 'Spaghetti Bolognese', 'price': 55},
        {'name': 'Chicken Alfredo Pasta', 'price': 60},
        {'name': 'Cheeseburger with Fries', 'price': 45},
        {'name': 'Grilled Steak with Mashed Potatoes', 'price': 80},
        {'name': 'Caesar Salad with Grilled Chicken', 'price': 50},
      ];
    } else if (category == 'drinks') {
      products = [
        {'name': 'Water', 'price': 5},
        {'name': 'Coffee', 'price': 15},
        {'name': 'Coca-Cola', 'price': 10},
        {'name': 'Fanta', 'price': 10},
        {'name': 'Orange Juice', 'price': 15},
        {'name': 'Apple Juice', 'price': 15},
      ];
    } else if (category == 'side_dishes') {
      products = [
        {'name': 'French Fries', 'price': 20},
        {'name': 'Coleslaw', 'price': 15},
        {'name': 'Mashed Potatoes', 'price': 20},
        {'name': 'Garlic Bread', 'price': 15},
        {'name': 'Stir-Fried Vegetables', 'price': 25},
        {'name': 'Wings', 'price': 35},
        {'name': 'Fried Plantains', 'price': 20},
        {'name': 'Rice', 'price': 15},
        {'name': 'Potato Wedges', 'price': 20},
        {'name': 'Garden Salad', 'price': 25},
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryToTitle(category)),
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
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
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text('Price: ZMW ${item['price']}'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                onPressed: () {
                  Cart.addItem(item); // Add item to global cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['name']} added to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text("Add to Cart"),
              ),
            ),
          );
        },
      ),
    );
  }

  String categoryToTitle(String category) {
    switch (category) {
      case 'main_meals':
        return 'Main Meals';
      case 'drinks':
        return 'Drinks';
      case 'side_dishes':
        return 'Side Dishes';
      default:
        return 'Products';
    }
  }
}
