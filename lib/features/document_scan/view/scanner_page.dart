import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:edge_detection/edge_detection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperless_api/paperless_api.dart';
import 'package:paperless_mobile/core/bloc/connectivity_cubit.dart';
import 'package:paperless_mobile/core/delegate/customizable_sliver_persistent_header_delegate.dart';
import 'package:paperless_mobile/core/global/constants.dart';
import 'package:paperless_mobile/core/repository/label_repository.dart';
import 'package:paperless_mobile/core/repository/provider/label_repositories_provider.dart';
import 'package:paperless_mobile/core/service/file_description.dart';
import 'package:paperless_mobile/core/service/file_service.dart';
import 'package:paperless_mobile/features/app_drawer/view/app_drawer.dart';
import 'package:paperless_mobile/features/document_scan/cubit/document_scanner_cubit.dart';
import 'package:paperless_mobile/features/document_scan/view/widgets/scanned_image_item.dart';
import 'package:paperless_mobile/features/document_search/view/sliver_search_bar.dart';
import 'package:paperless_mobile/features/document_upload/cubit/document_upload_cubit.dart';
import 'package:paperless_mobile/features/document_upload/view/document_upload_preparation_page.dart';
import 'package:paperless_mobile/features/documents/view/pages/document_view.dart';
import 'package:paperless_mobile/features/tasks/cubit/task_status_cubit.dart';
import 'package:paperless_mobile/generated/l10n/app_localizations.dart';
import 'package:paperless_mobile/helpers/file_helpers.dart';
import 'package:paperless_mobile/helpers/message_helpers.dart';
import 'package:paperless_mobile/helpers/permission_helpers.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  final SliverOverlapAbsorberHandle searchBarHandle =
      SliverOverlapAbsorberHandle();
  final SliverOverlapAbsorberHandle actionsHandle =
      SliverOverlapAbsorberHandle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, connectedState) {
        return Scaffold(
          drawer: const AppDrawer(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openDocumentScanner(context),
            child: const Icon(Icons.add_a_photo_outlined),
          ),
          body: BlocBuilder<DocumentScannerCubit, List<File>>(
            builder: (context, state) {
              return SafeArea(
                child: Scaffold(
                  drawer: const AppDrawer(),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => _openDocumentScanner(context),
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                  body: NestedScrollView(
                    floatHeaderSlivers: true,
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverOverlapAbsorber(
                        handle: searchBarHandle,
                        sliver: const SliverSearchBar(),
                      ),
                      SliverOverlapAbsorber(
                        handle: actionsHandle,
                        sliver: SliverPersistentHeader(
                          pinned: true,
                          delegate: CustomizableSliverPersistentHeaderDelegate(
                            child: _buildActions(connectedState.isConnected),
                            maxExtent: kTextTabBarHeight,
                            minExtent: kTextTabBarHeight,
                          ),
                        ),
                      ),
                    ],
                    body: BlocBuilder<DocumentScannerCubit, List<File>>(
                      builder: (context, state) {
                        if (state.isEmpty) {
                          return SizedBox.expand(
                            child: Center(
                              child: _buildEmptyState(
                                connectedState.isConnected,
                                state,
                              ),
                            ),
                          );
                        } else {
                          return _buildImageGrid(state);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActions(bool isConnected) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: SizedBox(
        height: kTextTabBarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BlocBuilder<DocumentScannerCubit, List<File>>(
              builder: (context, state) {
                return TextButton.icon(
                  label: Text(S.of(context)!.previewScan),
                  onPressed: state.isNotEmpty
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DocumentView(
                                documentBytes: _assembleFileBytes(
                                  state,
                                  forcePdf: true,
                                ).then((file) => file.bytes),
                              ),
                            ),
                          )
                      : null,
                  icon: const Icon(Icons.visibility_outlined),
                );
              },
            ),
            BlocBuilder<DocumentScannerCubit, List<File>>(
              builder: (context, state) {
                return TextButton.icon(
                  label: Text(S.of(context)!.clearAll),
                  onPressed: state.isEmpty ? null : () => _reset(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                );
              },
            ),
            BlocBuilder<DocumentScannerCubit, List<File>>(
              builder: (context, state) {
                return TextButton.icon(
                  label: Text(S.of(context)!.upload),
                  onPressed: state.isEmpty || !isConnected
                      ? null
                      : () => _onPrepareDocumentUpload(context),
                  icon: const Icon(Icons.upload_outlined),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openDocumentScanner(BuildContext context) async {
    final isGranted = await askForPermission(Permission.camera);
    if (!isGranted) {
      return;
    }
    final file = await FileService.allocateTemporaryFile(
      PaperlessDirectoryType.scans,
      extension: 'jpeg',
    );
    if (kDebugMode) {
      dev.log('[ScannerPage] Created temporary file: ${file.path}');
    }

    final success = await EdgeDetection.detectEdge(file.path);
    if (!success) {
      if (kDebugMode) {
        dev.log(
            '[ScannerPage] Scan either not successful or canceled by user.');
      }
      return;
    }
    if (kDebugMode) {
      dev.log('[ScannerPage] Wrote image to temporary file: ${file.path}');
    }
    context.read<DocumentScannerCubit>().addScan(file);
  }

  void _onPrepareDocumentUpload(BuildContext context) async {
    final file = await _assembleFileBytes(
      context.read<DocumentScannerCubit>().state,
    );
    final uploadResult = await Navigator.of(context).push<DocumentUploadResult>(
      MaterialPageRoute(
        builder: (_) => LabelRepositoriesProvider(
          child: BlocProvider(
            create: (context) => DocumentUploadCubit(
              documentApi: context.read<PaperlessDocumentsApi>(),
              correspondentRepository:
                  context.read<LabelRepository<Correspondent>>(),
              documentTypeRepository:
                  context.read<LabelRepository<DocumentType>>(),
              tagRepository: context.read<LabelRepository<Tag>>(),
            ),
            child: DocumentUploadPreparationPage(
              fileBytes: file.bytes,
              fileExtension: file.extension,
            ),
          ),
        ),
      ),
    );
    if ((uploadResult?.success ?? false) && uploadResult?.taskId != null) {
      // For paperless version older than 1.11.3, task id will always be null!
      context.read<DocumentScannerCubit>().reset();
      context
          .read<TaskStatusCubit>()
          .listenToTaskChanges(uploadResult!.taskId!);
    }
  }

  Widget _buildEmptyState(bool isConnected, List<File> scans) {
    if (scans.isNotEmpty) {
      return _buildImageGrid(scans);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context)!.noDocumentsScannedYet,
              textAlign: TextAlign.center,
            ),
            TextButton(
              child: Text(S.of(context)!.scanADocument),
              onPressed: () => _openDocumentScanner(context),
            ),
            Text(S.of(context)!.or),
            TextButton(
              child: Text(S.of(context)!.uploadADocumentFromThisDevice),
              onPressed: isConnected ? _onUploadFromFilesystem : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<File> scans) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(handle: searchBarHandle),
        SliverOverlapInjector(handle: actionsHandle),
        SliverGrid.builder(
          itemCount: scans.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1 / sqrt(2),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return ScannedImageItem(
              file: scans[index],
              onDelete: () async {
                try {
                  context.read<DocumentScannerCubit>().removeScan(index);
                } on PaperlessServerException catch (error, stackTrace) {
                  showErrorMessage(context, error, stackTrace);
                }
              },
              index: index,
              totalNumberOfFiles: scans.length,
            );
          },
        ),
      ],
    );
  }

  void _reset(BuildContext context) {
    try {
      context.read<DocumentScannerCubit>().reset();
    } on PaperlessServerException catch (error, stackTrace) {
      showErrorMessage(context, error, stackTrace);
    }
  }

  void _onUploadFromFilesystem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedFileExtensions,
      withData: true,
      allowMultiple: false,
    );
    if (result?.files.single.path != null) {
      final path = result!.files.single.path!;
      final fileDescription = FileDescription.fromPath(path);
      File file = File(path);
      if (!supportedFileExtensions.contains(
        fileDescription.extension.toLowerCase(),
      )) {
        showErrorMessage(
          context,
          const PaperlessServerException(ErrorCode.unsupportedFileFormat),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LabelRepositoriesProvider(
            child: BlocProvider(
              create: (context) => DocumentUploadCubit(
                documentApi: context.read<PaperlessDocumentsApi>(),
                correspondentRepository:
                    context.read<LabelRepository<Correspondent>>(),
                documentTypeRepository:
                    context.read<LabelRepository<DocumentType>>(),
                tagRepository: context.read<LabelRepository<Tag>>(),
              ),
              child: DocumentUploadPreparationPage(
                fileBytes: file.readAsBytesSync(),
                filename: fileDescription.filename,
                title: fileDescription.filename,
                fileExtension: fileDescription.extension,
              ),
            ),
          ),
        ),
      );
    }
  }

  ///
  /// Returns the file bytes of either a single file or multiple images concatenated into a single pdf.
  ///
  Future<AssembledFile> _assembleFileBytes(
    final List<File> files, {
    bool forcePdf = false,
  }) async {
    assert(files.isNotEmpty);
    if (files.length == 1 && !forcePdf) {
      final ext = p.extension(files.first.path);
      return AssembledFile(ext, files.first.readAsBytesSync());
    }
    final doc = pw.Document();
    for (final file in files) {
      final img = pw.MemoryImage(file.readAsBytesSync());
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            img.width!.toDouble(),
            img.height!.toDouble(),
          ),
          build: (context) => pw.Image(img),
        ),
      );
    }
    return AssembledFile('.pdf', await doc.save());
  }
}

class AssembledFile {
  final String extension;
  final Uint8List bytes;

  AssembledFile(this.extension, this.bytes);
}
