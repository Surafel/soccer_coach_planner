class Coach {
  final String id;
  final String name;

  const Coach({required this.id, required this.name});

  factory Coach.fromJson(Map<String, dynamic> json) => Coach(
        id: json['id'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  Coach copyWith({String? name}) => Coach(id: id, name: name ?? this.name);
}
