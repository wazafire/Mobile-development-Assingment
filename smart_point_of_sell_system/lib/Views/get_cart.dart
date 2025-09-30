class Cart {
static final List<Map<String, dynamic>> items = [];

static void addItem(Map<String, dynamic> item) {
final index = items.indexWhere((i) => i['name'] == item['name']);
if (index != -1) {
items[index]['quantity'] += 1;
} else {
items.add({...item, 'quantity': 1});
}
}

static void decreaseQuantity(int index) {
if (items[index]['quantity'] > 1) {
items[index]['quantity'] -= 1;
} else {
items.removeAt(index);
}
}

static double getTotal() {
return items.fold(
0, (sum, item) => sum + item['price'] * item['quantity']);
}

static void clear() {
items.clear();
}
}
