import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';
import 'request_detail_screen.dart';

class RequestListScreen extends StatefulWidget {
  const RequestListScreen({Key? key}) : super(key: key);

  @override
  _RequestListScreenState createState() => _RequestListScreenState();
}

class _RequestListScreenState extends State<RequestListScreen> {
  late Future<List<dynamic>> _requests;

  @override
  void initState() {
    super.initState();
    _requests = AdminApi.getRequests();
  }

  void _navigateToRequestDetail(Map<String, dynamic> request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(request: request),
      ),
    ).then((_) {
      setState(() {
        _requests = AdminApi.getRequests();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liste des Demandes",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: FutureBuilder<List<dynamic>>(
          future: _requests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur: ${snapshot.error}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucune demande disponible."));
            } else {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => Divider(height: 1.h),
                itemBuilder: (context, index) {
                  final request = snapshot.data![index];
                  return ListTile(
                    title: Text(
                      "Demande ID: ${request['_id']}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      "Client: ${request['client']['nom']} ${request['client']['prenom']}",
                    ),
                    trailing: Text(
                      request['statut'],
                      style: TextStyle(
                        color: request['statut'] == "Active"
                            ? Colors.orange
                            : request['statut'] == "Complétée"
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    onTap: () => _navigateToRequestDetail(request),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
