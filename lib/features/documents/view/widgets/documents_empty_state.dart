import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paperless_mobile/core/widgets/empty_state.dart';
import 'package:flutter_paperless_mobile/extensions/flutter_extensions.dart';
import 'package:flutter_paperless_mobile/features/documents/bloc/documents_cubit.dart';
import 'package:flutter_paperless_mobile/features/documents/bloc/documents_state.dart';
import 'package:flutter_paperless_mobile/features/documents/bloc/saved_view_cubit.dart';
import 'package:flutter_paperless_mobile/features/documents/model/document_filter.dart';
import 'package:flutter_paperless_mobile/generated/l10n.dart';

class DocumentsEmptyState extends StatelessWidget {
  final DocumentsState state;
  const DocumentsEmptyState({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        title: S.of(context).documentsPageEmptyStateOopsText,
        subtitle: S.of(context).documentsPageEmptyStateNothingHereText,
        bottomChild: state.filter != DocumentFilter.initial
            ? ElevatedButton(
                onPressed: () async {
                  await BlocProvider.of<DocumentsCubit>(context).updateFilter();
                  BlocProvider.of<SavedViewCubit>(context).resetSelection();
                },
                child: Text(
                  S.of(context).documentsFilterPageResetFilterLabel,
                ),
              ).padded()
            : null,
      ),
    );
  }
}