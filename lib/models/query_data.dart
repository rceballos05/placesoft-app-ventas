class QueryData {
  String? query;

  QueryData({this.query});

  factory QueryData.fromJson(Map<String, dynamic> json) {
    return QueryData(
      query: json["queryStr"],
    );
  }
}
