import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import 'chat.dart';
import 'edit_product.dart';
import 'reservation_preview.dart';

class ProductDetailView extends StatefulWidget {
  final int productId;

  const ProductDetailView({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  Product? _product;
  String? _error;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _showCalendar = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final product = await _productService.fetchProductById(widget.productId);
      
      setState(() {
        _product = product;
        _isLoading = false;
        _isOwner = userId != null && int.parse(userId) == product.ownerId;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showDateRangePicker() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.deepOrange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductView(product: _product!),
                  ),
                ).then((_) => _loadProductDetails()); // Reload after edit
              },
            ),
          if (_isOwner)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text('¿Estás seguro de que deseas eliminar este producto? Esta acción no se puede deshacer.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  try {
                    await _productService.deleteProduct(_product!.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Producto eliminado correctamente')),
                    );
                    Navigator.pop(context, true); // Regresa a la pantalla anterior con un valor
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al eliminar el producto: $e')),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              image: DecorationImage(
                                image: _product!.images.isNotEmpty
                                    ? NetworkImage(
                                        'http://192.168.1.136:8080/listing/images/${_product!.images.first}')
                                    : const AssetImage('assets/anuncio_image.jpg')
                                        as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _product!.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_product!.pricePerDay}€/día',
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (!_isOwner)
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatView(
                                                userName: _product!.ownerName ?? 'Usuario',
                                                productName: _product!.title,
                                                receiverId: _product!.ownerId,
                                                listingId: _product!.id,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepOrange,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Chat',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _product!.description,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.grey[600], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _product!.location,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.grey[600], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Publicado el ${_product!.createdAt}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),                                                        
                              ],
                            ),
                          ),
                          const SizedBox(height: 80), // Space for bottom button
                        ],
                      ),
                    ),
          if (_showCalendar)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent background
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Selecciona las fechas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _showCalendar = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _startDate ?? DateTime.now(),
                          selectedDayPredicate: (day) {
                            return isSameDay(_startDate, day) || 
                                   isSameDay(_endDate, day);
                          },
                          rangeStartDay: _startDate,
                          rangeEndDay: _endDate,
                          calendarFormat: CalendarFormat.month,
                          rangeSelectionMode: RangeSelectionMode.enforced,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              if (_startDate == null || _endDate != null) {
                                _startDate = selectedDay;
                                _endDate = null;
                              } else {
                                _endDate = selectedDay;
                                if (_endDate!.isBefore(_startDate!)) {
                                  final temp = _startDate;
                                  _startDate = _endDate;
                                  _endDate = temp;
                                }
                                _showCalendar = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (!_isOwner)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_startDate != null && _endDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Del ${_formatDate(_startDate!)} al ${_formatDate(_endDate!)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        if (_startDate == null) {
                          _showDateRangePicker();
                        } else if (_endDate == null) {
                          // Continue selecting end date
                        } else {
                          // Navigate to reservation preview
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationPreviewView(
                                product: _product!,
                                startDate: _startDate!,
                                endDate: _endDate!,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _startDate == null ? 'Reservar' : 
                        _endDate == null ? 'Selecciona fecha fin' : 'Confirmar reserva',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}