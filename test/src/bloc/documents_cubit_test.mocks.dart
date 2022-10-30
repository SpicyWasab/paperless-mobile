// Mocks generated by Mockito 5.3.2 from annotations
// in flutter_paperless_mobile/test/src/bloc/documents_cubit_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:typed_data' as _i7;

import 'package:flutter_paperless_mobile/features/documents/model/document.model.dart'
    as _i2;
import 'package:flutter_paperless_mobile/features/documents/model/document_filter.dart'
    as _i8;
import 'package:flutter_paperless_mobile/features/documents/model/document_meta_data.model.dart'
    as _i4;
import 'package:flutter_paperless_mobile/features/documents/model/paged_search_result.dart'
    as _i3;
import 'package:flutter_paperless_mobile/features/documents/model/similar_document.model.dart'
    as _i9;
import 'package:flutter_paperless_mobile/features/documents/repository/document_repository.dart'
    as _i5;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDocumentModel_0 extends _i1.SmartFake implements _i2.DocumentModel {
  _FakeDocumentModel_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePagedSearchResult_1<T> extends _i1.SmartFake
    implements _i3.PagedSearchResult<T> {
  _FakePagedSearchResult_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDocumentMetaData_2 extends _i1.SmartFake
    implements _i4.DocumentMetaData {
  _FakeDocumentMetaData_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [DocumentRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockDocumentRepository extends _i1.Mock
    implements _i5.DocumentRepository {
  @override
  _i6.Future<void> create(
    _i7.Uint8List? documentBytes,
    String? filename, {
    required String? title,
    int? documentType,
    int? correspondent,
    List<int>? tags,
    DateTime? createdAt,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #create,
          [
            documentBytes,
            filename,
          ],
          {
            #title: title,
            #documentType: documentType,
            #correspondent: correspondent,
            #tags: tags,
            #createdAt: createdAt,
          },
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);
  @override
  _i6.Future<_i2.DocumentModel> update(_i2.DocumentModel? doc) =>
      (super.noSuchMethod(
        Invocation.method(
          #update,
          [doc],
        ),
        returnValue: _i6.Future<_i2.DocumentModel>.value(_FakeDocumentModel_0(
          this,
          Invocation.method(
            #update,
            [doc],
          ),
        )),
        returnValueForMissingStub:
            _i6.Future<_i2.DocumentModel>.value(_FakeDocumentModel_0(
          this,
          Invocation.method(
            #update,
            [doc],
          ),
        )),
      ) as _i6.Future<_i2.DocumentModel>);
  @override
  _i6.Future<int> findNextAsn() => (super.noSuchMethod(
        Invocation.method(
          #findNextAsn,
          [],
        ),
        returnValue: _i6.Future<int>.value(0),
        returnValueForMissingStub: _i6.Future<int>.value(0),
      ) as _i6.Future<int>);
  @override
  _i6.Future<_i3.PagedSearchResult<dynamic>> find(_i8.DocumentFilter? filter) =>
      (super.noSuchMethod(
        Invocation.method(
          #find,
          [filter],
        ),
        returnValue: _i6.Future<_i3.PagedSearchResult<dynamic>>.value(
            _FakePagedSearchResult_1<dynamic>(
          this,
          Invocation.method(
            #find,
            [filter],
          ),
        )),
        returnValueForMissingStub:
            _i6.Future<_i3.PagedSearchResult<dynamic>>.value(
                _FakePagedSearchResult_1<dynamic>(
          this,
          Invocation.method(
            #find,
            [filter],
          ),
        )),
      ) as _i6.Future<_i3.PagedSearchResult<dynamic>>);
  @override
  _i6.Future<List<_i9.SimilarDocumentModel>> findSimilar(int? docId) =>
      (super.noSuchMethod(
        Invocation.method(
          #findSimilar,
          [docId],
        ),
        returnValue: _i6.Future<List<_i9.SimilarDocumentModel>>.value(
            <_i9.SimilarDocumentModel>[]),
        returnValueForMissingStub:
            _i6.Future<List<_i9.SimilarDocumentModel>>.value(
                <_i9.SimilarDocumentModel>[]),
      ) as _i6.Future<List<_i9.SimilarDocumentModel>>);
  @override
  _i6.Future<int> delete(_i2.DocumentModel? doc) => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [doc],
        ),
        returnValue: _i6.Future<int>.value(0),
        returnValueForMissingStub: _i6.Future<int>.value(0),
      ) as _i6.Future<int>);
  @override
  _i6.Future<_i4.DocumentMetaData> getMetaData(_i2.DocumentModel? document) =>
      (super.noSuchMethod(
        Invocation.method(
          #getMetaData,
          [document],
        ),
        returnValue:
            _i6.Future<_i4.DocumentMetaData>.value(_FakeDocumentMetaData_2(
          this,
          Invocation.method(
            #getMetaData,
            [document],
          ),
        )),
        returnValueForMissingStub:
            _i6.Future<_i4.DocumentMetaData>.value(_FakeDocumentMetaData_2(
          this,
          Invocation.method(
            #getMetaData,
            [document],
          ),
        )),
      ) as _i6.Future<_i4.DocumentMetaData>);
  @override
  _i6.Future<List<int>> bulkDelete(List<_i2.DocumentModel>? models) =>
      (super.noSuchMethod(
        Invocation.method(
          #bulkDelete,
          [models],
        ),
        returnValue: _i6.Future<List<int>>.value(<int>[]),
        returnValueForMissingStub: _i6.Future<List<int>>.value(<int>[]),
      ) as _i6.Future<List<int>>);
  @override
  _i6.Future<_i7.Uint8List> getPreview(int? docId) => (super.noSuchMethod(
        Invocation.method(
          #getPreview,
          [docId],
        ),
        returnValue: _i6.Future<_i7.Uint8List>.value(_i7.Uint8List(0)),
        returnValueForMissingStub:
            _i6.Future<_i7.Uint8List>.value(_i7.Uint8List(0)),
      ) as _i6.Future<_i7.Uint8List>);
  @override
  String getThumbnailUrl(int? docId) => (super.noSuchMethod(
        Invocation.method(
          #getThumbnailUrl,
          [docId],
        ),
        returnValue: '',
        returnValueForMissingStub: '',
      ) as String);
  @override
  _i6.Future<_i2.DocumentModel> waitForConsumptionFinished(
    String? filename,
    String? title,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #waitForConsumptionFinished,
          [
            filename,
            title,
          ],
        ),
        returnValue: _i6.Future<_i2.DocumentModel>.value(_FakeDocumentModel_0(
          this,
          Invocation.method(
            #waitForConsumptionFinished,
            [
              filename,
              title,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i6.Future<_i2.DocumentModel>.value(_FakeDocumentModel_0(
          this,
          Invocation.method(
            #waitForConsumptionFinished,
            [
              filename,
              title,
            ],
          ),
        )),
      ) as _i6.Future<_i2.DocumentModel>);
  @override
  _i6.Future<_i7.Uint8List> download(_i2.DocumentModel? document) =>
      (super.noSuchMethod(
        Invocation.method(
          #download,
          [document],
        ),
        returnValue: _i6.Future<_i7.Uint8List>.value(_i7.Uint8List(0)),
        returnValueForMissingStub:
            _i6.Future<_i7.Uint8List>.value(_i7.Uint8List(0)),
      ) as _i6.Future<_i7.Uint8List>);
  @override
  _i6.Future<List<String>> autocomplete(
    String? query, [
    int? limit = 10,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #autocomplete,
          [
            query,
            limit,
          ],
        ),
        returnValue: _i6.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i6.Future<List<String>>.value(<String>[]),
      ) as _i6.Future<List<String>>);
}