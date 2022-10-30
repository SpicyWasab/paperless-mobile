// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';
import 'package:flutter_paperless_mobile/core/type/json.dart';
import 'package:flutter_paperless_mobile/features/documents/model/query_parameters/id_query_parameter.dart';
import 'package:flutter_paperless_mobile/features/documents/model/query_parameters/ids_query_parameter.dart';

class DocumentModel extends Equatable {
  static const idKey = 'id';
  static const titleKey = "title";
  static const contentKey = "content";
  static const archivedFileNameKey = "archived_file_name";
  static const asnKey = "archive_serial_number";
  static const createdKey = "created";
  static const modifiedKey = "modified";
  static const addedKey = "added";
  static const correspondentKey = "correspondent";
  static const originalFileNameKey = 'original_file_name';
  static const documentTypeKey = "document_type";
  static const tagsKey = "tags";
  static const storagePathKey = "storage_path";

  final int id;
  final String title;
  final String? content;
  final List<int> tags;
  final int? documentType;
  final int? correspondent;
  final int? storagePath;
  final DateTime created;
  final DateTime modified;
  final DateTime added;
  final int? archiveSerialNumber;
  final String originalFileName;
  final String? archivedFileName;

  const DocumentModel({
    required this.id,
    required this.title,
    this.content,
    this.tags = const <int>[],
    required this.documentType,
    required this.correspondent,
    required this.created,
    required this.modified,
    required this.added,
    this.archiveSerialNumber,
    required this.originalFileName,
    this.archivedFileName,
    this.storagePath,
  });

  DocumentModel.fromJson(JSON json)
      : id = json[idKey],
        title = json[titleKey],
        content = json[contentKey],
        created = DateTime.parse(json[createdKey]),
        modified = DateTime.parse(json[modifiedKey]),
        added = DateTime.parse(json[addedKey]),
        archiveSerialNumber = json[asnKey],
        originalFileName = json[originalFileNameKey],
        archivedFileName = json[archivedFileNameKey],
        tags = (json[tagsKey] as List<dynamic>).cast<int>(),
        correspondent = json[correspondentKey],
        documentType = json[documentTypeKey],
        storagePath = json[storagePathKey];

  JSON toJson() {
    return {
      idKey: id,
      titleKey: title,
      asnKey: archiveSerialNumber,
      archivedFileNameKey: archivedFileName,
      contentKey: content,
      correspondentKey: correspondent,
      documentTypeKey: documentType,
      createdKey: created.toUtc().toIso8601String(),
      modifiedKey: modified.toUtc().toIso8601String(),
      addedKey: added.toUtc().toIso8601String(),
      originalFileNameKey: originalFileName,
      tagsKey: tags,
      storagePathKey: storagePath,
    };
  }

  DocumentModel copyWith({
    String? title,
    String? content,
    IdsQueryParameter? tags,
    IdQueryParameter? documentType,
    IdQueryParameter? correspondent,
    IdQueryParameter? storagePath,
    DateTime? created,
    DateTime? modified,
    DateTime? added,
    int? archiveSerialNumber,
    String? originalFileName,
    String? archivedFileName,
  }) {
    return DocumentModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      documentType: fromQuery(documentType, this.documentType),
      correspondent: fromQuery(correspondent, this.correspondent),
      storagePath: fromQuery(storagePath, this.storagePath),
      tags: fromListQuery(tags, this.tags),
      created: created ?? this.created,
      modified: modified ?? this.modified,
      added: added ?? this.added,
      originalFileName: originalFileName ?? this.originalFileName,
      archiveSerialNumber: archiveSerialNumber ?? this.archiveSerialNumber,
      archivedFileName: archivedFileName ?? this.archivedFileName,
    );
  }

  int? fromQuery(IdQueryParameter? query, int? previous) {
    if (query == null) {
      return previous;
    }
    return query.id;
  }

  List<int> fromListQuery(IdsQueryParameter? query, List<int> previous) {
    if (query == null) {
      return previous;
    }
    return query.ids;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        tags,
        documentType,
        storagePath,
        correspondent,
        created,
        modified,
        added,
        archiveSerialNumber,
        originalFileName,
        archivedFileName,
        storagePath
      ];
}