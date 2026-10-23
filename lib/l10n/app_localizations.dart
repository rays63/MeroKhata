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
  /// **'Accounts'**
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
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
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
  /// **'Account currency'**
  String get bookCurrency;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Account'**
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
  /// **'Add an account in this currency to record settlements.'**
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
  /// **'Linked to the entry you split, so nothing new is recorded in your account.'**
  String get splitLinkedNote;

  /// No description provided for @splitDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String splitDeleteTitle(String name);

  /// No description provided for @splitEntriesStay.
  ///
  /// In en, this message translates to:
  /// **'Entries already recorded in your accounts stay.'**
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
  /// **'You paid {amount}. Pick the account to record it in.'**
  String splitRecordPaidMessage(String amount);

  /// No description provided for @splitDontRecord.
  ///
  /// In en, this message translates to:
  /// **'Don’t record in an account'**
  String get splitDontRecord;

  /// No description provided for @splitNoBookInCurrency.
  ///
  /// In en, this message translates to:
  /// **'You don’t have a {currency} account yet.'**
  String splitNoBookInCurrency(String currency);

  /// No description provided for @splitCreateBookIn.
  ///
  /// In en, this message translates to:
  /// **'Create a {currency} account'**
  String splitCreateBookIn(String currency);

  /// No description provided for @splitSettledToast.
  ///
  /// In en, this message translates to:
  /// **'Settled {amount} with {name}'**
  String splitSettledToast(String amount, String name);

  /// No description provided for @splitYourBook.
  ///
  /// In en, this message translates to:
  /// **'your account'**
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
  /// **'Some balances aren’t settled yet. Entries already recorded in your accounts stay.'**
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
  /// **'Expense deleted · its account entry stays'**
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
  /// **'Accounts'**
  String get bookListTitle;

  /// No description provided for @bookNew.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get bookNew;

  /// No description provided for @bookSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search accounts'**
  String get bookSearchHint;

  /// No description provided for @bookSearchNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No accounts match “{query}”'**
  String bookSearchNoMatch(String query);

  /// No description provided for @bookDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String bookDeleteTitle(String name);

  /// No description provided for @bookDeleteEmpty.
  ///
  /// In en, this message translates to:
  /// **'This account has no entries.'**
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
  /// **'Account actions'**
  String get bookActions;

  /// No description provided for @bookRename.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get bookRename;

  /// No description provided for @bookEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first account'**
  String get bookEmptyTitle;

  /// No description provided for @bookEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Cash in hand, a NIC Asia account, eSewa or a card. Each one keeps its own balance and currency.'**
  String get bookEmptyBody;

  /// No description provided for @bookEmptyImport.
  ///
  /// In en, this message translates to:
  /// **'or import a statement'**
  String get bookEmptyImport;

  /// No description provided for @bookCurrencyLocked.
  ///
  /// In en, this message translates to:
  /// **'Currency is fixed once an account has entries'**
  String get bookCurrencyLocked;

  /// No description provided for @bookUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled account'**
  String get bookUntitled;

  /// No description provided for @bookRenamed.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get bookRenamed;

  /// No description provided for @bookCreated.
  ///
  /// In en, this message translates to:
  /// **'“{name}” created in {currency}'**
  String bookCreated(String name, String currency);

  /// No description provided for @bookRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get bookRenameTitle;

  /// No description provided for @bookNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get bookNameLabel;

  /// No description provided for @bookNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. eSewa'**
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
  /// **'An account\'s currency is fixed once it has entries. Use a separate account for each currency.'**
  String get bookCurrencyNote;

  /// No description provided for @bookCreate.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
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
  /// **'The account balance will be recalculated. This can’t be undone.'**
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

  /// No description provided for @importSummaryReport.
  ///
  /// In en, this message translates to:
  /// **'{file} is a summary report (day, category or payment mode totals) with no individual entries. Export an \"All entries\" report to import it.'**
  String importSummaryReport(String file);

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
  /// **'This account is empty, so an opening balance of {opening} will be added. After import it matches the statement’s closing balance of {closing}.'**
  String importOpeningWillSet(String opening, String closing);

  /// No description provided for @importOpeningWillSetFiles.
  ///
  /// In en, this message translates to:
  /// **'This account is empty, so an opening balance of {opening} (from {file}) will be added. Its balance after import will be {balance}.'**
  String importOpeningWillSetFiles(String opening, String file, String balance);

  /// No description provided for @importOpeningInfo.
  ///
  /// In en, this message translates to:
  /// **'The statement opens at {opening}. This account already has entries, so its balance isn’t changed.'**
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
  /// **'These files come from different sources ({sources}). All of them will go into this account.'**
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
  /// **'this account'**
  String get importThisBook;

  /// No description provided for @importBackToBook.
  ///
  /// In en, this message translates to:
  /// **'Back to account'**
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
  /// **'All your accounts, one pocket'**
  String get onboardBooksTitle;

  /// No description provided for @onboardBooksBody.
  ///
  /// In en, this message translates to:
  /// **'Cash, bank, eSewa, a card or a loan — each account in its own currency.'**
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
  /// **'Let\'s set up your first account'**
  String get setupTitle;

  /// No description provided for @setupBody.
  ///
  /// In en, this message translates to:
  /// **'Accounts keep money separate — cash, bank, eSewa. Each account keeps its own currency.'**
  String get setupBody;

  /// No description provided for @setupLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setupLanguage;

  /// No description provided for @setupBookName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
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
  /// **'Couldn’t save your account: {error}'**
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
  /// **'Default currency for new accounts'**
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
  /// **'No sign-in, no cloud. Make a backup and keep a copy somewhere safe.'**
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
  /// **'Saved across all accounts'**
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
  /// **'Linked entries stay in their accounts; they just stop counting toward this goal.'**
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
  /// **'All {currency} accounts'**
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

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountTypeLabel;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountTypeBank;

  /// No description provided for @accountTypeWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get accountTypeWallet;

  /// No description provided for @accountTypeCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get accountTypeCard;

  /// No description provided for @accountTypeLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get accountTypeLoan;

  /// No description provided for @accountTypeSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get accountTypeSavings;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @accountSetType.
  ///
  /// In en, this message translates to:
  /// **'Set type'**
  String get accountSetType;

  /// No description provided for @accountTypePrompt.
  ///
  /// In en, this message translates to:
  /// **'Set a type to group your accounts'**
  String get accountTypePrompt;

  /// No description provided for @accountTypePromptBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account is still “Other”.} other{{count} accounts are still “Other”.}} Pick Bank, Wallet, Card… so assets and liabilities add up right.'**
  String accountTypePromptBody(int count);

  /// No description provided for @accountLegacyNote.
  ///
  /// In en, this message translates to:
  /// **'This account was made before types existed, so it is “Other” for now.'**
  String get accountLegacyNote;

  /// No description provided for @accountLiabilityNote.
  ///
  /// In en, this message translates to:
  /// **'Counted as a liability. Its balance shows what you owe, and it is taken off your net worth.'**
  String get accountLiabilityNote;

  /// No description provided for @accountAmountOwed.
  ///
  /// In en, this message translates to:
  /// **'Amount owed'**
  String get accountAmountOwed;

  /// No description provided for @accountBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get accountBalance;

  /// No description provided for @accountOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get accountOutstanding;

  /// No description provided for @accountCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit {amount}'**
  String accountCredit(String amount);

  /// No description provided for @accountAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get accountAssets;

  /// No description provided for @accountLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get accountLiabilities;

  /// No description provided for @accountTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get accountTotal;

  /// No description provided for @accountOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get accountOwed;

  /// No description provided for @accountOwedAmount.
  ///
  /// In en, this message translates to:
  /// **'Owed {amount}'**
  String accountOwedAmount(String amount);

  /// No description provided for @homeNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth · {currency}'**
  String homeNetWorth(String currency);

  /// No description provided for @homeAssetsOwed.
  ///
  /// In en, this message translates to:
  /// **'Assets {assets} − Owed {owed}'**
  String homeAssetsOwed(String assets, String owed);

  /// No description provided for @homeOtherCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Other currencies'**
  String get homeOtherCurrencies;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get homeRecentActivity;

  /// No description provided for @allEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'All entries'**
  String get allEntriesTitle;

  /// No description provided for @feedIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get feedIncome;

  /// No description provided for @feedExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get feedExpenses;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first cash in or cash out, or import a bank statement. Everything from every account will show up here.'**
  String get feedEmptyBody;

  /// No description provided for @feedAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add an entry'**
  String get feedAddEntry;

  /// No description provided for @feedMonthEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {month}'**
  String feedMonthEmptyTitle(String month);

  /// No description provided for @feedMonthEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No entries were recorded in any account this month.'**
  String get feedMonthEmptyBody;

  /// No description provided for @feedGoToThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Go to this month'**
  String get feedGoToThisMonth;

  /// No description provided for @feedPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get feedPreviousMonth;

  /// No description provided for @feedNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get feedNextMonth;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @transferEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transfer'**
  String get transferEditTitle;

  /// No description provided for @transferFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get transferFrom;

  /// No description provided for @transferTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get transferTo;

  /// No description provided for @transferSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap accounts'**
  String get transferSwap;

  /// No description provided for @transferAmountIn.
  ///
  /// In en, this message translates to:
  /// **'Amount · {currency}'**
  String transferAmountIn(String currency);

  /// No description provided for @transferFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get transferFee;

  /// No description provided for @transferFeeHint.
  ///
  /// In en, this message translates to:
  /// **'Recorded as cash out in the From account'**
  String get transferFeeHint;

  /// No description provided for @transferNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Load eSewa'**
  String get transferNotesHint;

  /// No description provided for @transferExplain.
  ///
  /// In en, this message translates to:
  /// **'Transfers move money between your own accounts. They are not counted as income or spending.'**
  String get transferExplain;

  /// No description provided for @transferCardPay.
  ///
  /// In en, this message translates to:
  /// **'Card bill payment'**
  String get transferCardPay;

  /// No description provided for @transferWalletLoad.
  ///
  /// In en, this message translates to:
  /// **'Wallet top-up'**
  String get transferWalletLoad;

  /// No description provided for @transferCashWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Cash withdrawal'**
  String get transferCashWithdrawal;

  /// No description provided for @transferLoanRepayment.
  ///
  /// In en, this message translates to:
  /// **'Loan repayment'**
  String get transferLoanRepayment;

  /// No description provided for @transferBalanceChange.
  ///
  /// In en, this message translates to:
  /// **'{account} {before} → {after}'**
  String transferBalanceChange(String account, String before, String after);

  /// No description provided for @transferOwedChange.
  ///
  /// In en, this message translates to:
  /// **'{account} · Outstanding {before} → {after}'**
  String transferOwedChange(String account, String before, String after);

  /// No description provided for @transferCrossTitle.
  ///
  /// In en, this message translates to:
  /// **'Different currencies · {from} → {to}'**
  String transferCrossTitle(String from, String to);

  /// No description provided for @transferCrossBody.
  ///
  /// In en, this message translates to:
  /// **'Enter what left one account and what arrived in the other. Nothing is converted for you.'**
  String get transferCrossBody;

  /// No description provided for @transferReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount received · {currency}'**
  String transferReceived(String currency);

  /// No description provided for @transferRate.
  ///
  /// In en, this message translates to:
  /// **'1 {from} = {rate} {to} · worked out from your amounts'**
  String transferRate(String from, String rate, String to);

  /// No description provided for @transferRateNeeded.
  ///
  /// In en, this message translates to:
  /// **'Both amounts are needed. The rate is worked out for you.'**
  String get transferRateNeeded;

  /// No description provided for @transferErrorSame.
  ///
  /// In en, this message translates to:
  /// **'Pick two different accounts'**
  String get transferErrorSame;

  /// No description provided for @transferErrorReceived.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount that arrived'**
  String get transferErrorReceived;

  /// No description provided for @transferNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Add a second account to move money between them.'**
  String get transferNeedTwo;

  /// No description provided for @transferSaved.
  ///
  /// In en, this message translates to:
  /// **'Transfer saved · balances updated'**
  String get transferSaved;

  /// No description provided for @transferRowTitle.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String transferRowTitle(String from, String to);

  /// No description provided for @transferDeletedAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleted account'**
  String get transferDeletedAccount;

  /// No description provided for @transferDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete transfer'**
  String get transferDelete;

  /// No description provided for @transferDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Removes it from both accounts, and its fee entry.'**
  String get transferDeleteNote;

  /// No description provided for @transferDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transfer?'**
  String get transferDeleteTitle;

  /// No description provided for @transferDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Transfer deleted · balances recalculated'**
  String get transferDeletedToast;

  /// No description provided for @transferFeePart.
  ///
  /// In en, this message translates to:
  /// **'Part of the transfer {from} → {to}. Deleting this fee keeps the transfer.'**
  String transferFeePart(String from, String to);

  /// No description provided for @transferReceivedShort.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get transferReceivedShort;

  /// No description provided for @ledgerTransfers.
  ///
  /// In en, this message translates to:
  /// **'TRANSFERS'**
  String get ledgerTransfers;

  /// No description provided for @historyTransferCreated.
  ///
  /// In en, this message translates to:
  /// **'Transfer created'**
  String get historyTransferCreated;

  /// No description provided for @historyTransferUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transfer updated'**
  String get historyTransferUpdated;

  /// No description provided for @importLooksTransferTo.
  ///
  /// In en, this message translates to:
  /// **'Looks like a transfer to {account}'**
  String importLooksTransferTo(String account);

  /// No description provided for @importLooksTransferFrom.
  ///
  /// In en, this message translates to:
  /// **'Looks like a transfer from {account}'**
  String importLooksTransferFrom(String account);

  /// No description provided for @importMakeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Make transfer'**
  String get importMakeTransfer;

  /// No description provided for @importWillTransfer.
  ///
  /// In en, this message translates to:
  /// **'Will be saved as a transfer · not income or spending'**
  String get importWillTransfer;

  /// No description provided for @importUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get importUndo;

  /// No description provided for @importAsTransfers.
  ///
  /// In en, this message translates to:
  /// **'As transfers'**
  String get importAsTransfers;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagAdd.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get tagAdd;

  /// No description provided for @tagSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search or create a tag'**
  String get tagSearchHint;

  /// No description provided for @tagCreate.
  ///
  /// In en, this message translates to:
  /// **'Create #{tag}'**
  String tagCreate(String tag);

  /// No description provided for @tagUsedBefore.
  ///
  /// In en, this message translates to:
  /// **'Used before'**
  String get tagUsedBefore;

  /// No description provided for @tagNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Type one above, like #wedding or #japan-trip.'**
  String get tagNoneYet;

  /// No description provided for @tagRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove #{tag}'**
  String tagRemove(String tag);

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'A tag says what money was for, across any account. Renaming updates every entry; merging moves entries into another tag.'**
  String get tagsHint;

  /// No description provided for @tagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Add one here or from the entry form — try #wedding or #japan-trip.'**
  String get tagsEmpty;

  /// No description provided for @tagNew.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get tagNew;

  /// No description provided for @tagOpenSummary.
  ///
  /// In en, this message translates to:
  /// **'Open #{tag}'**
  String tagOpenSummary(String tag);

  /// No description provided for @tagMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge #{tag}'**
  String tagMerge(String tag);

  /// No description provided for @tagDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete #{tag}'**
  String tagDeleteAction(String tag);

  /// No description provided for @tagMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge #{tag} into…'**
  String tagMergeTitle(String tag);

  /// No description provided for @tagMergeBody.
  ///
  /// In en, this message translates to:
  /// **'Entries tagged #{tag} move to the tag you pick, and #{tag} is removed.'**
  String tagMergeBody(String tag);

  /// No description provided for @tagMerged.
  ///
  /// In en, this message translates to:
  /// **'#{from} merged into #{to}'**
  String tagMerged(String from, String to);

  /// No description provided for @tagRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed to #{tag}'**
  String tagRenamed(String tag);

  /// No description provided for @tagDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete #{tag}?'**
  String tagDeleteTitle(String tag);

  /// No description provided for @tagDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries use it.} =1{It is removed from 1 entry; the entry stays.} other{It is removed from {count} entries; the entries stay.}}'**
  String tagDeleteBody(int count);

  /// No description provided for @tagDeleted.
  ///
  /// In en, this message translates to:
  /// **'#{tag} deleted'**
  String tagDeleted(String tag);

  /// No description provided for @tagSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get tagSpent;

  /// No description provided for @tagReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get tagReceived;

  /// No description provided for @tagEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries use this tag yet.'**
  String get tagEmpty;

  /// No description provided for @tagRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename #{tag}'**
  String tagRenameTitle(String tag);

  /// No description provided for @importTagAll.
  ///
  /// In en, this message translates to:
  /// **'Tag all {count} rows…'**
  String importTagAll(int count);

  /// No description provided for @importTaggedAll.
  ///
  /// In en, this message translates to:
  /// **'All rows tagged {tags}'**
  String importTaggedAll(String tags);

  /// No description provided for @insightsTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get insightsTagsTitle;

  /// No description provided for @insightsTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tag entries (#wedding, #japan-trip) to see what each plan or event cost.'**
  String get insightsTagsEmpty;

  /// No description provided for @insightsTransfersNote.
  ///
  /// In en, this message translates to:
  /// **'Transfers between your accounts are left out.'**
  String get insightsTransfersNote;

  /// No description provided for @historyTags.
  ///
  /// In en, this message translates to:
  /// **'Tags updated'**
  String get historyTags;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, note, amount, reference'**
  String get searchHint;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// No description provided for @searchTip.
  ///
  /// In en, this message translates to:
  /// **'Searches every account. Try a shop name, a note, an amount like 5000, or a reference like NEFT-88213.'**
  String get searchTip;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResults(int count);

  /// No description provided for @searchNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String searchNoneTitle(String query);

  /// No description provided for @searchNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing in any account matches. Check the spelling, or search an amount without commas.'**
  String get searchNoneBody;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @searchClearRecent.
  ///
  /// In en, this message translates to:
  /// **'Clear recent searches'**
  String get searchClearRecent;

  /// No description provided for @feedFilterAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get feedFilterAccount;

  /// No description provided for @feedFilterAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get feedFilterAccountType;

  /// No description provided for @feedFilterKind.
  ///
  /// In en, this message translates to:
  /// **'In / out'**
  String get feedFilterKind;

  /// No description provided for @feedAllAccounts.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get feedAllAccounts;

  /// No description provided for @feedAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All account types'**
  String get feedAllTypes;

  /// No description provided for @feedAllTags.
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get feedAllTags;

  /// No description provided for @feedEverything.
  ///
  /// In en, this message translates to:
  /// **'In, out and transfers'**
  String get feedEverything;

  /// No description provided for @feedNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Try another account or category, or clear the filters.'**
  String get feedNoMatchBody;

  /// No description provided for @entrySaveAnother.
  ///
  /// In en, this message translates to:
  /// **'Save & add another'**
  String get entrySaveAnother;

  /// No description provided for @entrySavedKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Saved · fields kept for the next one'**
  String get entrySavedKeepGoing;

  /// No description provided for @templateStar.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get templateStar;

  /// No description provided for @templateStarHint.
  ///
  /// In en, this message translates to:
  /// **'Save as a template'**
  String get templateStarHint;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved as template · {title} · {amount}'**
  String templateSaved(String title, String amount);

  /// No description provided for @templateNeedsFields.
  ///
  /// In en, this message translates to:
  /// **'Add an amount and a title first'**
  String get templateNeedsFields;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @templatesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap ★ on the entry form to save an entry you repeat. Templates appear at the top of the form, one tap to fill.'**
  String get templatesHint;

  /// No description provided for @templatesManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get templatesManage;

  /// No description provided for @templateUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get templateUse;

  /// No description provided for @templateDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete template {title}'**
  String templateDelete(String title);

  /// No description provided for @templateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleted;

  /// No description provided for @templatesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get templatesEmptyTitle;

  /// No description provided for @templatesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Fill in an entry like “Momo · Rs 450 · Cafe · Cash” and tap ★ to keep it.'**
  String get templatesEmptyBody;

  /// No description provided for @templatesNewCashOut.
  ///
  /// In en, this message translates to:
  /// **'New cash out'**
  String get templatesNewCashOut;

  /// No description provided for @entrySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Use “{title}”'**
  String entrySuggestion(String title);

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupTitle;

  /// No description provided for @backupLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get backupLast;

  /// No description provided for @backupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupCreate;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get backupRestore;

  /// No description provided for @backupIncludes.
  ///
  /// In en, this message translates to:
  /// **'Backups include accounts, entries, tags, templates, goals and splits. Keep a copy off this phone — Drive, email or a computer.'**
  String get backupIncludes;

  /// No description provided for @restoreMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge (skip duplicates)'**
  String get restoreMerge;

  /// No description provided for @restoreMergeBody.
  ///
  /// In en, this message translates to:
  /// **'Adds what is missing. Entries already on this phone stay, duplicates are skipped.'**
  String get restoreMergeBody;

  /// No description provided for @restoreReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace everything'**
  String get restoreReplace;

  /// No description provided for @restoreReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Deletes all data on this phone, then restores the file.'**
  String get restoreReplaceBody;

  /// No description provided for @restoreReplaceWarnTitle.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone'**
  String get restoreReplaceWarnTitle;

  /// No description provided for @restoreReplaceWarnBody.
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone will be deleted and replaced by the backup.'**
  String get restoreReplaceWarnBody;

  /// No description provided for @restoreUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand. Delete and replace my data.'**
  String get restoreUnderstand;

  /// No description provided for @restoreRunning.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get restoreRunning;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Restore complete'**
  String get restoreDone;

  /// No description provided for @restoreContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get restoreContinue;

  /// No description provided for @backupNudgeBody.
  ///
  /// In en, this message translates to:
  /// **'Your data lives only on this phone. A backup takes 5 seconds.'**
  String get backupNudgeBody;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backupNow;

  /// No description provided for @restoreFileHas.
  ///
  /// In en, this message translates to:
  /// **'What\'s in this file'**
  String get restoreFileHas;

  /// No description provided for @restoreHow.
  ///
  /// In en, this message translates to:
  /// **'How should we restore?'**
  String get restoreHow;

  /// No description provided for @restoreRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get restoreRecommended;

  /// No description provided for @restoreGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get restoreGoHome;

  /// No description provided for @restoreTryOther.
  ///
  /// In en, this message translates to:
  /// **'Pick another file'**
  String get restoreTryOther;

  /// No description provided for @restoreRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get restoreRange;

  /// No description provided for @restoreCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get restoreCreated;

  /// No description provided for @restoreVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get restoreVersion;

  /// No description provided for @restoreErrWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a Paisa Flow backup'**
  String get restoreErrWrongTitle;

  /// No description provided for @restoreErrWrongBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a file named like “Paisa Flow 2026-10-11.pfbak”, made in Settings → Backup & restore. To add a bank statement, use Import on an account instead.'**
  String get restoreErrWrongBody;

  /// No description provided for @restoreErrBadTitle.
  ///
  /// In en, this message translates to:
  /// **'This backup is damaged'**
  String get restoreErrBadTitle;

  /// No description provided for @restoreErrBadBody.
  ///
  /// In en, this message translates to:
  /// **'The file ends early, so nothing was restored. Try another copy of the backup.'**
  String get restoreErrBadBody;

  /// No description provided for @restoreErrNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Made with a newer version'**
  String get restoreErrNewTitle;

  /// No description provided for @restoreUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Your data on this phone was not changed.'**
  String get restoreUnchanged;

  /// No description provided for @backupProtect.
  ///
  /// In en, this message translates to:
  /// **'Protect with password (recommended)'**
  String get backupProtect;

  /// No description provided for @backupProtectBody.
  ///
  /// In en, this message translates to:
  /// **'Anyone who gets the file would need this password to restore it.'**
  String get backupProtectBody;

  /// No description provided for @backupPassword.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPassword;

  /// No description provided for @backupPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Type it again'**
  String get backupPasswordAgain;

  /// No description provided for @backupPasswordLost.
  ///
  /// In en, this message translates to:
  /// **'A forgotten password can’t be recovered — not by us, not by anyone. Write it down somewhere safe.'**
  String get backupPasswordLost;

  /// No description provided for @backupNoPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Without a password, the backup is hidden but not truly secure'**
  String get backupNoPasswordTitle;

  /// No description provided for @backupNoPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'The file is encrypted so other apps can’t read it, but anyone with Paisa Flow could restore it.'**
  String get backupNoPasswordBody;

  /// No description provided for @backupEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Backups are compressed and always encrypted. They can only be opened in Paisa Flow.'**
  String get backupEncrypted;

  /// No description provided for @backupPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get backupPasswordsMatch;

  /// No description provided for @restoreLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'This backup is password-protected'**
  String get restoreLockedTitle;

  /// No description provided for @restoreLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the password you set when you made it.'**
  String get restoreLockedBody;

  /// No description provided for @restoreWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Check caps and try again.'**
  String get restoreWrongPassword;

  /// No description provided for @restoreUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock backup'**
  String get restoreUnlock;

  /// No description provided for @restoreForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot it? Passwords can’t be recovered — try a different backup file.'**
  String get restoreForgotPassword;

  /// No description provided for @backupOnPhone.
  ///
  /// In en, this message translates to:
  /// **'On this phone now'**
  String get backupOnPhone;

  /// No description provided for @restoreKeepOpen.
  ///
  /// In en, this message translates to:
  /// **'Keep Paisa Flow open. This takes a few seconds.'**
  String get restoreKeepOpen;

  /// No description provided for @restoreNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure? Go back and pick Merge — it never deletes anything.'**
  String get restoreNotSure;

  /// No description provided for @backupNudgeTitle.
  ///
  /// In en, this message translates to:
  /// **'No backup in {days} days'**
  String backupNudgeTitle(int days);

  /// No description provided for @backupNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get backupNever;

  /// No description provided for @backupDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Today} =1{Yesterday} other{{days} days ago}}'**
  String backupDaysAgo(int days);

  /// No description provided for @tagCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tag} other{{count} tags}}'**
  String tagCount(int count);

  /// No description provided for @backupCreateProtected.
  ///
  /// In en, this message translates to:
  /// **'Create protected backup'**
  String get backupCreateProtected;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved · {file}'**
  String backupSaved(String file);

  /// No description provided for @backupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the backup: {error}'**
  String backupSaveFailed(String error);

  /// No description provided for @backupPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get backupPasswordTooShort;

  /// No description provided for @backupPasswordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'The passwords don’t match'**
  String get backupPasswordsDiffer;

  /// No description provided for @backupStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get backupStrengthWeak;

  /// No description provided for @backupStrengthOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get backupStrengthOkay;

  /// No description provided for @backupStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get backupStrengthStrong;

  /// No description provided for @backupShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get backupShowPassword;

  /// No description provided for @backupHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get backupHidePassword;

  /// No description provided for @restoreErrNewBody.
  ///
  /// In en, this message translates to:
  /// **'This backup is from Paisa Flow {version}. Update the app from Play Store, then restore again.'**
  String restoreErrNewBody(String version);

  /// No description provided for @restoreMergeStat.
  ///
  /// In en, this message translates to:
  /// **'Adds {added} · {existing} already here'**
  String restoreMergeStat(String added, String existing);

  /// No description provided for @restoreReplaceStat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing on this phone is deleted} =1{1 entry on this phone will be deleted} other{{count} entries on this phone will be deleted}}'**
  String restoreReplaceStat(int count);

  /// No description provided for @restoreDoneMerge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Everything in the backup was already here. Nothing was removed.} =1{1 entry added. Nothing on this phone was removed.} other{{count} entries added. Nothing on this phone was removed.}}'**
  String restoreDoneMerge(int count);

  /// No description provided for @restoreDoneReplace.
  ///
  /// In en, this message translates to:
  /// **'Your data now matches the backup from {date}.'**
  String restoreDoneReplace(String date);

  /// No description provided for @restoreStepCheck.
  ///
  /// In en, this message translates to:
  /// **'Checking the file'**
  String get restoreStepCheck;

  /// No description provided for @restoreStepData.
  ///
  /// In en, this message translates to:
  /// **'Restoring accounts and entries'**
  String get restoreStepData;

  /// No description provided for @restoreStepBalances.
  ///
  /// In en, this message translates to:
  /// **'Recalculating balances'**
  String get restoreStepBalances;

  /// No description provided for @restoreReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the backup…'**
  String get restoreReading;

  /// No description provided for @restoreAccountsLabel.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get restoreAccountsLabel;

  /// No description provided for @restoreEntriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get restoreEntriesLabel;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get lockTitle;

  /// No description provided for @lockSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set a 4-digit PIN'**
  String get lockSetPin;

  /// No description provided for @lockEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get lockEnterPin;

  /// No description provided for @lockConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get lockConfirmPin;

  /// No description provided for @lockBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Unlock with fingerprint or face'**
  String get lockBiometrics;

  /// No description provided for @lockAfterLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock when the app is in the background'**
  String get lockAfterLabel;

  /// No description provided for @lockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get lockImmediately;

  /// No description provided for @lockAfter1.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get lockAfter1;

  /// No description provided for @lockAfter5.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get lockAfter5;

  /// No description provided for @lockChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get lockChangePin;

  /// No description provided for @lockTurnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off app lock'**
  String get lockTurnOff;

  /// No description provided for @lockNoRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'There is no PIN recovery'**
  String get lockNoRecoveryTitle;

  /// No description provided for @lockNoRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Your data lives only on this phone. If you forget your PIN you must reinstall Paisa Flow, and only a backup can bring your data back.'**
  String get lockNoRecoveryBody;

  /// No description provided for @lockIntro.
  ///
  /// In en, this message translates to:
  /// **'Keep your accounts private with a PIN, fingerprint or face.'**
  String get lockIntro;

  /// No description provided for @lockOn.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get lockOn;

  /// No description provided for @lockPinsDiffer.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Try again.'**
  String get lockPinsDiffer;

  /// No description provided for @lockForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get lockForgot;

  /// No description provided for @lockGoToBackup.
  ///
  /// In en, this message translates to:
  /// **'Go to Backup & restore'**
  String get lockGoToBackup;

  /// No description provided for @lockFeaturePin.
  ///
  /// In en, this message translates to:
  /// **'4-digit PIN'**
  String get lockFeaturePin;

  /// No description provided for @lockFeatureBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint or face unlock'**
  String get lockFeatureBiometrics;

  /// No description provided for @lockFeatureSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Hidden in the app switcher'**
  String get lockFeatureSwitcher;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// No description provided for @lockOffNeedsPin.
  ///
  /// In en, this message translates to:
  /// **'There is no PIN recovery. Turning the lock off needs your PIN.'**
  String get lockOffNeedsPin;

  /// No description provided for @lockWrongPin.
  ///
  /// In en, this message translates to:
  /// **'{left, plural, =1{Wrong PIN · 1 attempt left} other{Wrong PIN · {left} attempts left}}'**
  String lockWrongPin(int left);

  /// No description provided for @lockTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts · Try again in {seconds}s'**
  String lockTooMany(int seconds);

  /// No description provided for @lockStep.
  ///
  /// In en, this message translates to:
  /// **'STEP {step} OF 2'**
  String lockStep(int step);

  /// No description provided for @lockNewPin.
  ///
  /// In en, this message translates to:
  /// **'Enter a new PIN'**
  String get lockNewPin;

  /// No description provided for @lockCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get lockCurrentPin;

  /// No description provided for @lockOnToast.
  ///
  /// In en, this message translates to:
  /// **'App lock is on'**
  String get lockOnToast;

  /// No description provided for @lockOffToast.
  ///
  /// In en, this message translates to:
  /// **'App lock turned off'**
  String get lockOffToast;

  /// No description provided for @lockChangedToast.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get lockChangedToast;

  /// No description provided for @lockBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Paisa Flow'**
  String get lockBiometricReason;

  /// No description provided for @lockUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face'**
  String get lockUseBiometrics;

  /// No description provided for @lockDeleteDigit.
  ///
  /// In en, this message translates to:
  /// **'Delete digit'**
  String get lockDeleteDigit;

  /// No description provided for @lockStatus.
  ///
  /// In en, this message translates to:
  /// **'{method} · {after}'**
  String lockStatus(String method, String after);

  /// No description provided for @lockMethodPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get lockMethodPin;

  /// No description provided for @lockMethodPinBio.
  ///
  /// In en, this message translates to:
  /// **'PIN and fingerprint or face'**
  String get lockMethodPinBio;

  /// No description provided for @lockHidden.
  ///
  /// In en, this message translates to:
  /// **'Content hidden'**
  String get lockHidden;

  /// No description provided for @settingsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOff;

  /// No description provided for @emiTitle.
  ///
  /// In en, this message translates to:
  /// **'EMI calculator'**
  String get emiTitle;

  /// No description provided for @emiEntryBody.
  ///
  /// In en, this message translates to:
  /// **'Work out the monthly payment and set a reminder'**
  String get emiEntryBody;

  /// No description provided for @emiPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Loan amount (principal)'**
  String get emiPrincipal;

  /// No description provided for @emiRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate · per year'**
  String get emiRate;

  /// No description provided for @emiTenure.
  ///
  /// In en, this message translates to:
  /// **'Tenure'**
  String get emiTenure;

  /// No description provided for @emiTotalInterest.
  ///
  /// In en, this message translates to:
  /// **'Total interest'**
  String get emiTotalInterest;

  /// No description provided for @emiTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total payable'**
  String get emiTotalPayable;

  /// No description provided for @emiRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat as a monthly transfer'**
  String get emiRepeat;

  /// No description provided for @emiRepeatBody.
  ///
  /// In en, this message translates to:
  /// **'You’ll get a popup to confirm each EMI. Nothing is added on its own.'**
  String get emiRepeatBody;

  /// No description provided for @emiNote.
  ///
  /// In en, this message translates to:
  /// **'Estimate using the reducing-balance method. Your bank’s figure may differ slightly because of processing fees and rounding.'**
  String get emiNote;

  /// No description provided for @repeatLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatLabel;

  /// No description provided for @repeatConfirmEach.
  ///
  /// In en, this message translates to:
  /// **'You’ll be asked to confirm each one'**
  String get repeatConfirmEach;

  /// No description provided for @repeatNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeatNever;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get repeatYearly;

  /// No description provided for @repeatSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved · repeats {when}'**
  String repeatSaved(String when);

  /// No description provided for @repeatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeating entries'**
  String get repeatingTitle;

  /// No description provided for @repeatingHint.
  ///
  /// In en, this message translates to:
  /// **'These are never added on their own. When one is due, Paisa Flow asks you to confirm it.'**
  String get repeatingHint;

  /// No description provided for @repeatingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing repeats yet. Pick Repeat on the entry form, or set up a loan EMI.'**
  String get repeatingEmpty;

  /// No description provided for @repeatingNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String repeatingNext(String date);

  /// No description provided for @repeatingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating {title}'**
  String repeatingStop(String title);

  /// No description provided for @repeatingStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped repeating'**
  String get repeatingStopped;

  /// No description provided for @dueTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry is due} other{{count} entries are due}}'**
  String dueTitle(int count);

  /// No description provided for @dueBody.
  ///
  /// In en, this message translates to:
  /// **'Ticked ones will be added. Untick anything you didn’t pay.'**
  String get dueBody;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Due yesterday} other{Due {days} days ago}}'**
  String dueDaysAgo(int days);

  /// No description provided for @dueAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Add nothing} =1{Add 1 entry} other{Add {count} entries}}'**
  String dueAdd(int count);

  /// No description provided for @dueSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip these'**
  String get dueSkip;

  /// No description provided for @dueLater.
  ///
  /// In en, this message translates to:
  /// **'Ask me later'**
  String get dueLater;

  /// No description provided for @dueAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Skipped · they come back next time} =1{1 entry added} other{{count} entries added}}'**
  String dueAdded(int count);

  /// No description provided for @dueEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit {title} before adding'**
  String dueEdit(String title);

  /// No description provided for @dueTick.
  ///
  /// In en, this message translates to:
  /// **'Add {title}'**
  String dueTick(String title);

  /// No description provided for @emiOutstanding.
  ///
  /// In en, this message translates to:
  /// **'{loan} · Outstanding {amount}'**
  String emiOutstanding(String loan, String amount);

  /// No description provided for @emiUseOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Use outstanding {amount}'**
  String emiUseOutstanding(String amount);

  /// No description provided for @emiYears.
  ///
  /// In en, this message translates to:
  /// **'years · {months} months'**
  String emiYears(int months);

  /// No description provided for @emiYearsChip.
  ///
  /// In en, this message translates to:
  /// **'{years, plural, =1{1 yr} other{{years} yrs}}'**
  String emiYearsChip(int years);

  /// No description provided for @emiMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly EMI · {months} months'**
  String emiMonthly(int months);

  /// No description provided for @emiMonth.
  ///
  /// In en, this message translates to:
  /// **'MONTH'**
  String get emiMonth;

  /// No description provided for @emiPrincipalCol.
  ///
  /// In en, this message translates to:
  /// **'PRINCIPAL'**
  String get emiPrincipalCol;

  /// No description provided for @emiInterestCol.
  ///
  /// In en, this message translates to:
  /// **'INTEREST'**
  String get emiInterestCol;

  /// No description provided for @emiBalanceCol.
  ///
  /// In en, this message translates to:
  /// **'BALANCE'**
  String get emiBalanceCol;

  /// No description provided for @emiPayFrom.
  ///
  /// In en, this message translates to:
  /// **'Pay from · day {day} of each month'**
  String emiPayFrom(int day);

  /// No description provided for @emiSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up monthly EMI · {amount}'**
  String emiSetUp(String amount);

  /// No description provided for @emiDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get emiDone;

  /// No description provided for @emiSaved.
  ///
  /// In en, this message translates to:
  /// **'EMI set up · you’ll confirm each one'**
  String get emiSaved;

  /// No description provided for @emiErrAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the loan amount'**
  String get emiErrAmount;

  /// No description provided for @emiErrTenure.
  ///
  /// In en, this message translates to:
  /// **'Enter a tenure of at least 1 month'**
  String get emiErrTenure;

  /// No description provided for @emiErrRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a yearly rate between 0 and 60%'**
  String get emiErrRate;

  /// No description provided for @emiNoFrom.
  ///
  /// In en, this message translates to:
  /// **'Add a bank, cash or wallet account to pay the EMI from.'**
  String get emiNoFrom;

  /// No description provided for @historyRepeated.
  ///
  /// In en, this message translates to:
  /// **'Added from a repeating entry'**
  String get historyRepeated;

  /// No description provided for @insightsCustomize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get insightsCustomize;

  /// No description provided for @chartFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get chartFlow;

  /// No description provided for @chartCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get chartCalendar;

  /// No description provided for @chartPace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get chartPace;

  /// No description provided for @chartShowList.
  ///
  /// In en, this message translates to:
  /// **'Show as a list'**
  String get chartShowList;

  /// No description provided for @chartShowChart.
  ///
  /// In en, this message translates to:
  /// **'Show as a chart'**
  String get chartShowChart;

  /// No description provided for @chartsRule.
  ///
  /// In en, this message translates to:
  /// **'One currency per chart. Transfers and opening balances are left out.'**
  String get chartsRule;

  /// No description provided for @flowTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} flow'**
  String flowTitle(String month);

  /// No description provided for @flowSub.
  ///
  /// In en, this message translates to:
  /// **'{income} in · {spent} out'**
  String flowSub(String income, String spent);

  /// No description provided for @flowSaved.
  ///
  /// In en, this message translates to:
  /// **'You kept {amount} · {percent}% of what came in'**
  String flowSaved(String amount, int percent);

  /// No description provided for @flowOver.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} more than came in, from your balance'**
  String flowOver(String amount);

  /// No description provided for @flowEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing came in or went out in {month}.'**
  String flowEmpty(String month);

  /// No description provided for @flowIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get flowIncome;

  /// No description provided for @flowSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get flowSpending;

  /// No description provided for @flowSavedNode.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get flowSavedNode;

  /// No description provided for @flowFromBalance.
  ///
  /// In en, this message translates to:
  /// **'From balance'**
  String get flowFromBalance;

  /// No description provided for @flowOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get flowOthers;

  /// No description provided for @paceTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending pace'**
  String get paceTitle;

  /// No description provided for @paceSpentBy.
  ///
  /// In en, this message translates to:
  /// **'Spent by {date}'**
  String paceSpentBy(String date);

  /// No description provided for @paceProjected.
  ///
  /// In en, this message translates to:
  /// **'On track for {amount} this month'**
  String paceProjected(String amount);

  /// No description provided for @paceThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get paceThisMonth;

  /// No description provided for @paceLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get paceLastMonth;

  /// No description provided for @paceProjection.
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get paceProjection;

  /// No description provided for @paceBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get paceBudget;

  /// No description provided for @paceMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than by this day last month'**
  String paceMore(String amount);

  /// No description provided for @paceLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less than by this day last month'**
  String paceLess(String amount);

  /// No description provided for @paceSame.
  ///
  /// In en, this message translates to:
  /// **'About the same as last month by this day'**
  String get paceSame;

  /// No description provided for @paceNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget set yet. Budgets are coming soon.'**
  String get paceNoBudget;

  /// No description provided for @paceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No spending in {month} or the month before.'**
  String paceEmpty(String month);

  /// No description provided for @paceDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get paceDay;

  /// No description provided for @calListTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} by day'**
  String calListTitle(String month);

  /// No description provided for @boxesTap.
  ///
  /// In en, this message translates to:
  /// **'Tap a box to see that category'**
  String get boxesTap;

  /// No description provided for @placesTitle.
  ///
  /// In en, this message translates to:
  /// **'Top places'**
  String get placesTitle;

  /// No description provided for @placesSub.
  ///
  /// In en, this message translates to:
  /// **'Where you spent most in {month}'**
  String placesSub(String month);

  /// No description provided for @placesMeta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment} other{{count} payments}} · {category}'**
  String placesMeta(int count, String category);

  /// No description provided for @placesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No spending in {month} yet.'**
  String placesEmpty(String month);

  /// No description provided for @layoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Insights'**
  String get layoutTitle;

  /// No description provided for @layoutIntro.
  ///
  /// In en, this message translates to:
  /// **'Reorder the cards with the arrows and hide any you don’t need.'**
  String get layoutIntro;

  /// No description provided for @layoutPinned.
  ///
  /// In en, this message translates to:
  /// **'Account and month always stay on top'**
  String get layoutPinned;

  /// No description provided for @layoutReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get layoutReset;

  /// No description provided for @layoutHidden.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card hidden · Customize} other{{count} cards hidden · Customize}}'**
  String layoutHidden(int count);

  /// No description provided for @layoutAllHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'All cards are hidden'**
  String get layoutAllHiddenTitle;

  /// No description provided for @layoutAllHiddenBody.
  ///
  /// In en, this message translates to:
  /// **'Turn some back on in Customize.'**
  String get layoutAllHiddenBody;

  /// No description provided for @layoutUp.
  ///
  /// In en, this message translates to:
  /// **'Move {card} up'**
  String layoutUp(String card);

  /// No description provided for @layoutDown.
  ///
  /// In en, this message translates to:
  /// **'Move {card} down'**
  String layoutDown(String card);

  /// No description provided for @layoutShow.
  ///
  /// In en, this message translates to:
  /// **'Show {card}'**
  String layoutShow(String card);

  /// No description provided for @cardCharts.
  ///
  /// In en, this message translates to:
  /// **'Flow, calendar and pace'**
  String get cardCharts;

  /// No description provided for @cardTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get cardTrends;

  /// No description provided for @cardModes.
  ///
  /// In en, this message translates to:
  /// **'By payment mode'**
  String get cardModes;

  /// No description provided for @catLast6.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get catLast6;

  /// No description provided for @catAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get catAverage;

  /// No description provided for @catMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than usual'**
  String catMore(String amount);

  /// No description provided for @catLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less than usual'**
  String catLess(String amount);

  /// No description provided for @catUsual.
  ///
  /// In en, this message translates to:
  /// **'About usual'**
  String get catUsual;

  /// No description provided for @catEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries in {month}'**
  String catEntries(String month);

  /// No description provided for @catNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing spent on {category} in {month}.'**
  String catNone(String category, String month);

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @budgetScope.
  ///
  /// In en, this message translates to:
  /// **'Budget for'**
  String get budgetScope;

  /// No description provided for @budgetScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All {currency} accounts'**
  String budgetScopeAll(String currency);

  /// No description provided for @budgetMonth.
  ///
  /// In en, this message translates to:
  /// **'{month} · resets on the 1st'**
  String budgetMonth(String month);

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get budgetEmptyTitle;

  /// No description provided for @budgetEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit for a category or for everything. You’ll see how much is left as you spend.'**
  String get budgetEmptyBody;

  /// No description provided for @budgetExample.
  ///
  /// In en, this message translates to:
  /// **'For example'**
  String get budgetExample;

  /// No description provided for @budgetFirst.
  ///
  /// In en, this message translates to:
  /// **'Set a category budget'**
  String get budgetFirst;

  /// No description provided for @budgetAddOverall.
  ///
  /// In en, this message translates to:
  /// **'Set an overall budget'**
  String get budgetAddOverall;

  /// No description provided for @budgetOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall budget'**
  String get budgetOverall;

  /// No description provided for @budgetByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get budgetByCategory;

  /// No description provided for @budgetAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a category budget'**
  String get budgetAddCategory;

  /// No description provided for @budgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String budgetLeft(String amount);

  /// No description provided for @budgetOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String budgetOver(String amount);

  /// No description provided for @budgetOf.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String budgetOf(String spent, String limit);

  /// No description provided for @budgetAllOk.
  ///
  /// In en, this message translates to:
  /// **'Everything is within budget this month.'**
  String get budgetAllOk;

  /// No description provided for @budgetNear.
  ///
  /// In en, this message translates to:
  /// **'{category} is at {percent}% of its budget'**
  String budgetNear(String category, int percent);

  /// No description provided for @budgetOverNote.
  ///
  /// In en, this message translates to:
  /// **'{category} is {amount} over budget'**
  String budgetOverNote(String category, String amount);

  /// No description provided for @budgetRule.
  ///
  /// In en, this message translates to:
  /// **'One currency per budget, never converted. Transfers and opening balances never count. No notifications.'**
  String get budgetRule;

  /// No description provided for @budgetNoAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'No {currency} accounts'**
  String budgetNoAccountsTitle(String currency);

  /// No description provided for @budgetNoAccountsBody.
  ///
  /// In en, this message translates to:
  /// **'Budgets count spending in accounts of this currency. Add one, or pick another scope.'**
  String get budgetNoAccountsBody;

  /// No description provided for @budgetAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add an account'**
  String get budgetAddAccount;

  /// No description provided for @budgetOtherScope.
  ///
  /// In en, this message translates to:
  /// **'Pick another'**
  String get budgetOtherScope;

  /// No description provided for @budgetNew.
  ///
  /// In en, this message translates to:
  /// **'New budget'**
  String get budgetNew;

  /// No description provided for @budgetEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get budgetEdit;

  /// No description provided for @budgetCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'What it covers'**
  String get budgetCategoryLabel;

  /// No description provided for @budgetHas.
  ///
  /// In en, this message translates to:
  /// **'Has one'**
  String get budgetHas;

  /// No description provided for @budgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get budgetLimit;

  /// No description provided for @budgetErrAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a limit greater than zero'**
  String get budgetErrAmount;

  /// No description provided for @budgetHint.
  ///
  /// In en, this message translates to:
  /// **'You usually spend about {amount}'**
  String budgetHint(String amount);

  /// No description provided for @budgetHintSub.
  ///
  /// In en, this message translates to:
  /// **'Average of the last 3 months'**
  String get budgetHintSub;

  /// No description provided for @budgetUseIt.
  ///
  /// In en, this message translates to:
  /// **'Use it'**
  String get budgetUseIt;

  /// No description provided for @budgetSpentSoFar.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent so far this month'**
  String budgetSpentSoFar(String amount);

  /// No description provided for @budgetNoCarry.
  ///
  /// In en, this message translates to:
  /// **'Unused budget doesn’t carry over; each month starts fresh.'**
  String get budgetNoCarry;

  /// No description provided for @budgetSaved.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetSaved;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @budgetDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete budget'**
  String get budgetDelete;

  /// No description provided for @budgetBadgeOver.
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get budgetBadgeOver;

  /// No description provided for @paceSetBudget.
  ///
  /// In en, this message translates to:
  /// **'Set a budget'**
  String get paceSetBudget;

  /// No description provided for @paceWithin.
  ///
  /// In en, this message translates to:
  /// **'Within budget · {amount} left'**
  String paceWithin(String amount);

  /// No description provided for @paceGoingOver.
  ///
  /// In en, this message translates to:
  /// **'At this pace you’ll go {amount} over budget'**
  String paceGoingOver(String amount);

  /// No description provided for @paceOverBudget.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String paceOverBudget(String amount);

  /// No description provided for @paceNoBudgetSet.
  ///
  /// In en, this message translates to:
  /// **'No budget set for this scope.'**
  String get paceNoBudgetSet;

  /// No description provided for @catBudgetLine.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount}'**
  String catBudgetLine(String amount);

  /// No description provided for @catNoBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget for this category.'**
  String get catNoBudget;

  /// No description provided for @subJust.
  ///
  /// In en, this message translates to:
  /// **'Just {category}'**
  String subJust(String category);

  /// No description provided for @subNone.
  ///
  /// In en, this message translates to:
  /// **'{category} (no subcategory)'**
  String subNone(String category);

  /// No description provided for @subcategories.
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get subcategories;

  /// No description provided for @subAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a subcategory'**
  String get subAdd;

  /// No description provided for @subTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get subTitle;

  /// No description provided for @subIntro.
  ///
  /// In en, this message translates to:
  /// **'Tap a category to manage its subcategories. Renaming updates every entry.'**
  String get subIntro;

  /// No description provided for @subCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No subcategories} =1{1 subcategory} other{{count} subcategories}}'**
  String subCount(int count);

  /// No description provided for @subNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No subcategories yet'**
  String get subNoneTitle;

  /// No description provided for @subNoneBody.
  ///
  /// In en, this message translates to:
  /// **'Add one below, like Lunch or Groceries under Food.'**
  String get subNoneBody;

  /// No description provided for @subNewHint.
  ///
  /// In en, this message translates to:
  /// **'New subcategory under {category}'**
  String subNewHint(String category);

  /// No description provided for @subDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Deleting a subcategory moves its entries up to {category}.'**
  String subDeleteNote(String category);

  /// No description provided for @subDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String subDeleteTitle(String name);

  /// No description provided for @subDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries use it.} =1{Its 1 entry moves up to {category}.} other{Its {count} entries move up to {category}.}}'**
  String subDeleteBody(int count, String category);

  /// No description provided for @subRename.
  ///
  /// In en, this message translates to:
  /// **'Rename {name}'**
  String subRename(String name);

  /// No description provided for @subMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move {name} up'**
  String subMoveUp(String name);

  /// No description provided for @subMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move {name} down'**
  String subMoveDown(String name);

  /// No description provided for @subAddFor.
  ///
  /// In en, this message translates to:
  /// **'Add a subcategory'**
  String get subAddFor;

  /// No description provided for @subPickOne.
  ///
  /// In en, this message translates to:
  /// **'Pick a subcategory'**
  String get subPickOne;

  /// No description provided for @subEntryUses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String subEntryUses(int count);

  /// No description provided for @subManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get subManageCategories;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number like 1250 or 1250.50 (one decimal point, up to 2 decimals).'**
  String get amountInvalid;

  /// No description provided for @amountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Amounts can be up to {max}.'**
  String amountTooLarge(String max);
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
