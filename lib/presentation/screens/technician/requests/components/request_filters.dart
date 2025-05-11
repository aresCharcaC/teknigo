// lib/presentation/screens/technician/requests/components/request_filters.dart
import 'package:flutter/material.dart';

class RequestFilterModel {
  bool onlyUrgent;
  bool onlyHomeService;
  String? categoryFilter;

  RequestFilterModel({
    this.onlyUrgent = false,
    this.onlyHomeService = false,
    this.categoryFilter,
  });

  RequestFilterModel copyWith({
    bool? onlyUrgent,
    bool? onlyHomeService,
    String? categoryFilter,
  }) {
    return RequestFilterModel(
      onlyUrgent: onlyUrgent ?? this.onlyUrgent,
      onlyHomeService: onlyHomeService ?? this.onlyHomeService,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

class RequestFilters extends StatefulWidget {
  final Function(RequestFilterModel) onApplyFilters;

  const RequestFilters({Key? key, required this.onApplyFilters})
    : super(key: key);

  @override
  _RequestFiltersState createState() => _RequestFiltersState();
}

class _RequestFiltersState extends State<RequestFilters> {
  final RequestFilterModel _filters = RequestFilterModel();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Filtro de urgencia
              Expanded(
                child: CheckboxListTile(
                  title: Text('Solo urgentes', style: TextStyle(fontSize: 14)),
                  value: _filters.onlyUrgent,
                  onChanged: (value) {
                    setState(() {
                      _filters.onlyUrgent = value ?? false;
                    });
                    widget.onApplyFilters(_filters);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),

              // Filtro de servicio a domicilio
              Expanded(
                child: CheckboxListTile(
                  title: Text('A domicilio', style: TextStyle(fontSize: 14)),
                  value: _filters.onlyHomeService,
                  onChanged: (value) {
                    setState(() {
                      _filters.onlyHomeService = value ?? false;
                    });
                    widget.onApplyFilters(_filters);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),

          // Filtro de categoría
          DropdownButtonFormField<String?>(
            decoration: InputDecoration(
              labelText: 'Categoría',
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            value: _filters.categoryFilter,
            onChanged: (value) {
              setState(() {
                _filters.categoryFilter = value;
              });
              widget.onApplyFilters(_filters);
            },
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas las categorías'),
              ),
              ...['1', '2', '3', '4', '5', '16', '17'].map((categoryId) {
                return DropdownMenuItem<String?>(
                  value: categoryId,
                  child: Text(_getCategoryName(categoryId)),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    final Map<String, String> categories = {
      '1': 'Electricista',
      '2': 'Iluminación',
      '3': 'Plomero',
      '4': 'Calefacción',
      '5': 'Técnico PC',
      '16': 'Pintor',
      '17': 'Jardinero',
    };

    return categories[categoryId] ?? 'Categoría';
  }
}
