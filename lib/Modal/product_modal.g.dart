// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_modal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModal _$ProductModalFromJson(Map<String, dynamic> json) => ProductModal(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  category: json['category'] as String,
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$ProductModalToJson(ProductModal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'price': instance.price,
    };
