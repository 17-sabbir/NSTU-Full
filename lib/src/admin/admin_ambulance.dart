import 'package:flutter/material.dart';
import 'package:backend_client/backend_client.dart';

class AdminAmbulance extends StatefulWidget {
  const AdminAmbulance({super.key});

  @override
  State<AdminAmbulance> createState() => _AdminAmbulanceState();
}

class _AdminAmbulanceState extends State<AdminAmbulance> {
  late Future<List<AmbulanceContact>> _ambulances;

  @override
  void initState() {
    super.initState();
    _loadAmbulances();
  }

  void _loadAmbulances() {
    _ambulances = client.patient.getAmbulanceContacts();
  }
  void _showAddEditDialog({AmbulanceContact? contact}) {
    final titleController = TextEditingController(text: contact?.contactTitle ?? '');
    final phoneBnController = TextEditingController(text: contact?.phoneBn ?? '');
    final phoneEnController = TextEditingController(text: contact?.phoneEn ?? '');
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(contact == null ? "Add Ambulance" : "Edit Ambulance"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: phoneBnController,
                  decoration: const InputDecoration(labelText: "Phone (Bangla)"),
                ),
                TextField(
                  controller: phoneEnController,
                  decoration: const InputDecoration(labelText: "Phone (English)"),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isPrimary,
                      onChanged: (val) {
                        setDialogState(() {
                          isPrimary = val ?? false;
                        });
                      },
                    ),
                    const Text("Primary Ambulance"),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final phoneBn = phoneBnController.text.trim();
                final phoneEn = phoneEnController.text.trim();

                if (title.isEmpty || phoneBn.isEmpty || phoneEn.isEmpty) return;

                if (contact == null) {
                  await client.adminEndpoints.addAmbulanceContact(title, phoneBn, phoneEn, isPrimary);
                } else {
                  await client.adminEndpoints.updateAmbulanceContact(contact.contactId, title, phoneBn, phoneEn, isPrimary);
                }

                Navigator.pop(context);
                setState(() => _loadAmbulances());
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAmbulanceTile(AmbulanceContact contact) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(contact.contactTitle),
        subtitle: Text("${contact.phoneBn} || ${contact.phoneEn}"),

        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _showAddEditDialog(contact: contact),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambulances"),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<AmbulanceContact>>(
        future: _ambulances,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load ambulances"));
          }
          final ambulances = snapshot.data ?? [];
          if (ambulances.isEmpty) {
            return const Center(child: Text("No ambulances found"));
          }
          return ListView(
            padding: const EdgeInsets.all(10),
            children: ambulances.map(_buildAmbulanceTile).toList(),
          );
        },
      ),
    );
  }
}
