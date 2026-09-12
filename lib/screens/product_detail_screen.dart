import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/star_rating.dart';
import '../widgets/add_review_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(
        context,
        listen: false,
      ).fetchReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget
        .product; // Purane code me 'product' use hota tha, ab 'widget.product' se milega

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, _) {
              final isWishlisted = wishlistProvider.isInWishlist(product.id);
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : null,
                ),
                onPressed: () async {
                  if (isWishlisted) {
                    final item = wishlistProvider.wishlistItems.firstWhere(
                      (i) => i.productId == product.id,
                    );
                    await wishlistProvider.removeFromWishlist(
                      item.wishlistItemId,
                    );
                  } else {
                    await wishlistProvider.addToWishlist(product.id);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              width: double.infinity,
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image_not_supported, size: 60),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(product.categoryName),
                    backgroundColor: Colors.deepPurple.shade50,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Average rating yahan dikhate hain
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, _) {
                      if (reviewProvider.reviews.isEmpty)
                        return const SizedBox.shrink();
                      return Row(
                        children: [
                          StarRating(
                            rating: reviewProvider.averageRating,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${reviewProvider.averageRating.toStringAsFixed(1)} (${reviewProvider.reviews.length} reviews)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '₹${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    product.stock > 0
                        ? 'In Stock (${product.stock} available)'
                        : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 14,
                      color: product.stock > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sold by: ${product.sellerName}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 8),

                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Koi description nahi diya gaya',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Divider(),
                  const SizedBox(height: 8),

                  // Reviews Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                AddReviewDialog(productId: product.id),
                          );
                        },
                        child: const Text('Review Likhein'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, _) {
                      if (reviewProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (reviewProvider.reviews.isEmpty) {
                        return const Text(
                          'Abhi koi review nahi hai',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return Column(
                        children: reviewProvider.reviews.map((review) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      review.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StarRating(
                                      rating: review.rating.toDouble(),
                                      size: 14,
                                    ),
                                  ],
                                ),
                                if (review.comment != null &&
                                    review.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    review.comment!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: product.stock > 0
                ? () async {
                    final cartProvider = Provider.of<CartProvider>(
                      context,
                      listen: false,
                    );
                    bool success = await cartProvider.addToCart(product.id, 1);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Cart me add ho gaya!'
                                : 'Kuch galat ho gaya',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
