import 'package:pocketbase/pocketbase.dart';
import 'package:skyline_tower2/components/prefs_auth_store.dart';

class PocketBaseService {
  static PocketBaseService? _instance;
  factory PocketBaseService() => _instance!;

  final PocketBase pb;

  PocketBaseService._(this.pb);

  /// Initialize PocketBase with persistent auth store
  static Future<void> init() async {
    final authStore = await PrefsAuthStore.create();
    final pb = PocketBase('http://192.168.1.4:8090', authStore: authStore);
    _instance = PocketBaseService._(pb);
  }

  // --- Authentication ---
  bool get isLoggedIn => pb.authStore.isValid;

  Future<void> login(String username, String password) async {
    await pb.collection("users").authWithPassword(username, password);
    // Auth will auto-save via PrefsAuthStore
  }

  Future<void> loginWithGoogle(
    Future<void> Function(Uri url) urlLauncher,
  ) async {
    await pb.collection("users").authWithOAuth2("google", urlLauncher);
  }

  void logout() {
    pb.authStore.clear();
  }

  // --- Fetch News ---
  Future<List<RecordModel>> getNews() async {
    return await pb.collection('news').getFullList(sort: '-published_at');
  }

  // NEW METHOD FOR PAGINATION
  Future<List<RecordModel>> getNewsPaginated({
    int page = 1,
    int perPage = 5,
  }) async {
    final result = await pb
        .collection('news')
        .getList(page: page, perPage: perPage, sort: '-published_at');
    return result.items;
  }

  Future<void> debugPrintNews() async {
    final news = await getNews();
    for (var n in news) {
      print("News: ${n.data}");
    }
  }

  // --- Fetch Services ---
  Future<List<RecordModel>> getServices() async {
    return await pb.collection('dich_vu').getFullList(sort: 'ten_dich_vu');
  }

  // --- Fetch Favorites for current user ---
  Future<List<RecordModel>> getFavorites() async {
    if (!isLoggedIn) throw Exception("Not logged in");
    final userId = pb.authStore.model.id;
    return await pb
        .collection('dich_vu_yeu_thich')
        .getFullList(filter: 'user = "$userId"', expand: 'dich_vu');
  }

  // --- Add a Favorite ---
  Future<void> addFavorite(String dichVuId) async {
    if (!isLoggedIn) throw Exception("Not logged in");
    final userId = pb.authStore.model.id;
    await pb
        .collection('dich_vu_yeu_thich')
        .create(body: {"user": userId, "dich_vu": dichVuId});
  }

  // --- Remove a Favorite ---
  Future<void> removeFavorite(String recordId) async {
    await pb.collection('dich_vu_yeu_thich').delete(recordId);
  }

  // --- Fetch Invoices for current user ---
  Future<List<RecordModel>> getInvoices() async {
    // Ensure user is logged in before making a request that depends on their ID
    if (!isLoggedIn) return [];

    // Fetch the list of invoices.
    // We use `expand` to also fetch the full record from the 'can_ho' and 'cu_dan' relations.
    // This is much more efficient than making separate queries later.
    final records = await pb
        .collection('hoa_don')
        .getFullList(
          sort: '-created', // Show newest first
          expand: 'can_ho, cu_dan',
        );
    return records;
  }
  // --- User Opinions ---

  /// Fetches all opinions submitted by the currently logged-in user.
  Future<List<RecordModel>> getUserOpinions() async {
    if (!isLoggedIn) throw Exception("User is not logged in.");
    final userId = pb.authStore.model.id;
    // Filter by the user's ID and sort by the newest first
    return await pb
        .collection('y_kien_cu_dan')
        .getFullList(filter: 'nguoi_gui = "$userId"', sort: '-created');
  }

  /// Creates a new opinion record for the currently logged-in user.
  Future<void> createUserOpinion(String content) async {
    if (!isLoggedIn) throw Exception("User is not logged in.");
    final userId = pb.authStore.model.id;
    final body = <String, dynamic>{"nguoi_gui": userId, "noi_dung": content};
    await pb.collection('y_kien_cu_dan').create(body: body);
  }
}
