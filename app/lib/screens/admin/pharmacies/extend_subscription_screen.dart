import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/admin_api.dart';
import '../../../widgets/side_navigation_bar.dart';

class ExtendSubscriptionScreen extends StatefulWidget {
  final Map<String, dynamic> pharmacy;

  const ExtendSubscriptionScreen({Key? key, required this.pharmacy}) : super(key: key);

  @override
  _ExtendSubscriptionScreenState createState() => _ExtendSubscriptionScreenState();
}

class _ExtendSubscriptionScreenState extends State<ExtendSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPlan;
  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final response = await AdminApi.extendSubscription(
      widget.pharmacy['_id'],
      {'plan': _selectedPlan},
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Abonnement prolongé avec succès!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prolonger l’Abonnement de ${widget.pharmacy['nom']}"),
      ),
      drawer: const SideNavigationBar(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Abonnement Actuel: ${widget.pharmacy['abonnement']['plan']}"),
              SizedBox(height: 8.h),
              Text("Date de Début: ${widget.pharmacy['abonnement']['date_debut']}"),
              Text("Date de Fin: ${widget.pharmacy['abonnement']['date_fin']}"),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Nouveau Plan'),
                items: ["1 mois", "3 mois", "6 mois", "12 mois"]
                    .map((plan) => DropdownMenuItem<String>(
                          value: plan,
                          child: Text(plan),
                        ))
                    .toList(),
                onChanged: (value) => _selectedPlan = value,
                validator: (value) => value == null ? 'Plan requis' : null,
              ),
              SizedBox(height: 30.h),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Prolonger"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
