import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/product_service.dart';
import 'custom_bottom_nav.dart';

class ReservationsView extends StatefulWidget {
  const ReservationsView({super.key});
  @override
  _ReservationsViewState createState() => _ReservationsViewState();
}

class _ReservationsViewState extends State<ReservationsView> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  late TabController _tabController;
  late Future<List<Reservation>> _receivedReservationsFuture;
  late Future<List<Reservation>> _madeReservationsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReservations() {
    _receivedReservationsFuture = _productService.getReceivedReservations();
    _madeReservationsFuture = _productService.getMadeReservations();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildReservationCard(Reservation reservation, {required bool showActions}) {
    final bool isPending = reservation.status == 'PENDING';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.listingTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fechas: ${_formatDate(reservation.startDate)} - ${_formatDate(reservation.endDate)}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duración: ${reservation.numberOfDays} días',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Precio total: ${reservation.totalPrice.toStringAsFixed(2)}€',
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estado: ${reservation.status}',
              style: TextStyle(
                color: isPending ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isPending && showActions) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _productService.confirmReservation(reservation.id);
                        setState(() {
                          _loadReservations();
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reserva confirmada'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _productService.cancelReservation(reservation.id);
                        setState(() {
                          _loadReservations();
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reserva cancelada'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mis Reservas',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: const [
            Tab(text: 'Recibidas'),
            Tab(text: 'Realizadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab de reservas recibidas
          FutureBuilder<List<Reservation>>(
            future: _receivedReservationsFuture,
            builder: (context, snapshot) => _buildReservationsList(snapshot, showActions: true),
          ),
          // Tab de reservas realizadas
          FutureBuilder<List<Reservation>>(
            future: _madeReservationsFuture,
            builder: (context, snapshot) => _buildReservationsList(snapshot, showActions: false),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildReservationsList(AsyncSnapshot<List<Reservation>> snapshot, {required bool showActions}) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('No hay reservas'));
    }

    final reservations = snapshot.data!;
    final pendingReservations = reservations.where((r) => r.status == 'PENDING').toList();
    final confirmedReservations = reservations.where((r) => r.status == 'CONFIRMED').toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingReservations.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pendientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...pendingReservations.map((r) => _buildReservationCard(r, showActions: showActions)),
          ],
          if (confirmedReservations.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Confirmadas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...confirmedReservations.map((r) => _buildReservationCard(r, showActions: showActions)),
          ],
        ],
      ),
    );
  }
}