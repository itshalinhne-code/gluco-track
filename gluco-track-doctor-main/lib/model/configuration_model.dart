class ConfigurationModel {
  int? id;
  String? value;

  ConfigurationModel({
    this.id,
    this.value,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(id: json['id'], value: json['value']);
  }
}
