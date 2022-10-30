import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paperless_mobile/core/bloc/connectivity_cubit.dart';
import 'package:flutter_paperless_mobile/core/logic/error_code_localization_mapper.dart';
import 'package:flutter_paperless_mobile/core/model/error_message.dart';
import 'package:flutter_paperless_mobile/core/widgets/offline_banner.dart';
import 'package:flutter_paperless_mobile/di_initializer.dart';
import 'package:flutter_paperless_mobile/features/labels/correspondent/bloc/correspondents_cubit.dart';
import 'package:flutter_paperless_mobile/features/labels/document_type/bloc/document_type_cubit.dart';
import 'package:flutter_paperless_mobile/features/documents/bloc/documents_cubit.dart';
import 'package:flutter_paperless_mobile/features/documents/bloc/documents_state.dart';
import 'package:flutter_paperless_mobile/features/documents/model/document.model.dart';
import 'package:flutter_paperless_mobile/features/documents/view/pages/document_details_page.dart';
import 'package:flutter_paperless_mobile/features/documents/view/widgets/documents_empty_state.dart';
import 'package:flutter_paperless_mobile/features/documents/view/widgets/grid/document_grid.dart';
import 'package:flutter_paperless_mobile/features/documents/view/widgets/list/document_list.dart';
import 'package:flutter_paperless_mobile/features/documents/view/widgets/search/document_filter_panel.dart';
import 'package:flutter_paperless_mobile/features/documents/view/widgets/selection/documents_page_app_bar.dart';
import 'package:flutter_paperless_mobile/features/documents/view/widgets/sort_documents_button.dart';
import 'package:flutter_paperless_mobile/features/home/view/widget/info_drawer.dart';
import 'package:flutter_paperless_mobile/features/labels/storage_path/bloc/storage_path_cubit.dart';
import 'package:flutter_paperless_mobile/features/login/bloc/authentication_cubit.dart';
import 'package:flutter_paperless_mobile/features/labels/tags/bloc/tags_cubit.dart';
import 'package:flutter_paperless_mobile/util.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final PagingController<int, DocumentModel> _pagingController =
      PagingController<int, DocumentModel>(
    firstPageKey: 1,
  );

  final PanelController _panelController = PanelController();
  ViewType _viewType = ViewType.list;

  @override
  void initState() {
    super.initState();
    final documentsCubit = BlocProvider.of<DocumentsCubit>(context);
    if (!documentsCubit.state.isLoaded) {
      documentsCubit.loadDocuments().onError<ErrorMessage>(
            (error, stackTrace) => showSnackBar(
              context,
              translateError(context, error.code),
            ),
          );
    }
    _pagingController.addPageRequestListener(_loadNewPage);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _loadNewPage(int pageKey) async {
    final documentsCubit = BlocProvider.of<DocumentsCubit>(context);
    final pageCount =
        documentsCubit.state.inferPageCount(pageSize: documentsCubit.state.filter.pageSize);
    if (pageCount <= pageKey + 1) {
      _pagingController.nextPageKey = null;
    }
    documentsCubit.loadMore();
  }

  void _onSelected(DocumentModel model) {
    BlocProvider.of<DocumentsCubit>(context).toggleDocumentSelection(model);
  }

  Future<void> _onRefresh() {
    final documentsCubit = BlocProvider.of<DocumentsCubit>(context);
    return documentsCubit
        .updateFilter(filter: documentsCubit.state.filter.copyWith(page: 1))
        .onError<ErrorMessage>((error, _) {
      showSnackBar(context, translateError(context, error.code));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_panelController.isPanelOpen) {
          FocusScope.of(context).unfocus();
          _panelController.close();
          return false;
        }
        final docBloc = BlocProvider.of<DocumentsCubit>(context);
        if (docBloc.state.selection.isNotEmpty) {
          docBloc.resetSelection();
          return false;
        }
        return true;
      },
      child: BlocConsumer<ConnectivityCubit, ConnectivityState>(
        listenWhen: (previous, current) =>
            previous != ConnectivityState.connected && current == ConnectivityState.connected,
        listener: (context, state) {
          BlocProvider.of<DocumentsCubit>(context).loadDocuments();
        },
        builder: (context, connectivityState) {
          return Scaffold(
            drawer: BlocProvider.value(
              value: BlocProvider.of<AuthenticationCubit>(context),
              child: const InfoDrawer(),
            ),
            resizeToAvoidBottomInset: true,
            appBar: connectivityState == ConnectivityState.connected ? null : const OfflineBanner(),
            body: SlidingUpPanel(
              backdropEnabled: true,
              parallaxEnabled: true,
              parallaxOffset: .5,
              controller: _panelController,
              defaultPanelState: PanelState.CLOSED,
              minHeight: 48,
              maxHeight: MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight -
                  2 * kToolbarHeight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              body: _buildBody(connectivityState),
              color: Theme.of(context).scaffoldBackgroundColor,
              panelBuilder: (scrollController) => DocumentFilterPanel(
                panelController: _panelController,
                scrollController: scrollController,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ConnectivityState connectivityState) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      builder: (context, state) {
        // Some ugly tricks to make it work with bloc, update pageController
        _pagingController.value = PagingState(
          itemList: state.documents,
          nextPageKey: state.nextPageNumber,
        );

        late Widget child;
        switch (_viewType) {
          case ViewType.list:
            child = DocumentListView(
              onTap: _openDocumentDetails,
              state: state,
              onSelected: _onSelected,
              pagingController: _pagingController,
              hasInternetConnection: connectivityState == ConnectivityState.connected,
            );
            break;
          case ViewType.grid:
            child = DocumentGridView(
                onTap: _openDocumentDetails,
                state: state,
                onSelected: _onSelected,
                pagingController: _pagingController,
                hasInternetConnection: connectivityState == ConnectivityState.connected);
            break;
        }

        if (state.isLoaded && state.documents.isEmpty) {
          child = SliverToBoxAdapter(
            child: DocumentsEmptyState(
              state: state,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: Container(
            padding: const EdgeInsets.only(
              bottom: 142,
            ), // Prevents panel from hiding scrollable content
            child: CustomScrollView(
              slivers: [
                DocumentsPageAppBar(
                  actions: [
                    const SortDocumentsButton(),
                    IconButton(
                      icon: Icon(
                        _viewType == ViewType.grid ? Icons.list : Icons.grid_view,
                      ),
                      onPressed: () => setState(() => _viewType = _viewType.toggle()),
                    ),
                  ],
                ),
                child
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDocumentDetails(DocumentModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<DocumentsCubit>()),
            BlocProvider.value(value: getIt<CorrespondentCubit>()),
            BlocProvider.value(value: getIt<DocumentTypeCubit>()),
            BlocProvider.value(value: getIt<TagCubit>()),
            BlocProvider.value(value: getIt<StoragePathCubit>()),
          ],
          child: DocumentDetailsPage(
            documentId: model.id,
          ),
        ),
      ),
    );
  }
}

enum ViewType {
  grid,
  list;

  ViewType toggle() {
    return this == grid ? list : grid;
  }
}