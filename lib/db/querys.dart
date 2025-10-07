class Query {
  String? fecha;
  String? hora;
  String? query;

  Query({this.fecha, this.hora, this.query});

  Map<String, dynamic> toMap() {
    return {"fecha": fecha, "hora": hora, "query": query};
  }
}
