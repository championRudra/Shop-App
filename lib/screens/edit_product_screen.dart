// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, prefer_void_to_null

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  static const routeName = '/edit-product';
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _editedProducts = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final productId = ModalRoute.of(context)!.settings.arguments as String;
        if (productId != '') {
          _editedProducts =
              Provider.of<Products>(context, listen: false).findById(productId);
          _initValues = {
            'title': _editedProducts.title,
            'description': _editedProducts.description,
            'price': _editedProducts.price.toString(),
            'imageUrl': '',
          };
          _imageUrlController.text = _editedProducts.imageUrl;
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProducts.id != '') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProducts.id, _editedProducts);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProducts);
      } catch (e) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error has occurred!'),
            content: Text('Something went wrong!'),
            actions: [
              TextButton(
                onPressed: () {
                  // Pops AlertDialog
                  Navigator.of(ctx).pop();
                },
                child: Text('Okay'),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == "") {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (value) => _editedProducts = Product(
                        id: _editedProducts.id,
                        isFavorite: _editedProducts.isFavorite,
                        title: value as String,
                        description: _editedProducts.description,
                        price: _editedProducts.price,
                        imageUrl: _editedProducts.imageUrl,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == "") {
                          return 'Please enter a price.';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than 0.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _editedProducts = Product(
                        id: _editedProducts.id,
                        isFavorite: _editedProducts.isFavorite,
                        title: _editedProducts.title,
                        description: _editedProducts.description,
                        price: double.parse(value as String),
                        imageUrl: _editedProducts.imageUrl,
                      ),
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == "") {
                          return "Please enter a description.";
                        }
                        if (value!.length < 10) {
                          return "Should be at least 10 characters.";
                        }
                        return null;
                      },
                      onSaved: (value) => _editedProducts = Product(
                        id: _editedProducts.id,
                        isFavorite: _editedProducts.isFavorite,
                        title: _editedProducts.title,
                        description: value as String,
                        price: _editedProducts.price,
                        imageUrl: _editedProducts.imageUrl,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Placeholder(
                                  color: Colors.grey,
                                  strokeWidth: 0.5,
                                )
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageFocusNode,
                            onFieldSubmitted: (_) => _saveForm(),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }

                              return null;
                            },
                            onSaved: (value) => _editedProducts = Product(
                              id: _editedProducts.id,
                              isFavorite: _editedProducts.isFavorite,
                              title: _editedProducts.title,
                              description: _editedProducts.description,
                              price: _editedProducts.price,
                              imageUrl: value as String,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
