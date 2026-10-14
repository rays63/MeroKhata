import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../features/books/book_detail_screen.dart';
import '../features/books/book_form_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/entries/entry_detail_screen.dart';
import '../features/entries/entry_form_screen.dart';
import '../features/goals/goal_form_screen.dart';
import '../features/goals/goals_screen.dart';
import '../features/import/import_pick_screen.dart';
import '../features/settings/settings_screen.dart';

Future<T?> _push<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));

/// The book quick actions act on: the most recently used one.
String? defaultBookId(BuildContext context) =>
    AppScope.read(context).booksByRecent.firstOrNull?.id;

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
    _push(
      context,
      EntryFormScreen(bookId: entry.bookId, type: entry.type, existing: entry),
    );

Future<void> openEntry(BuildContext context, String entryId) =>
    _push(context, EntryDetailScreen(entryId: entryId));

Future<void> openImport(BuildContext context, {String? bookId}) async {
  final id = bookId ?? defaultBookId(context);
  if (id == null) {
    await openNewBook(context);
    return;
  }
  await _push(context, ImportPickScreen(bookId: id));
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
