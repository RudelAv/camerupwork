import 'package:flutter/material.dart';
import 'package:pfe/pages/user_profile/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MarketPlace extends StatefulWidget {
  final String userId;
  const MarketPlace({super.key, required this.userId});

  @override
  State<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productPriceController = TextEditingController();
  File? _productFinalImage; // For the main product image
  List<File> _productImages = []; // For additional images
  List<File> _productVideos = [];
  bool _isLoading = false; // Flag to show loading indicator
  bool _isSubmitted = false; // Flag to show success message

  Future<void> _getImageFromGallery(ImageType type) async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (type == ImageType.finalImage) {
          _productFinalImage = File(image.path);
        } else {
          _productImages.add(File(image.path));
        }
      });
    }
  }

  Future<void> _getVideoFromGallery() async {
    final XFile? video =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _productVideos.add(File(video.path));
      });
    }
  }

  Future<void> _submitProduct() async {
    setState(() {
      _isLoading = true;
    }); // Show loading indicator

    if (_formKey.currentState!.validate()) {
      // Upload images and videos to Firebase Storage
      List<String> imageUrls = [];
      List<String> videoUrls = [];

      if (_productFinalImage != null) {
        final ref = FirebaseStorage.instance.ref().child(
            'products/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}_final.jpg');
        await ref.putFile(_productFinalImage!);
        imageUrls.add(await ref.getDownloadURL());
      }

      for (File image in _productImages) {
        final ref = FirebaseStorage.instance.ref().child(
            'products/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}_${_productImages.indexOf(image)}.jpg');
        await ref.putFile(image);
        imageUrls.add(await ref.getDownloadURL());
      }

      for (File video in _productVideos) {
        final ref = FirebaseStorage.instance.ref().child(
            'products/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}_${_productVideos.indexOf(video)}.mp4');
        await ref.putFile(video);
        videoUrls.add(await ref.getDownloadURL());
      }

      // Add product to Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'name': _productNameController.text,
        'description': _productDescriptionController.text,
        'price': double.parse(_productPriceController.text),
        'images': imageUrls,
        'videos': videoUrls,
        'userId': widget.userId,
      });

      // Clear the form
      _productNameController.clear();
      _productDescriptionController.clear();
      _productPriceController.clear();
      _productFinalImage = null;
      _productImages.clear();
      _productVideos.clear();
      setState(() {
        _isSubmitted = true; // Show success message
        _isLoading = false; // Hide loading indicator
      });
    } else {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text('Market Place'),
        ),
        // leading: BackButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ProfilePage(userId: widget.userId),
        //       ),
        //     );
        //   },
        // ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du Produit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Product Description
                TextFormField(
                  controller: _productDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description du produit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Product Price
                TextFormField(
                  controller: _productPriceController,
                  decoration: InputDecoration(
                    labelText: 'Prix en FCFA',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Product Final Image
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Produit Final'),
                    const SizedBox(height: 8),
                    if (_productFinalImage != null)
                      Image.file(
                        _productFinalImage!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _getImageFromGallery(ImageType.finalImage),
                      child: const Text('Selectionnez l\'Image'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product Images
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('D\'autres Images du Produit'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _productImages.map((image) {
                        return Image.file(
                          image,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _getImageFromGallery(ImageType.additional),
                      child: const Text('Ajouter des Images'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Product Videos
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Videos'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _productVideos.map((video) {
                        return VideoPlayer(video
                            as VideoPlayerController); // Implement video player
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _getVideoFromGallery,
                      child: const Text('Add Video'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_isSubmitted)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Produit soumis avec succès!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vous pouvez ajouter d\'autres produits.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: _submitProduct,
                    child: const Text('Mettre en Vente'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ImageType { finalImage, additional }
