import 'package:flutter/material.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/views/custom_bottom_nav.dart';
import './login.dart';
import '../models/product.dart';
import './product_detail.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> futureProducts;
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    futureProducts = ProductService().fetchProducts();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      final matchesSearchQuery = product.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todos' || product.category == _selectedCategory;
      return matchesSearchQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'TUKOO',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepOrange),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoginView(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          // Categorías horizontales
          Container(
            height: 40,
            margin: const EdgeInsets.only(top: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('Todos', _selectedCategory == 'Todos'),
                _buildCategoryChip('Electrónica', _selectedCategory == 'Electrónica'),
                _buildCategoryChip('Moda', _selectedCategory == 'Moda'),
                _buildCategoryChip('Hogar', _selectedCategory == 'Hogar'),
                _buildCategoryChip('Deportes', _selectedCategory == 'Deportes'),
                _buildCategoryChip('Juguetes', _selectedCategory == 'Juguetes'),
              ],
            ),
          ),
          // Grid de productos
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No products found'));
                } else {
                  final filteredProducts = _filterProducts(snapshot.data!);
                  if (filteredProducts.isEmpty) {
                    return Center(child: Text('No products match your criteria'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(filteredProducts[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (bool value) {
          setState(() {
            _selectedCategory = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.deepOrange,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? Colors.deepOrange : Colors.grey[300]!),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell( // Cambiamos GestureDetector por InkWell para mejor feedback
      onTap: () {
        debugPrint('Tap detectado en producto: ${product.id}');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              debugPrint('Construyendo ProductDetailView para producto: ${product.id}');
              return ProductDetailView(productId: product.id);
            },
          ),
        ).then((_) => debugPrint('Regresó de ProductDetailView'));
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  image: DecorationImage(
                    image: const AssetImage('assets/anuncio_image.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.pricePerDay.toStringAsFixed(2)}€/día',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RentApp',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const LoginView(),
      debugShowCheckedModeBanner: false,
    );
  }
}