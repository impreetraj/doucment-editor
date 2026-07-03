class DataSource {
  DataSource({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.e,
    required this.f,
    required this.g,
    required this.h,
    required this.i,
  });

  String a;
  String b;
  String c;
  String d;
  String e;
  String f;
  String g;
  String h;
  String i;

  Map<String, dynamic> toJson() {
    return {
      'A': a,
      'B': b,
      'C': c,
      'D': d,
      'E': e,
      'F': f,
      'G': g,
      'H': h,
      'I': i,
    };
  }
  factory DataSource.fromJson(Map<String, dynamic> json) {
    return DataSource(
      a: json['A'] ?? '',
      b: json['B'] ?? '',
      c: json['C'] ?? '',
      d: json['D'] ?? '',
      e: json['E'] ?? '',
      f: json['F'] ?? '',
      g: json['G'] ?? '',
      h: json['H'] ?? '',
      i: json['I'] ?? '',
    );
  }
}
