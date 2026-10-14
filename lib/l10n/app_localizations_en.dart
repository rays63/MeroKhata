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
  String get tabBooks => 'Books';

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
      other: '$count books',
      one: '1 book',
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
  String get bookCurrency => 'Book currency';

  @override
  String get book => 'Book';

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
      'Add a book in this currency to record settlements.';

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
      'Linked to the entry you split, so nothing new is recorded in your book.';

  @override
  String splitDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get splitEntriesStay => 'Entries already recorded in your books stay.';

  @override
  String get splitAllSettled => 'All settled';

  @override
  String get splitSettle => 'Settle';

  @override
  String get splitYourBook => 'your book';

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
      'Some balances aren’t settled yet. Entries already recorded in your books stay.';

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
      'Expense deleted · its book entry stays';

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
  String get bookListTitle => 'Books';

  @override
  String get bookNew => 'New book';

  @override
  String get bookSearchHint => 'Search books';

  @override
  String bookSearchNoMatch(String query) {
    return 'No books match “$query”';
  }

  @override
  String bookDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get bookDeleteEmpty => 'This book has no entries.';

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
  String get bookActions => 'Book actions';

  @override
  String get bookRename => 'Rename';

  @override
  String get bookEmptyTitle => 'Start your first book';

  @override
  String get bookEmptyBody =>
      'One book per purpose — daily spending, your shop, a trip abroad. It takes under a minute.';

  @override
  String get bookEmptyImport => 'or import a statement';

  @override
  String get bookCurrencyLocked => 'Currency is fixed once a book has entries';

  @override
  String get bookUntitled => 'Untitled book';

  @override
  String get bookRenamed => 'Book renamed';

  @override
  String bookCreated(String name, String currency) {
    return '“$name” created in $currency';
  }

  @override
  String get bookRenameTitle => 'Rename book';

  @override
  String get bookNameLabel => 'Book name';

  @override
  String get bookNameHint => 'e.g. Kirana Pasal';

  @override
  String get bookCurrencyLabel => 'Currency';

  @override
  String get bookOpeningBalance => 'Opening balance';

  @override
  String get bookCurrencyNote =>
      'A book\'s currency is fixed once it has entries. Use a separate book for each currency.';

  @override
  String get bookCreate => 'Create book';

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
      'The book balance will be recalculated. This can’t be undone.';

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
  String get importThisBook => 'this book';

  @override
  String get importBackToBook => 'Back to book';

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
  String get onboardBooksTitle => 'All your books, one pocket';

  @override
  String get onboardBooksBody =>
      'Keep personal spending, your shop and that trip abroad apart — each book in its own currency.';

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
  String get setupTitle => 'Let\'s set up your first book';

  @override
  String get setupBody =>
      'Books keep money separate — personal, shop, a trip. Each book keeps its own currency.';

  @override
  String get setupLanguage => 'Language';

  @override
  String get setupBookName => 'Book name';

  @override
  String get setupBookNameHint => 'e.g. Personal';

  @override
  String get setupCurrency => 'Currency';

  @override
  String get setupOpeningBalance => 'Opening balance';

  @override
  String setupSaveFailed(String error) {
    return 'Couldn’t save your book: $error';
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
  String get settingsDefaultCurrency => 'Default currency for new books';

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
      'No account, no cloud. Export regularly to keep a backup.';

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
  String get goalSavedAcross => 'Saved across all books';

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
      'Linked entries stay in their books; they just stop counting toward this goal.';

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
    return 'All $currency books';
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
}
