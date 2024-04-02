class Task {
  final int? id; // # tarkoittaa että id voi olla null
  final String title; // tehtävän nimi
  final bool done; // onko tehtävä tehty

  const Task({required this.title, required this.done, this.id}); // konstruktori

  factory Task.fromJson(Map<String, dynamic> json) { // jsonista muodosta tehtävä
    return Task( // palauta tehtävä
      id: json['id'], // id
      title: json['title'], // nimi
      done: json['done'], // onko tehty
    );
  }

  Map<String, dynamic> toJson() { // jsoniin 
    return {
      'id': id,
      'title': title,
      'done': done,
    };
  }
}