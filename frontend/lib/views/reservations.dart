import 'package:flutter/material.dart';
import 'package:frontend/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final bool isConfirmed = reservation.status == 'CONFIRMED';
    final bool isInProgress = reservation.status == 'IN_PROGRESS';
    final bool isFinished = reservation.status == 'FINISHED';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation.listingTitle ?? 'Cargando...',
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
            if (reservation.pricePerDay != null) ...[
              const SizedBox(height: 8),
              Text(
                'Precio total: ${reservation.totalPrice.toStringAsFixed(2)}€',
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
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
            if (isConfirmed && showActions) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _productService.startReservation(reservation.id);
                      setState(() {
                        _loadReservations();
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reserva iniciada'),
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
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Comenzar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 243, 170, 33),
                  ),
                ),
              ),
            ],
            if (isInProgress && showActions) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _productService.finishReservation(reservation.id);
                      setState(() {
                        _loadReservations();
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reserva finalizada'),
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
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Finalizar Reserva'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 76, 162, 175),
                  ),
                ),
              ),
            ],
            if (isFinished && !showActions && !reservation.hasReview) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showReviewDialog(reservation);
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Dejar Reseña'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(Reservation reservation) async {
    try {
      final product = await _productService.fetchProductById(reservation.listingId);
      
      double rating = 0;
      final commentController = TextEditingController();

      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) {  // Renombrado para claridad
            return StatefulBuilder(
              builder: (context, dialogSetState) {  // Renombrado para claridad
                return AlertDialog(
                  title: const Text('Dejar Reseña'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Calificación:'),
                        Slider(
                          value: rating,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: rating.toString(),
                          onChanged: (value) {
                            dialogSetState(() {
                              rating = value;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            if (index < rating.floor()) {
                              return const Icon(Icons.star, color: Colors.amber);
                            } else if (index < rating) {
                              return const Icon(Icons.star_half, color: Colors.amber);
                            }
                            return const Icon(Icons.star_border, color: Colors.amber);
                          }),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Comentario',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (rating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, selecciona una calificación')),
                          );
                          return;
                        }
                        if (commentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, escribe un comentario')),
                          );
                          return;
                        }

                        try {
                          final prefs = await SharedPreferences.getInstance();
                          final reviewerName = prefs.getString('username') ?? 'Usuario';

                          // Crear la review
                          await ReviewService().createReview(
                            userId: product.ownerId,
                            reviewerName: reviewerName,
                            listingId: reservation.listingId,
                            rating: rating,
                            comment: commentController.text,
                          );

                          // Actualizar el estado de la reserva a REVIEWED
                          await _productService.reviewReservation(reservation.id);

                          if (mounted) {
                            // Cerrar el diálogo
                            Navigator.pop(dialogContext);
                            
                            // Actualizar el estado del widget principal
                            setState(() {
                              // Recargar las reservas
                              _receivedReservationsFuture = _productService.getReceivedReservations();
                              _madeReservationsFuture = _productService.getMadeReservations();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reseña enviada correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al enviar la reseña: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Enviar Reseña'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos del producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    final inProgressReservations = reservations.where((r) => r.status == 'IN_PROGRESS').toList();
    final finishedReservations = reservations.where((r) => r.status == 'FINISHED').toList();

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
          if (inProgressReservations.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'En Progreso',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...inProgressReservations.map((r) => _buildReservationCard(r, showActions: showActions)),
          ],
          if (finishedReservations.isNotEmpty && !showActions) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Finalizadas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...finishedReservations.map((r) => _buildReservationCard(r, showActions: showActions)),
          ],
        ],
      ),
    );
  }
}