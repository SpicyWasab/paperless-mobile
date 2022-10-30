import 'package:flutter_paperless_mobile/core/bloc/label_cubit.dart';
import 'package:flutter_paperless_mobile/features/labels/correspondent/model/correspondent.model.dart';
import 'package:flutter_paperless_mobile/features/labels/storage_path/model/storage_path.model.dart';
import 'package:injectable/injectable.dart';

@singleton
class StoragePathCubit extends LabelCubit<StoragePath> {
  StoragePathCubit(super.metaDataService);

  @override
  Future<void> initialize() async {
    return labelRepository.getStoragePaths().then(loadFrom);
  }

  @override
  Future<StoragePath> save(StoragePath item) => labelRepository.saveStoragePath(item);

  @override
  Future<StoragePath> update(StoragePath item) => labelRepository.updateStoragePath(item);

  @override
  Future<int> delete(StoragePath item) => labelRepository.deleteStoragePath(item);
}