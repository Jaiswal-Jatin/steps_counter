class StepData {
  final DateTime date;
  final int steps;
  final double distance;
  final int calories;

  StepData({
    required this.date,
    required this.steps,
    required this.distance,
    required this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'steps': steps,
      'distance': distance,
      'calories': calories,
    };
  }

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      steps: json['steps'],
      distance: json['distance'],
      calories: json['calories'],
    );
  }
}

class UserProfile {
  final String name;
  final double height; // in cm
  final double weight; // in kg
  final int age;
  final String gender;
  final int dailyStepsGoal;
  final int dailyCaloriesGoal;
  final double dailyWaterGoal; // in liters

  UserProfile({
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    this.dailyStepsGoal = 10000,
    this.dailyCaloriesGoal = 2000,
    this.dailyWaterGoal = 2.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'dailyStepsGoal': dailyStepsGoal,
      'dailyCaloriesGoal': dailyCaloriesGoal,
      'dailyWaterGoal': dailyWaterGoal,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      age: json['age'],
      gender: json['gender'],
      dailyStepsGoal: json['dailyStepsGoal'] ?? 10000,
      dailyCaloriesGoal: json['dailyCaloriesGoal'] ?? 2000,
      dailyWaterGoal: json['dailyWaterGoal'] ?? 2.5,
    );
  }
}

class WaterIntake {
  final DateTime date;
  final double amount; // in ml

  WaterIntake({
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
    };
  }

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      amount: json['amount'],
    );
  }
}

class NutritionData {
  final DateTime date;
  final double carbs;
  final double protein;
  final double fat;
  final int totalCalories;

  NutritionData({
    required this.date,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.totalCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'totalCalories': totalCalories,
    };
  }

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      carbs: json['carbs'],
      protein: json['protein'],
      fat: json['fat'],
      totalCalories: json['totalCalories'],
    );
  }
}
