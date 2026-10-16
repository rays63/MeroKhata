import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/data/split.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppStore> _store() async {
  SharedPreferences.setMockInitialValues({
    'hissabkitab_data_v1': jsonEncode({
      'books': [
        {
          'id': 'personal',
          'name': 'Personal',
          'createdAt': '2026-10-01T00:00:00.000',
          'updatedAt': '2026-10-01T00:00:00.000',
        },
        {
          'id': 'trip',
          'name': 'Japan Trip',
          'currency': 'JPY',
          'createdAt': '2026-10-01T00:00:00.000',
          'updatedAt': '2026-10-02T00:00:00.000',
        },
      ],
      'transactions': [],
      'onboarded': true,
    }),
  });
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  group('splitAmount', () {
    test('equal and by shares, as in the design', () {
      expect(splitAmount(3600, {me: 1, 'sita': 1, 'bikash': 1}), {
        me: 1200,
        'sita': 1200,
        'bikash': 1200,
      });
      expect(
        splitAmount(3600, {
          me: 1,
          'sita': 2,
          'bikash': 1,
          'anu': 1,
          'rohan': 0,
        }),
        {me: 720, 'sita': 1440, 'bikash': 720, 'anu': 720},
      );
    });

    test('rounding remainder keeps the total exact', () {
      final parts = splitAmount(100, {me: 1, 'a': 1, 'b': 1});
      expect(parts.values.reduce((a, b) => a + b), closeTo(100, 1e-9));
      expect(parts[me], 33.34);
    });

    test('balances only involve you', () {
      expect(balancesFor(3600, me, {me: 1, 'sita': 2, 'bikash': 1}), {
        'sita': 1800,
        'bikash': 900,
      });
      expect(balancesFor(1600, 'sita', {me: 1, 'sita': 1, 'bikash': 2}), {
        'sita': -400,
      });
      expect(balancesFor(1600, 'sita', {'sita': 1, 'bikash': 1}), isEmpty);
    });
  });

  test('group expenses, settle-up posts to the chosen book', () async {
    final store = await _store();
    final sita = await store.addFriend('Sita');
    final bikash = await store.addFriend('Bikash');
    expect((await store.addFriend(' sita ')).id, sita.id);

    final groupId = await store.saveGroup(
      name: 'Pokhara Trip',
      memberIds: [sita.id, bikash.id],
    );
    await store.addGroupExpense(
      groupId: groupId,
      title: 'Hotel',
      amount: 8400,
      paidBy: me,
      shares: {me: 1, sita.id: 1, bikash.id: 1},
      recordInBookId: 'personal',
    );
    await store.addGroupExpense(
      groupId: groupId,
      title: 'Boating',
      amount: 1500,
      paidBy: sita.id,
      shares: {me: 1, sita.id: 1, bikash.id: 1},
    );

    final group = store.groups.single;
    expect(group.balances, {sita.id: 2300, bikash.id: 2800});
    expect(group.totalSpent, 9900);
    expect(store.owedToYou, 5100);
    expect(store.youOwe, 0);
    // The hotel you paid is in the book.
    expect(store.balanceFor('personal'), -8400);

    final settled = await store.settleGroup(
      groupId: groupId,
      friendId: sita.id,
      bookId: 'personal',
    );
    expect(settled, 2300);
    expect(store.groups.single.balances[sita.id], 0);
    expect(store.balanceFor('personal'), -8400 + 2300);
    expect(
      store.transactionsForBook('personal').first.title,
      'Settlement · Sita',
    );
    expect(store.lastSplitBookId, 'personal');
  });

  test('members in an expense stay when the group is edited', () async {
    final store = await _store();
    final sita = await store.addFriend('Sita');
    final anu = await store.addFriend('Anu');
    final id = await store.saveGroup(
      name: 'Flat',
      memberIds: [sita.id, anu.id],
    );
    await store.addGroupExpense(
      groupId: id,
      title: 'Gas',
      amount: 1950,
      paidBy: sita.id,
      shares: {me: 1, sita.id: 1, anu.id: 1},
    );
    await store.saveGroup(id: id, name: 'Flat 3B', memberIds: []);
    expect(store.groups.single.name, 'Flat 3B');
    expect(store.groups.single.memberIds, containsAll([sita.id, anu.id]));
    expect(store.youOwe, 650);
  });

  test('bills: record or link the cost, then settle', () async {
    final store = await _store();
    final sita = await store.addFriend('Sita');
    final bikash = await store.addFriend('Bikash');

    final bill = await store.saveBill(
      title: 'Thakali dinner',
      amount: 3600,
      shares: {me: 1, sita.id: 2, bikash.id: 1},
      recordInBookId: 'personal',
    );
    expect(bill.toCollect, 2700);
    expect(store.balanceFor('personal'), -3600);

    await store.settleBill(
      billId: bill.id,
      friendId: sita.id,
      bookId: 'personal',
    );
    await store.settleBill(
      billId: bill.id,
      friendId: bikash.id,
      bookId: 'personal',
    );
    expect(store.bills.single.settled, isTrue);
    expect(store.balanceFor('personal'), -900);

    // Splitting an existing entry links it instead of recording again.
    final linked = await store.saveBill(
      title: 'Groceries',
      amount: 1000,
      shares: {me: 1, sita.id: 1},
      linkedEntryId: 'existing',
    );
    expect(linked.transactionId, 'existing');
    expect(store.balanceFor('personal'), -900);
  });

  test('split books are home-currency only and survive a reload', () async {
    final store = await _store();
    expect(store.splitBooks().map((b) => b.id), ['personal']);
    expect(store.defaultSplitBookId(), 'personal');

    final sita = await store.addFriend('Sita');
    await store.saveBill(
      title: 'Cab',
      amount: 1200,
      shares: {me: 1, sita.id: 1},
    );

    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.friends.single.name, 'Sita');
    expect(reloaded.bills.single.toCollect, 600);
    expect(reloaded.owedToYou, 600);
  });

  test(
    'QA regressions: memory, linked entries, removed members, currency',
    () async {
      final store = await _store();
      final sita = await store.addFriend('Sita');
      final groupId = await store.saveGroup(name: 'Trip', memberIds: [sita.id]);

      // The book picked for a group expense is remembered.
      store.lastSplitBookId = null;
      await store.addGroupExpense(
        groupId: groupId,
        title: 'Taxi',
        amount: 1000.005,
        paidBy: me,
        shares: {me: 1, sita.id: 1},
        recordInBookId: 'personal',
      );
      expect(store.lastSplitBookId, 'personal');
      expect(store.groups.single.expenses.single.amount, 1000.01);

      // Entries created by splits are recognised; a split entry finds its bill.
      final expenseEntry = store.groups.single.expenses.single.transactionId!;
      expect(store.isSplitEntry(expenseEntry), isTrue);
      final bill = await store.saveBill(
        title: 'Dinner',
        amount: 600,
        shares: {me: 1, sita.id: 1},
        linkedEntryId: 'entry-1',
      );
      expect(store.billForEntry('entry-1')?.id, bill.id);

      // Settled, then the expense is deleted: the balance flips but stays
      // visible even if Sita is removed from the group.
      await store.settleGroup(
        groupId: groupId,
        friendId: sita.id,
        bookId: 'personal',
      );
      await store.deleteGroupExpense(
        groupId,
        store.groups.single.expenses.single.id,
      );
      await store.saveGroup(id: groupId, name: 'Trip', memberIds: []);
      expect(store.groups.single.memberIds, contains(sita.id));
      expect(store.groups.single.balances[sita.id], closeTo(-500, .001));
      expect(store.categories, contains('Settlement'));

      // Changing the home currency doesn't relabel or merge old splits.
      await store.setDefaultCurrency('JPY');
      expect(store.groups.single.currency, 'NPR');
      expect(store.owedToYou, 0);
      expect(store.youOwe, 0);
      expect(store.splitBooks('NPR').map((b) => b.id), ['personal']);
      expect(store.splitBooks().map((b) => b.id), ['trip']);
    },
  );
}
