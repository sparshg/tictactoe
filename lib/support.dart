import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'providermodel.dart';
import 'package:provider/provider.dart';

class Support extends StatefulWidget {
  const Support({Key? key, required this.animMode}) : super(key: key);
  final ValueChanged<bool> animMode;
  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  bool _newAnimations = false;
  final prices = {
    'smalld': 2,
    'centerd': 5,
    'larged': 10,
    'small': 2,
    'medium': 5,
    'large': 10
  };

  late ProviderModel _appProvider;
  TextStyle _textStyle =
      const TextStyle(fontSize: 18, fontFamily: 'Monospace', color: black);
  TextStyle _textStyle2 =
      const TextStyle(fontSize: 18, fontFamily: 'Monospace', color: white);

  @override
  void initState() {
    final provider = Provider.of<ProviderModel>(context, listen: false);
    _appProvider = provider;
    inAppStream(provider);
    super.initState();
  }

  inAppStream(provider) async {
    await provider.inAppStream();
  }

  @override
  void dispose() {
    _appProvider.subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderModel>(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: SimpleDialog(
        backgroundColor: white,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Spacer(flex: 3),
          Text('Buy me a Coffee!'),
          Spacer(),
          Icon(provider.unlockAnims ? Icons.check_circle : Icons.coffee_rounded,
              color: black, size: 18),
          Spacer(flex: 3)
        ]),
        titlePadding: const EdgeInsets.all(24),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        children: [
          Text(
            "Also get some nice fluid animations :)",
            style: _textStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Thanks for your support!",
            style: _textStyle,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Text("New animations", style: _textStyle)),
                  Switch(
                    onChanged: (to) {
                      if (provider.unlockAnims) {
                        setState(() {
                          widget.animMode(to);
                          _newAnimations = to;
                        });
                      }
                    },
                    value: _newAnimations,
                    inactiveThumbColor: provider.unlockAnims
                        ? Colors.grey.shade800
                        : Colors.grey,
                    inactiveTrackColor: provider.unlockAnims
                        ? Colors.grey.shade600.withOpacity(0.8)
                        : Colors.grey.withOpacity(0.5),
                    activeColor: black,
                  ),
                ]),
          ),
          if (provider.queryProductError == null) _buildProductList(provider),
          if (provider.queryProductError == null)
            _buildConnectionCheckTile(provider),
        ],
      ),
    );
  }

  Widget _buildConnectionCheckTile(provider) {
    TextStyle _textStyle =
        const TextStyle(fontSize: 12, fontFamily: 'Monospace', color: black);
    if (provider.loading) {
      return const Text('Trying to connect...');
    }
    String s = provider.notFoundIds.isNotEmpty ? 'Store unavailable' : '';
    if (!provider.isAvailable) {
      s += '\nUnable to connect to the payments processor';
    }
    return Text(s, style: _textStyle, textAlign: TextAlign.center);
  }

  Widget _buildProductList(provider) {
    if (provider.loading) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text('Fetching...', style: _textStyle),
        CircularProgressIndicator(
          color: black,
          strokeWidth: 1,
        ),
      ]);
    }
    if (!provider.isAvailable) {
      return Container();
    }
    List<Widget> productList = <Widget>[];
    if (provider.notFoundIds.isNotEmpty) {
      log(provider.notFoundIds.toString());
      productList.add(
        Text('Error fetching',
            style: TextStyle(color: ThemeData.light().errorColor)),
      );
    }

    Map<String, PurchaseDetails> purchasesIn =
        Map.fromEntries(purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        provider.inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));

    // productList.add(Icon(Icons.check, color: Colors.teal, size: 60));

    ButtonStyle _supportButton = ElevatedButton.styleFrom(
      primary: black,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.all(12),
      elevation: 8,
    );
    products.sort((a, b) => a.price.compareTo(b.price));

    productList.add(Row(
        children: products.map(
      (ProductDetails productDetails) {
        if ((provider.unlockAnims &&
                ['smalld', 'centerd', 'larged'].contains(productDetails.id)) ||
            (!provider.unlockAnims &&
                ['small', 'medium', 'large'].contains(productDetails.id))) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 0.0),
              child: ElevatedButton(
                child: Text('\$ ${prices[productDetails.id]}'),
                style: _supportButton,
                onPressed: () {
                  late PurchaseParam purchaseParam;

                  if (Platform.isAndroid) {
                    purchaseParam = GooglePlayPurchaseParam(
                      productDetails: productDetails,
                    );
                  } else {
                    purchaseParam = PurchaseParam(
                      productDetails: productDetails,
                      applicationUserName: null,
                    );
                  }

                  if (provider.unlockAnims) {
                    provider.inAppPurchase.buyConsumable(
                        purchaseParam: purchaseParam,
                        autoConsume: kAutoConsume || Platform.isIOS);
                  } else {
                    provider.inAppPurchase
                        .buyNonConsumable(purchaseParam: purchaseParam);
                  }
                },
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    ).toList()));

    return Column(children: productList);
  }
}
