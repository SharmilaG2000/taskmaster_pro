class UserModel {
  final String id;
  final String email;
  final String name;
  final bool isPremium;
  final DateTime? premiumExpiryDate;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.isPremium,
    this.premiumExpiryDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isPremium: json['isPremium'] ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.parse(json['premiumExpiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
    };
  }
}
