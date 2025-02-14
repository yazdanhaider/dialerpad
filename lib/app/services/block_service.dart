import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BlockService extends GetxService {
  final _box = GetStorage();
  final _key = 'blocked_numbers';

  final blockedNumbers = <String>[].obs;

  @override
  Future<BlockService> onInit() async {
    super.onInit();
    _loadBlockedNumbers();
    return this;
  }

  void _loadBlockedNumbers() {
    final saved = _box.read<List>(_key) ?? [];
    blockedNumbers.value = saved.map((e) => e.toString()).toList();
  }

  void _saveBlockedNumbers() {
    _box.write(_key, blockedNumbers.toList());
  }

  bool isBlocked(String number) {
    // Normalize the number before checking
    final normalizedNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    return blockedNumbers.any((blocked) =>
        blocked.replaceAll(RegExp(r'[^\d+]'), '') == normalizedNumber);
  }

  void blockNumber(String number) {
    if (!isBlocked(number)) {
      blockedNumbers.add(number);
      _saveBlockedNumbers();
      Get.snackbar(
        'Number Blocked',
        'Successfully blocked $number',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void unblockNumber(String number) {
    final normalizedNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    blockedNumbers.removeWhere((blocked) =>
        blocked.replaceAll(RegExp(r'[^\d+]'), '') == normalizedNumber);
    _saveBlockedNumbers();
    Get.snackbar(
      'Number Unblocked',
      'Successfully unblocked $number',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
