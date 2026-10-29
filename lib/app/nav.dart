import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../features/books/book_detail_screen.dart';
import '../features/books/book_form_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/entries/all_entries_screen.dart';
import '../features/entries/entry_detail_screen.dart';
import '../features/entries/entry_form_screen.dart';
import '../features/entries/templates_screen.dart';
import '../features/entries/transfer_form_screen.dart';
import '../features/goals/goal_form_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/import/import_pick_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/tags/manage_tags_screen.dart';
import '../features/tags/tag_screen.dart';

Future<T?> _push<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));

/// The account quick actions act on: the most recently used one that isn't
/// a card or loan (everyday cash in/out rarely belongs on a liability).
String? defaultBookId(BuildContext context) {
  final books = AppScope.read(context).booksByRecent;
  return (books.where((b) => !b.isLiability).firstOrNull ?? books.firstOrNull)
      ?.id;
}

Future<void> openBook(BuildContext context, String bookId) =>
    Navigator.of(context).push(BookDetailScreen.route(bookId));

Future<void> openNewEntry(
  BuildContext context, {
  String? bookId,
  required TransactionType type,
}) async {
  final id = bookId ?? defaultBookId(context);
  if (id == null) {
    await openNewBook(context);
    return;
  }
  await _push(context, EntryFormScreen(bookId: id, type: type));
}

Future<void> openEditEntry(BuildContext context, LedgerTransaction entry) =>
    entry.isTransferLeg
    ? _push(context, TransferFormScreen(transferId: entry.transferId))
    : _push(
        context,
        EntryFormScreen(
          bookId: entry.bookId,
          type: entry.type,
          existing: entry,
        ),
      );

/// New transfer, starting from [fromId] (or the user's bank account).
Future<void> openNewTransfer(BuildContext context, {String? fromId}) async {
  if (defaultBookId(context) == null) {
    await openNewBook(context);
    return;
  }
  await _push(context, TransferFormScreen(fromId: fromId));
}

Future<void> openEntry(BuildContext context, String entryId) =>
    _push(context, EntryDetailScreen(entryId: entryId));

Future<void> openImport(BuildContext context, {String? bookId}) async {
  final id = bookId ?? defaultBookId(context);
  if (id == null) {
    await openNewBook(context);
    return;
  }
  // From Home the book can be switched; from inside a book it is fixed.
  await _push(
    context,
    ImportPickScreen(bookId: id, canChangeBook: bookId == null),
  );
}

Future<void> openNewBook(BuildContext context) =>
    _push(context, const BookFormScreen());

Future<void> openRenameBook(BuildContext context, LedgerBook book) =>
    _push(context, BookFormScreen(book: book));

Future<void> openGoals(BuildContext context) =>
    _push(context, const GoalsScreen());

Future<void> openNewGoal(BuildContext context) =>
    _push(context, const GoalFormScreen());

Future<void> openCalendar(BuildContext context) =>
    _push(context, const CalendarScreen());

Future<void> openSettings(BuildContext context) =>
    _push(context, const SettingsScreen());

Future<void> openTag(BuildContext context, String tag) =>
    _push(context, TagScreen(tag: tag));

Future<void> openManageTags(BuildContext context) =>
    _push(context, const ManageTagsScreen());

Future<void> openAllEntries(BuildContext context, {String? tag}) =>
    _push(context, AllEntriesScreen(tag: tag));

Future<void> openSearch(BuildContext context) =>
    _push(context, const SearchScreen());

Future<void> openTemplates(BuildContext context) =>
    _push(context, const TemplatesScreen());

/// A new entry filled from [template] (its account, or the most recent one
/// if that account was removed).
Future<void> openTemplate(BuildContext context, EntryTemplate template) {
  final store = AppScope.read(context);
  final bookId = store.bookById(template.bookId) != null
      ? template.bookId
      : defaultBookId(context);
  if (bookId == null) return openNewBook(context);
  return _push(
    context,
    EntryFormScreen(bookId: bookId, type: template.type, template: template),
  );
}
