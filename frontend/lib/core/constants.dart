import 'package:flutter/material.dart';

/// Mapeamento de categorias: chave do backend → { emoji, label, cor }
/// As chaves correspondem exatamente aos valores retornados pelo endpoint /categories.
class CategoryInfo {
  final String emoji;
  final String label;
  final Color color;

  const CategoryInfo({
    required this.emoji,
    required this.label,
    required this.color,
  });
}

class AppCategories {
  AppCategories._();

  /// Mapa completo de categorias.
  /// Chave = label retornado pelo backend (ex: "Alimentação").
  static const Map<String, CategoryInfo> all = {
    'Alimentação': CategoryInfo(
      emoji: '🛒',
      label: 'Alimentação',
      color: Color(0xFF4CAF50),
    ),
    'Bebidas': CategoryInfo(
      emoji: '🍺',
      label: 'Bebidas',
      color: Color(0xFF2196F3),
    ),
    'Limpeza': CategoryInfo(
      emoji: '🧹',
      label: 'Limpeza',
      color: Color(0xFF00BCD4),
    ),
    'Higiene': CategoryInfo(
      emoji: '🧴',
      label: 'Higiene',
      color: Color(0xFF26C6DA),
    ),
    'Saúde & Farmácia': CategoryInfo(
      emoji: '💊',
      label: 'Saúde & Farmácia',
      color: Color(0xFFF44336),
    ),
    'Beleza & Cuidados': CategoryInfo(
      emoji: '💄',
      label: 'Beleza & Cuidados',
      color: Color(0xFFE91E63),
    ),
    'Academia & Suplementos': CategoryInfo(
      emoji: '🏋️',
      label: 'Academia & Suplementos',
      color: Color(0xFFFF5722),
    ),
    'Eletrônicos': CategoryInfo(
      emoji: '📺',
      label: 'Eletrônicos',
      color: Color(0xFF607D8B),
    ),
    'Informática': CategoryInfo(
      emoji: '💻',
      label: 'Informática',
      color: Color(0xFF546E7A),
    ),
    'Celulares & Tablets': CategoryInfo(
      emoji: '📱',
      label: 'Celulares & Tablets',
      color: Color(0xFF78909C),
    ),
    'Eletrodomésticos': CategoryInfo(
      emoji: '🏠',
      label: 'Eletrodomésticos',
      color: Color(0xFF795548),
    ),
    'Eletroportáteis': CategoryInfo(
      emoji: '⚡',
      label: 'Eletroportáteis',
      color: Color(0xFFFFB300),
    ),
    'Móveis & Decoração': CategoryInfo(
      emoji: '🛋️',
      label: 'Móveis & Decoração',
      color: Color(0xFF8D6E63),
    ),
    'Casa & Doméstico': CategoryInfo(
      emoji: '🛏️',
      label: 'Casa & Doméstico',
      color: Color(0xFFA1887F),
    ),
    'Utensílios Domésticos': CategoryInfo(
      emoji: '🍳',
      label: 'Utensílios Domésticos',
      color: Color(0xFFBCAAA4),
    ),
    'Vestuário & Calçados': CategoryInfo(
      emoji: '👗',
      label: 'Vestuário & Calçados',
      color: Color(0xFF9C27B0),
    ),
    'Bebês & Kids': CategoryInfo(
      emoji: '👶',
      label: 'Bebês & Kids',
      color: Color(0xFFFF80AB),
    ),
    'Brinquedos & Hobbies': CategoryInfo(
      emoji: '🎲',
      label: 'Brinquedos & Hobbies',
      color: Color(0xFFFF6F00),
    ),
    'Esporte & Lazer': CategoryInfo(
      emoji: '⚽',
      label: 'Esporte & Lazer',
      color: Color(0xFF43A047),
    ),
    'Pet Shop': CategoryInfo(
      emoji: '🐾',
      label: 'Pet Shop',
      color: Color(0xFF8BC34A),
    ),
    'Livros & Educação': CategoryInfo(
      emoji: '📚',
      label: 'Livros & Educação',
      color: Color(0xFF3F51B5),
    ),
    'Papelaria & Escritório': CategoryInfo(
      emoji: '📎',
      label: 'Papelaria & Escritório',
      color: Color(0xFF5C6BC0),
    ),
    'Ferramentas & Jardim': CategoryInfo(
      emoji: '🔧',
      label: 'Ferramentas & Jardim',
      color: Color(0xFF6D4C41),
    ),
    'Viagem': CategoryInfo(
      emoji: '✈️',
      label: 'Viagem',
      color: Color(0xFF00ACC1),
    ),
    'Automotivo': CategoryInfo(
      emoji: '🚗',
      label: 'Automotivo',
      color: Color(0xFF37474F),
    ),
    'Outros': CategoryInfo(
      emoji: '📦',
      label: 'Outros',
      color: Color(0xFF757575),
    ),
  };

  /// Retorna a info de uma categoria pelo label. Fallback para "Outros".
  static CategoryInfo get(String? label) {
    if (label == null || label.isEmpty) return all['Outros']!;
    return all[label] ?? all['Outros']!;
  }

  /// Lista de todos os labels para uso em filtros.
  static List<String> get labels => all.keys.toList();
}
