import 'package:flutter/material.dart';
import 'package:backend_client/backend_client.dart'; // Client access এর জন্য

class Medicine {
  int? itemId;
  String name;
  int stock;
  String dose;
  int prescribedQty;
  int dispenseQty;
  bool isAlternative;
  int? originalItemId;

  Medicine({
    required this.itemId,
    required this.name,
    required this.stock,
    required this.dose,
    required this.prescribedQty,
    required this.dispenseQty,
    this.isAlternative = false,
    this.originalItemId,
  });
}

class MedicineItem extends StatefulWidget {
  final Medicine medicine;
  final Client client; // Serverpod client pass করতে হবে
  final void Function(Medicine) onChanged;

  const MedicineItem({
    super.key,
    required this.medicine,
    required this.client,
    required this.onChanged,
  });

  @override
  State<MedicineItem> createState() => _MedicineItemState();
}

class _MedicineItemState extends State<MedicineItem> {
  bool _isSearching = false;
  List<InventoryItemInfo> _searchResults = [];
  final TextEditingController _altSearchController = TextEditingController();

  void _searchAlternative(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = []; // সার্চ বক্স ফাঁকা হলে লিস্ট ক্লিয়ার করে দিবে
      });
      return;
    }
    final results = await widget.client.dispenser.searchInventoryItems(query);
    setState(() {
      _searchResults = results;
    });
  }

  void _selectAlternative(InventoryItemInfo item) async {
    // শুধু তখনই originalItemId set করো যদি এটি আগে null থাকে
    if (widget.medicine.originalItemId == null && widget.medicine.itemId != null) {
      // check inventory validity
      final validOriginal = await widget.client.dispenser.getStockByFirstWord(widget.medicine.name);
      widget.medicine.originalItemId = validOriginal?.itemId;
    }

    // নতুন alternative medicine set
    setState(() {
      widget.medicine.itemId = item.itemId;
      widget.medicine.name = item.itemName;
      widget.medicine.stock = item.currentQuantity;
      widget.medicine.isAlternative = true;
      _isSearching = false;
      _searchResults.clear();
    });

    widget.onChanged(widget.medicine);
  }



  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;
    final bool itemNotFound = med.itemId == null;
    final bool outOfStock = med.stock <= 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: (itemNotFound || outOfStock) ? Colors.red.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    med.name + (med.isAlternative ? " (Alt)" : ""),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: med.isAlternative
                          ? Colors.green
                          : (outOfStock ? Colors.red : Colors.black),
                    ),
                  ),
                ),

                Text(
                  itemNotFound ? "NOT IN INVENTORY" : " Name: ${med.name} (Stock: ${med.stock})",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Prescribed Dose: ${med.dose}",
              style: const TextStyle(color: Colors.black54),
            ),

            const Divider(),

            // সার্চ সেকশন (যদি স্টক না থাকে বা ইউজার পরিবর্তন করতে চায়)
            if (outOfStock || _isSearching) ...[
              TextField(
                controller: _altSearchController,
                decoration: InputDecoration(
                  hintText: "Search alternative medicine...",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () =>
                        _searchAlternative(_altSearchController.text),
                  ),
                ),
                onChanged: _searchAlternative,
              ),
              if (_altSearchController.text.isNotEmpty && _searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        title: Text(item.itemName),
                        subtitle: Text("Stock: ${item.currentQuantity}"),
                        onTap: () => _selectAlternative(item),
                      );
                    },
                  ),
                ),
            ] else
              TextButton.icon(
                onPressed: () => setState(() => _isSearching = true),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text("Change / Find Alternative"),
              ),

            const SizedBox(height: 10),
            Row(
              children: [
                Text("Prescribed: ${med.prescribedQty}"),
                const Spacer(),
                const Text("Dispense: "),
                SizedBox(
                  width: 60,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: med.dispenseQty > 0 ? med.dispenseQty.toString() : med.prescribedQty.toString(),
                    ),
                    onChanged: (val) {
                      int q = int.tryParse(val) ?? 0;
                      if (q < 0) q = 0;
                      med.dispenseQty = q;
                      widget.onChanged(med);
                    },
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
