class ResponseData {
  late int? code;
  late int? totalRecords;
  late String? message;
  late List<dynamic>? items;

  ResponseData({
    this.code,
    this.message,
    this.totalRecords,
    this.items,
  });
  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      code: json['code'],
      message: json['message'],
      items: json['items'],
      totalRecords: json['totalRecords'],
    );
  }
}
