import 'package:flutter/material.dart';
import 'package:frontend/views/main.dart';
import './custom_bottom_nav.dart';
import '../services/product_service.dart';

class PublishView extends StatefulWidget {
  const PublishView({super.key});

  @override
  State<PublishView> createState() => _PublishViewState();
}

class _PublishViewState extends State<PublishView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = [
    'Electrónica', 'Moda', 'Hogar', 'Deportes', 'Juguetes',
    'Vehículos', 'Inmobiliaria', 'Servicios', 'Otros'
  ];
  final ProductService _productService = ProductService();
  bool _isLoading = false; // Para controlar el estado de carga

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Publicar Anuncio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título del anuncio',
                        hintText: 'Ej: iPhone 13 Pro Max',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Precio
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Precio por día',
                        prefixText: '€ ',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un precio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describe tu producto...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Ciudad
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Ciudad',
                        hintText: 'Ej: Madrid',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una ciudad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Botón publicar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    print('Intentando crear el anuncio...');
                                    await _productService.createListing(
                                      title: _titleController.text,
                                      description: _descriptionController.text,
                                      pricePerDay: double.parse(_priceController.text),
                                      category: _selectedCategory!,
                                      location: _locationController.text,
                                    );
                                    print('Anuncio creado correctamente en la base de datos.');

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Anuncio creado correctamente')),
                                    );
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>  HomeScreen()),
                                      );
                                      print('Navegación de regreso completada.');
                                    } else {
                                      print('El widget ya no está montado. No se puede navegar.');
                                    }
                                  } catch (e) {
                                    print('Error al crear el anuncio: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                      print('Estado de _isLoading actualizado a false.');
                                    } else {
                                      print('El widget ya no está montado. No se puede actualizar el estado.');
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Publicar Anuncio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}