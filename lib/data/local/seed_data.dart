import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../../core/constants/app_colors.dart';

class SeedData {
  SeedData._();

  static List<AccountModel> get defaultAccounts => [
    AccountModel(
      name: 'Cash', type: AccountType.cash,
      balance: 0, colorValue: AppColors.catFood.value, isDefault: true,
    ),
    AccountModel(
      name: 'bKash', type: AccountType.bkash,
      balance: 0, colorValue: const Color(0xFFE2136E).value,
    ),
    AccountModel(
      name: 'Nagad', type: AccountType.nagad,
      balance: 0, colorValue: const Color(0xFFFF6B00).value,
    ),
    AccountModel(
      name: 'Bank', type: AccountType.bank,
      balance: 0, colorValue: AppColors.primary.value,
    ),
  ];

  static List<CategoryModel> get defaultCategories => [
    // ── Expense categories ───────────────────────────
    CategoryModel(name: 'Food & Dining',  icon: '🍛',
        colorValue: AppColors.catFood.value,      isIncome: false, isDefault: true),
    CategoryModel(name: 'Transport',      icon: '🚌',
        colorValue: AppColors.catTransport.value, isIncome: false, isDefault: true),
    CategoryModel(name: 'House Rent',     icon: '🏠',
        colorValue: AppColors.catRent.value,      isIncome: false, isDefault: true),
    CategoryModel(name: 'Electricity',    icon: '⚡',
        colorValue: AppColors.catBills.value,     isIncome: false, isDefault: true),
    CategoryModel(name: 'Internet',       icon: '🌐',
        colorValue: AppColors.catMobile.value,    isIncome: false, isDefault: true),
    CategoryModel(name: 'Mobile Recharge',icon: '📱',
        colorValue: AppColors.catMobile.value,    isIncome: false, isDefault: true),
    CategoryModel(name: 'Medicine',       icon: '💊',
        colorValue: AppColors.catHealth.value,    isIncome: false, isDefault: true),
    CategoryModel(name: 'Shopping',       icon: '🛍️',
        colorValue: AppColors.catShopping.value,  isIncome: false, isDefault: true),
    CategoryModel(name: 'Education',      icon: '📚',
        colorValue: AppColors.catEducation.value, isIncome: false, isDefault: true),
    CategoryModel(name: 'bKash/Nagad',    icon: '📲',
        colorValue: const Color(0xFFE2136E).value,isIncome: false, isDefault: true),
    CategoryModel(name: 'CNG/Rickshaw',   icon: '🛺',
        colorValue: AppColors.catTransport.value, isIncome: false, isDefault: true),
    CategoryModel(name: 'Bazaar',         icon: '🛒',
        colorValue: AppColors.catFood.value,      isIncome: false, isDefault: true),
    CategoryModel(name: 'Other Expense',  icon: '💸',
        colorValue: AppColors.catOther.value,     isIncome: false, isDefault: true),

    // ── Income categories ────────────────────────────
    CategoryModel(name: 'Salary',         icon: '💼',
        colorValue: AppColors.catSalary.value,    isIncome: true, isDefault: true),
    CategoryModel(name: 'Freelance',      icon: '💻',
        colorValue: AppColors.catFreelance.value, isIncome: true, isDefault: true),
    CategoryModel(name: 'Business',       icon: '🏪',
        colorValue: AppColors.catBusiness.value,  isIncome: true, isDefault: true),
    CategoryModel(name: 'bKash Received', icon: '📲',
        colorValue: const Color(0xFFE2136E).value,isIncome: true, isDefault: true),
    CategoryModel(name: 'Other Income',   icon: '💰',
        colorValue: AppColors.catOther.value,     isIncome: true, isDefault: true),
  ];
}