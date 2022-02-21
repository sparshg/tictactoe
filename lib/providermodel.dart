import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

List<PurchaseDetails> purchases = [];
List<ProductDetails> products = [];
const bool kAutoConsume = true;
const List<String> _kProductIds = [
  'small',
  'medium',
  'large',
  'smalld',
  'centerd',
  'larged'
];

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
    }, onError: (error) {});
    await initStoreInfo();
    await verifyPreviousPurchases();
  }

  Future<void> inAppStream() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        inAppPurchase.purchaseStream;
    subscription = purchaseUpdated.listen((purchaseDetailsList) {}, onDone: () {
      subscription.cancel();
    }, onError: (error) {});
  }

  verifyPreviousPurchases() async {
    await inAppPurchase.restorePurchases();
    await Future.delayed(const Duration(milliseconds: 100), () {
      for (var pur in purchases) {
        log(pur.productID);
      }
      if (purchases.isNotEmpty) {
        unlockAnims = true;
        log("not empty");
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
    isAvailable = isAvailableStore;
    products = productDetailResponse.productDetails;
    notFoundIds = productDetailResponse.notFoundIDs;
    purchasePending = false;
    loading = false;
    notifyListeners();
  }

  void showPendingUI() {
    purchasePending = true;
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    purchases.add(purchaseDetails);
    purchasePending = false;
  }

  void handleError(IAPError error) {
    purchasePending = false;
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          deliverProduct(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await inAppPurchase.completePurchase(purchaseDetails);
          verifyPreviousPurchases();
        }
      }
    });
  }
}
