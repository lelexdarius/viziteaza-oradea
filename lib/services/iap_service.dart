import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../premium_unlock_page.dart';


class IAPService {
  // Singleton
  static final IAPService instance = IAPService._internal();
  IAPService._internal();

  //------------------------------------------------
  // CONSTANTE
  //------------------------------------------------
  static const String premiumProductId = "premium_trasee_oradea";
  static const String _prefKey = "premium_unlocked";

  //------------------------------------------------
  // STATE
  //------------------------------------------------
  bool isAvailable = false;
  bool premiumUnlocked = false;

  ProductDetails? premiumProduct;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _inited = false;

  // Restore state
  bool _isRestoring = false;
  bool _sawRestoreEvent = false; // devine true dacă am primit restored/purchased pt produs

  // 🔔 Notifică UI când s-a deblocat premium
  final StreamController<bool> _premiumStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get premiumStateStream => _premiumStateController.stream;

  // 🔔 Notifică UI cu mesaje (pentru SnackBar)
  final StreamController<String> _iapMessageController =
      StreamController<String>.broadcast();
  Stream<String> get iapMessageStream => _iapMessageController.stream;

  //------------------------------------------------
  // INIT (cheamă o singură dată, la start)
  //------------------------------------------------
  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    await loadPremiumStatus();

    isAvailable = await InAppPurchase.instance.isAvailable();

    // Ascultă stream-ul de cumpărături (o singură dată)
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (e) {
        debugPrint("❌ purchaseStream error: $e");
        _iapMessageController.add("Eroare magazin. Încearcă din nou.");
      },
    );

    if (!isAvailable) {
      debugPrint("⚠️ IAP indisponibil pe acest device/store.");
      return;
    }

    await _loadProducts();

    // ❌ NU mai facem restore automat aici.
    // Apple vrea restore ca acțiune explicită și oricum îți încurcă feedback-ul.
  }

  //------------------------------------------------
  // LOAD STATUS (doar citire)
  //------------------------------------------------
  Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    premiumUnlocked = prefs.getBool(_prefKey) ?? false;
  }

  //------------------------------------------------
  // SET STATUS (scriere + broadcast)
  //------------------------------------------------
  Future<void> setPremiumUnlocked(bool value) async {
    premiumUnlocked = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    _premiumStateController.add(value);
  }

  //------------------------------------------------
  // HELPER: PREȚ DIN STORE (pentru UI)
  //------------------------------------------------
  String? get premiumPrice => premiumProduct?.price;
  String? get premiumTitle => premiumProduct?.title;
  String? get premiumDescription => premiumProduct?.description;

  //------------------------------------------------
  // GATEKEEPER (folosit de pagina cu trasee)
  //------------------------------------------------
  Future<bool> ensurePremium(BuildContext context) async {
    if (premiumUnlocked) return true;

    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PremiumUnlockPage()),
    );

    return result == true || premiumUnlocked == true;
  }

  //------------------------------------------------
  // ÎNCĂRCARE PRODUS
  //------------------------------------------------
  Future<void> _loadProducts() async {
    const ids = {premiumProductId};
    final response = await InAppPurchase.instance.queryProductDetails(ids);

    if (response.error != null) {
      debugPrint("❌ queryProductDetails error: ${response.error}");
      _iapMessageController.add("Nu pot încărca produsul (Store).");
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("❌ PRODUSUL NU A FOST GĂSIT ÎN STORE: ${response.notFoundIDs}");
      _iapMessageController.add("Produsul nu există în Store.");
      return;
    }

    if (response.productDetails.isEmpty) {
      debugPrint("❌ productDetails empty. Verifică produsul în Store.");
      _iapMessageController.add("Produs indisponibil momentan.");
      return;
    }

    premiumProduct = response.productDetails.first;
    debugPrint("✅ Produs încărcat: ${premiumProduct!.id} / ${premiumProduct!.price}");
  }

  //------------------------------------------------
  // CUMPĂRARE PREMIUM
  //------------------------------------------------
  Future<void> buyPremium() async {
    if (!isAvailable) {
      debugPrint("❌ IAP indisponibil. buyPremium oprit.");
      _iapMessageController.add("Magazin indisponibil momentan.");
      return;
    }

    if (premiumProduct == null) {
      await _loadProducts();
      if (premiumProduct == null) {
        debugPrint("❌ Nu există productDetails pentru premium (după reload).");
        _iapMessageController.add("Produs indisponibil momentan.");
        return;
      }
    }

    _iapMessageController.add("Se inițiază achiziția...");
    final purchaseParam = PurchaseParam(productDetails: premiumProduct!);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  //------------------------------------------------
  // RESTAURARE ACHIZIȚIE (cu feedback)
  //------------------------------------------------
  Future<void> restore() async {
    if (!isAvailable) {
      _iapMessageController.add("Magazin indisponibil momentan.");
      return;
    }
    if (_isRestoring) return;

    _isRestoring = true;
    _sawRestoreEvent = false;

    _iapMessageController.add("Se restaurează achizițiile...");

    try {
      await InAppPurchase.instance.restorePurchases();

      // Așteptăm puțin să ajungă evenimentele în purchaseStream
      await Future.delayed(const Duration(seconds: 2));

      if (premiumUnlocked) {
        _iapMessageController.add("Achiziția a fost restaurată ✅");
      } else if (_sawRestoreEvent == false) {
        // niciun eveniment relevant pentru produsul tău
        _iapMessageController.add("Nu există achiziții de restaurat.");
      } else {
        // am văzut un eveniment, dar nu a deblocat (foarte rar)
        _iapMessageController.add("Nu s-a putut restaura achiziția.");
      }
    } catch (e) {
      debugPrint("❌ restorePurchases error: $e");
      _iapMessageController.add("Eroare la restaurare. Încearcă din nou.");
    } finally {
      _isRestoring = false;
    }
  }

  //------------------------------------------------
  // MANAGEAZĂ EVENIMENTELE DE PLATĂ
  //------------------------------------------------
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final isOurProduct = purchase.productID == premiumProductId;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
          if (isOurProduct) {
            _sawRestoreEvent = true;
            await setPremiumUnlocked(true);
            _iapMessageController.add("Premium activ ✅");
          } else {
            debugPrint("⚠️ Purchase ignorat (alt productID): ${purchase.productID}");
          }
          break;

        case PurchaseStatus.restored:
          if (isOurProduct) {
            _sawRestoreEvent = true;
            await setPremiumUnlocked(true);
            // mesajul final îl dăm în restore() după delay
          } else {
            debugPrint("⚠️ Restore ignorat (alt productID): ${purchase.productID}");
          }
          break;

        case PurchaseStatus.pending:
          debugPrint("⏳ Purchase pending...");
          _iapMessageController.add("Se procesează...");
          break;

        case PurchaseStatus.error:
          debugPrint("❌ Eroare la cumpărare: ${purchase.error}");
          _iapMessageController.add("Eroare la plată. Încearcă din nou.");
          break;

        case PurchaseStatus.canceled:
          debugPrint("❕ Utilizatorul a anulat plata");
          _iapMessageController.add("Plata a fost anulată.");
          break;
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await InAppPurchase.instance.completePurchase(purchase);
        } catch (e) {
          debugPrint("❌ completePurchase error: $e");
        }
      }
    }
  }

  //------------------------------------------------
  // DISPOSE
  //------------------------------------------------
  void dispose() {
    _subscription?.cancel();
    _premiumStateController.close();
    _iapMessageController.close();
  }
}
