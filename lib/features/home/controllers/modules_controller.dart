import 'package:get/get.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/module.dart';

class ModulesController extends GetxController {
  final PrefsService _prefsService = Get.find<PrefsService>();
  final AppLogger _logger = Get.find<AppLogger>();

  // Map of CategoryName to list of Modules in it, sorted
  final RxList<MapEntry<String, List<Module>>> groupedModules = <MapEntry<String, List<Module>>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt expandedIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    loadModules();
  }

  void loadModules() {
    isLoading.value = true;
    try {
      final cache = _prefsService.getAppInitializationData();
      final modules = (cache?.modules ?? []).where((m) => m.isVisibleOnMobile).toList();

      if (modules.isEmpty) {
        groupedModules.clear();
        _logger.warning("No modules found in the local cache.");
        isLoading.value = false;
        return;
      }

      // 1. Group modules by their category name
      final Map<String, List<Module>> tempGrouped = {};
      for (var module in modules) {
        final category = module.moduleCategoryName.trim();
        if (!tempGrouped.containsKey(category)) {
          tempGrouped[category] = [];
        }
        tempGrouped[category]!.add(module);
      }

      // 2. Sort modules inside each category by their DisplayOrder
      for (var key in tempGrouped.keys) {
        tempGrouped[key]!.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      }

      // 3. Sort categories dynamically by the minimum DisplayOrder of their child modules
      final List<MapEntry<String, List<Module>>> sortedList = tempGrouped.entries.toList();
      sortedList.sort((a, b) {
        final int minA = a.value.isNotEmpty ? a.value.first.displayOrder : 9999;
        final int minB = b.value.isNotEmpty ? b.value.first.displayOrder : 9999;
        return minA.compareTo(minB);
      });

      groupedModules.value = sortedList;
      _logger.debug("Loaded and sorted ${groupedModules.length} module categories successfully.");
    } catch (e, stack) {
      _logger.error("Failed to parse and group modules", e.toString(), stack);
    } finally {
      isLoading.value = false;
    }
  }
}
