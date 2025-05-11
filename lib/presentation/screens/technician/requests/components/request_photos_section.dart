// lib/presentation/screens/technician/requests/components/request_photos_section.dart
import 'package:flutter/material.dart';

class RequestPhotosSection extends StatelessWidget {
  final List<String>? photos;

  const RequestPhotosSection({Key? key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (photos == null || photos!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fotos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photos!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Mostrar foto en pantalla completa
                      showDialog(
                        context: context,
                        builder:
                            (context) => Dialog(
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: Image.network(
                                      photos![index],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 5,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          photos![index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
