import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final int id;
  final String title;
  final bool isCompleted;

  Lesson markCompleted() => Lesson(id: id, title: title, isCompleted: true);

  @override
  List<Object?> get props => [id, title, isCompleted];
}
