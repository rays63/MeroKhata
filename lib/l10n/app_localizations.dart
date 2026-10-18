import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Paisa Flow'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get tabBooks;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @tabSplit.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get tabSplit;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntry;

  /// No description provided for @cashIn.
  ///
  /// In en, this message translates to:
  /// **'Cash in'**
  String get cashIn;

  /// No description provided for @cashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out'**
  String get cashOut;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @editList.
  ///
  /// In en, this message translates to:
  /// **'Edit list'**
  String get editList;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get greetingEvening;

  /// No description provided for @updatedToday.
  ///
  /// In en, this message translates to:
  /// **'Updated today'**
  String get updatedToday;

  /// No description provided for @updatedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Updated yesterday'**
  String get updatedYesterday;

  /// No description provided for @updatedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {days} days ago'**
  String updatedDaysAgo(int days);

  /// No description provided for @updatedLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Updated last week'**
  String get updatedLastWeek;

  /// No description provided for @updatedOn.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String updatedOn(String date);

  /// No description provided for @entryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String entryCount(int count);

  /// No description provided for @bookCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book} other{{count} books}}'**
  String bookCount(int count);

  /// No description provided for @goalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 goal} other{{count} goals}}'**
  String goalCount(int count);

  /// No description provided for @homeTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance · {currency}'**
  String homeTotalBalance(String currency);

  /// No description provided for @homeCashInMonth.
  ///
  /// In en, this message translates to:
  /// **'Cash in · {month}'**
  String homeCashInMonth(String month);

  /// No description provided for @homeCashOutMonth.
  ///
  /// In en, this message translates to:
  /// **'Cash out · {month}'**
  String homeCashOutMonth(String month);

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @splitABill.
  ///
  /// In en, this message translates to:
  /// **'Split a bill'**
  String get splitABill;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @setSavingsTarget.
  ///
  /// In en, this message translates to:
  /// **'Set a savings target'**
  String get setSavingsTarget;

  /// No description provided for @goalsSaved.
  ///
  /// In en, this message translates to:
  /// **'{amount} saved · {goals}'**
  String goalsSaved(String amount, String goals);

  /// No description provided for @split.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split;

  /// No description provided for @youreOwed.
  ///
  /// In en, this message translates to:
  /// **'You\'re owed'**
  String get youreOwed;

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get youOwe;

  /// No description provided for @recentlyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get recentlyUpdated;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @paymentMode.
  ///
  /// In en, this message translates to:
  /// **'Payment mode'**
  String get paymentMode;

  /// No description provided for @bookCurrency.
  ///
  /// In en, this message translates to:
  /// **'Book currency'**
  String get bookCurrency;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @editListTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {title} list'**
  String editListTitle(String title);

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add new…'**
  String get addNew;

  /// No description provided for @optionAdded.
  ///
  /// In en, this message translates to:
  /// **'“{name}” added'**
  String optionAdded(String name);

  /// No description provided for @optionRemoved.
  ///
  /// In en, this message translates to:
  /// **'“{name}” removed. Entries that use it keep it.'**
  String optionRemoved(String name);

  /// No description provided for @deleteOption.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteOption(String name);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @weekdaysShort.
  ///
  /// In en, this message translates to:
  /// **'S,M,T,W,T,F,S'**
  String get weekdaysShort;

  /// No description provided for @weekdaysLong.
  ///
  /// In en, this message translates to:
  /// **'SUN,MON,TUE,WED,THU,FRI,SAT'**
  String get weekdaysLong;

  /// No description provided for @daySemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}{activity}'**
  String daySemantics(String date, String activity);

  /// No description provided for @hasCashIn.
  ///
  /// In en, this message translates to:
  /// **', cash in'**
  String get hasCashIn;

  /// No description provided for @hasCashOut.
  ///
  /// In en, this message translates to:
  /// **', cash out'**
  String get hasCashOut;

  /// No description provided for @entrySemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {type} {amount}'**
  String entrySemantics(String title, String type, String amount);

  /// No description provided for @balanceShort.
  ///
  /// In en, this message translates to:
  /// **'Bal {amount}'**
  String balanceShort(String amount);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @readyToShare.
  ///
  /// In en, this message translates to:
  /// **'{name} ready to share'**
  String readyToShare(String name);

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Some saved data couldn’t be read. A copy was kept.'**
  String get loadError;

  /// No description provided for @splitYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get splitYou;

  /// No description provided for @splitFriendFallback.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get splitFriendFallback;

  /// No description provided for @splitAddFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a friend'**
  String get splitAddFriendTitle;

  /// No description provided for @splitAddFriendHint.
  ///
  /// In en, this message translates to:
  /// **'Name, e.g. Sita'**
  String get splitAddFriendHint;

  /// No description provided for @splitEqual.
  ///
  /// In en, this message translates to:
  /// **'Equal'**
  String get splitEqual;

  /// No description provided for @splitShares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get splitShares;

  /// No description provided for @splitFewerShares.
  ///
  /// In en, this message translates to:
  /// **'Fewer shares for {name}'**
  String splitFewerShares(String name);

  /// No description provided for @splitMoreShares.
  ///
  /// In en, this message translates to:
  /// **'More shares for {name}'**
  String splitMoreShares(String name);

  /// No description provided for @splitRecordBeforeBook.
  ///
  /// In en, this message translates to:
  /// **'Record {amount} as cash out in'**
  String splitRecordBeforeBook(String amount);

  /// No description provided for @splitRecordAfterBook.
  ///
  /// In en, this message translates to:
  /// **''**
  String get splitRecordAfterBook;

  /// No description provided for @splitSettleUpWith.
  ///
  /// In en, this message translates to:
  /// **'Settle up with {name}'**
  String splitSettleUpWith(String name);

  /// No description provided for @splitPayName.
  ///
  /// In en, this message translates to:
  /// **'Pay {name}'**
  String splitPayName(String name);

  /// No description provided for @splitTheyPayYou.
  ///
  /// In en, this message translates to:
  /// **'{name} pays you {amount}.'**
  String splitTheyPayYou(String name, String amount);

  /// No description provided for @splitYouPayThem.
  ///
  /// In en, this message translates to:
  /// **'You pay {name} {amount}.'**
  String splitYouPayThem(String name, String amount);

  /// No description provided for @splitNoBookForCurrency.
  ///
  /// In en, this message translates to:
  /// **'Add a book in this currency to record settlements.'**
  String get splitNoBookForCurrency;

  /// No description provided for @splitAddAsCashIn.
  ///
  /// In en, this message translates to:
  /// **'Add as cash in to {book}'**
  String splitAddAsCashIn(String book);

  /// No description provided for @splitAddAsCashOut.
  ///
  /// In en, this message translates to:
  /// **'Add as cash out to {book}'**
  String splitAddAsCashOut(String book);

  /// No description provided for @splitSettleAmount.
  ///
  /// In en, this message translates to:
  /// **'Settle {amount}'**
  String splitSettleAmount(String amount);

  /// No description provided for @splitPayAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String splitPayAmount(String amount);

  /// No description provided for @splitGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get splitGroups;

  /// No description provided for @splitBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get splitBills;

  /// No description provided for @splitNoGroupsTitle.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get splitNoGroupsTitle;

  /// No description provided for @splitNoGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Make a group for a trip or a shared flat and keep running balances with everyone in it.'**
  String get splitNoGroupsBody;

  /// No description provided for @splitNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get splitNewGroup;

  /// No description provided for @splitNoBillsTitle.
  ///
  /// In en, this message translates to:
  /// **'No bills yet'**
  String get splitNoBillsTitle;

  /// No description provided for @splitNoBillsBody.
  ///
  /// In en, this message translates to:
  /// **'Split a dinner, a cab or a movie night in a few taps.'**
  String get splitNoBillsBody;

  /// No description provided for @splitPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String splitPeopleCount(int count);

  /// No description provided for @splitExpenseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String splitExpenseCount(int count);

  /// No description provided for @splitGroupOwed.
  ///
  /// In en, this message translates to:
  /// **'owed {amount}'**
  String splitGroupOwed(String amount);

  /// No description provided for @splitYouOweAmount.
  ///
  /// In en, this message translates to:
  /// **'you owe {amount}'**
  String splitYouOweAmount(String amount);

  /// No description provided for @splitOwesYou.
  ///
  /// In en, this message translates to:
  /// **'owes you {amount}'**
  String splitOwesYou(String amount);

  /// No description provided for @splitSettledUp.
  ///
  /// In en, this message translates to:
  /// **'settled up'**
  String get splitSettledUp;

  /// No description provided for @splitBillSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get splitBillSettled;

  /// No description provided for @splitToCollectAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} to collect'**
  String splitToCollectAmount(String amount);

  /// No description provided for @splitBillSavedToast.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Split saved · 1 person owes you {amount}} other{Split saved · {count} people owe you {amount}}}'**
  String splitBillSavedToast(int count, String amount);

  /// No description provided for @splitEnterTotal.
  ///
  /// In en, this message translates to:
  /// **'Enter the total'**
  String get splitEnterTotal;

  /// No description provided for @splitPickFriend.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one friend'**
  String get splitPickFriend;

  /// No description provided for @splitSaveCta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save · 1 owes you {amount}} other{Save · {count} owe you {amount}}}'**
  String splitSaveCta(int count, String amount);

  /// No description provided for @splitWhatFor.
  ///
  /// In en, this message translates to:
  /// **'What\'s it for?'**
  String get splitWhatFor;

  /// No description provided for @splitBillHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Thakali dinner'**
  String get splitBillHint;

  /// No description provided for @splitTotalPaidByYou.
  ///
  /// In en, this message translates to:
  /// **'Total · paid by you'**
  String get splitTotalPaidByYou;

  /// No description provided for @splitBetween.
  ///
  /// In en, this message translates to:
  /// **'Split between'**
  String get splitBetween;

  /// No description provided for @splitLinkedNote.
  ///
  /// In en, this message translates to:
  /// **'Linked to the entry you split, so nothing new is recorded in your book.'**
  String get splitLinkedNote;

  /// No description provided for @splitDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String splitDeleteTitle(String name);

  /// No description provided for @splitEntriesStay.
  ///
  /// In en, this message translates to:
  /// **'Entries already recorded in your books stay.'**
  String get splitEntriesStay;

  /// No description provided for @splitAllSettled.
  ///
  /// In en, this message translates to:
  /// **'All settled'**
  String get splitAllSettled;

  /// No description provided for @splitSettle.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get splitSettle;

  /// No description provided for @splitRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record this payment'**
  String get splitRecordTitle;

  /// No description provided for @splitRecordPaidMessage.
  ///
  /// In en, this message translates to:
  /// **'You paid {amount}. Pick the book to record it in.'**
  String splitRecordPaidMessage(String amount);

  /// No description provided for @splitDontRecord.
  ///
  /// In en, this message translates to:
  /// **'Don’t record in a book'**
  String get splitDontRecord;

  /// No description provided for @splitNoBookInCurrency.
  ///
  /// In en, this message translates to:
  /// **'You don’t have a {currency} book yet.'**
  String splitNoBookInCurrency(String currency);

  /// No description provided for @splitCreateBookIn.
  ///
  /// In en, this message translates to:
  /// **'Create a {currency} book'**
  String splitCreateBookIn(String currency);

  /// No description provided for @splitSettledToast.
  ///
  /// In en, this message translates to:
  /// **'Settled {amount} with {name}'**
  String splitSettledToast(String amount, String name);

  /// No description provided for @splitYourBook.
  ///
  /// In en, this message translates to:
  /// **'your book'**
  String get splitYourBook;

  /// No description provided for @splitReceivedToast.
  ///
  /// In en, this message translates to:
  /// **'{amount} from {name} recorded in {book}'**
  String splitReceivedToast(String amount, String name, String book);

  /// No description provided for @splitPaidToast.
  ///
  /// In en, this message translates to:
  /// **'{amount} to {name} recorded in {book}'**
  String splitPaidToast(String amount, String name, String book);

  /// No description provided for @groupNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the group a name'**
  String get groupNameRequired;

  /// No description provided for @groupFriendRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one friend'**
  String get groupFriendRequired;

  /// No description provided for @groupUpdated.
  ///
  /// In en, this message translates to:
  /// **'Group updated'**
  String get groupUpdated;

  /// No description provided for @groupCreated.
  ///
  /// In en, this message translates to:
  /// **'Group “{name}” created'**
  String groupCreated(String name);

  /// No description provided for @groupDeleteOpenBody.
  ///
  /// In en, this message translates to:
  /// **'Some balances aren’t settled yet. Entries already recorded in your books stay.'**
  String get groupDeleteOpenBody;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupDeleted;

  /// No description provided for @groupEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get groupEdit;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupNameLabel;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pokhara Trip, Flat 3B'**
  String get groupNameHint;

  /// No description provided for @groupMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembers;

  /// No description provided for @groupMemberLocked.
  ///
  /// In en, this message translates to:
  /// **'{name} is part of an expense in this group'**
  String groupMemberLocked(String name);

  /// No description provided for @groupTapAddHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Add to add the friends you share costs with.'**
  String get groupTapAddHint;

  /// No description provided for @groupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get groupCreate;

  /// No description provided for @groupDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get groupDelete;

  /// No description provided for @groupTitle.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupTitle;

  /// No description provided for @groupTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent {amount}'**
  String groupTotalSpent(String amount);

  /// No description provided for @groupBalances.
  ///
  /// In en, this message translates to:
  /// **'Balances'**
  String get groupBalances;

  /// No description provided for @groupExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get groupExpenses;

  /// No description provided for @groupNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet. Add the first one below.'**
  String get groupNoExpenses;

  /// No description provided for @expensePaidByName.
  ///
  /// In en, this message translates to:
  /// **'Paid by {name}'**
  String expensePaidByName(String name);

  /// No description provided for @expenseDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get expenseDelete;

  /// No description provided for @expenseDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Balances will be recalculated without it.'**
  String get expenseDeleteBody;

  /// No description provided for @expenseDeleteSettledBody.
  ///
  /// In en, this message translates to:
  /// **'You’ve already settled up with {names}. Deleting this changes those balances, so someone may end up owing the other.'**
  String expenseDeleteSettledBody(String names);

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @expenseDeletedEntryStays.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted · its book entry stays'**
  String get expenseDeletedEntryStays;

  /// No description provided for @expenseAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get expenseAmountRequired;

  /// No description provided for @expensePickSharers.
  ///
  /// In en, this message translates to:
  /// **'Pick who shares this expense'**
  String get expensePickSharers;

  /// No description provided for @expenseNeedOther.
  ///
  /// In en, this message translates to:
  /// **'Add someone besides the payer to split with'**
  String get expenseNeedOther;

  /// No description provided for @expenseAddedToast.
  ///
  /// In en, this message translates to:
  /// **'Expense added · balances updated'**
  String get expenseAddedToast;

  /// No description provided for @expenseAdd.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get expenseAdd;

  /// No description provided for @expenseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hotel (2 nights)'**
  String get expenseHint;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expensePaidBy.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get expensePaidBy;

  /// No description provided for @billTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get billTitle;

  /// No description provided for @billPaidByYou.
  ///
  /// In en, this message translates to:
  /// **'paid by you'**
  String get billPaidByYou;

  /// No description provided for @billDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete bill'**
  String get billDelete;

  /// No description provided for @billDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bill deleted'**
  String get billDeleted;

  /// No description provided for @billToCollect.
  ///
  /// In en, this message translates to:
  /// **'To collect'**
  String get billToCollect;

  /// No description provided for @billTotalLine.
  ///
  /// In en, this message translates to:
  /// **'Bill total {total} · your share {share}'**
  String billTotalLine(String total, String share);

  /// No description provided for @bookListTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get bookListTitle;

  /// No description provided for @bookNew.
  ///
  /// In en, this message translates to:
  /// **'New book'**
  String get bookNew;

  /// No description provided for @bookSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search books'**
  String get bookSearchHint;

  /// No description provided for @bookSearchNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No books match “{query}”'**
  String bookSearchNoMatch(String query);

  /// No description provided for @bookDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String bookDeleteTitle(String name);

  /// No description provided for @bookDeleteEmpty.
  ///
  /// In en, this message translates to:
  /// **'This book has no entries.'**
  String get bookDeleteEmpty;

  /// No description provided for @bookDeleteWithEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Its 1 entry will be deleted too. This can’t be undone.} other{Its {count} entries will be deleted too. This can’t be undone.}}'**
  String bookDeleteWithEntries(int count);

  /// No description provided for @bookDeleted.
  ///
  /// In en, this message translates to:
  /// **'“{name}” deleted'**
  String bookDeleted(String name);

  /// No description provided for @bookActions.
  ///
  /// In en, this message translates to:
  /// **'Book actions'**
  String get bookActions;

  /// No description provided for @bookRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get bookRename;

  /// No description provided for @bookEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start your first book'**
  String get bookEmptyTitle;

  /// No description provided for @bookEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'One book per purpose — daily spending, your shop, a trip abroad. It takes under a minute.'**
  String get bookEmptyBody;

  /// No description provided for @bookEmptyImport.
  ///
  /// In en, this message translates to:
  /// **'or import a statement'**
  String get bookEmptyImport;

  /// No description provided for @bookCurrencyLocked.
  ///
  /// In en, this message translates to:
  /// **'Currency is fixed once a book has entries'**
  String get bookCurrencyLocked;

  /// No description provided for @bookUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled book'**
  String get bookUntitled;

  /// No description provided for @bookRenamed.
  ///
  /// In en, this message translates to:
  /// **'Book renamed'**
  String get bookRenamed;

  /// No description provided for @bookCreated.
  ///
  /// In en, this message translates to:
  /// **'“{name}” created in {currency}'**
  String bookCreated(String name, String currency);

  /// No description provided for @bookRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename book'**
  String get bookRenameTitle;

  /// No description provided for @bookNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Book name'**
  String get bookNameLabel;

  /// No description provided for @bookNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kirana Pasal'**
  String get bookNameHint;

  /// No description provided for @bookCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get bookCurrencyLabel;

  /// No description provided for @bookOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get bookOpeningBalance;

  /// No description provided for @bookCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'A book\'s currency is fixed once it has entries. Use a separate book for each currency.'**
  String get bookCurrencyNote;

  /// No description provided for @bookCreate.
  ///
  /// In en, this message translates to:
  /// **'Create book'**
  String get bookCreate;

  /// No description provided for @ledgerRangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get ledgerRangeWeek;

  /// No description provided for @ledgerRangeMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get ledgerRangeMonth;

  /// No description provided for @ledgerRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get ledgerRangeAll;

  /// No description provided for @ledgerDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get ledgerDateRange;

  /// No description provided for @ledgerFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by category'**
  String get ledgerFilterCategory;

  /// No description provided for @ledgerAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get ledgerAllCategories;

  /// No description provided for @ledgerFilterMode.
  ///
  /// In en, this message translates to:
  /// **'Filter by payment mode'**
  String get ledgerFilterMode;

  /// No description provided for @ledgerAllModes.
  ///
  /// In en, this message translates to:
  /// **'All modes'**
  String get ledgerAllModes;

  /// No description provided for @ledgerImportStatement.
  ///
  /// In en, this message translates to:
  /// **'Import statement'**
  String get ledgerImportStatement;

  /// No description provided for @ledgerReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get ledgerReport;

  /// No description provided for @ledgerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get ledgerEmptyTitle;

  /// No description provided for @ledgerEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first cash in or cash out below, or import a statement.'**
  String get ledgerEmptyBody;

  /// No description provided for @ledgerNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries match'**
  String get ledgerNoMatchTitle;

  /// No description provided for @ledgerNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try a wider date range or clear filters.'**
  String get ledgerNoMatchBody;

  /// No description provided for @ledgerClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get ledgerClearFilters;

  /// No description provided for @ledgerNetBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance'**
  String get ledgerNetBalance;

  /// No description provided for @ledgerInflow.
  ///
  /// In en, this message translates to:
  /// **'INFLOW'**
  String get ledgerInflow;

  /// No description provided for @ledgerOutflow.
  ///
  /// In en, this message translates to:
  /// **'OUTFLOW'**
  String get ledgerOutflow;

  /// No description provided for @entryErrorAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get entryErrorAmount;

  /// No description provided for @entryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a title so you can find this later'**
  String get entryErrorTitle;

  /// No description provided for @entrySaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get entrySaved;

  /// No description provided for @entryChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get entryChangesSaved;

  /// No description provided for @entryBalanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'balance updated'**
  String get entryBalanceUpdated;

  /// No description provided for @entryGoalUpdated.
  ///
  /// In en, this message translates to:
  /// **'goal progress updated'**
  String get entryGoalUpdated;

  /// No description provided for @entryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get entryEditTitle;

  /// No description provided for @entryNewCashIn.
  ///
  /// In en, this message translates to:
  /// **'New cash in'**
  String get entryNewCashIn;

  /// No description provided for @entryNewCashOut.
  ///
  /// In en, this message translates to:
  /// **'New cash out'**
  String get entryNewCashOut;

  /// No description provided for @entryTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get entryTitleLabel;

  /// No description provided for @entryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What was it for?'**
  String get entryTitleHint;

  /// No description provided for @entryDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get entryDateTime;

  /// No description provided for @entryNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get entryNotes;

  /// No description provided for @entryAddToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add to a goal'**
  String get entryAddToGoal;

  /// No description provided for @entrySave.
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get entrySave;

  /// No description provided for @entryWhenToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String entryWhenToday(String date);

  /// No description provided for @entryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get entryDeleteTitle;

  /// No description provided for @entryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The book balance will be recalculated. This can’t be undone.'**
  String get entryDeleteBody;

  /// No description provided for @entryDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted · balance recalculated'**
  String get entryDeletedToast;

  /// No description provided for @entryReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get entryReference;

  /// No description provided for @entryImportedFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Imported from'**
  String get entryImportedFromLabel;

  /// No description provided for @entryGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get entryGoal;

  /// No description provided for @entryTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get entryTitle;

  /// No description provided for @entryBadgeCashIn.
  ///
  /// In en, this message translates to:
  /// **'CASH IN'**
  String get entryBadgeCashIn;

  /// No description provided for @entryBadgeCashOut.
  ///
  /// In en, this message translates to:
  /// **'CASH OUT'**
  String get entryBadgeCashOut;

  /// No description provided for @entryRunningBalance.
  ///
  /// In en, this message translates to:
  /// **'Running balance'**
  String get entryRunningBalance;

  /// No description provided for @entrySplitWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Split this bill with friends'**
  String get entrySplitWithFriends;

  /// No description provided for @entryViewSplitSettled.
  ///
  /// In en, this message translates to:
  /// **'View split · settled'**
  String get entryViewSplitSettled;

  /// No description provided for @entryViewSplitToCollect.
  ///
  /// In en, this message translates to:
  /// **'View split · {amount} to collect'**
  String entryViewSplitToCollect(String amount);

  /// No description provided for @entryEditHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit history'**
  String get entryEditHistory;

  /// No description provided for @entryCreated.
  ///
  /// In en, this message translates to:
  /// **'Entry created'**
  String get entryCreated;

  /// No description provided for @entryImportedFrom.
  ///
  /// In en, this message translates to:
  /// **'Imported from {source}'**
  String entryImportedFrom(String source);

  /// No description provided for @entryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get entryDelete;

  /// No description provided for @importNoEntriesPdf.
  ///
  /// In en, this message translates to:
  /// **'No entries found in {file}. Scanned, image-only PDFs aren’t supported yet.'**
  String importNoEntriesPdf(String file);

  /// No description provided for @importNoEntriesXls.
  ///
  /// In en, this message translates to:
  /// **'No entries found in {file}. Check it has date, debit and credit columns.'**
  String importNoEntriesXls(String file);

  /// No description provided for @importWrongFileType.
  ///
  /// In en, this message translates to:
  /// **'{file} isn’t a supported file. Choose a {types} file.'**
  String importWrongFileType(String file, String types);

  /// No description provided for @pdfPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password protected'**
  String get pdfPasswordTitle;

  /// No description provided for @pdfPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'{file} is locked. Enter the password your bank gave you to open it.'**
  String pdfPasswordBody(String file);

  /// No description provided for @pdfPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'PDF password'**
  String get pdfPasswordHint;

  /// No description provided for @pdfPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'That password didn’t work. Try again.'**
  String get pdfPasswordWrong;

  /// No description provided for @pdfPasswordOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pdfPasswordOpen;

  /// No description provided for @importReadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t read {file}: {error}'**
  String importReadError(String file, String error);

  /// No description provided for @importInto.
  ///
  /// In en, this message translates to:
  /// **'into {book}'**
  String importInto(String book);

  /// No description provided for @importPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF bank statement'**
  String get importPdfTitle;

  /// No description provided for @importPdfBody.
  ///
  /// In en, this message translates to:
  /// **'Text-based PDFs with date, description, withdraw, deposit and balance columns.'**
  String get importPdfBody;

  /// No description provided for @importPdfAction.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF →'**
  String get importPdfAction;

  /// No description provided for @importXlsTitle.
  ///
  /// In en, this message translates to:
  /// **'XLS wallet statement'**
  String get importXlsTitle;

  /// No description provided for @importXlsBody.
  ///
  /// In en, this message translates to:
  /// **'Legacy .xls exports from wallets. Keeps original descriptions and reference codes.'**
  String get importXlsBody;

  /// No description provided for @importXlsAction.
  ///
  /// In en, this message translates to:
  /// **'Choose XLS →'**
  String get importXlsAction;

  /// No description provided for @importTipReview.
  ///
  /// In en, this message translates to:
  /// **'You’ll review everything before it’s saved.'**
  String get importTipReview;

  /// No description provided for @importTipDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Re-importing the same statement won’t create duplicates.'**
  String get importTipDuplicates;

  /// No description provided for @importTipScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned, image-only PDFs aren’t supported yet.'**
  String get importTipScanned;

  /// No description provided for @importImportedToast.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 entry} other{Imported {count} entries}}'**
  String importImportedToast(int count);

  /// No description provided for @importDuplicatesSkippedToast.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 duplicate skipped} other{{count} duplicates skipped}}'**
  String importDuplicatesSkippedToast(int count);

  /// No description provided for @importReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review import'**
  String get importReviewTitle;

  /// No description provided for @importParsedLines.
  ///
  /// In en, this message translates to:
  /// **'{file} · parsed {count, plural, =1{1 line} other{{count} lines}}'**
  String importParsedLines(String file, int count);

  /// No description provided for @importReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to import'**
  String get importReady;

  /// No description provided for @importDuplicatesSkipped.
  ///
  /// In en, this message translates to:
  /// **'Duplicates skipped'**
  String get importDuplicatesSkipped;

  /// No description provided for @importIgnoredLines.
  ///
  /// In en, this message translates to:
  /// **'Non-entry lines'**
  String get importIgnoredLines;

  /// No description provided for @importUpToDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Already up to date'**
  String get importUpToDateTitle;

  /// No description provided for @importUpToDateBody.
  ///
  /// In en, this message translates to:
  /// **'Every entry in this statement is already in {book}. Nothing new to import.'**
  String importUpToDateBody(String book);

  /// No description provided for @importOpeningWillSet.
  ///
  /// In en, this message translates to:
  /// **'This book is empty, so an opening balance of {opening} will be added. After import it matches the statement’s closing balance of {closing}.'**
  String importOpeningWillSet(String opening, String closing);

  /// No description provided for @importOpeningWillSetFiles.
  ///
  /// In en, this message translates to:
  /// **'This book is empty, so an opening balance of {opening} (from {file}) will be added. Its balance after import will be {balance}.'**
  String importOpeningWillSetFiles(String opening, String file, String balance);

  /// No description provided for @importOpeningInfo.
  ///
  /// In en, this message translates to:
  /// **'The statement opens at {opening}. This book already has entries, so its balance isn’t changed.'**
  String importOpeningInfo(String opening);

  /// No description provided for @importFilesParsed.
  ///
  /// In en, this message translates to:
  /// **'{files} files · parsed {lines} lines'**
  String importFilesParsed(int files, int lines);

  /// No description provided for @importFileCounts.
  ///
  /// In en, this message translates to:
  /// **'{ready} ready · {duplicates} duplicates · {ignored} non-entry'**
  String importFileCounts(int ready, int duplicates, int ignored);

  /// No description provided for @importWarnMixedSources.
  ///
  /// In en, this message translates to:
  /// **'These files come from different sources ({sources}). All of them will go into this book.'**
  String importWarnMixedSources(String sources);

  /// No description provided for @importWarnChainGap.
  ///
  /// In en, this message translates to:
  /// **'{from} ends at {closing}, but {to} starts at {opening}. A statement in between may be missing.'**
  String importWarnChainGap(
    String from,
    String to,
    String closing,
    String opening,
  );

  /// No description provided for @importPasswordSkipped.
  ///
  /// In en, this message translates to:
  /// **'{file} was skipped because no password was entered.'**
  String importPasswordSkipped(String file);

  /// No description provided for @importFileUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t read {file}.'**
  String importFileUnreadable(String file);

  /// No description provided for @importThisBook.
  ///
  /// In en, this message translates to:
  /// **'this book'**
  String get importThisBook;

  /// No description provided for @importBackToBook.
  ///
  /// In en, this message translates to:
  /// **'Back to book'**
  String get importBackToBook;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 entry} other{Import {count} entries}}'**
  String importButton(int count);

  /// No description provided for @importRef.
  ///
  /// In en, this message translates to:
  /// **'Ref {reference}'**
  String importRef(String reference);

  /// No description provided for @importDuplicateBadge.
  ///
  /// In en, this message translates to:
  /// **'DUPLICATE'**
  String get importDuplicateBadge;

  /// No description provided for @calNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries on this day.'**
  String get calNoEntries;

  /// No description provided for @splashOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline-first · your data stays on this phone'**
  String get splashOffline;

  /// No description provided for @onboardBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'All your books, one pocket'**
  String get onboardBooksTitle;

  /// No description provided for @onboardBooksBody.
  ///
  /// In en, this message translates to:
  /// **'Keep personal spending, your shop and that trip abroad apart — each book in its own currency.'**
  String get onboardBooksBody;

  /// No description provided for @onboardImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import statements, skip the typing'**
  String get onboardImportTitle;

  /// No description provided for @onboardImportBody.
  ///
  /// In en, this message translates to:
  /// **'Drop in a PDF or XLS statement. Review it first — duplicates are caught automatically.'**
  String get onboardImportBody;

  /// No description provided for @onboardGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals and splits that add up'**
  String get onboardGoalsTitle;

  /// No description provided for @onboardGoalsBody.
  ///
  /// In en, this message translates to:
  /// **'Tag income to a savings goal, split bills with friends, and always know who owes what.'**
  String get onboardGoalsBody;

  /// No description provided for @onboardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardSkip;

  /// No description provided for @onboardPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String onboardPageOf(int page, int total);

  /// No description provided for @onboardArtParsed.
  ///
  /// In en, this message translates to:
  /// **'Parsed · {count} lines'**
  String onboardArtParsed(int count);

  /// No description provided for @onboardArtReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get onboardArtReady;

  /// No description provided for @onboardArtDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get onboardArtDuplicates;

  /// No description provided for @onboardArtSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get onboardArtSkipped;

  /// No description provided for @onboardArtImportEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 entry} other{Import {count} entries}}'**
  String onboardArtImportEntries(int count);

  /// No description provided for @onboardArtGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String onboardArtGoalProgress(String saved, String target);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Your details'**
  String get profileTitle;

  /// No description provided for @profileStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get profileStepTitle;

  /// No description provided for @profileStepBody.
  ///
  /// In en, this message translates to:
  /// **'Used to personalise the app and put your name on exported reports.'**
  String get profileStepBody;

  /// No description provided for @profileAvatarHint.
  ///
  /// In en, this message translates to:
  /// **'Your initials become your avatar. You can add a photo later in Settings.'**
  String get profileAvatarHint;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Aarav Shrestha'**
  String get profileNameHint;

  /// No description provided for @profileMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get profileMobile;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Saved only on this phone. We never upload or share your details.'**
  String get profilePrivacy;

  /// No description provided for @profileValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get profileValid;

  /// No description provided for @profileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please tell us your name'**
  String get profileNameRequired;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That email looks incomplete — fix it or leave it blank'**
  String get profileEmailInvalid;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Details saved'**
  String get profileSaved;

  /// No description provided for @setupStepOf.
  ///
  /// In en, this message translates to:
  /// **'STEP {step} OF {total}'**
  String setupStepOf(int step, int total);

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your first book'**
  String get setupTitle;

  /// No description provided for @setupBody.
  ///
  /// In en, this message translates to:
  /// **'Books keep money separate — personal, shop, a trip. Each book keeps its own currency.'**
  String get setupBody;

  /// No description provided for @setupLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setupLanguage;

  /// No description provided for @setupBookName.
  ///
  /// In en, this message translates to:
  /// **'Book name'**
  String get setupBookName;

  /// No description provided for @setupBookNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Personal'**
  String get setupBookNameHint;

  /// No description provided for @setupCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get setupCurrency;

  /// No description provided for @setupOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get setupOpeningBalance;

  /// No description provided for @setupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save your book: {error}'**
  String setupSaveFailed(String error);

  /// No description provided for @setupWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Paisa Flow'**
  String get setupWelcome;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// No description provided for @settingsPaymentModes.
  ///
  /// In en, this message translates to:
  /// **'Payment modes'**
  String get settingsPaymentModes;

  /// No description provided for @settingsItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String settingsItemCount(int count);

  /// No description provided for @settingsDefaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency for new books'**
  String get settingsDefaultCurrency;

  /// No description provided for @settingsDefaultCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsDefaultCurrencyTitle;

  /// No description provided for @settingsExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all data'**
  String get settingsExportAll;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsSoon.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get settingsSoon;

  /// No description provided for @settingsStoredTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this phone'**
  String get settingsStoredTitle;

  /// No description provided for @settingsStoredBody.
  ///
  /// In en, this message translates to:
  /// **'No account, no cloud. Export regularly to keep a backup.'**
  String get settingsStoredBody;

  /// No description provided for @goalNoDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get goalNoDeadline;

  /// No description provided for @goalDeadlineBy.
  ///
  /// In en, this message translates to:
  /// **'By {date}'**
  String goalDeadlineBy(String date);

  /// No description provided for @goalNew.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalNew;

  /// No description provided for @goalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalEdit;

  /// No description provided for @goalSavedAcross.
  ///
  /// In en, this message translates to:
  /// **'Saved across all books'**
  String get goalSavedAcross;

  /// No description provided for @goalOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String goalOfTarget(String amount);

  /// No description provided for @goalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get goalEmptyTitle;

  /// No description provided for @goalEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Set a savings target — an emergency fund, a laptop, Dashain gifts.'**
  String get goalEmptyBody;

  /// No description provided for @goalTagHint.
  ///
  /// In en, this message translates to:
  /// **'Tag any cash-in entry with a goal and progress updates automatically.'**
  String get goalTagHint;

  /// No description provided for @goalReachedBadge.
  ///
  /// In en, this message translates to:
  /// **'REACHED'**
  String get goalReachedBadge;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @goalToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String goalToGo(String amount);

  /// No description provided for @goalNoLinked.
  ///
  /// In en, this message translates to:
  /// **'No linked entries'**
  String get goalNoLinked;

  /// No description provided for @goalLinkedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 linked entry} other{{count} linked entries}}'**
  String goalLinkedCount(int count);

  /// No description provided for @goalDeadlineKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get goalDeadlineKeep;

  /// No description provided for @goalDeadlineMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String goalDeadlineMonths(int count);

  /// No description provided for @goalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your goal a name'**
  String get goalNameRequired;

  /// No description provided for @goalTargetInvalid.
  ///
  /// In en, this message translates to:
  /// **'Target must be greater than zero'**
  String get goalTargetInvalid;

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated'**
  String get goalUpdated;

  /// No description provided for @goalCreated.
  ///
  /// In en, this message translates to:
  /// **'Goal “{name}” created'**
  String goalCreated(String name);

  /// No description provided for @goalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String goalDeleteTitle(String name);

  /// No description provided for @goalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Linked entries stay in their books; they just stop counting toward this goal.'**
  String get goalDeleteBody;

  /// No description provided for @goalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted'**
  String get goalDeleted;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalName;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. New scooter'**
  String get goalNameHint;

  /// No description provided for @goalTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get goalTargetAmount;

  /// No description provided for @goalDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get goalDeadline;

  /// No description provided for @goalCreate.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get goalCreate;

  /// No description provided for @goalDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get goalDelete;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All entries'**
  String get reportTypeAll;

  /// No description provided for @reportTypeDaily.
  ///
  /// In en, this message translates to:
  /// **'Day-wise'**
  String get reportTypeDaily;

  /// No description provided for @reportTypeCategory.
  ///
  /// In en, this message translates to:
  /// **'Category-wise'**
  String get reportTypeCategory;

  /// No description provided for @reportColumnEntry.
  ///
  /// In en, this message translates to:
  /// **'ENTRY'**
  String get reportColumnEntry;

  /// No description provided for @reportColumnDay.
  ///
  /// In en, this message translates to:
  /// **'DAY'**
  String get reportColumnDay;

  /// No description provided for @reportColumnCategory.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get reportColumnCategory;

  /// No description provided for @reportColumnMode.
  ///
  /// In en, this message translates to:
  /// **'MODE'**
  String get reportColumnMode;

  /// No description provided for @reportColumnAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get reportColumnAmount;

  /// No description provided for @reportFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reportFieldDate;

  /// No description provided for @reportFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reportFieldTitle;

  /// No description provided for @reportFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get reportFieldNotes;

  /// No description provided for @reportFieldBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get reportFieldBalance;

  /// No description provided for @reportFieldReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reportFieldReference;

  /// No description provided for @reportFieldsToExport.
  ///
  /// In en, this message translates to:
  /// **'Fields to export · {selected} of {total}'**
  String reportFieldsToExport(int selected, int total);

  /// No description provided for @reportExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get reportExportPdf;

  /// No description provided for @reportExportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get reportExportExcel;

  /// No description provided for @reportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries in this range.'**
  String get reportEmpty;

  /// No description provided for @reportMoreInExport.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more in the export'**
  String reportMoreInExport(int count);

  /// No description provided for @reportNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get reportNet;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsAllBooks.
  ///
  /// In en, this message translates to:
  /// **'All {currency} books'**
  String insightsAllBooks(String currency);

  /// No description provided for @insightsPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get insightsPrevMonth;

  /// No description provided for @insightsNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get insightsNextMonth;

  /// No description provided for @insightsActivityOn.
  ///
  /// In en, this message translates to:
  /// **'Activity · {date}'**
  String insightsActivityOn(String date);

  /// No description provided for @insightsTransactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String insightsTransactionCount(int count);

  /// No description provided for @insightsNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity on this day.'**
  String get insightsNoActivity;

  /// No description provided for @insightsTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get insightsTrends;

  /// No description provided for @insightsIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get insightsIncome;

  /// No description provided for @insightsSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get insightsSpending;

  /// No description provided for @insightsSpendingSaved.
  ///
  /// In en, this message translates to:
  /// **'Spending · {percent}% saved'**
  String insightsSpendingSaved(int percent);

  /// No description provided for @insightsNetFlow.
  ///
  /// In en, this message translates to:
  /// **'Net flow · {month}'**
  String insightsNetFlow(String month);

  /// No description provided for @insightsCashFlowTrend.
  ///
  /// In en, this message translates to:
  /// **'Cash flow trend'**
  String get insightsCashFlowTrend;

  /// No description provided for @insightsLegendIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get insightsLegendIn;

  /// No description provided for @insightsLegendOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get insightsLegendOut;

  /// No description provided for @insightsBarSemantics.
  ///
  /// In en, this message translates to:
  /// **'{period}: in {inflow}, out {outflow}'**
  String insightsBarSemantics(String period, String inflow, String outflow);

  /// No description provided for @insightsWhereItWent.
  ///
  /// In en, this message translates to:
  /// **'Where it went'**
  String get insightsWhereItWent;

  /// No description provided for @insightsNoSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending in this period.'**
  String get insightsNoSpending;

  /// No description provided for @insightsByMode.
  ///
  /// In en, this message translates to:
  /// **'By payment mode'**
  String get insightsByMode;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every paisa, accounted for.'**
  String get splashSubtitle;

  /// No description provided for @profilePhoneRule.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit mobile number starting with 9'**
  String get profilePhoneRule;

  /// No description provided for @goalDeadlineOneYear.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get goalDeadlineOneYear;

  /// No description provided for @reportFieldsHint.
  ///
  /// In en, this message translates to:
  /// **'Fields apply to the All entries report; summaries list totals.'**
  String get reportFieldsHint;

  /// No description provided for @insightsRange7d.
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get insightsRange7d;

  /// No description provided for @insightsRange30d.
  ///
  /// In en, this message translates to:
  /// **'30D'**
  String get insightsRange30d;

  /// No description provided for @insightsRange3m.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get insightsRange3m;

  /// No description provided for @insightsRange1y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get insightsRange1y;

  /// No description provided for @historyAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount {from} → {to}'**
  String historyAmount(String from, String to);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Title changed to “{title}”'**
  String historyTitle(String title);

  /// No description provided for @historyCategory.
  ///
  /// In en, this message translates to:
  /// **'Category {from} → {to}'**
  String historyCategory(String from, String to);

  /// No description provided for @historyMode.
  ///
  /// In en, this message translates to:
  /// **'Payment mode {from} → {to}'**
  String historyMode(String from, String to);

  /// No description provided for @historyTypeIn.
  ///
  /// In en, this message translates to:
  /// **'Type changed to cash in'**
  String get historyTypeIn;

  /// No description provided for @historyTypeOut.
  ///
  /// In en, this message translates to:
  /// **'Type changed to cash out'**
  String get historyTypeOut;

  /// No description provided for @historyDate.
  ///
  /// In en, this message translates to:
  /// **'Date changed to {date}'**
  String historyDate(String date);

  /// No description provided for @historyNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes updated'**
  String get historyNotes;

  /// No description provided for @historyGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal link updated'**
  String get historyGoal;

  /// No description provided for @historyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get historyDeleted;

  /// No description provided for @historySplitGroup.
  ///
  /// In en, this message translates to:
  /// **'Created from {group} split'**
  String historySplitGroup(String group);

  /// No description provided for @historySplitBill.
  ///
  /// In en, this message translates to:
  /// **'Created from split bill'**
  String get historySplitBill;

  /// No description provided for @historySettled.
  ///
  /// In en, this message translates to:
  /// **'Settled from {source}'**
  String historySettled(String source);

  /// No description provided for @uncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get uncategorised;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @insightsWeekBucket.
  ///
  /// In en, this message translates to:
  /// **'W{n}'**
  String insightsWeekBucket(int n);

  /// No description provided for @insightsQuarterBucket.
  ///
  /// In en, this message translates to:
  /// **'Q{n}'**
  String insightsQuarterBucket(int n);

  /// No description provided for @weekdaysTwo.
  ///
  /// In en, this message translates to:
  /// **'Su,Mo,Tu,We,Th,Fr,Sa'**
  String get weekdaysTwo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
