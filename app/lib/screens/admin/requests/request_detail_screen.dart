import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const RequestDetailScreen({Key? key, required this.request}) : super(key: key);

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late Map<String, dynamic> _requestDetails;

  @override
  void initState() {
    super.initState();
    _requestDetails = Map.from(widget.request);
  }

  void _updateRequestStatus(String newStatus) async {
    try {
      await AdminApi.updateRequestStatus(_requestDetails['_id'], newStatus);
      setState(() {
        _requestDetails['statut'] = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Statut mis à jour avec succès.")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Détails de la Demande",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID de la Demande: ${_requestDetails['_id']}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 10.h),
            Text(
              "Client: ${_requestDetails['client']['nom']} ${_requestDetails['client']['prenom']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            Text(
              "Pharmacie: ${_requestDetails['pharmacie']['nom'] ?? 'Non attribuée'}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            Text(
              "Statut: ${_requestDetails['statut']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            Text(
              "Date de Création: ${_requestDetails['date_creation']}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () => _updateRequestStatus("Complétée"),
              child: const Text("Marquer comme Complétée"),
            ),
            ElevatedButton(
              onPressed: () => _updateRequestStatus("Active"),
              child: const Text("Réactiver"),
            ),
          ],
        ),
      ),
    );
  }
}
