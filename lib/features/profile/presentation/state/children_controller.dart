import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/user_profile_repository.dart';
import '../../domain/child_summary.dart';

/// The authenticated parent's full list of children (oldest-created first).
///
/// [loadChildren] also runs the one-time legacy-account migration first, so
/// callers never need to think about the pre-multi-child data shape.
class ChildrenController extends Notifier<List<ChildSummary>> {
  @override
  List<ChildSummary> build() => const [];

  Future<List<ChildSummary>> loadChildren(String uid) async {
    final repository = ref.read(userProfileRepositoryProvider);
    await repository.migrateLegacyChildIfNeeded(uid);
    final children = await repository.getChildren(uid);
    state = children;
    return children;
  }

  void clear() => state = const [];
}

final childrenProvider = NotifierProvider<ChildrenController, List<ChildSummary>>(ChildrenController.new);
