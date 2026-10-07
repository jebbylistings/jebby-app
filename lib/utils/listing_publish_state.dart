import 'package:jebby/models/get_all_products_by_vendor_id_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side labels for server-driven listing visibility.
class ListingPublishState {
  ListingPublishState._();

  static const pendingVerification = 'pending_verification';
  static const published = 'published';
  static const draft = 'draft';
  static const _localDraftActiveKey = 'listing_draft_active';

  /// In-progress listing saved locally (matches My Products draft card).
  static Future<bool> hasActiveLocalDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_localDraftActiveKey) == true;
  }

  /// Subtitle counts for vendor home: published listings + local draft.
  static Future<({int live, int draft})> vendorHomeCountsAsync(
    List<Data> products,
  ) async {
    final hasDraft = await hasActiveLocalDraft();
    return (live: products.length, draft: hasDraft ? 1 : 0);
  }

  static bool isDraftListing(Data product) {
    final publish = product.publishState?.toLowerCase();
    if (publish == draft) return true;
    final listing = product.listingStatus?.toLowerCase();
    return listing == draft;
  }

  static String badgeLabel(Data product) {
    if (isDraftListing(product)) return 'Draft';
    final state = product.publishState?.toLowerCase();
    if (state == pendingVerification) return 'Pending verification';
    if (product.bookable == true) return 'Live';
    if (state == published) return 'Published';
    return 'Live';
  }

  static bool isBookable(Data product) {
    if (product.bookable != null) return product.bookable!;
    final state = product.publishState?.toLowerCase();
    if (state == pendingVerification) return false;
    return true;
  }
}
