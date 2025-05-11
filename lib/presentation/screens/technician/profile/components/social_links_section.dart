// lib/presentation/screens/technician/components/social_links_section.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/models/social_link.dart';
import 'profile_section.dart';

class SocialLinksSection extends StatelessWidget {
  final bool isEditing;
  final List<SocialLink> socialLinks;
  final Function(List<SocialLink>) onUpdateSocialLinks;

  const SocialLinksSection({
    Key? key,
    required this.isEditing,
    required this.socialLinks,
    required this.onUpdateSocialLinks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'Redes sociales y sitio web',
      icon: Icons.link,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lista de enlaces sociales
          socialLinks.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No has agregado ningún enlace',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
              : Column(
                children:
                    socialLinks.map((link) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_getIconForLink(link.icon)),
                        title: Text(link.name),
                        subtitle: Text(
                          link.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing:
                            isEditing
                                ? IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _removeLink(link),
                                )
                                : IconButton(
                                  icon: const Icon(Icons.open_in_new, size: 20),
                                  onPressed: () => _openLink(link.url),
                                ),
                      );
                    }).toList(),
              ),

          // Botón para agregar enlace (solo en modo edición)
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: OutlinedButton.icon(
                onPressed: () => _showAddLinkDialog(context),
                icon: const Icon(Icons.add_link),
                label: const Text('Agregar enlace'),
              ),
            ),
        ],
      ),
    );
  }

  // Obtener ícono para la red social
  IconData _getIconForLink(String icon) {
    switch (icon) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.chat;
      case 'youtube':
        return Icons.video_library;
      case 'tiktok':
        return Icons.music_note;
      case 'website':
        return Icons.language;
      default:
        return Icons.link;
    }
  }

  // Remover un enlace
  void _removeLink(SocialLink link) {
    final updatedLinks = socialLinks.where((l) => l.url != link.url).toList();
    onUpdateSocialLinks(updatedLinks);
  }

  // Abrir enlace
  void _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('No se pudo abrir el enlace: $url');
    }
  }

  // Mostrar diálogo para agregar enlace
  void _showAddLinkDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    String selectedType = 'website';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Agregar enlace'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tipo de enlace
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          items: const [
                            DropdownMenuItem(
                              value: 'website',
                              child: Text('Sitio web'),
                            ),
                            DropdownMenuItem(
                              value: 'facebook',
                              child: Text('Facebook'),
                            ),
                            DropdownMenuItem(
                              value: 'instagram',
                              child: Text('Instagram'),
                            ),
                            DropdownMenuItem(
                              value: 'twitter',
                              child: Text('Twitter'),
                            ),
                            DropdownMenuItem(
                              value: 'youtube',
                              child: Text('YouTube'),
                            ),
                            DropdownMenuItem(
                              value: 'tiktok',
                              child: Text('TikTok'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Otro'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;

                              // Preconfigurar el nombre según el tipo
                              switch (selectedType) {
                                case 'website':
                                  nameController.text = 'Sitio web';
                                  break;
                                case 'facebook':
                                  nameController.text = 'Facebook';
                                  break;
                                case 'instagram':
                                  nameController.text = 'Instagram';
                                  break;
                                case 'twitter':
                                  nameController.text = 'Twitter';
                                  break;
                                case 'youtube':
                                  nameController.text = 'YouTube';
                                  break;
                                case 'tiktok':
                                  nameController.text = 'TikTok';
                                  break;
                                default:
                                  nameController.text = '';
                              }
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Nombre personalizado
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre a mostrar',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // URL
                        TextField(
                          controller: urlController,
                          decoration: InputDecoration(
                            labelText: 'URL',
                            hintText: 'https://',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCELAR'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Validar datos
                        final name = nameController.text.trim();
                        var url = urlController.text.trim();

                        if (name.isEmpty || url.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Completa todos los campos'),
                            ),
                          );
                          return;
                        }

                        // Asegurar que URL tenga http/https
                        if (!url.startsWith('http://') &&
                            !url.startsWith('https://')) {
                          url = 'https://$url';
                        }

                        // Crear nuevo enlace
                        final newLink = SocialLink(
                          name: name,
                          url: url,
                          icon: selectedType,
                        );

                        // Actualizar lista
                        final updatedLinks = List<SocialLink>.from(socialLinks);
                        updatedLinks.add(newLink);
                        onUpdateSocialLinks(updatedLinks);

                        Navigator.pop(context);
                      },
                      child: const Text('GUARDAR'),
                    ),
                  ],
                ),
          ),
    );
  }
}
