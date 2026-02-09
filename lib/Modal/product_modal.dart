import 'package:json_annotation/json_annotation.dart';

part 'product_modal.g.dart';

@JsonSerializable()
class ProductModal {
  final int id;
  final String title;
  final String category;
  final double price;

  ProductModal({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });

  factory ProductModal.fromJson(Map<String, dynamic> json) =>
      _$ProductModalFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModalToJson(this);
}
