// lib/core/models/social_link.dart
class SocialLink {
  final String name;
  final String url;
  final String icon;

  SocialLink({required this.name, required this.url, this.icon = 'link'});

  Map<String, dynamic> toMap() {
    return {'name': name, 'url': url, 'icon': icon};
  }

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      icon: map['icon'] ?? 'link',
    );
  }
}
