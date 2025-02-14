import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:get_storage/get_storage.dart';

class CountryService extends GetxService {
  final _box = GetStorage();
  final _key = 'selectedCountry';

  final selectedCountry = Rxn<Country>();

  @override
  Future<CountryService> onInit() async {
    super.onInit();
    await _initializeDefaultCountry();
    return this;
  }

  Future<void> _initializeDefaultCountry() async {
    try {
      final defaultCountry = {
        'e164_cc': '91',
        'iso2_cc': 'IN',
        'name': 'India',
        'example': '9123456789',
        'display_name': 'India (IN) [+91]',
        'full_example_with_plus_sign': '+919123456789',
        'display_name_no_country_code': 'India (IN)',
        'flag': '🇮🇳',
        'region': 'Asia',
        'translations': {'en': 'India'},
      };

      final savedCountryCode = _box.read(_key) ?? 'IN';
      if (savedCountryCode != 'IN') {
        defaultCountry['iso2_cc'] = savedCountryCode;
      }

      selectedCountry.value = Country.from(json: defaultCountry);
    } catch (e) {
      print('Error initializing country: $e');
      // If initialization fails, set a basic country object
      selectedCountry.value = Country.from(json: {
        'e164_cc': '91',
        'iso2_cc': 'IN',
        'name': 'India',
        'example': '9123456789',
        'display_name': 'India (IN) [+91]',
        'full_example_with_plus_sign': '+919123456789',
        'display_name_no_country_code': 'India (IN)',
        'flag': '🇮🇳',
        'region': 'Asia',
        'translations': {'en': 'India'},
      });
    }
  }

  void updateCountry(Country country) {
    selectedCountry.value = country;
    _box.write(_key, country.countryCode);
  }

  String formatNumber(String number) {
    if (number.isEmpty) return '';

    // Remove any existing + or country code
    number = number.replaceAll(RegExp(r'^\+'), '');
    if (selectedCountry.value != null) {
      final countryCode = selectedCountry.value!.phoneCode;
      if (number.startsWith(countryCode)) {
        number = number.substring(countryCode.length);
      }
    }

    // Format the number with country code
    return '+${selectedCountry.value?.phoneCode ?? '91'}$number';
  }

  String getDisplayNumber(String number) {
    if (number.isEmpty) return '';

    // If number starts with +, format it nicely
    if (number.startsWith('+')) {
      final countryCode = number.substring(1).split(RegExp(r'\d'))[0];
      final mainNumber = number.substring(countryCode.length + 1);
      return '(+$countryCode) $mainNumber';
    }

    return number;
  }
}
