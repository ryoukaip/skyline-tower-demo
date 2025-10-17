import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../components/pocketbase_service.dart';

class FavoriteServicesScreen extends StatefulWidget {
  const FavoriteServicesScreen({super.key});

  @override
  State<FavoriteServicesScreen> createState() => _FavoriteServicesScreenState();
}

class _FavoriteServicesScreenState extends State<FavoriteServicesScreen> {
  final PocketBaseService pbService = PocketBaseService();
  List<RecordModel> allServices = [];
  Map<String, String> favoriteMap = {};
  // key: dich_vu.id, value: dich_vu_yeu_thich.id

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final services = await pbService.getServices();
      final favorites = await pbService.getFavorites();

      final favMap = {
        for (var fav in favorites) fav.expand['dich_vu']![0].id: fav.id,
      };

      setState(() {
        allServices = services;
        favoriteMap = favMap;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> toggleFavorite(String dichVuId) async {
    if (favoriteMap.containsKey(dichVuId)) {
      // remove favorite
      await pbService.removeFavorite(favoriteMap[dichVuId]!);
      setState(() {
        favoriteMap.remove(dichVuId);
      });
    } else {
      if (favoriteMap.length >= 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bạn chỉ có thể chọn tối đa 4 dịch vụ."),
          ),
        );
        return;
      }
      await pbService.addFavorite(dichVuId);
      await loadData(); // reload to get updated favorite id
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dịch vụ yêu thích")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: allServices.length,
                      itemBuilder: (context, index) {
                        final service = allServices[index];
                        final isFav = favoriteMap.containsKey(service.id);

                        return CheckboxListTile(
                          title: Text(service.data["ten_dich_vu"] ?? ""),
                          subtitle: Text(service.data["mo_ta"] ?? ""),
                          value: isFav,
                          onChanged: (_) => toggleFavorite(service.id),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Chọn tối đa 4 dịch vụ",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
    );
  }
}
