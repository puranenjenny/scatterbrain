import 'package:scatter_brain/database/task_model.dart';

class Daily extends Task {
  final String timeOfDay;

  // Päivitä konstruktori ottamaan vastaan id ja välitä se yläluokalle
  Daily({required String title, bool done = false, required this.timeOfDay, int? id}) 
    : super(title: title, done: done, id: id);

  factory Daily.fromJson(Map<String, dynamic> json) {
    return Daily(
      id: json['id'], // Ota id huomioon täällä
      title: json['title'],
      done: json['done'] == 1,
      timeOfDay: json['timeOfDay'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // Kutsu yläluokan toJson ja lisää timeOfDay
    final map = super.toJson();
    map['timeOfDay'] = timeOfDay;
    return map;
  }
}
