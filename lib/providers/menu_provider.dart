import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';

class MenuProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<MenuModel> _menus = [];
  List<MenuModel> _filteredMenus = [];
  bool _isLoading = false;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  List<MenuModel> get menus => _filteredMenus;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  
  List<String> get categories => [
    'Semua',
    'Makanan Utama',
    'Minuman',
    'Snack',
  ];

  MenuProvider() {
    loadMenus();
  }

  Future<void> loadMenus() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('menus')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _menus = snapshot.docs
          .map((doc) => MenuModel.fromFirestore(doc))
          .toList();
      
      _applyFilters();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading menus: $e');
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void searchMenu(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMenus = _menus.where((menu) {
      bool matchesCategory = _selectedCategory == 'Semua' || 
                             menu.category == _selectedCategory;
      bool matchesSearch = _searchQuery.isEmpty || 
                          menu.name.toLowerCase().contains(_searchQuery) ||
                          menu.description.toLowerCase().contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  MenuModel? getMenuById(String id) {
    try {
      return _menus.firstWhere((menu) => menu.id == id);
    } catch (e) {
      return null;
    }
  }
}
