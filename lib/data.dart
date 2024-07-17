class Data {
  String domisili;
  String umur;

  Data(this.domisili, this.umur);

  String getDomisili() {
    return domisili;
  }

  String getUmur() {
    return umur;
  }
  Map<String, dynamic> toJson() {
    return {
      'domisili': domisili,
      'umur': umur,
    };
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      json['domisili'],
      json['umur'],
    );
  }
}
