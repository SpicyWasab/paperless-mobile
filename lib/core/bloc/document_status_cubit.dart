import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paperless_mobile/core/model/document_processing_status.dart';
import 'package:injectable/injectable.dart';

@singleton
class DocumentStatusCubit extends Cubit<DocumentProcessingStatus?> {
  DocumentStatusCubit() : super(null);

  void updateStatus(DocumentProcessingStatus? status) => emit(status);
}