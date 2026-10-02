import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/silpo_repository.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/silpo_badge.dart';

/// Screen simulating Silpo's signature "Вільнокаса" (in-store camera self-checkout barcode scanner).
class VilnokasaScreen extends StatefulWidget {
  final CartViewModel cartViewModel;
  final SilpoRepository? repository;

  const VilnokasaScreen({
    super.key,
    required this.cartViewModel,
    this.repository,
  });

  @override
  State<VilnokasaScreen> createState() => _VilnokasaScreenState();
}

class _VilnokasaScreenState extends State<VilnokasaScreen> with SingleTickerProviderStateMixin {
  late final SilpoRepository _repository;
  final TextEditingController _barcodeInputController = TextEditingController();
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnimation;

  Product? _scannedProduct;
  bool _isSearching = false;
  bool _isTorchOn = false;
  String? _errorMessage;

  static const List<Map<String, String>> _sampleBarcodes = [
    {'code': '482000000001', 'name': 'Сметана «Премія»'},
    {'code': '482000000002', 'name': 'Кава Lavazza Oro'},
    {'code': '482000000003', 'name': 'Сир Гауда 48%'},
    {'code': '482000000004', 'name': 'Стейк сьомги'},
    {'code': '482000000005', 'name': 'Пампушки з часником'},
    {'code': '482000000006', 'name': 'Шоколад чорний 70%'},
    {'code': '482000000007', 'name': 'Молоко «Галичина»'},
    {'code': '482000000008', 'name': 'Паста Barilla No.5'},
    {'code': '482000000009', 'name': 'Яйця С0 «Ясенсвіт»'},
    {'code': '482000000010', 'name': 'Авокадо Хасс 2 шт'},
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SilpoRepository();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _barcodeInputController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _scannedProduct = null;
    });

    final product = await _repository.getProductByBarcode(cleanCode);

    if (!mounted) return;

    setState(() {
      _isSearching = false;
      if (product != null) {
        _scannedProduct = product;
        _errorMessage = null;
      } else {
        _errorMessage = 'Товар за штрихкодом "$cleanCode" не знайдено в каталозі.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner, color: AppColors.silpoOrange),
            SizedBox(width: 8),
            Text('Вільнокаса • Скан у магазині'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? AppColors.silpoYellow : Colors.grey,
            ),
            tooltip: 'Ліхтарик',
            onPressed: () {
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Camera Viewfinder Box
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: _isTorchOn ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.silpoOrange, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Viewfinder Target Frame
                Container(
                  width: 220,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Laser scan line
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, _) {
                          return Positioned(
                            top: 140 * _scanLineAnimation.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              decoration: const BoxDecoration(
                                color: AppColors.silpoOrange,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.silpoOrange,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Center(
                        child: Text(
                          'Наведіть на штрихкод товару',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

                // Torch indicator
                if (_isTorchOn)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.silpoYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lightbulb, size: 14, color: AppColors.silpoYellow),
                          SizedBox(width: 4),
                          Text('Світло активне', style: TextStyle(color: AppColors.silpoYellow, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),

                if (_isSearching)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.silpoOrange),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick-tap Barcode Chips
          const Text(
            'Швидкий вибір штрихкоду товару:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _sampleBarcodes.map((item) {
              return ActionChip(
                avatar: const Icon(Icons.barcode_reader, size: 16, color: AppColors.silpoOrange),
                label: Text(item['name']!, style: const TextStyle(fontSize: 12)),
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.silpoOrangeLight,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onPressed: () {
                  _barcodeInputController.text = item['code']!;
                  _scanBarcode(item['code']!);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Manual Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barcodeInputController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ввести номер штрихкоду вручну',
                    hintText: '482000000001',
                    isDense: true,
                    prefixIcon: Icon(Icons.keyboard),
                  ),
                  onSubmitted: _scanBarcode,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.silpoOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _scanBarcode(_barcodeInputController.text),
                child: const Text('Скан'),
              ),
            ],
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],

          // Scanned Product Card
          if (_scannedProduct != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.silpoOrange, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.silpoOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _scannedProduct!.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_scannedProduct!.brand ?? _scannedProduct!.category} • ${_scannedProduct!.weightGrams} г',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_scannedProduct!.hasDiscount)
                          SilpoBadge(
                            text: '-${_scannedProduct!.discountPercentage}%',
                            type: SilpoBadgeType.discount,
                          ),
                        if (_scannedProduct!.isCinotyzhik) ...[
                          const SizedBox(width: 6),
                          const SilpoBadge(
                            text: 'Цінотижик',
                            type: SilpoBadgeType.cinotyzhik,
                          ),
                        ],
                        const Spacer(),
                        SilpoBadge(
                          text: '+${_scannedProduct!.bonusPoints ?? 0} балів',
                          type: SilpoBadgeType.bonus,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_scannedProduct!.regularPrice != _scannedProduct!.currentPrice)
                              Text(
                                '${_scannedProduct!.regularPrice.toStringAsFixed(2)} ₴',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              '${_scannedProduct!.currentPrice.toStringAsFixed(2)} ₴',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.silpoOrange,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Додати у Вільнокасу'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.silpoOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onPressed: () {
                            widget.cartViewModel.addProduct(_scannedProduct!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Додано у Вільнокасу: ${_scannedProduct!.title}'),
                                backgroundColor: AppColors.successGreen,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Running Cart Summary Card
          ListenableBuilder(
            listenable: widget.cartViewModel,
            builder: (context, _) {
              return Card(
                color: isDark ? AppColors.darkCard : const Color(0xFFFFF9F5),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: AppColors.silpoOrange, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'У Вільнокасі: ${widget.cartViewModel.itemCount} товарів',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Сума: ${widget.cartViewModel.finalTotal.toStringAsFixed(2)} ₴ (Економія: ${widget.cartViewModel.totalSavings.toStringAsFixed(2)} ₴)',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.silpoOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('До кошика'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
