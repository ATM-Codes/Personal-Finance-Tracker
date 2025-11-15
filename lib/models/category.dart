class Category {
  final int? id;
  final String name;
  final String color;
  final String icon;

  Category({
    this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  //Convert category to map for database
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color, 'icon': icon};
  }

  //Convert map to category from database

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      color: map['color'] as String,
      icon: map['icon'] as String,
    );
  }
}
