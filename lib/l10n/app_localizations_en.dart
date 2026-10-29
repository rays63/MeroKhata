// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Paisa Flow';

  @override
  String get tabHome => 'Home';

  @override
  String get tabBooks => 'Accounts';

  @override
  String get tabInsights => 'Insights';

  @override
  String get tabSplit => 'Split';

  @override
  String get newEntry => 'New entry';

  @override
  String get cashIn => 'Cash in';

  @override
  String get cashOut => 'Cash out';

  @override
  String get all => 'All';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get editList => 'Edit list';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get continueLabel => 'Continue';

  @override
  String get optional => 'optional';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get greetingMorning => 'Good morning,';

  @override
  String get greetingAfternoon => 'Good afternoon,';

  @override
  String get greetingEvening => 'Good evening,';

  @override
  String get updatedToday => 'Updated today';

  @override
  String get updatedYesterday => 'Updated yesterday';

  @override
  String updatedDaysAgo(int days) {
    return 'Updated $days days ago';
  }

  @override
  String get updatedLastWeek => 'Updated last week';

  @override
  String updatedOn(String date) {
    return 'Updated $date';
  }

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String bookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String goalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goals',
      one: '1 goal',
    );
    return '$_temp0';
  }

  @override
  String homeTotalBalance(String currency) {
    return 'Total balance · $currency';
  }

  @override
  String homeCashInMonth(String month) {
    return 'Cash in · $month';
  }

  @override
  String homeCashOutMonth(String month) {
    return 'Cash out · $month';
  }

  @override
  String get import => 'Import';

  @override
  String get splitABill => 'Split a bill';

  @override
  String get goals => 'Goals';

  @override
  String get setSavingsTarget => 'Set a savings target';

  @override
  String goalsSaved(String amount, String goals) {
    return '$amount saved · $goals';
  }

  @override
  String get split => 'Split';

  @override
  String get youreOwed => 'You\'re owed';

  @override
  String get youOwe => 'You owe';

  @override
  String get recentlyUpdated => 'Recently updated';

  @override
  String get seeAll => 'See all';

  @override
  String get calendar => 'Calendar';

  @override
  String get settings => 'Settings';

  @override
  String get category => 'Category';

  @override
  String get paymentMode => 'Payment mode';

  @override
  String get bookCurrency => 'Account currency';

  @override
  String get book => 'Account';

  @override
  String editListTitle(String title) {
    return 'Edit $title list';
  }

  @override
  String get addNew => 'Add new…';

  @override
  String optionAdded(String name) {
    return '“$name” added';
  }

  @override
  String optionRemoved(String name) {
    return '“$name” removed. Entries that use it keep it.';
  }

  @override
  String deleteOption(String name) {
    return 'Delete $name';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get weekdaysShort => 'S,M,T,W,T,F,S';

  @override
  String get weekdaysLong => 'SUN,MON,TUE,WED,THU,FRI,SAT';

  @override
  String daySemantics(String date, String activity) {
    return '$date$activity';
  }

  @override
  String get hasCashIn => ', cash in';

  @override
  String get hasCashOut => ', cash out';

  @override
  String entrySemantics(String title, String type, String amount) {
    return '$title, $type $amount';
  }

  @override
  String balanceShort(String amount) {
    return 'Bal $amount';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String readyToShare(String name) {
    return '$name ready to share';
  }

  @override
  String get loadError => 'Some saved data couldn’t be read. A copy was kept.';

  @override
  String get splitYou => 'You';

  @override
  String get splitFriendFallback => 'Friend';

  @override
  String get splitAddFriendTitle => 'Add a friend';

  @override
  String get splitAddFriendHint => 'Name, e.g. Sita';

  @override
  String get splitEqual => 'Equal';

  @override
  String get splitShares => 'Shares';

  @override
  String splitFewerShares(String name) {
    return 'Fewer shares for $name';
  }

  @override
  String splitMoreShares(String name) {
    return 'More shares for $name';
  }

  @override
  String splitRecordBeforeBook(String amount) {
    return 'Record $amount as cash out in';
  }

  @override
  String get splitRecordAfterBook => '';

  @override
  String splitSettleUpWith(String name) {
    return 'Settle up with $name';
  }

  @override
  String splitPayName(String name) {
    return 'Pay $name';
  }

  @override
  String splitTheyPayYou(String name, String amount) {
    return '$name pays you $amount.';
  }

  @override
  String splitYouPayThem(String name, String amount) {
    return 'You pay $name $amount.';
  }

  @override
  String get splitNoBookForCurrency =>
      'Add an account in this currency to record settlements.';

  @override
  String splitAddAsCashIn(String book) {
    return 'Add as cash in to $book';
  }

  @override
  String splitAddAsCashOut(String book) {
    return 'Add as cash out to $book';
  }

  @override
  String splitSettleAmount(String amount) {
    return 'Settle $amount';
  }

  @override
  String splitPayAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get splitGroups => 'Groups';

  @override
  String get splitBills => 'Bills';

  @override
  String get splitNoGroupsTitle => 'No groups yet';

  @override
  String get splitNoGroupsBody =>
      'Make a group for a trip or a shared flat and keep running balances with everyone in it.';

  @override
  String get splitNewGroup => 'New group';

  @override
  String get splitNoBillsTitle => 'No bills yet';

  @override
  String get splitNoBillsBody =>
      'Split a dinner, a cab or a movie night in a few taps.';

  @override
  String splitPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String splitExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String splitGroupOwed(String amount) {
    return 'owed $amount';
  }

  @override
  String splitYouOweAmount(String amount) {
    return 'you owe $amount';
  }

  @override
  String splitOwesYou(String amount) {
    return 'owes you $amount';
  }

  @override
  String get splitSettledUp => 'settled up';

  @override
  String get splitBillSettled => 'Settled';

  @override
  String splitToCollectAmount(String amount) {
    return '$amount to collect';
  }

  @override
  String splitBillSavedToast(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Split saved · $count people owe you $amount',
      one: 'Split saved · 1 person owes you $amount',
    );
    return '$_temp0';
  }

  @override
  String get splitEnterTotal => 'Enter the total';

  @override
  String get splitPickFriend => 'Pick at least one friend';

  @override
  String splitSaveCta(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save · $count owe you $amount',
      one: 'Save · 1 owes you $amount',
    );
    return '$_temp0';
  }

  @override
  String get splitWhatFor => 'What\'s it for?';

  @override
  String get splitBillHint => 'e.g. Thakali dinner';

  @override
  String get splitTotalPaidByYou => 'Total · paid by you';

  @override
  String get splitBetween => 'Split between';

  @override
  String get splitLinkedNote =>
      'Linked to the entry you split, so nothing new is recorded in your account.';

  @override
  String splitDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get splitEntriesStay =>
      'Entries already recorded in your accounts stay.';

  @override
  String get splitAllSettled => 'All settled';

  @override
  String get splitSettle => 'Settle';

  @override
  String get splitRecordTitle => 'Record this payment';

  @override
  String splitRecordPaidMessage(String amount) {
    return 'You paid $amount. Pick the account to record it in.';
  }

  @override
  String get splitDontRecord => 'Don’t record in an account';

  @override
  String splitNoBookInCurrency(String currency) {
    return 'You don’t have a $currency account yet.';
  }

  @override
  String splitCreateBookIn(String currency) {
    return 'Create a $currency account';
  }

  @override
  String splitSettledToast(String amount, String name) {
    return 'Settled $amount with $name';
  }

  @override
  String get splitYourBook => 'your account';

  @override
  String splitReceivedToast(String amount, String name, String book) {
    return '$amount from $name recorded in $book';
  }

  @override
  String splitPaidToast(String amount, String name, String book) {
    return '$amount to $name recorded in $book';
  }

  @override
  String get groupNameRequired => 'Give the group a name';

  @override
  String get groupFriendRequired => 'Add at least one friend';

  @override
  String get groupUpdated => 'Group updated';

  @override
  String groupCreated(String name) {
    return 'Group “$name” created';
  }

  @override
  String get groupDeleteOpenBody =>
      'Some balances aren’t settled yet. Entries already recorded in your accounts stay.';

  @override
  String get groupDeleted => 'Group deleted';

  @override
  String get groupEdit => 'Edit group';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupNameHint => 'e.g. Pokhara Trip, Flat 3B';

  @override
  String get groupMembers => 'Members';

  @override
  String groupMemberLocked(String name) {
    return '$name is part of an expense in this group';
  }

  @override
  String get groupTapAddHint =>
      'Tap Add to add the friends you share costs with.';

  @override
  String get groupCreate => 'Create group';

  @override
  String get groupDelete => 'Delete group';

  @override
  String get groupTitle => 'Group';

  @override
  String groupTotalSpent(String amount) {
    return 'Total spent $amount';
  }

  @override
  String get groupBalances => 'Balances';

  @override
  String get groupExpenses => 'Expenses';

  @override
  String get groupNoExpenses => 'No expenses yet. Add the first one below.';

  @override
  String expensePaidByName(String name) {
    return 'Paid by $name';
  }

  @override
  String get expenseDelete => 'Delete expense';

  @override
  String get expenseDeleteBody => 'Balances will be recalculated without it.';

  @override
  String expenseDeleteSettledBody(String names) {
    return 'You’ve already settled up with $names. Deleting this changes those balances, so someone may end up owing the other.';
  }

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get expenseDeletedEntryStays =>
      'Expense deleted · its account entry stays';

  @override
  String get expenseAmountRequired => 'Enter an amount greater than zero';

  @override
  String get expensePickSharers => 'Pick who shares this expense';

  @override
  String get expenseNeedOther => 'Add someone besides the payer to split with';

  @override
  String get expenseAddedToast => 'Expense added · balances updated';

  @override
  String get expenseAdd => 'Add expense';

  @override
  String get expenseHint => 'e.g. Hotel (2 nights)';

  @override
  String get expenseAmount => 'Amount';

  @override
  String get expensePaidBy => 'Paid by';

  @override
  String get billTitle => 'Bill';

  @override
  String get billPaidByYou => 'paid by you';

  @override
  String get billDelete => 'Delete bill';

  @override
  String get billDeleted => 'Bill deleted';

  @override
  String get billToCollect => 'To collect';

  @override
  String billTotalLine(String total, String share) {
    return 'Bill total $total · your share $share';
  }

  @override
  String get bookListTitle => 'Accounts';

  @override
  String get bookNew => 'New account';

  @override
  String get bookSearchHint => 'Search accounts';

  @override
  String bookSearchNoMatch(String query) {
    return 'No accounts match “$query”';
  }

  @override
  String bookDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get bookDeleteEmpty => 'This account has no entries.';

  @override
  String bookDeleteWithEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Its $count entries will be deleted too. This can’t be undone.',
      one: 'Its 1 entry will be deleted too. This can’t be undone.',
    );
    return '$_temp0';
  }

  @override
  String bookDeleted(String name) {
    return '“$name” deleted';
  }

  @override
  String get bookActions => 'Account actions';

  @override
  String get bookRename => 'Edit account';

  @override
  String get bookEmptyTitle => 'Add your first account';

  @override
  String get bookEmptyBody =>
      'Cash in hand, a NIC Asia account, eSewa or a card. Each one keeps its own balance and currency.';

  @override
  String get bookEmptyImport => 'or import a statement';

  @override
  String get bookCurrencyLocked =>
      'Currency is fixed once an account has entries';

  @override
  String get bookUntitled => 'Untitled account';

  @override
  String get bookRenamed => 'Account updated';

  @override
  String bookCreated(String name, String currency) {
    return '“$name” created in $currency';
  }

  @override
  String get bookRenameTitle => 'Edit account';

  @override
  String get bookNameLabel => 'Account name';

  @override
  String get bookNameHint => 'e.g. eSewa';

  @override
  String get bookCurrencyLabel => 'Currency';

  @override
  String get bookOpeningBalance => 'Opening balance';

  @override
  String get bookCurrencyNote =>
      'An account\'s currency is fixed once it has entries. Use a separate account for each currency.';

  @override
  String get bookCreate => 'Create account';

  @override
  String get ledgerRangeWeek => 'Last 7 days';

  @override
  String get ledgerRangeMonth => 'This month';

  @override
  String get ledgerRangeAll => 'All time';

  @override
  String get ledgerDateRange => 'Date range';

  @override
  String get ledgerFilterCategory => 'Filter by category';

  @override
  String get ledgerAllCategories => 'All categories';

  @override
  String get ledgerFilterMode => 'Filter by payment mode';

  @override
  String get ledgerAllModes => 'All modes';

  @override
  String get ledgerImportStatement => 'Import statement';

  @override
  String get ledgerReport => 'Report';

  @override
  String get ledgerEmptyTitle => 'No entries yet';

  @override
  String get ledgerEmptyBody =>
      'Add your first cash in or cash out below, or import a statement.';

  @override
  String get ledgerNoMatchTitle => 'No entries match';

  @override
  String get ledgerNoMatchBody => 'Try a wider date range or clear filters.';

  @override
  String get ledgerClearFilters => 'Clear filters';

  @override
  String get ledgerNetBalance => 'Net balance';

  @override
  String get ledgerInflow => 'INFLOW';

  @override
  String get ledgerOutflow => 'OUTFLOW';

  @override
  String get entryErrorAmount => 'Enter an amount greater than zero';

  @override
  String get entryErrorTitle => 'Add a title so you can find this later';

  @override
  String get entrySaved => 'Entry saved';

  @override
  String get entryChangesSaved => 'Changes saved';

  @override
  String get entryBalanceUpdated => 'balance updated';

  @override
  String get entryGoalUpdated => 'goal progress updated';

  @override
  String get entryEditTitle => 'Edit entry';

  @override
  String get entryNewCashIn => 'New cash in';

  @override
  String get entryNewCashOut => 'New cash out';

  @override
  String get entryTitleLabel => 'Title';

  @override
  String get entryTitleHint => 'What was it for?';

  @override
  String get entryDateTime => 'Date & time';

  @override
  String get entryNotes => 'Notes';

  @override
  String get entryAddToGoal => 'Add to a goal';

  @override
  String get entrySave => 'Save entry';

  @override
  String entryWhenToday(String date) {
    return 'Today, $date';
  }

  @override
  String get entryDeleteTitle => 'Delete this entry?';

  @override
  String get entryDeleteBody =>
      'The account balance will be recalculated. This can’t be undone.';

  @override
  String get entryDeletedToast => 'Entry deleted · balance recalculated';

  @override
  String get entryReference => 'Reference';

  @override
  String get entryImportedFromLabel => 'Imported from';

  @override
  String get entryGoal => 'Goal';

  @override
  String get entryTitle => 'Entry';

  @override
  String get entryBadgeCashIn => 'CASH IN';

  @override
  String get entryBadgeCashOut => 'CASH OUT';

  @override
  String get entryRunningBalance => 'Running balance';

  @override
  String get entrySplitWithFriends => 'Split this bill with friends';

  @override
  String get entryViewSplitSettled => 'View split · settled';

  @override
  String entryViewSplitToCollect(String amount) {
    return 'View split · $amount to collect';
  }

  @override
  String get entryEditHistory => 'Edit history';

  @override
  String get entryCreated => 'Entry created';

  @override
  String entryImportedFrom(String source) {
    return 'Imported from $source';
  }

  @override
  String get entryDelete => 'Delete entry';

  @override
  String importNoEntriesPdf(String file) {
    return 'No entries found in $file. Scanned, image-only PDFs aren’t supported yet.';
  }

  @override
  String importNoEntriesXls(String file) {
    return 'No entries found in $file. Check it has date, debit and credit columns.';
  }

  @override
  String importSummaryReport(String file) {
    return '$file is a summary report (day, category or payment mode totals) with no individual entries. Export an \"All entries\" report to import it.';
  }

  @override
  String importWrongFileType(String file, String types) {
    return '$file isn’t a supported file. Choose a $types file.';
  }

  @override
  String get pdfPasswordTitle => 'Password protected';

  @override
  String pdfPasswordBody(String file) {
    return '$file is locked. Enter the password your bank gave you to open it.';
  }

  @override
  String get pdfPasswordHint => 'PDF password';

  @override
  String get pdfPasswordWrong => 'That password didn’t work. Try again.';

  @override
  String get pdfPasswordOpen => 'Open';

  @override
  String importReadError(String file, String error) {
    return 'Couldn’t read $file: $error';
  }

  @override
  String importInto(String book) {
    return 'into $book';
  }

  @override
  String get importPdfTitle => 'PDF bank statement';

  @override
  String get importPdfBody =>
      'Text-based PDFs with date, description, withdraw, deposit and balance columns.';

  @override
  String get importPdfAction => 'Choose PDF →';

  @override
  String get importXlsTitle => 'XLS wallet statement';

  @override
  String get importXlsBody =>
      'Legacy .xls exports from wallets. Keeps original descriptions and reference codes.';

  @override
  String get importXlsAction => 'Choose XLS →';

  @override
  String get importTipReview => 'You’ll review everything before it’s saved.';

  @override
  String get importTipDuplicates =>
      'Re-importing the same statement won’t create duplicates.';

  @override
  String get importTipScanned =>
      'Scanned, image-only PDFs aren’t supported yet.';

  @override
  String importImportedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count entries',
      one: 'Imported 1 entry',
    );
    return '$_temp0';
  }

  @override
  String importDuplicatesSkippedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count duplicates skipped',
      one: '1 duplicate skipped',
    );
    return '$_temp0';
  }

  @override
  String get importReviewTitle => 'Review import';

  @override
  String importParsedLines(String file, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
    );
    return '$file · parsed $_temp0';
  }

  @override
  String get importReady => 'Ready to import';

  @override
  String get importDuplicatesSkipped => 'Duplicates skipped';

  @override
  String get importIgnoredLines => 'Non-entry lines';

  @override
  String get importUpToDateTitle => 'Already up to date';

  @override
  String importUpToDateBody(String book) {
    return 'Every entry in this statement is already in $book. Nothing new to import.';
  }

  @override
  String importOpeningWillSet(String opening, String closing) {
    return 'This account is empty, so an opening balance of $opening will be added. After import it matches the statement’s closing balance of $closing.';
  }

  @override
  String importOpeningWillSetFiles(
    String opening,
    String file,
    String balance,
  ) {
    return 'This account is empty, so an opening balance of $opening (from $file) will be added. Its balance after import will be $balance.';
  }

  @override
  String importOpeningInfo(String opening) {
    return 'The statement opens at $opening. This account already has entries, so its balance isn’t changed.';
  }

  @override
  String importFilesParsed(int files, int lines) {
    return '$files files · parsed $lines lines';
  }

  @override
  String importFileCounts(int ready, int duplicates, int ignored) {
    return '$ready ready · $duplicates duplicates · $ignored non-entry';
  }

  @override
  String importWarnMixedSources(String sources) {
    return 'These files come from different sources ($sources). All of them will go into this account.';
  }

  @override
  String importWarnChainGap(
    String from,
    String to,
    String closing,
    String opening,
  ) {
    return '$from ends at $closing, but $to starts at $opening. A statement in between may be missing.';
  }

  @override
  String importPasswordSkipped(String file) {
    return '$file was skipped because no password was entered.';
  }

  @override
  String importFileUnreadable(String file) {
    return 'Couldn’t read $file.';
  }

  @override
  String get importThisBook => 'this account';

  @override
  String get importBackToBook => 'Back to account';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count entries',
      one: 'Import 1 entry',
    );
    return '$_temp0';
  }

  @override
  String importRef(String reference) {
    return 'Ref $reference';
  }

  @override
  String get importDuplicateBadge => 'DUPLICATE';

  @override
  String get calNoEntries => 'No entries on this day.';

  @override
  String get splashOffline => 'Offline-first · your data stays on this phone';

  @override
  String get onboardBooksTitle => 'All your accounts, one pocket';

  @override
  String get onboardBooksBody =>
      'Cash, bank, eSewa, a card or a loan — each account in its own currency.';

  @override
  String get onboardImportTitle => 'Import statements, skip the typing';

  @override
  String get onboardImportBody =>
      'Drop in a PDF or XLS statement. Review it first — duplicates are caught automatically.';

  @override
  String get onboardGoalsTitle => 'Goals and splits that add up';

  @override
  String get onboardGoalsBody =>
      'Tag income to a savings goal, split bills with friends, and always know who owes what.';

  @override
  String get onboardSkip => 'Skip';

  @override
  String onboardPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String onboardArtParsed(int count) {
    return 'Parsed · $count lines';
  }

  @override
  String get onboardArtReady => 'Ready';

  @override
  String get onboardArtDuplicates => 'Duplicates';

  @override
  String get onboardArtSkipped => 'Skipped';

  @override
  String onboardArtImportEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count entries',
      one: 'Import 1 entry',
    );
    return '$_temp0';
  }

  @override
  String onboardArtGoalProgress(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String get profileTitle => 'Your details';

  @override
  String get profileStepTitle => 'Tell us about you';

  @override
  String get profileStepBody =>
      'Used to personalise the app and put your name on exported reports.';

  @override
  String get profileAvatarHint =>
      'Your initials become your avatar. You can add a photo later in Settings.';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileNameHint => 'e.g. Aarav Shrestha';

  @override
  String get profileMobile => 'Mobile number';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePrivacy =>
      'Saved only on this phone. We never upload or share your details.';

  @override
  String get profileValid => 'Valid';

  @override
  String get profileNameRequired => 'Please tell us your name';

  @override
  String get profileEmailInvalid =>
      'That email looks incomplete — fix it or leave it blank';

  @override
  String get profileSaved => 'Details saved';

  @override
  String setupStepOf(int step, int total) {
    return 'STEP $step OF $total';
  }

  @override
  String get setupTitle => 'Let\'s set up your first account';

  @override
  String get setupBody =>
      'Accounts keep money separate — cash, bank, eSewa. Each account keeps its own currency.';

  @override
  String get setupLanguage => 'Language';

  @override
  String get setupBookName => 'Account name';

  @override
  String get setupBookNameHint => 'e.g. Personal';

  @override
  String get setupCurrency => 'Currency';

  @override
  String get setupOpeningBalance => 'Opening balance';

  @override
  String setupSaveFailed(String error) {
    return 'Couldn’t save your account: $error';
  }

  @override
  String get setupWelcome => 'Welcome to Paisa Flow';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsPaymentModes => 'Payment modes';

  @override
  String settingsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get settingsDefaultCurrency => 'Default currency for new accounts';

  @override
  String get settingsDefaultCurrencyTitle => 'Default currency';

  @override
  String get settingsExportAll => 'Export all data';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsSoon => 'SOON';

  @override
  String get settingsStoredTitle => 'Stored only on this phone';

  @override
  String get settingsStoredBody =>
      'No sign-in, no cloud. Make a backup and keep a copy somewhere safe.';

  @override
  String get goalNoDeadline => 'No deadline';

  @override
  String goalDeadlineBy(String date) {
    return 'By $date';
  }

  @override
  String get goalNew => 'New goal';

  @override
  String get goalEdit => 'Edit goal';

  @override
  String get goalSavedAcross => 'Saved across all accounts';

  @override
  String goalOfTarget(String amount) {
    return 'of $amount';
  }

  @override
  String get goalEmptyTitle => 'No goals yet';

  @override
  String get goalEmptyBody =>
      'Set a savings target — an emergency fund, a laptop, Dashain gifts.';

  @override
  String get goalTagHint =>
      'Tag any cash-in entry with a goal and progress updates automatically.';

  @override
  String get goalReachedBadge => 'REACHED';

  @override
  String get goalReached => 'Goal reached';

  @override
  String goalToGo(String amount) {
    return '$amount to go';
  }

  @override
  String get goalNoLinked => 'No linked entries';

  @override
  String goalLinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count linked entries',
      one: '1 linked entry',
    );
    return '$_temp0';
  }

  @override
  String get goalDeadlineKeep => 'Keep current';

  @override
  String goalDeadlineMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get goalNameRequired => 'Give your goal a name';

  @override
  String get goalTargetInvalid => 'Target must be greater than zero';

  @override
  String get goalUpdated => 'Goal updated';

  @override
  String goalCreated(String name) {
    return 'Goal “$name” created';
  }

  @override
  String goalDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get goalDeleteBody =>
      'Linked entries stay in their accounts; they just stop counting toward this goal.';

  @override
  String get goalDeleted => 'Goal deleted';

  @override
  String get goalName => 'Goal name';

  @override
  String get goalNameHint => 'e.g. New scooter';

  @override
  String get goalTargetAmount => 'Target amount';

  @override
  String get goalDeadline => 'Deadline';

  @override
  String get goalCreate => 'Create goal';

  @override
  String get goalDelete => 'Delete goal';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportTypeAll => 'All entries';

  @override
  String get reportTypeDaily => 'Day-wise';

  @override
  String get reportTypeCategory => 'Category-wise';

  @override
  String get reportColumnEntry => 'ENTRY';

  @override
  String get reportColumnDay => 'DAY';

  @override
  String get reportColumnCategory => 'CATEGORY';

  @override
  String get reportColumnMode => 'MODE';

  @override
  String get reportColumnAmount => 'AMOUNT';

  @override
  String get reportFieldDate => 'Date';

  @override
  String get reportFieldTitle => 'Title';

  @override
  String get reportFieldNotes => 'Notes';

  @override
  String get reportFieldBalance => 'Balance';

  @override
  String get reportFieldReference => 'Reference';

  @override
  String reportFieldsToExport(int selected, int total) {
    return 'Fields to export · $selected of $total';
  }

  @override
  String get reportExportPdf => 'Export PDF';

  @override
  String get reportExportExcel => 'Export Excel';

  @override
  String get reportEmpty => 'No entries in this range.';

  @override
  String reportMoreInExport(int count) {
    return '+ $count more in the export';
  }

  @override
  String get reportNet => 'Net';

  @override
  String get insightsTitle => 'Insights';

  @override
  String insightsAllBooks(String currency) {
    return 'All $currency accounts';
  }

  @override
  String get insightsPrevMonth => 'Previous month';

  @override
  String get insightsNextMonth => 'Next month';

  @override
  String insightsActivityOn(String date) {
    return 'Activity · $date';
  }

  @override
  String insightsTransactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get insightsNoActivity => 'No activity on this day.';

  @override
  String get insightsTrends => 'Trends';

  @override
  String get insightsIncome => 'Income';

  @override
  String get insightsSpending => 'Spending';

  @override
  String insightsSpendingSaved(int percent) {
    return 'Spending · $percent% saved';
  }

  @override
  String insightsNetFlow(String month) {
    return 'Net flow · $month';
  }

  @override
  String get insightsCashFlowTrend => 'Cash flow trend';

  @override
  String get insightsLegendIn => 'In';

  @override
  String get insightsLegendOut => 'Out';

  @override
  String insightsBarSemantics(String period, String inflow, String outflow) {
    return '$period: in $inflow, out $outflow';
  }

  @override
  String get insightsWhereItWent => 'Where it went';

  @override
  String get insightsNoSpending => 'No spending in this period.';

  @override
  String get insightsByMode => 'By payment mode';

  @override
  String get splashSubtitle => 'Every paisa, accounted for.';

  @override
  String get profilePhoneRule =>
      'Enter a 10-digit mobile number starting with 9';

  @override
  String get goalDeadlineOneYear => '1 year';

  @override
  String get reportFieldsHint =>
      'Fields apply to the All entries report; summaries list totals.';

  @override
  String get insightsRange7d => '7D';

  @override
  String get insightsRange30d => '30D';

  @override
  String get insightsRange3m => '3M';

  @override
  String get insightsRange1y => '1Y';

  @override
  String historyAmount(String from, String to) {
    return 'Amount $from → $to';
  }

  @override
  String historyTitle(String title) {
    return 'Title changed to “$title”';
  }

  @override
  String historyCategory(String from, String to) {
    return 'Category $from → $to';
  }

  @override
  String historyMode(String from, String to) {
    return 'Payment mode $from → $to';
  }

  @override
  String get historyTypeIn => 'Type changed to cash in';

  @override
  String get historyTypeOut => 'Type changed to cash out';

  @override
  String historyDate(String date) {
    return 'Date changed to $date';
  }

  @override
  String get historyNotes => 'Notes updated';

  @override
  String get historyGoal => 'Goal link updated';

  @override
  String get historyDeleted => 'Entry deleted';

  @override
  String historySplitGroup(String group) {
    return 'Created from $group split';
  }

  @override
  String get historySplitBill => 'Created from split bill';

  @override
  String historySettled(String source) {
    return 'Settled from $source';
  }

  @override
  String get uncategorised => 'Uncategorised';

  @override
  String get notSet => 'Not set';

  @override
  String insightsWeekBucket(int n) {
    return 'W$n';
  }

  @override
  String insightsQuarterBucket(int n) {
    return 'Q$n';
  }

  @override
  String get weekdaysTwo => 'Su,Mo,Tu,We,Th,Fr,Sa';

  @override
  String get accountTypeLabel => 'Account type';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeWallet => 'Wallet';

  @override
  String get accountTypeCard => 'Card';

  @override
  String get accountTypeLoan => 'Loan';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get accountSetType => 'Set type';

  @override
  String get accountTypePrompt => 'Set a type to group your accounts';

  @override
  String accountTypePromptBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts are still “Other”.',
      one: '1 account is still “Other”.',
    );
    return '$_temp0 Pick Bank, Wallet, Card… so assets and liabilities add up right.';
  }

  @override
  String get accountLegacyNote =>
      'This account was made before types existed, so it is “Other” for now.';

  @override
  String get accountLiabilityNote =>
      'Counted as a liability. Its balance shows what you owe, and it is taken off your net worth.';

  @override
  String get accountAmountOwed => 'Amount owed';

  @override
  String get accountBalance => 'Balance';

  @override
  String get accountOutstanding => 'Outstanding';

  @override
  String accountCredit(String amount) {
    return 'Credit $amount';
  }

  @override
  String get accountAssets => 'Assets';

  @override
  String get accountLiabilities => 'Liabilities';

  @override
  String get accountTotal => 'Total';

  @override
  String get accountOwed => 'Owed';

  @override
  String accountOwedAmount(String amount) {
    return 'Owed $amount';
  }

  @override
  String homeNetWorth(String currency) {
    return 'Net worth · $currency';
  }

  @override
  String homeAssetsOwed(String assets, String owed) {
    return 'Assets $assets − Owed $owed';
  }

  @override
  String get homeOtherCurrencies => 'Other currencies';

  @override
  String get later => 'Later';

  @override
  String get homeRecentActivity => 'Recent activity';

  @override
  String get allEntriesTitle => 'All entries';

  @override
  String get feedIncome => 'Income';

  @override
  String get feedExpenses => 'Expenses';

  @override
  String get feedEmptyTitle => 'No entries yet';

  @override
  String get feedEmptyBody =>
      'Add your first cash in or cash out, or import a bank statement. Everything from every account will show up here.';

  @override
  String get feedAddEntry => 'Add an entry';

  @override
  String feedMonthEmptyTitle(String month) {
    return 'Nothing in $month';
  }

  @override
  String get feedMonthEmptyBody =>
      'No entries were recorded in any account this month.';

  @override
  String get feedGoToThisMonth => 'Go to this month';

  @override
  String get feedPreviousMonth => 'Previous month';

  @override
  String get feedNextMonth => 'Next month';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferEditTitle => 'Edit transfer';

  @override
  String get transferFrom => 'From';

  @override
  String get transferTo => 'To';

  @override
  String get transferSwap => 'Swap accounts';

  @override
  String transferAmountIn(String currency) {
    return 'Amount · $currency';
  }

  @override
  String get transferFee => 'Fee';

  @override
  String get transferFeeHint => 'Recorded as cash out in the From account';

  @override
  String get transferNotesHint => 'e.g. Load eSewa';

  @override
  String get transferExplain =>
      'Transfers move money between your own accounts. They are not counted as income or spending.';

  @override
  String get transferCardPay => 'Card bill payment';

  @override
  String get transferWalletLoad => 'Wallet top-up';

  @override
  String get transferCashWithdrawal => 'Cash withdrawal';

  @override
  String get transferLoanRepayment => 'Loan repayment';

  @override
  String transferBalanceChange(String account, String before, String after) {
    return '$account $before → $after';
  }

  @override
  String transferOwedChange(String account, String before, String after) {
    return '$account · Outstanding $before → $after';
  }

  @override
  String transferCrossTitle(String from, String to) {
    return 'Different currencies · $from → $to';
  }

  @override
  String get transferCrossBody =>
      'Enter what left one account and what arrived in the other. Nothing is converted for you.';

  @override
  String transferReceived(String currency) {
    return 'Amount received · $currency';
  }

  @override
  String transferRate(String from, String rate, String to) {
    return '1 $from = $rate $to · worked out from your amounts';
  }

  @override
  String get transferRateNeeded =>
      'Both amounts are needed. The rate is worked out for you.';

  @override
  String get transferErrorSame => 'Pick two different accounts';

  @override
  String get transferErrorReceived => 'Enter the amount that arrived';

  @override
  String get transferNeedTwo =>
      'Add a second account to move money between them.';

  @override
  String get transferSaved => 'Transfer saved · balances updated';

  @override
  String transferRowTitle(String from, String to) {
    return '$from → $to';
  }

  @override
  String get transferDeletedAccount => 'Deleted account';

  @override
  String get transferDelete => 'Delete transfer';

  @override
  String get transferDeleteNote =>
      'Removes it from both accounts, and its fee entry.';

  @override
  String get transferDeleteTitle => 'Delete this transfer?';

  @override
  String get transferDeletedToast => 'Transfer deleted · balances recalculated';

  @override
  String transferFeePart(String from, String to) {
    return 'Part of the transfer $from → $to. Deleting this fee keeps the transfer.';
  }

  @override
  String get transferReceivedShort => 'Received';

  @override
  String get ledgerTransfers => 'TRANSFERS';

  @override
  String get historyTransferCreated => 'Transfer created';

  @override
  String get historyTransferUpdated => 'Transfer updated';

  @override
  String importLooksTransferTo(String account) {
    return 'Looks like a transfer to $account';
  }

  @override
  String importLooksTransferFrom(String account) {
    return 'Looks like a transfer from $account';
  }

  @override
  String get importMakeTransfer => 'Make transfer';

  @override
  String get importWillTransfer =>
      'Will be saved as a transfer · not income or spending';

  @override
  String get importUndo => 'Undo';

  @override
  String get importAsTransfers => 'As transfers';

  @override
  String get tags => 'Tags';

  @override
  String get tagAdd => 'Add tag';

  @override
  String get tagSearchHint => 'Search or create a tag';

  @override
  String tagCreate(String tag) {
    return 'Create #$tag';
  }

  @override
  String get tagUsedBefore => 'Used before';

  @override
  String get tagNoneYet =>
      'No tags yet. Type one above, like #wedding or #japan-trip.';

  @override
  String tagRemove(String tag) {
    return 'Remove #$tag';
  }

  @override
  String get tagsHint =>
      'A tag says what money was for, across any account. Renaming updates every entry; merging moves entries into another tag.';

  @override
  String get tagsEmpty =>
      'No tags yet. Add one here or from the entry form — try #wedding or #japan-trip.';

  @override
  String get tagNew => 'New tag';

  @override
  String tagOpenSummary(String tag) {
    return 'Open #$tag';
  }

  @override
  String tagMerge(String tag) {
    return 'Merge #$tag';
  }

  @override
  String tagDeleteAction(String tag) {
    return 'Delete #$tag';
  }

  @override
  String tagMergeTitle(String tag) {
    return 'Merge #$tag into…';
  }

  @override
  String tagMergeBody(String tag) {
    return 'Entries tagged #$tag move to the tag you pick, and #$tag is removed.';
  }

  @override
  String tagMerged(String from, String to) {
    return '#$from merged into #$to';
  }

  @override
  String tagRenamed(String tag) {
    return 'Renamed to #$tag';
  }

  @override
  String tagDeleteTitle(String tag) {
    return 'Delete #$tag?';
  }

  @override
  String tagDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It is removed from $count entries; the entries stay.',
      one: 'It is removed from 1 entry; the entry stays.',
      zero: 'No entries use it.',
    );
    return '$_temp0';
  }

  @override
  String tagDeleted(String tag) {
    return '#$tag deleted';
  }

  @override
  String get tagSpent => 'Spent';

  @override
  String get tagReceived => 'Received';

  @override
  String get tagEmpty => 'No entries use this tag yet.';

  @override
  String tagRenameTitle(String tag) {
    return 'Rename #$tag';
  }

  @override
  String importTagAll(int count) {
    return 'Tag all $count rows…';
  }

  @override
  String importTaggedAll(String tags) {
    return 'All rows tagged $tags';
  }

  @override
  String get insightsTagsTitle => 'Tags';

  @override
  String get insightsTagsEmpty =>
      'Tag entries (#wedding, #japan-trip) to see what each plan or event cost.';

  @override
  String get insightsTransfersNote =>
      'Transfers between your accounts are left out.';

  @override
  String get historyTags => 'Tags updated';

  @override
  String get clear => 'Clear';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Title, note, amount, reference';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchTip =>
      'Searches every account. Try a shop name, a note, an amount like 5000, or a reference like NEFT-88213.';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String searchNoneTitle(String query) {
    return 'No results for “$query”';
  }

  @override
  String get searchNoneBody =>
      'Nothing in any account matches. Check the spelling, or search an amount without commas.';

  @override
  String get searchClear => 'Clear search';

  @override
  String get searchClearRecent => 'Clear recent searches';

  @override
  String get feedFilterAccount => 'Account';

  @override
  String get feedFilterAccountType => 'Account type';

  @override
  String get feedFilterKind => 'In / out';

  @override
  String get feedAllAccounts => 'All accounts';

  @override
  String get feedAllTypes => 'All account types';

  @override
  String get feedAllTags => 'All tags';

  @override
  String get feedEverything => 'In, out and transfers';

  @override
  String get feedNoMatchBody =>
      'Try another account or category, or clear the filters.';

  @override
  String get entrySaveAnother => 'Save & add another';

  @override
  String get entrySavedKeepGoing => 'Saved · fields kept for the next one';

  @override
  String get templateStar => 'Template';

  @override
  String get templateStarHint => 'Save as a template';

  @override
  String templateSaved(String title, String amount) {
    return 'Saved as template · $title · $amount';
  }

  @override
  String get templateNeedsFields => 'Add an amount and a title first';

  @override
  String get templates => 'Templates';

  @override
  String get templatesHint =>
      'Tap ★ on the entry form to save an entry you repeat. Templates appear at the top of the form, one tap to fill.';

  @override
  String get templatesManage => 'Manage';

  @override
  String get templateUse => 'Use';

  @override
  String templateDelete(String title) {
    return 'Delete template $title';
  }

  @override
  String get templateDeleted => 'Template deleted';

  @override
  String get templatesEmptyTitle => 'No templates yet';

  @override
  String get templatesEmptyBody =>
      'Fill in an entry like “Momo · Rs 450 · Cafe · Cash” and tap ★ to keep it.';

  @override
  String get templatesNewCashOut => 'New cash out';

  @override
  String entrySuggestion(String title) {
    return 'Use “$title”';
  }

  @override
  String get backupTitle => 'Backup & restore';

  @override
  String get backupLast => 'Last backup';

  @override
  String get backupCreate => 'Create backup';

  @override
  String get backupRestore => 'Restore from backup';

  @override
  String get backupIncludes =>
      'Backups include accounts, entries, tags, templates, goals and splits. Keep a copy off this phone — Drive, email or a computer.';

  @override
  String get restoreMerge => 'Merge (skip duplicates)';

  @override
  String get restoreMergeBody =>
      'Adds what is missing. Entries already on this phone stay, duplicates are skipped.';

  @override
  String get restoreReplace => 'Replace everything';

  @override
  String get restoreReplaceBody =>
      'Deletes all data on this phone, then restores the file.';

  @override
  String get restoreReplaceWarnTitle => 'This cannot be undone';

  @override
  String get restoreReplaceWarnBody =>
      'Everything on this phone will be deleted and replaced by the backup.';

  @override
  String get restoreUnderstand => 'I understand. Delete and replace my data.';

  @override
  String get restoreRunning => 'Restoring…';

  @override
  String get restoreDone => 'Restore complete';

  @override
  String get restoreContinue => 'Continue';

  @override
  String get backupNudgeBody =>
      'Your data lives only on this phone. A backup takes 5 seconds.';

  @override
  String get backupNow => 'Back up now';

  @override
  String get restoreFileHas => 'What\'s in this file';

  @override
  String get restoreHow => 'How should we restore?';

  @override
  String get restoreRecommended => 'Recommended';

  @override
  String get restoreGoHome => 'Go to Home';

  @override
  String get restoreTryOther => 'Pick another file';

  @override
  String get restoreRange => 'Date range';

  @override
  String get restoreCreated => 'Created';

  @override
  String get restoreVersion => 'App version';

  @override
  String get restoreErrWrongTitle => 'This isn\'t a Paisa Flow backup';

  @override
  String get restoreErrWrongBody =>
      'Pick a file named like “Paisa Flow 2026-10-11.pfbak”, made in Settings → Backup & restore. To add a bank statement, use Import on an account instead.';

  @override
  String get restoreErrBadTitle => 'This backup is damaged';

  @override
  String get restoreErrBadBody =>
      'The file ends early, so nothing was restored. Try another copy of the backup.';

  @override
  String get restoreErrNewTitle => 'Made with a newer version';

  @override
  String get restoreUnchanged => 'Your data on this phone was not changed.';

  @override
  String get backupProtect => 'Protect with password (recommended)';

  @override
  String get backupProtectBody =>
      'Anyone who gets the file would need this password to restore it.';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupPasswordAgain => 'Type it again';

  @override
  String get backupPasswordLost =>
      'A forgotten password can’t be recovered — not by us, not by anyone. Write it down somewhere safe.';

  @override
  String get backupNoPasswordTitle =>
      'Without a password, the backup is hidden but not truly secure';

  @override
  String get backupNoPasswordBody =>
      'The file is encrypted so other apps can’t read it, but anyone with Paisa Flow could restore it.';

  @override
  String get backupEncrypted =>
      'Backups are compressed and always encrypted. They can only be opened in Paisa Flow.';

  @override
  String get backupPasswordsMatch => 'Passwords match';

  @override
  String get restoreLockedTitle => 'This backup is password-protected';

  @override
  String get restoreLockedBody =>
      'Enter the password you set when you made it.';

  @override
  String get restoreWrongPassword =>
      'Wrong password. Check caps and try again.';

  @override
  String get restoreUnlock => 'Unlock backup';

  @override
  String get restoreForgotPassword =>
      'Forgot it? Passwords can’t be recovered — try a different backup file.';

  @override
  String get backupOnPhone => 'On this phone now';

  @override
  String get restoreKeepOpen =>
      'Keep Paisa Flow open. This takes a few seconds.';

  @override
  String get restoreNotSure =>
      'Not sure? Go back and pick Merge — it never deletes anything.';

  @override
  String backupNudgeTitle(int days) {
    return 'No backup in $days days';
  }

  @override
  String get backupNever => 'Never';

  @override
  String backupDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: 'Yesterday',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String tagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
    );
    return '$_temp0';
  }

  @override
  String get backupCreateProtected => 'Create protected backup';

  @override
  String backupSaved(String file) {
    return 'Backup saved · $file';
  }

  @override
  String backupSaveFailed(String error) {
    return 'Couldn’t save the backup: $error';
  }

  @override
  String get backupPasswordTooShort => 'Use at least 6 characters';

  @override
  String get backupPasswordsDiffer => 'The passwords don’t match';

  @override
  String get backupStrengthWeak => 'Weak';

  @override
  String get backupStrengthOkay => 'Okay';

  @override
  String get backupStrengthStrong => 'Strong';

  @override
  String get backupShowPassword => 'Show password';

  @override
  String get backupHidePassword => 'Hide password';

  @override
  String restoreErrNewBody(String version) {
    return 'This backup is from Paisa Flow $version. Update the app from Play Store, then restore again.';
  }

  @override
  String restoreMergeStat(String added, String existing) {
    return 'Adds $added · $existing already here';
  }

  @override
  String restoreReplaceStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries on this phone will be deleted',
      one: '1 entry on this phone will be deleted',
      zero: 'Nothing on this phone is deleted',
    );
    return '$_temp0';
  }

  @override
  String restoreDoneMerge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries added. Nothing on this phone was removed.',
      one: '1 entry added. Nothing on this phone was removed.',
      zero: 'Everything in the backup was already here. Nothing was removed.',
    );
    return '$_temp0';
  }

  @override
  String restoreDoneReplace(String date) {
    return 'Your data now matches the backup from $date.';
  }

  @override
  String get restoreStepCheck => 'Checking the file';

  @override
  String get restoreStepData => 'Restoring accounts and entries';

  @override
  String get restoreStepBalances => 'Recalculating balances';

  @override
  String get restoreReading => 'Reading the backup…';

  @override
  String get restoreAccountsLabel => 'Accounts';

  @override
  String get restoreEntriesLabel => 'Entries';

  @override
  String get lockTitle => 'App lock';

  @override
  String get lockSetPin => 'Set a 4-digit PIN';

  @override
  String get lockEnterPin => 'Enter your PIN';

  @override
  String get lockConfirmPin => 'Confirm your PIN';

  @override
  String get lockBiometrics => 'Unlock with fingerprint or face';

  @override
  String get lockAfterLabel => 'Lock when the app is in the background';

  @override
  String get lockImmediately => 'Immediately';

  @override
  String get lockAfter1 => 'After 1 minute';

  @override
  String get lockAfter5 => 'After 5 minutes';

  @override
  String get lockChangePin => 'Change PIN';

  @override
  String get lockTurnOff => 'Turn off app lock';

  @override
  String get lockNoRecoveryTitle => 'There is no PIN recovery';

  @override
  String get lockNoRecoveryBody =>
      'Your data lives only on this phone. If you forget your PIN you must reinstall Paisa Flow, and only a backup can bring your data back.';

  @override
  String get lockIntro =>
      'Keep your accounts private with a PIN, fingerprint or face.';

  @override
  String get lockOn => 'App lock is on';

  @override
  String get lockPinsDiffer => 'PINs don\'t match. Try again.';

  @override
  String get lockForgot => 'Forgot PIN?';

  @override
  String get lockGoToBackup => 'Go to Backup & restore';

  @override
  String get lockFeaturePin => '4-digit PIN';

  @override
  String get lockFeatureBiometrics => 'Fingerprint or face unlock';

  @override
  String get lockFeatureSwitcher => 'Hidden in the app switcher';

  @override
  String get lockNow => 'Lock now';

  @override
  String get lockOffNeedsPin =>
      'There is no PIN recovery. Turning the lock off needs your PIN.';

  @override
  String lockWrongPin(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Wrong PIN · $left attempts left',
      one: 'Wrong PIN · 1 attempt left',
    );
    return '$_temp0';
  }

  @override
  String lockTooMany(int seconds) {
    return 'Too many attempts · Try again in ${seconds}s';
  }

  @override
  String lockStep(int step) {
    return 'STEP $step OF 2';
  }

  @override
  String get lockNewPin => 'Enter a new PIN';

  @override
  String get lockCurrentPin => 'Enter your current PIN';

  @override
  String get lockOnToast => 'App lock is on';

  @override
  String get lockOffToast => 'App lock turned off';

  @override
  String get lockChangedToast => 'PIN changed';

  @override
  String get lockBiometricReason => 'Unlock Paisa Flow';

  @override
  String get lockUseBiometrics => 'Use fingerprint or face';

  @override
  String get lockDeleteDigit => 'Delete digit';

  @override
  String lockStatus(String method, String after) {
    return '$method · $after';
  }

  @override
  String get lockMethodPin => 'PIN';

  @override
  String get lockMethodPinBio => 'PIN and fingerprint or face';

  @override
  String get lockHidden => 'Content hidden';

  @override
  String get settingsOn => 'On';

  @override
  String get settingsOff => 'Off';

  @override
  String get emiTitle => 'EMI calculator';

  @override
  String get emiEntryBody => 'Work out the monthly payment and set a reminder';

  @override
  String get emiPrincipal => 'Loan amount (principal)';

  @override
  String get emiRate => 'Interest rate · per year';

  @override
  String get emiTenure => 'Tenure';

  @override
  String get emiTotalInterest => 'Total interest';

  @override
  String get emiTotalPayable => 'Total payable';

  @override
  String get emiRepeat => 'Repeat as a monthly transfer';

  @override
  String get emiRepeatBody =>
      'You’ll get a popup to confirm each EMI. Nothing is added on its own.';

  @override
  String get emiNote =>
      'Estimate using the reducing-balance method. Your bank’s figure may differ slightly because of processing fees and rounding.';

  @override
  String get repeatLabel => 'Repeat';

  @override
  String get repeatConfirmEach => 'You’ll be asked to confirm each one';

  @override
  String get repeatNever => 'Never';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekly => 'Every week';

  @override
  String get repeatMonthly => 'Every month';

  @override
  String get repeatYearly => 'Every year';

  @override
  String repeatSaved(String when) {
    return 'Saved · repeats $when';
  }

  @override
  String get repeatingTitle => 'Repeating entries';

  @override
  String get repeatingHint =>
      'These are never added on their own. When one is due, Paisa Flow asks you to confirm it.';

  @override
  String get repeatingEmpty =>
      'Nothing repeats yet. Pick Repeat on the entry form, or set up a loan EMI.';

  @override
  String repeatingNext(String date) {
    return 'Next: $date';
  }

  @override
  String repeatingStop(String title) {
    return 'Stop repeating $title';
  }

  @override
  String get repeatingStopped => 'Stopped repeating';

  @override
  String dueTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries are due',
      one: '1 entry is due',
    );
    return '$_temp0';
  }

  @override
  String get dueBody =>
      'Ticked ones will be added. Untick anything you didn’t pay.';

  @override
  String get dueToday => 'Due today';

  @override
  String dueDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Due $days days ago',
      one: 'Due yesterday',
    );
    return '$_temp0';
  }

  @override
  String dueAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count entries',
      one: 'Add 1 entry',
      zero: 'Add nothing',
    );
    return '$_temp0';
  }

  @override
  String get dueSkip => 'Skip these';

  @override
  String get dueLater => 'Ask me later';

  @override
  String dueAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries added',
      one: '1 entry added',
      zero: 'Skipped · they come back next time',
    );
    return '$_temp0';
  }

  @override
  String dueEdit(String title) {
    return 'Edit $title before adding';
  }

  @override
  String dueTick(String title) {
    return 'Add $title';
  }

  @override
  String emiOutstanding(String loan, String amount) {
    return '$loan · Outstanding $amount';
  }

  @override
  String emiUseOutstanding(String amount) {
    return 'Use outstanding $amount';
  }

  @override
  String emiYears(int months) {
    return 'years · $months months';
  }

  @override
  String emiYearsChip(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years yrs',
      one: '1 yr',
    );
    return '$_temp0';
  }

  @override
  String emiMonthly(int months) {
    return 'Monthly EMI · $months months';
  }

  @override
  String get emiMonth => 'MONTH';

  @override
  String get emiPrincipalCol => 'PRINCIPAL';

  @override
  String get emiInterestCol => 'INTEREST';

  @override
  String get emiBalanceCol => 'BALANCE';

  @override
  String emiPayFrom(int day) {
    return 'Pay from · day $day of each month';
  }

  @override
  String emiSetUp(String amount) {
    return 'Set up monthly EMI · $amount';
  }

  @override
  String get emiDone => 'Done';

  @override
  String get emiSaved => 'EMI set up · you’ll confirm each one';

  @override
  String get emiErrAmount => 'Enter the loan amount';

  @override
  String get emiErrTenure => 'Enter a tenure of at least 1 month';

  @override
  String get emiErrRate => 'Enter a yearly rate between 0 and 60%';

  @override
  String get emiNoFrom =>
      'Add a bank, cash or wallet account to pay the EMI from.';

  @override
  String get historyRepeated => 'Added from a repeating entry';

  @override
  String get insightsCustomize => 'Customize';

  @override
  String get chartFlow => 'Flow';

  @override
  String get chartCalendar => 'Calendar';

  @override
  String get chartPace => 'Pace';

  @override
  String get chartShowList => 'Show as a list';

  @override
  String get chartShowChart => 'Show as a chart';

  @override
  String get chartsRule =>
      'One currency per chart. Transfers and opening balances are left out.';

  @override
  String flowTitle(String month) {
    return '$month flow';
  }

  @override
  String flowSub(String income, String spent) {
    return '$income in · $spent out';
  }

  @override
  String flowSaved(String amount, int percent) {
    return 'You kept $amount · $percent% of what came in';
  }

  @override
  String flowOver(String amount) {
    return 'You spent $amount more than came in, from your balance';
  }

  @override
  String flowEmpty(String month) {
    return 'Nothing came in or went out in $month.';
  }

  @override
  String get flowIncome => 'Income';

  @override
  String get flowSpending => 'Spending';

  @override
  String get flowSavedNode => 'Saved';

  @override
  String get flowFromBalance => 'From balance';

  @override
  String get flowOthers => 'Others';

  @override
  String get paceTitle => 'Spending pace';

  @override
  String paceSpentBy(String date) {
    return 'Spent by $date';
  }

  @override
  String paceProjected(String amount) {
    return 'On track for $amount this month';
  }

  @override
  String get paceThisMonth => 'This month';

  @override
  String get paceLastMonth => 'Last month';

  @override
  String get paceProjection => 'Projection';

  @override
  String get paceBudget => 'Budget';

  @override
  String paceMore(String amount) {
    return '$amount more than by this day last month';
  }

  @override
  String paceLess(String amount) {
    return '$amount less than by this day last month';
  }

  @override
  String get paceSame => 'About the same as last month by this day';

  @override
  String get paceNoBudget => 'No budget set yet. Budgets are coming soon.';

  @override
  String paceEmpty(String month) {
    return 'No spending in $month or the month before.';
  }

  @override
  String get paceDay => 'Day';

  @override
  String calListTitle(String month) {
    return '$month by day';
  }

  @override
  String get boxesTap => 'Tap a box to see that category';

  @override
  String get placesTitle => 'Top places';

  @override
  String placesSub(String month) {
    return 'Where you spent most in $month';
  }

  @override
  String placesMeta(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$_temp0 · $category';
  }

  @override
  String placesEmpty(String month) {
    return 'No spending in $month yet.';
  }

  @override
  String get layoutTitle => 'Customize Insights';

  @override
  String get layoutIntro =>
      'Reorder the cards with the arrows and hide any you don’t need.';

  @override
  String get layoutPinned => 'Account and month always stay on top';

  @override
  String get layoutReset => 'Reset to default';

  @override
  String layoutHidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards hidden · Customize',
      one: '1 card hidden · Customize',
    );
    return '$_temp0';
  }

  @override
  String get layoutAllHiddenTitle => 'All cards are hidden';

  @override
  String get layoutAllHiddenBody => 'Turn some back on in Customize.';

  @override
  String layoutUp(String card) {
    return 'Move $card up';
  }

  @override
  String layoutDown(String card) {
    return 'Move $card down';
  }

  @override
  String layoutShow(String card) {
    return 'Show $card';
  }

  @override
  String get cardCharts => 'Flow, calendar and pace';

  @override
  String get cardTrends => 'Trends';

  @override
  String get cardModes => 'By payment mode';

  @override
  String get catLast6 => 'Last 6 months';

  @override
  String get catAverage => 'Average';

  @override
  String catMore(String amount) {
    return '$amount more than usual';
  }

  @override
  String catLess(String amount) {
    return '$amount less than usual';
  }

  @override
  String get catUsual => 'About usual';

  @override
  String catEntries(String month) {
    return 'Entries in $month';
  }

  @override
  String catNone(String category, String month) {
    return 'Nothing spent on $category in $month.';
  }

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetScope => 'Budget for';

  @override
  String budgetScopeAll(String currency) {
    return 'All $currency accounts';
  }

  @override
  String budgetMonth(String month) {
    return '$month · resets on the 1st';
  }

  @override
  String get budgetEmptyTitle => 'No budgets yet';

  @override
  String get budgetEmptyBody =>
      'Set a monthly limit for a category or for everything. You’ll see how much is left as you spend.';

  @override
  String get budgetExample => 'For example';

  @override
  String get budgetFirst => 'Set a category budget';

  @override
  String get budgetAddOverall => 'Set an overall budget';

  @override
  String get budgetOverall => 'Overall budget';

  @override
  String get budgetByCategory => 'By category';

  @override
  String get budgetAddCategory => 'Add a category budget';

  @override
  String budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String budgetOver(String amount) {
    return '$amount over';
  }

  @override
  String budgetOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get budgetAllOk => 'Everything is within budget this month.';

  @override
  String budgetNear(String category, int percent) {
    return '$category is at $percent% of its budget';
  }

  @override
  String budgetOverNote(String category, String amount) {
    return '$category is $amount over budget';
  }

  @override
  String get budgetRule =>
      'One currency per budget, never converted. Transfers and opening balances never count. No notifications.';

  @override
  String budgetNoAccountsTitle(String currency) {
    return 'No $currency accounts';
  }

  @override
  String get budgetNoAccountsBody =>
      'Budgets count spending in accounts of this currency. Add one, or pick another scope.';

  @override
  String get budgetAddAccount => 'Add an account';

  @override
  String get budgetOtherScope => 'Pick another';

  @override
  String get budgetNew => 'New budget';

  @override
  String get budgetEdit => 'Edit budget';

  @override
  String get budgetCategoryLabel => 'What it covers';

  @override
  String get budgetHas => 'Has one';

  @override
  String get budgetLimit => 'Monthly limit';

  @override
  String get budgetErrAmount => 'Enter a limit greater than zero';

  @override
  String budgetHint(String amount) {
    return 'You usually spend about $amount';
  }

  @override
  String get budgetHintSub => 'Average of the last 3 months';

  @override
  String get budgetUseIt => 'Use it';

  @override
  String budgetSpentSoFar(String amount) {
    return '$amount spent so far this month';
  }

  @override
  String get budgetNoCarry =>
      'Unused budget doesn’t carry over; each month starts fresh.';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get budgetDelete => 'Delete budget';

  @override
  String get budgetBadgeOver => 'Over';

  @override
  String get paceSetBudget => 'Set a budget';

  @override
  String paceWithin(String amount) {
    return 'Within budget · $amount left';
  }

  @override
  String paceGoingOver(String amount) {
    return 'At this pace you’ll go $amount over budget';
  }

  @override
  String paceOverBudget(String amount) {
    return '$amount over budget';
  }

  @override
  String get paceNoBudgetSet => 'No budget set for this scope.';

  @override
  String catBudgetLine(String amount) {
    return 'Budget $amount';
  }

  @override
  String get catNoBudget => 'No budget for this category.';

  @override
  String subJust(String category) {
    return 'Just $category';
  }

  @override
  String subNone(String category) {
    return '$category (no subcategory)';
  }

  @override
  String get subcategories => 'Subcategories';

  @override
  String get subAdd => 'Add a subcategory';

  @override
  String get subTitle => 'Categories';

  @override
  String get subIntro =>
      'Tap a category to manage its subcategories. Renaming updates every entry.';

  @override
  String subCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '1 subcategory',
      zero: 'No subcategories',
    );
    return '$_temp0';
  }

  @override
  String get subNoneTitle => 'No subcategories yet';

  @override
  String get subNoneBody =>
      'Add one below, like Lunch or Groceries under Food.';

  @override
  String subNewHint(String category) {
    return 'New subcategory under $category';
  }

  @override
  String subDeleteNote(String category) {
    return 'Deleting a subcategory moves its entries up to $category.';
  }

  @override
  String subDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String subDeleteBody(int count, String category) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Its $count entries move up to $category.',
      one: 'Its 1 entry moves up to $category.',
      zero: 'No entries use it.',
    );
    return '$_temp0';
  }

  @override
  String subRename(String name) {
    return 'Rename $name';
  }

  @override
  String subMoveUp(String name) {
    return 'Move $name up';
  }

  @override
  String subMoveDown(String name) {
    return 'Move $name down';
  }

  @override
  String get subAddFor => 'Add a subcategory';

  @override
  String get subPickOne => 'Pick a subcategory';

  @override
  String subEntryUses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get subManageCategories => 'Manage categories';

  @override
  String get amountInvalid =>
      'Enter a number like 1250 or 1250.50 (one decimal point, up to 2 decimals).';

  @override
  String amountTooLarge(String max) {
    return 'Amounts can be up to $max.';
  }
}
