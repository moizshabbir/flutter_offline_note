class Note {
  int? id;
  String contents;
  int? isSync;

  Note({this.id, required this.contents, isSync});

  factory Note.fromJson(Map<String, dynamic> json) =>
      Note(id: json["id"], contents: json["contents"], isSync: json["isSync"]);

  factory Note.fromApiJson(Map<String, dynamic> json) => Note(
        id: json["id"],
        contents: json["body"],
      );

  Map<String, dynamic> toJson() =>
      {"id": id, "contents": contents, "isSync": isSync};

  Map<String, dynamic> toApiJson() => {
        "id": id.toString(),
        "title": "Note New",
        "body": contents,
      };
}
