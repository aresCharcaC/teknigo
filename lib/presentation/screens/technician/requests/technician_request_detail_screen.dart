// lib/presentation/screens/technician/requests/technician_request_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/service_request_model.dart';
import '../../../view_models/category_view_model.dart';
import 'components/request_detail_header.dart';
import 'components/request_detail_info.dart';
import 'components/request_photos_section.dart';
import 'components/request_client_info.dart';
import 'components/action_buttons.dart';

class TechnicianRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const TechnicianRequestDetailScreen({Key? key, required this.requestId})
    : super(key: key);

  @override
  _TechnicianRequestDetailScreenState createState() =>
      _TechnicianRequestDetailScreenState();
}

class _TechnicianRequestDetailScreenState
    extends State<TechnicianRequestDetailScreen> {
  late Future<ServiceRequestModel?> _requestFuture;

  @override
  void initState() {
    super.initState();
    // Cargar los detalles de la solicitud
    _requestFuture = _loadRequestDetails();
  }

  Future<ServiceRequestModel?> _loadRequestDetails() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('service_requests')
              .doc(widget.requestId)
              .get();

      if (!doc.exists) {
        return null;
      }

      return ServiceRequestModel.fromFirestore(doc);
    } catch (e) {
      print('Error al obtener solicitud por ID: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de solicitud')),
      body: FutureBuilder<ServiceRequestModel?>(
        future: _requestFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los detalles: ${snapshot.error}',
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Volver'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontró la solicitud',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Volver'),
                  ),
                ],
              ),
            );
          }

          // Si hay datos, mostrar los detalles
          final request = snapshot.data!;
          return _buildRequestDetail(context, request);
        },
      ),
    );
  }

  Widget _buildRequestDetail(
    BuildContext context,
    ServiceRequestModel request,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y descripción
          RequestDetailHeader(request: request),

          const SizedBox(height: 16),

          // Detalles de la solicitud
          RequestDetailInfo(request: request),

          const SizedBox(height: 16),

          // Fotos (si hay)
          if (request.photos != null && request.photos!.isNotEmpty)
            RequestPhotosSection(photos: request.photos),

          if (request.photos != null && request.photos!.isNotEmpty)
            const SizedBox(height: 16),

          // Información del cliente
          RequestClientInfo(clientId: request.userId),

          const SizedBox(height: 16),

          // Botones de acción
          ActionButtons(
            onNotInterested: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('¿No te interesa esta solicitud?'),
                      content: Text(
                        'Esta solicitud no volverá a aparecer en tu lista.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('CANCELAR'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            // Guardar en SharedPreferences
                            try {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final ignoredIds =
                                  prefs.getStringList('ignored_request_ids') ??
                                  [];
                              if (!ignoredIds.contains(request.id)) {
                                ignoredIds.add(request.id);
                                await prefs.setStringList(
                                  'ignored_request_ids',
                                  ignoredIds,
                                );
                              }
                            } catch (e) {
                              print('Error al guardar solicitud ignorada: $e');
                            }

                            Navigator.pop(
                              context,
                            ); // Volver a la pantalla anterior
                          },
                          child: Text(
                            'NO ME INTERESA',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
            onSendProposal: () {
              // Aquí se implementará el envío de propuesta más adelante
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Próximamente: Envío de propuesta'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
