class Activity {
  final String id;
  final String img;
  final String name;
  final double price;
  final DateTime createdAt;
  final int duration;
  final String type;
  final int seats;
  bool started;

  Activity(
      {required this.id, required this.img, required this.name, required this.price, required this.createdAt, required this.duration, required this.type, required this.seats, required this.started});
}
