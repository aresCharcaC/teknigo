// lib/presentation/screens/technician/profile/components/reviews_section.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../widgets/star_rating.dart';
import '../../../../../core/constants/app_constants.dart';

class ReviewsSection extends StatelessWidget {
  final String technicianId;

  const ReviewsSection({Key? key, required this.technicianId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reseñas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('reviews')
                          .where('reviewedId', isEqualTo: technicianId)
                          .where('isVisible', isEqualTo: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("...", style: TextStyle(fontSize: 16));
                    }

                    final int count = snapshot.data?.docs.length ?? 0;
                    return Text(
                      '$count reseñas',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de reseñas
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('reviews')
                      .where('reviewedId', isEqualTo: technicianId)
                      .where('isVisible', isEqualTo: true)
                      .orderBy('createdAt', descending: true)
                      .limit(5)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar reseñas',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  );
                }

                final reviews = snapshot.data?.docs ?? [];

                if (reviews.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No hay reseñas todavía',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review =
                        reviews[index].data() as Map<String, dynamic>;
                    final double rating =
                        (review['rating'] as num?)?.toDouble() ?? 0.0;
                    final String? comment = review['comment'] as String?;
                    final Timestamp createdAt =
                        review['createdAt'] as Timestamp? ?? Timestamp.now();
                    final String reviewerId =
                        review['reviewerId'] as String? ?? '';

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection(AppConstants.usersCollection)
                              .doc(reviewerId)
                              .get(),
                      builder: (context, snapshot) {
                        String reviewerName = 'Cliente';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          reviewerName = userData?['name'] ?? 'Cliente';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    reviewerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(createdAt.toDate()),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              StarRating(
                                rating: rating,
                                size: 16,
                                showText: false,
                              ),

                              if (comment != null && comment.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  comment,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],

                              if (index < reviews.length - 1)
                                Divider(
                                  height: 24,
                                  color: Colors.grey.shade200,
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),

            // Botón para ver todas las reseñas
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Aquí puedes navegar a una pantalla de todas las reseñas
                  // o mostrar un diálogo con todas las reseñas
                  _showAllReviews(context);
                },
                icon: Icon(Icons.star, color: Theme.of(context).primaryColor),
                label: Text('Ver todas las reseñas'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAllReviews(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Todas las reseñas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('reviews')
                              .where('reviewedId', isEqualTo: technicianId)
                              .where('isVisible', isEqualTo: true)
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar reseñas',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          );
                        }

                        final reviews = snapshot.data?.docs ?? [];

                        if (reviews.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay reseñas todavía',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: reviews.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final review =
                                reviews[index].data() as Map<String, dynamic>;
                            final double rating =
                                (review['rating'] as num?)?.toDouble() ?? 0.0;
                            final String? comment =
                                review['comment'] as String?;
                            final Timestamp createdAt =
                                review['createdAt'] as Timestamp? ??
                                Timestamp.now();
                            final String reviewerId =
                                review['reviewerId'] as String? ?? '';

                            return FutureBuilder<DocumentSnapshot>(
                              future:
                                  FirebaseFirestore.instance
                                      .collection(AppConstants.usersCollection)
                                      .doc(reviewerId)
                                      .get(),
                              builder: (context, snapshot) {
                                String reviewerName = 'Cliente';
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final userData =
                                      snapshot.data!.data()
                                          as Map<String, dynamic>?;
                                  reviewerName = userData?['name'] ?? 'Cliente';
                                }

                                return ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(reviewerName),
                                      Text(
                                        _formatDate(createdAt.toDate()),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StarRating(
                                        rating: rating,
                                        size: 16,
                                        showText: false,
                                      ),
                                      if (comment != null && comment.isNotEmpty)
                                        Text(comment),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('CERRAR'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
