import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class EditProductView extends StatefulWidget {
  final Product product;

  const EditProductView({super.key, required this.product});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _descriptionController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.pricePerDay.toString());
    _categoryController = TextEditingController(text: widget.product.category);
    _locationController = TextEditingController(text: widget.product.location);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _productService.updateListing(
          listingId: widget.product.id,
          title: _titleController.text,
          description: _descriptionController.text,
          pricePerDay: double.parse(_priceController.text),
          category: _categoryController.text,
          location: _locationController.text,
        );
        if (mounted) {
          Navigator.pop(context); // Return to detail view
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar anuncio',
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'El título es requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'La descripción es requerida' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio por día',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'El precio es requerido';
                        if (double.tryParse(value!) == null) return 'Precio inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'La categoría es requerida' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'La ubicación es requerida' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Actualizar anuncio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}