// lib/presentation/screens/technician/components/account_type_selector.dart

import 'package:flutter/material.dart';

class AccountTypeSelector extends StatelessWidget {
  final bool isIndividual;
  final bool isEditing;
  final Function(bool) onTypeChanged;

  const AccountTypeSelector({
    Key? key,
    required this.isIndividual,
    required this.isEditing,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de cuenta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: isEditing ? () => onTypeChanged(true) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            isIndividual
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              isIndividual
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                          width: isIndividual ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            size: 28,
                            color:
                                isIndividual
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Individual',
                            style: TextStyle(
                              fontWeight:
                                  isIndividual
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  isIndividual
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade700,
                            ),
                          ),
                          if (isIndividual) const SizedBox(height: 4),
                          if (isIndividual)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: isEditing ? () => onTypeChanged(false) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            !isIndividual
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              !isIndividual
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade300,
                          width: !isIndividual ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.business,
                            size: 28,
                            color:
                                !isIndividual
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Negocio',
                            style: TextStyle(
                              fontWeight:
                                  !isIndividual
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  !isIndividual
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade700,
                            ),
                          ),
                          if (!isIndividual) const SizedBox(height: 4),
                          if (!isIndividual)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
