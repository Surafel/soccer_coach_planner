import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/player_repository.dart';

class PlayerFormScreen extends StatefulWidget {
  final PlayerRepository playerRepository;
  final String rosterId;
  final Player? existingPlayer;

  const PlayerFormScreen({
    super.key,
    required this.playerRepository,
    required this.rosterId,
    this.existingPlayer,
  });

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _jerseyController;
  late final TextEditingController _notesController;
  late PlayerPosition _position;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingPlayer?.name);
    _jerseyController = TextEditingController(
      text: widget.existingPlayer?.jerseyNumber?.toString(),
    );
    _notesController = TextEditingController(text: widget.existingPlayer?.notes);
    _position = widget.existingPlayer?.position ?? PlayerPosition.unspecified;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the player a name.')),
      );
      return;
    }
    final jerseyText = _jerseyController.text.trim();
    final notesText = _notesController.text.trim();
    final player = Player(
      id: widget.existingPlayer?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      rosterId: widget.rosterId,
      name: name,
      position: _position,
      jerseyNumber: jerseyText.isEmpty ? null : int.tryParse(jerseyText),
      notes: notesText.isEmpty ? null : notesText,
    );
    await widget.playerRepository.savePlayer(player);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingPlayer == null ? 'New Player' : 'Edit Player'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Player name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PlayerPosition>(
            value: _position,
            decoration: const InputDecoration(
              labelText: 'Position',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: PlayerPosition.unspecified,
                child: Text('Not set'),
              ),
              DropdownMenuItem(
                value: PlayerPosition.goalkeeper,
                child: Text('Goalkeeper'),
              ),
              DropdownMenuItem(
                value: PlayerPosition.defender,
                child: Text('Defender'),
              ),
              DropdownMenuItem(
                value: PlayerPosition.midfielder,
                child: Text('Midfielder'),
              ),
              DropdownMenuItem(
                value: PlayerPosition.forward,
                child: Text('Forward'),
              ),
            ],
            onChanged: (value) => setState(() => _position = value!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _jerseyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jersey number (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
