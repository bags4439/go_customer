import 'package:flutter/material.dart';

import '../../domain/entities/shipping.dart';
import 'shipping_agent_note_card.dart';

/// Optional agent note block used below the main shipping content.
class ShippingAgentNotesSection extends StatelessWidget {
  const ShippingAgentNotesSection({super.key, required this.shipping});

  final Shipping shipping;

  @override
  Widget build(BuildContext context) {
    final note = shipping.agentNotes?.trim();
    if (note == null || note.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 16),
        ShippingAgentNoteCard(note: note),
      ],
    );
  }
}
