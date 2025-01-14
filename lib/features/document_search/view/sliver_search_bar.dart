import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperless_mobile/core/bloc/paperless_server_information_cubit.dart';
import 'package:paperless_mobile/core/bloc/paperless_server_information_state.dart';
import 'package:paperless_mobile/core/delegate/customizable_sliver_persistent_header_delegate.dart';
import 'package:paperless_mobile/core/widgets/material/search/m3_search_bar.dart';
import 'package:paperless_mobile/features/document_search/view/document_search_page.dart';
import 'package:paperless_mobile/features/settings/view/dialogs/account_settings_dialog.dart';
import 'package:paperless_mobile/generated/l10n/app_localizations.dart';

class SliverSearchBar extends StatelessWidget {
  final bool floating;
  final bool pinned;
  const SliverSearchBar({
    super.key,
    this.floating = false,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      floating: floating,
      pinned: pinned,
      delegate: CustomizableSliverPersistentHeaderDelegate(
        minExtent: 56 + 8,
        maxExtent: 56 + 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchBar(
            height: 56,
            supportingText: S.of(context)!.searchDocuments,
            onTap: () => showDocumentSearchPage(context),
            leadingIcon: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: Scaffold.of(context).openDrawer,
            ),
            trailingIcon: IconButton(
              icon: BlocBuilder<PaperlessServerInformationCubit,
                  PaperlessServerInformationState>(
                builder: (context, state) {
                  return CircleAvatar(
                    child: Text(state.information?.userInitials ?? ''),
                  );
                },
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AccountSettingsDialog(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
