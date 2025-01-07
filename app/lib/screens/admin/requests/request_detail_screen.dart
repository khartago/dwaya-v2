// lib/screens/admin/requests/request_detail_screen.dart
import 'package:dwaya_flutter/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import '../../../models/request.dart';
import '../../../models/message.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class RequestDetailScreen extends StatefulWidget {
  final RequestModel request;

  const RequestDetailScreen({Key? key, required this.request}) : super(key: key);

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late Future<List<MessageModel>> _messagesFuture;
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messagesFuture = AdminApi.getMessages(widget.request.id);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    Map<String, dynamic> messageData = {
      'request_id': widget.request.id,
      'destinataire_id': widget.request.clientId,
      'destinataire_model': 'User',
      'message': _messageController.text.trim(),
    };

    try {
      await AdminApi.sendMessage(messageData);
      _messageController.clear();
      setState(() {
        _messagesFuture = AdminApi.getMessages(widget.request.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _updateRequestStatus(String status) async {
    try {
      await AdminApi.updateRequestStatus(widget.request.id, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut de la demande mis à jour')),
      );
      setState(() {
        widget.request.status = status;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildMessage(MessageModel message) {
    bool isAdmin = message.expediteurModel == 'Admin';
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.message,
          style: TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    RequestModel request = widget.request;

    return Scaffold(
      drawer: SideNavigationBar(),
      appBar: AppBar(
        title: Text('Détails de la Demande'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _updateRequestStatus(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'in-progress',
                child: Text('Marquer comme en cours'),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Text('Marquer comme complétée'),
              ),
              PopupMenuItem(
                value: 'refused',
                child: Text('Refuser'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Informations de la demande
            Card(
              child: ListTile(
                title: Text('Zone'),
                subtitle: Text(request.zone.capitalize()),
              ),
            ),
            if (request.zone == 'ville')
              Card(
                child: ListTile(
                  title: Text('Ville'),
                  subtitle: Text(request.ville ?? 'N/A'),
                ),
              ),
            if (request.zone == 'region')
              Card(
                child: ListTile(
                  title: Text('Région'),
                  subtitle: Text(request.region ?? 'N/A'),
                ),
              ),
            Card(
              child: ListTile(
                title: Text('Statut'),
                subtitle: Text(request.status.capitalize()),
              ),
            ),
            SizedBox(height: 10),
            // Liste des messages
            Expanded(
              child: FutureBuilder<List<MessageModel>>(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<MessageModel> messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return Center(child: Text('Aucun message trouvé.'));
                    }
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        MessageModel message = messages[index];
                        return _buildMessage(message);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            // Champ d'envoi de message
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Envoyer un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSending ? null : _sendMessage,
                  child: _isSending ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(12),
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
