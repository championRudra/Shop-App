// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/product_grid.dart';
// import '../widgets/badge.dart';

enum FilterOption {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showFavouriteOnly = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selected) {
              setState(
                () {
                  if (selected == FilterOption.Favorites) {
                    _showFavouriteOnly = true;
                  } else {
                    _showFavouriteOnly = false;
                  }
                },
              );
            },
            icon: Icon(
              Icons.more_vert_rounded,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: FilterOption.Favorites,
                child: Text('Only Favourite'),
              ),
              PopupMenuItem(
                value: FilterOption.All,
                child: Text('Show All'),
              ),
            ],
          ),
          FittedBox(
            child: Consumer<Cart>(
              builder: (_, cart, ch) => BadgeWidget(
                value: cart.itemCount.toString(),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/cart');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showFavouriteOnly),
    );
  }
}
