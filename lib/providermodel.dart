import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

List<PurchaseDetails> purchases = [];
List<ProductDetails> products = [];
const bool kAutoConsume = true;
// const String kConsumableId = 'small';
// const String kUpgradeId = 'medium';
const List<String> _kProductIds = ['small', 'medium', 'large'];

class ProviderModel with ChangeNotifier {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> subscription;
  List<String> notFoundIds = [];
  List<String> consumables = [];
  bool isAvailable = false;
  bool purchasePending = false;
  bool loading = true;
  String? queryProductError;

  Future<void> initInApp() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    await initStoreInfo();
    await verifyPreviousPurchases();
  }

  Future<void> inAppStream() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {}, onDone: () {
      subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
  }

  verifyPreviousPurchases() async {
    await inAppPurchase.restorePurchases();
    await Future.delayed(const Duration(milliseconds: 100), () {
      if (purchases.isNotEmpty) {
        unlockAnims = true;
      }

      finishedLoad = true;
    });

    notifyListeners();
  }

  bool _unlockAnims = false;
  bool get unlockAnims => _unlockAnims;
  set unlockAnims(bool value) {
    _unlockAnims = value;
    notifyListeners();
  }

  bool _finishedLoad = false;
  bool get finishedLoad => _finishedLoad;
  set finishedLoad(bool value) {
    _finishedLoad = value;
    notifyListeners();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailableStore = await inAppPurchase.isAvailable();
    if (!isAvailableStore) {
      isAvailable = isAvailableStore;
      products = [];
      purchases = [];
      notFoundIds = [];
      consumables = [];
      purchasePending = false;
      loading = false;
      return;
    }

    ProductDetailsResponse productDetailResponse =
        await inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      queryProductError = productDetailResponse.error!.message;
      isAvailable = isAvailableStore;
      products = productDetailResponse.productDetails;
      purchases = [];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumables = [];
      purchasePending = false;
      loading = false;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      queryProductError = null;
      isAvailable = isAvailableStore;
      products = productDetailResponse.productDetails;
      purchases = [];
      notFoundIds = productDetailResponse.notFoundIDs;
      consumables = [];
      purchasePending = false;
      loading = false;
      return;
    }

    // List<String> consumableProd = await ConsumableStore.load();
    isAvailable = isAvailableStore;
    products = productDetailResponse.productDetails;
    notFoundIds = productDetailResponse.notFoundIDs;
    // consumables = consumableProd;
    purchasePending = false;
    loading = false;
    notifyListeners();
  }

  // Future<void> consume(String id) async {
  //   await ConsumableStore.consume(id);
  //   final List<String> consumableProd = await ConsumableStore.load();
  //   consumables = consumableProd;
  //   notifyListeners();
  // }

  void showPendingUI() {
    purchasePending = true;
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    // if (purchaseDetails.productID == kConsumableId) {
    //   await ConsumableStore.save(purchaseDetails.purchaseID!);
    //   List<String> consumableProd = await ConsumableStore.load();
    //   purchasePending = false;
    //   consumables = consumableProd;
    // } else {
    purchases.add(purchaseDetails);
    purchasePending = false;
    // }
  }

  void handleError(IAPError error) {
    purchasePending = false;
  }

  // Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
  //   // IMPORTANT!! Always verify a purchase before delivering the product.
  //   // For the purpose of an example, we directly return true.
  //   return Future<bool>.value(true);
  // }

  // void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
  //   // handle invalid purchase here if  _verifyPurchase` failed.
  // }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // bool valid = await _verifyPurchase(purchaseDetails);
          // if (valid) {
          deliverProduct(purchaseDetails);
          // } else {
          //   _handleInvalidPurchase(purchaseDetails);
          //   return;
          // }
        }
        // if (Platform.isAndroid) {
        //   if (!kAutoConsume && purchaseDetails.productID == kConsumableId) {
        //     final InAppPurchaseAndroidPlatformAddition androidAddition =
        //         inAppPurchase.getPlatformAddition<
        //             InAppPurchaseAndroidPlatformAddition>();
        //     await androidAddition.consumePurchase(purchaseDetails);
        //   }
        // }
        if (purchaseDetails.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchaseDetails);
          verifyPreviousPurchases();
        }
      }
    });
  }

  // Future<void> confirmPriceChange(BuildContext context) async {
  //   if (Platform.isAndroid) {
  //     final InAppPurchaseAndroidPlatformAddition androidAddition = inAppPurchase
  //         .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
  //     var priceChangeConfirmationResult =
  //         await androidAddition.launchPriceChangeConfirmationFlow(
  //       sku: 'purchaseId',
  //     );
  //     if (priceChangeConfirmationResult.responseCode == BillingResponse.ok) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Price change accepted'),
  //       ));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text(
  //           priceChangeConfirmationResult.debugMessage ??
  //               "Price change failed with code ${priceChangeConfirmationResult.responseCode}",
  //         ),
  //       ));
  //     }
  //   }
  // }

  // GooglePlayPurchaseDetails? getOldSubscription(
  //     ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
  //   GooglePlayPurchaseDetails? oldSubscription;
  //   return oldSubscription;
  // }
  // bool unlockAnims = false;
  //
  // void unlockAnimsFunc(newValue) {
  //   unlockAnims = newValue;
  //   notifyListeners();
  // }

}
