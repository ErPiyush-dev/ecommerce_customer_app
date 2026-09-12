import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/admin_provider.dart';
import '../../models/product_model.dart';

class AdminPendingProductsScreen extends StatefulWidget {
  const AdminPendingProductsScreen({super.key});

  @override
  State<AdminPendingProductsScreen> createState() =>
      _AdminPendingProductsScreenState();
}

class _AdminPendingProductsScreenState
    extends State<AdminPendingProductsScreen> {
  String _filter = 'ALL'; // ALL, PENDING, APPROVED

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAllProducts();
    });
  }

  void _showRejectDialog(Product product) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Product Reject Karein'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${product.name} kyun reject kar rahe hain?',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Jaise: Image clear nahi hai, description missing hai...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) return;
                Provider.of<AdminProvider>(
                  context,
                  listen: false,
                ).rejectProduct(product.id, reasonController.text.trim());
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(product.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 12),
                _detailRow('Price', '₹${product.price.toStringAsFixed(0)}'),
                _detailRow('Stock', '${product.stock}'),
                _detailRow('Category', product.categoryName),
                _detailRow('Seller', product.sellerName),
                _detailRow('Status', product.approved ? 'Approved' : 'Pending'),
                if (!product.approved &&
                    product.rejectionReason != null &&
                    product.rejectionReason!.isNotEmpty)
                  _detailRow('Rejected reason', product.rejectionReason!),
                const SizedBox(height: 8),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(product.description),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            if (product.approved)
              ElevatedButton(
                onPressed: () {
                  Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).unapproveProduct(product.id);
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Unapprove'),
              )
            else ...[
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _showRejectDialog(product);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AdminProvider>(
                    context,
                    listen: false,
                  ).approveProduct(product.id);
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Approve'),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Product> displayedProducts;
          if (_filter == 'PENDING') {
            displayedProducts = adminProvider.allProducts
                .where((p) => !p.approved)
                .toList();
          } else if (_filter == 'APPROVED') {
            displayedProducts = adminProvider.allProducts
                .where((p) => p.approved)
                .toList();
          } else {
            displayedProducts = adminProvider.allProducts;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _filterChip('All', 'ALL'),
                    const SizedBox(width: 8),
                    _filterChip('Pending', 'PENDING'),
                    const SizedBox(width: 8),
                    _filterChip('Approved', 'APPROVED'),
                  ],
                ),
              ),
              Expanded(
                child: displayedProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'Koi product nahi hai',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => adminProvider.fetchAllProducts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: displayedProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayedProducts[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () => _showProductDetails(product),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child:
                                        product.imageUrl != null &&
                                            product.imageUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: product.imageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                                title: Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '₹${product.price.toStringAsFixed(0)} · ${product.sellerName}',
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.approved
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    product.approved ? 'Approved' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: product.approved
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = value),
      selectedColor: Colors.deepPurple.shade100,
    );
  }
}
