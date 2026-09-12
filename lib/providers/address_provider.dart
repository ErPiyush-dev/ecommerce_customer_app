import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedAddressId; // Checkout ke waqt kaunsa address chuna hai

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedAddressId => _selectedAddressId;

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _addresses = await _addressService.getMyAddresses();
      _errorMessage = null;

      // Agar koi address select nahi hai, to default wala ya pehla wala select kar do
      if (_selectedAddressId == null && _addresses.isNotEmpty) {
        final defaultAddr = _addresses.where((a) => a.isDefault).toList();
        _selectedAddressId = defaultAddr.isNotEmpty
            ? defaultAddr.first.id
            : _addresses.first.id;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAddress({
    required String fullName,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = false,
  }) async {
    try {
      await _addressService.addAddress(
        fullName: fullName,
        phoneNumber: phoneNumber,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        pincode: pincode,
        isDefault: isDefault,
      );
      await fetchAddresses();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectAddress(int addressId) {
    _selectedAddressId = addressId;
    notifyListeners();
  }
}
