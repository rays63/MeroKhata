// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'Paisa Flow';

  @override
  String get tabHome => 'गृह';

  @override
  String get tabBooks => 'खाताहरू';

  @override
  String get tabInsights => 'विश्लेषण';

  @override
  String get tabSplit => 'बाँडफाँड';

  @override
  String get newEntry => 'नयाँ प्रविष्टि';

  @override
  String get cashIn => 'आम्दानी';

  @override
  String get cashOut => 'खर्च';

  @override
  String get all => 'सबै';

  @override
  String get back => 'फर्कनुहोस्';

  @override
  String get close => 'बन्द गर्नुहोस्';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get delete => 'मेटाउनुहोस्';

  @override
  String get save => 'सेभ गर्नुहोस्';

  @override
  String get saveChanges => 'परिवर्तन सेभ गर्नुहोस्';

  @override
  String get add => 'थप्नुहोस्';

  @override
  String get done => 'भयो';

  @override
  String get editList => 'सूची सम्पादन';

  @override
  String get next => 'अर्को';

  @override
  String get getStarted => 'सुरु गरौं';

  @override
  String get continueLabel => 'जारी राख्नुहोस्';

  @override
  String get optional => 'वैकल्पिक';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'हिजो';

  @override
  String get greetingMorning => 'शुभ प्रभात,';

  @override
  String get greetingAfternoon => 'शुभ दिन,';

  @override
  String get greetingEvening => 'शुभ सन्ध्या,';

  @override
  String get updatedToday => 'आज अपडेट गरिएको';

  @override
  String get updatedYesterday => 'हिजो अपडेट गरिएको';

  @override
  String updatedDaysAgo(int days) {
    return '$days दिन अघि अपडेट गरिएको';
  }

  @override
  String get updatedLastWeek => 'गत हप्ता अपडेट गरिएको';

  @override
  String updatedOn(String date) {
    return '$date मा अपडेट गरिएको';
  }

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रविष्टि',
    );
    return '$_temp0';
  }

  @override
  String bookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खाता',
    );
    return '$_temp0';
  }

  @override
  String goalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लक्ष्य',
    );
    return '$_temp0';
  }

  @override
  String homeTotalBalance(String currency) {
    return 'कुल मौज्दात · $currency';
  }

  @override
  String homeCashInMonth(String month) {
    return 'आम्दानी · $month';
  }

  @override
  String homeCashOutMonth(String month) {
    return 'खर्च · $month';
  }

  @override
  String get import => 'आयात';

  @override
  String get splitABill => 'बिल बाँड्नुहोस्';

  @override
  String get goals => 'लक्ष्यहरू';

  @override
  String get setSavingsTarget => 'बचत लक्ष्य राख्नुहोस्';

  @override
  String goalsSaved(String amount, String goals) {
    return '$amount बचत · $goals';
  }

  @override
  String get split => 'बाँडफाँड';

  @override
  String get youreOwed => 'तपाईंले पाउनुपर्ने';

  @override
  String get youOwe => 'तपाईंले तिर्नुपर्ने';

  @override
  String get recentlyUpdated => 'भर्खर अपडेट भएका';

  @override
  String get seeAll => 'सबै';

  @override
  String get calendar => 'पात्रो';

  @override
  String get settings => 'सेटिङ';

  @override
  String get category => 'वर्ग';

  @override
  String get paymentMode => 'भुक्तानी माध्यम';

  @override
  String get bookCurrency => 'खाताको मुद्रा';

  @override
  String get book => 'खाता';

  @override
  String editListTitle(String title) {
    return '$title सूची सम्पादन';
  }

  @override
  String get addNew => 'नयाँ थप्नुहोस्…';

  @override
  String optionAdded(String name) {
    return '“$name” थपियो';
  }

  @override
  String optionRemoved(String name) {
    return '“$name” हटाइयो। यो प्रयोग गर्ने प्रविष्टिहरूमा यो रहिरहन्छ।';
  }

  @override
  String deleteOption(String name) {
    return '$name मेटाउनुहोस्';
  }

  @override
  String get previousMonth => 'अघिल्लो महिना';

  @override
  String get nextMonth => 'अर्को महिना';

  @override
  String get weekdaysShort => 'आ,सो,मं,बु,बि,शु,श';

  @override
  String get weekdaysLong => 'आइत,सोम,मंगल,बुध,बिही,शुक्र,शनि';

  @override
  String daySemantics(String date, String activity) {
    return '$date$activity';
  }

  @override
  String get hasCashIn => ', आम्दानी';

  @override
  String get hasCashOut => ', खर्च';

  @override
  String entrySemantics(String title, String type, String amount) {
    return '$title, $type $amount';
  }

  @override
  String balanceShort(String amount) {
    return 'मौज्दात $amount';
  }

  @override
  String exportFailed(String error) {
    return 'निर्यात असफल: $error';
  }

  @override
  String readyToShare(String name) {
    return '$name सेयर गर्न तयार';
  }

  @override
  String get loadError =>
      'केही सेभ गरिएको डाटा पढ्न सकिएन। एउटा प्रतिलिपि राखिएको छ।';

  @override
  String get splitYou => 'तपाईं';

  @override
  String get splitFriendFallback => 'साथी';

  @override
  String get splitAddFriendTitle => 'साथी थप्नुहोस्';

  @override
  String get splitAddFriendHint => 'नाम, जस्तै: सीता';

  @override
  String get splitEqual => 'बराबर';

  @override
  String get splitShares => 'भाग';

  @override
  String splitFewerShares(String name) {
    return '$name को भाग घटाउनुहोस्';
  }

  @override
  String splitMoreShares(String name) {
    return '$name को भाग बढाउनुहोस्';
  }

  @override
  String splitRecordBeforeBook(String amount) {
    return '$amount खर्चको रूपमा';
  }

  @override
  String get splitRecordAfterBook => 'खातामा लेख्नुहोस्';

  @override
  String splitSettleUpWith(String name) {
    return '$name सँग हिसाब मिलाउनुहोस्';
  }

  @override
  String splitPayName(String name) {
    return '$name लाई तिर्नुहोस्';
  }

  @override
  String splitTheyPayYou(String name, String amount) {
    return '$name ले तपाईंलाई $amount तिर्नुहुन्छ।';
  }

  @override
  String splitYouPayThem(String name, String amount) {
    return 'तपाईंले $name लाई $amount तिर्नुहुन्छ।';
  }

  @override
  String get splitNoBookForCurrency =>
      'हिसाब मिलाएको रकम लेख्न यो मुद्रामा एउटा खाता थप्नुहोस्।';

  @override
  String splitAddAsCashIn(String book) {
    return '$book मा आम्दानीको रूपमा थप्नुहोस्';
  }

  @override
  String splitAddAsCashOut(String book) {
    return '$book मा खर्चको रूपमा थप्नुहोस्';
  }

  @override
  String splitSettleAmount(String amount) {
    return '$amount मिलाउनुहोस्';
  }

  @override
  String splitPayAmount(String amount) {
    return '$amount तिर्नुहोस्';
  }

  @override
  String get splitGroups => 'समूहहरू';

  @override
  String get splitBills => 'बिलहरू';

  @override
  String get splitNoGroupsTitle => 'अहिलेसम्म कुनै समूह छैन';

  @override
  String get splitNoGroupsBody =>
      'यात्रा वा साझा फ्ल्याटका लागि समूह बनाउनुहोस् र सबैसँगको चालु हिसाब राख्नुहोस्।';

  @override
  String get splitNewGroup => 'नयाँ समूह';

  @override
  String get splitNoBillsTitle => 'अहिलेसम्म कुनै बिल छैन';

  @override
  String get splitNoBillsBody =>
      'खाना, ट्याक्सी वा सिनेमाको खर्च केही ट्यापमै बाँड्नुहोस्।';

  @override
  String splitPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जना',
    );
    return '$_temp0';
  }

  @override
  String splitExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खर्च',
    );
    return '$_temp0';
  }

  @override
  String splitGroupOwed(String amount) {
    return 'पाउनुपर्ने $amount';
  }

  @override
  String splitYouOweAmount(String amount) {
    return 'तपाईंले $amount तिर्नुपर्ने';
  }

  @override
  String splitOwesYou(String amount) {
    return 'तपाईंलाई $amount तिर्नुपर्ने';
  }

  @override
  String get splitSettledUp => 'हिसाब मिलेको';

  @override
  String get splitBillSettled => 'मिलिसकेको';

  @override
  String splitToCollectAmount(String amount) {
    return '$amount उठाउन बाँकी';
  }

  @override
  String splitBillSavedToast(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'बाँडफाँड सेभ भयो · $count जनाले तपाईंलाई $amount तिर्नुपर्छ',
    );
    return '$_temp0';
  }

  @override
  String get splitEnterTotal => 'कुल रकम हाल्नुहोस्';

  @override
  String get splitPickFriend => 'कम्तीमा एक जना साथी छान्नुहोस्';

  @override
  String splitSaveCta(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'सेभ · $count जनाले $amount तिर्नुपर्ने',
    );
    return '$_temp0';
  }

  @override
  String get splitWhatFor => 'केका लागि?';

  @override
  String get splitBillHint => 'जस्तै: थकाली खाना';

  @override
  String get splitTotalPaidByYou => 'कुल रकम · तपाईंले तिर्नुभएको';

  @override
  String get splitBetween => 'कसकसबीच बाँड्ने';

  @override
  String get splitLinkedNote =>
      'तपाईंले बाँड्नुभएको प्रविष्टिसँग जोडिएको छ, त्यसैले खातामा नयाँ केही लेखिँदैन।';

  @override
  String splitDeleteTitle(String name) {
    return '“$name” मेटाउने?';
  }

  @override
  String get splitEntriesStay =>
      'खातामा पहिले नै लेखिएका प्रविष्टिहरू रहिरहन्छन्।';

  @override
  String get splitAllSettled => 'सबै हिसाब मिल्यो';

  @override
  String get splitSettle => 'मिलाउनुहोस्';

  @override
  String get splitYourBook => 'तपाईंको खाता';

  @override
  String splitReceivedToast(String amount, String name, String book) {
    return '$name बाट $amount $book मा लेखियो';
  }

  @override
  String splitPaidToast(String amount, String name, String book) {
    return '$name लाई $amount $book मा लेखियो';
  }

  @override
  String get groupNameRequired => 'समूहको नाम दिनुहोस्';

  @override
  String get groupFriendRequired => 'कम्तीमा एक जना साथी थप्नुहोस्';

  @override
  String get groupUpdated => 'समूह अपडेट भयो';

  @override
  String groupCreated(String name) {
    return '“$name” समूह बनाइयो';
  }

  @override
  String get groupDeleteOpenBody =>
      'केही हिसाब अझै मिलेका छैनन्। खातामा पहिले नै लेखिएका प्रविष्टिहरू रहिरहन्छन्।';

  @override
  String get groupDeleted => 'समूह मेटाइयो';

  @override
  String get groupEdit => 'समूह सम्पादन';

  @override
  String get groupNameLabel => 'समूहको नाम';

  @override
  String get groupNameHint => 'जस्तै: पोखरा यात्रा, फ्ल्याट 3B';

  @override
  String get groupMembers => 'सदस्यहरू';

  @override
  String groupMemberLocked(String name) {
    return '$name यो समूहको खर्चमा समावेश हुनुहुन्छ';
  }

  @override
  String get groupTapAddHint =>
      'खर्च बाँड्ने साथीहरू थप्न “थप्नुहोस्” मा ट्याप गर्नुहोस्।';

  @override
  String get groupCreate => 'समूह बनाउनुहोस्';

  @override
  String get groupDelete => 'समूह मेटाउनुहोस्';

  @override
  String get groupTitle => 'समूह';

  @override
  String groupTotalSpent(String amount) {
    return 'कुल खर्च $amount';
  }

  @override
  String get groupBalances => 'हिसाब';

  @override
  String get groupExpenses => 'खर्चहरू';

  @override
  String get groupNoExpenses =>
      'अहिलेसम्म कुनै खर्च छैन। तल पहिलो खर्च थप्नुहोस्।';

  @override
  String expensePaidByName(String name) {
    return 'तिर्ने: $name';
  }

  @override
  String get expenseDelete => 'खर्च मेटाउनुहोस्';

  @override
  String get expenseDeleteBody => 'यसबिना हिसाब फेरि गणना हुनेछ।';

  @override
  String expenseDeleteSettledBody(String names) {
    return 'तपाईंले $names सँग हिसाब मिलाइसक्नुभएको छ। यो मेटाउँदा ती हिसाब बदलिन्छन्, र कसैले अर्कोलाई तिर्नुपर्ने हुन सक्छ।';
  }

  @override
  String get expenseDeleted => 'खर्च मेटाइयो';

  @override
  String get expenseDeletedEntryStays =>
      'खर्च मेटाइयो · खाताको प्रविष्टि रहिरहन्छ';

  @override
  String get expenseAmountRequired => 'शून्यभन्दा बढी रकम लेख्नुहोस्';

  @override
  String get expensePickSharers => 'यो खर्च कसकसले बाँड्ने छान्नुहोस्';

  @override
  String get expenseNeedOther =>
      'तिर्नेबाहेक अरू कसैलाई पनि बाँडफाँडमा राख्नुहोस्';

  @override
  String get expenseAddedToast => 'खर्च थपियो · हिसाब अपडेट भयो';

  @override
  String get expenseAdd => 'खर्च थप्नुहोस्';

  @override
  String get expenseHint => 'जस्तै: होटल (2 रात)';

  @override
  String get expenseAmount => 'रकम';

  @override
  String get expensePaidBy => 'तिर्ने';

  @override
  String get billTitle => 'बिल';

  @override
  String get billPaidByYou => 'तपाईंले तिर्नुभएको';

  @override
  String get billDelete => 'बिल मेटाउनुहोस्';

  @override
  String get billDeleted => 'बिल मेटाइयो';

  @override
  String get billToCollect => 'उठाउन बाँकी';

  @override
  String billTotalLine(String total, String share) {
    return 'बिलको कुल $total · तपाईंको भाग $share';
  }

  @override
  String get bookListTitle => 'खाताहरू';

  @override
  String get bookNew => 'नयाँ खाता';

  @override
  String get bookSearchHint => 'खाता खोज्नुहोस्';

  @override
  String bookSearchNoMatch(String query) {
    return '“$query” सँग मिल्ने खाता भेटिएन';
  }

  @override
  String bookDeleteTitle(String name) {
    return '“$name” मेटाउने?';
  }

  @override
  String get bookDeleteEmpty => 'यो खातामा कुनै प्रविष्टि छैन।';

  @override
  String bookDeleteWithEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यसका $count प्रविष्टि पनि मेटिनेछन्। यो फिर्ता गर्न सकिँदैन।',
    );
    return '$_temp0';
  }

  @override
  String bookDeleted(String name) {
    return '“$name” मेटाइयो';
  }

  @override
  String get bookActions => 'खाताका विकल्पहरू';

  @override
  String get bookRename => 'नाम बदल्नुहोस्';

  @override
  String get bookEmptyTitle => 'आफ्नो पहिलो खाता सुरु गर्नुहोस्';

  @override
  String get bookEmptyBody =>
      'हरेक उद्देश्यका लागि एउटा खाता — दैनिक खर्च, तपाईंको पसल, विदेश यात्रा। एक मिनेट पनि लाग्दैन।';

  @override
  String get bookEmptyImport => 'वा विवरण आयात गर्नुहोस्';

  @override
  String get bookCurrencyLocked =>
      'खातामा प्रविष्टि भएपछि मुद्रा परिवर्तन गर्न मिल्दैन';

  @override
  String get bookUntitled => 'शीर्षकविहीन खाता';

  @override
  String get bookRenamed => 'खाताको नाम बदलियो';

  @override
  String bookCreated(String name, String currency) {
    return '“$name” $currency मा बनाइयो';
  }

  @override
  String get bookRenameTitle => 'खाताको नाम बदल्नुहोस्';

  @override
  String get bookNameLabel => 'खाताको नाम';

  @override
  String get bookNameHint => 'जस्तै: किराना पसल';

  @override
  String get bookCurrencyLabel => 'मुद्रा';

  @override
  String get bookOpeningBalance => 'सुरुको मौज्दात';

  @override
  String get bookCurrencyNote =>
      'प्रविष्टि भएपछि खाताको मुद्रा परिवर्तन गर्न मिल्दैन। हरेक मुद्राका लागि छुट्टै खाता प्रयोग गर्नुहोस्।';

  @override
  String get bookCreate => 'खाता बनाउनुहोस्';

  @override
  String get ledgerRangeWeek => 'पछिल्ला 7 दिन';

  @override
  String get ledgerRangeMonth => 'यो महिना';

  @override
  String get ledgerRangeAll => 'सबै समय';

  @override
  String get ledgerDateRange => 'मिति अवधि';

  @override
  String get ledgerFilterCategory => 'वर्ग अनुसार छान्नुहोस्';

  @override
  String get ledgerAllCategories => 'सबै वर्ग';

  @override
  String get ledgerFilterMode => 'भुक्तानी माध्यम अनुसार छान्नुहोस्';

  @override
  String get ledgerAllModes => 'सबै माध्यम';

  @override
  String get ledgerImportStatement => 'विवरण आयात गर्नुहोस्';

  @override
  String get ledgerReport => 'रिपोर्ट';

  @override
  String get ledgerEmptyTitle => 'अहिलेसम्म कुनै प्रविष्टि छैन';

  @override
  String get ledgerEmptyBody =>
      'तल आफ्नो पहिलो आम्दानी वा खर्च थप्नुहोस्, वा विवरण आयात गर्नुहोस्।';

  @override
  String get ledgerNoMatchTitle => 'मिल्ने प्रविष्टि भेटिएन';

  @override
  String get ledgerNoMatchBody =>
      'अझ लामो मिति अवधि छान्नुहोस् वा फिल्टर हटाउनुहोस्।';

  @override
  String get ledgerClearFilters => 'फिल्टर हटाउनुहोस्';

  @override
  String get ledgerNetBalance => 'खुद मौज्दात';

  @override
  String get ledgerInflow => 'आम्दानी';

  @override
  String get ledgerOutflow => 'खर्च';

  @override
  String get entryErrorAmount => 'शून्यभन्दा बढी रकम लेख्नुहोस्';

  @override
  String get entryErrorTitle => 'पछि सजिलै भेट्टाउन शीर्षक थप्नुहोस्';

  @override
  String get entrySaved => 'प्रविष्टि सेभ भयो';

  @override
  String get entryChangesSaved => 'परिवर्तन सेभ भयो';

  @override
  String get entryBalanceUpdated => 'मौज्दात अपडेट भयो';

  @override
  String get entryGoalUpdated => 'लक्ष्यको प्रगति अपडेट भयो';

  @override
  String get entryEditTitle => 'प्रविष्टि सम्पादन';

  @override
  String get entryNewCashIn => 'नयाँ आम्दानी';

  @override
  String get entryNewCashOut => 'नयाँ खर्च';

  @override
  String get entryTitleLabel => 'शीर्षक';

  @override
  String get entryTitleHint => 'केका लागि थियो?';

  @override
  String get entryDateTime => 'मिति र समय';

  @override
  String get entryNotes => 'टिप्पणी';

  @override
  String get entryAddToGoal => 'लक्ष्यमा थप्नुहोस्';

  @override
  String get entrySave => 'सेभ गर्नुहोस्';

  @override
  String entryWhenToday(String date) {
    return 'आज, $date';
  }

  @override
  String get entryDeleteTitle => 'यो प्रविष्टि मेटाउने?';

  @override
  String get entryDeleteBody =>
      'खाताको मौज्दात फेरि हिसाब गरिनेछ। यो फिर्ता गर्न सकिँदैन।';

  @override
  String get entryDeletedToast =>
      'प्रविष्टि मेटाइयो · मौज्दात फेरि हिसाब गरियो';

  @override
  String get entryReference => 'सन्दर्भ';

  @override
  String get entryImportedFromLabel => 'आयात स्रोत';

  @override
  String get entryGoal => 'लक्ष्य';

  @override
  String get entryTitle => 'प्रविष्टि';

  @override
  String get entryBadgeCashIn => 'आम्दानी';

  @override
  String get entryBadgeCashOut => 'खर्च';

  @override
  String get entryRunningBalance => 'चालु मौज्दात';

  @override
  String get entrySplitWithFriends => 'यो बिल साथीहरूसँग बाँड्नुहोस्';

  @override
  String get entryViewSplitSettled => 'बाँडफाँड हेर्नुहोस् · हिसाब मिलिसकेको';

  @override
  String entryViewSplitToCollect(String amount) {
    return 'बाँडफाँड हेर्नुहोस् · $amount उठाउन बाँकी';
  }

  @override
  String get entryEditHistory => 'सम्पादन इतिहास';

  @override
  String get entryCreated => 'प्रविष्टि बनाइयो';

  @override
  String entryImportedFrom(String source) {
    return '$source बाट आयात गरियो';
  }

  @override
  String get entryDelete => 'प्रविष्टि मेटाउनुहोस्';

  @override
  String importNoEntriesPdf(String file) {
    return '$file मा कुनै प्रविष्टि भेटिएन। स्क्यान गरिएका, तस्बिर मात्र भएका PDF अहिले समर्थित छैनन्।';
  }

  @override
  String importNoEntriesXls(String file) {
    return '$file मा कुनै प्रविष्टि भेटिएन। यसमा मिति, डेबिट र क्रेडिट स्तम्भ छन् कि जाँच गर्नुहोस्।';
  }

  @override
  String importWrongFileType(String file, String types) {
    return '$file समर्थित फाइल होइन। $types फाइल छान्नुहोस्।';
  }

  @override
  String get pdfPasswordTitle => 'पासवर्ड सुरक्षित';

  @override
  String pdfPasswordBody(String file) {
    return '$file लक गरिएको छ। खोल्न बैंकले दिएको पासवर्ड हाल्नुहोस्।';
  }

  @override
  String get pdfPasswordHint => 'PDF पासवर्ड';

  @override
  String get pdfPasswordWrong => 'पासवर्ड मिलेन। फेरि प्रयास गर्नुहोस्।';

  @override
  String get pdfPasswordOpen => 'खोल्नुहोस्';

  @override
  String importReadError(String file, String error) {
    return '$file पढ्न सकिएन: $error';
  }

  @override
  String importInto(String book) {
    return '$book मा';
  }

  @override
  String get importPdfTitle => 'PDF बैंक विवरण';

  @override
  String get importPdfBody =>
      'मिति, विवरण, निकासी, जम्मा र मौज्दात स्तम्भ भएका टेक्स्टमा आधारित PDF।';

  @override
  String get importPdfAction => 'PDF छान्नुहोस् →';

  @override
  String get importXlsTitle => 'XLS वालेट विवरण';

  @override
  String get importXlsBody =>
      'वालेटबाट निर्यात गरिएका पुराना .xls फाइल। मूल विवरण र सन्दर्भ कोड जस्ताको तस्तै रहन्छन्।';

  @override
  String get importXlsAction => 'XLS छान्नुहोस् →';

  @override
  String get importTipReview => 'सेभ हुनुअघि तपाईं सबै कुरा हेर्न सक्नुहुन्छ।';

  @override
  String get importTipDuplicates =>
      'एउटै विवरण फेरि आयात गर्दा दोहोरिएका प्रविष्टि बन्दैनन्।';

  @override
  String get importTipScanned =>
      'स्क्यान गरिएका, तस्बिर मात्र भएका PDF अहिले समर्थित छैनन्।';

  @override
  String importImportedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रविष्टि आयात गरियो',
    );
    return '$_temp0';
  }

  @override
  String importDuplicatesSkippedToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दोहोरिएका प्रविष्टि छोडिए',
    );
    return '$_temp0';
  }

  @override
  String get importReviewTitle => 'आयात जाँच गर्नुहोस्';

  @override
  String importParsedLines(String file, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लाइन पढियो',
    );
    return '$file · $_temp0';
  }

  @override
  String get importReady => 'आयात गर्न तयार';

  @override
  String get importDuplicatesSkipped => 'दोहोरिएका छोडिए';

  @override
  String get importIgnoredLines => 'प्रविष्टि नभएका लाइन';

  @override
  String get importUpToDateTitle => 'पहिले नै अपडेट छ';

  @override
  String importUpToDateBody(String book) {
    return 'यो विवरणका सबै प्रविष्टि $book मा पहिले नै छन्। आयात गर्न नयाँ केही छैन।';
  }

  @override
  String importOpeningWillSet(String opening, String closing) {
    return 'यो खाता खाली छ, त्यसैले $opening सुरु मौज्दात थपिनेछ। आयातपछि यो विवरणको अन्तिम मौज्दात $closing सँग मिल्नेछ।';
  }

  @override
  String importOpeningWillSetFiles(
    String opening,
    String file,
    String balance,
  ) {
    return 'यो खाता खाली छ, त्यसैले $opening सुरु मौज्दात ($file बाट) थपिनेछ। आयातपछि मौज्दात $balance हुनेछ।';
  }

  @override
  String importOpeningInfo(String opening) {
    return 'विवरण $opening बाट सुरु हुन्छ। यो खातामा पहिले नै प्रविष्टिहरू छन्, त्यसैले मौज्दात परिवर्तन हुँदैन।';
  }

  @override
  String importFilesParsed(int files, int lines) {
    return '$files फाइल · $lines लाइन पढियो';
  }

  @override
  String importFileCounts(int ready, int duplicates, int ignored) {
    return '$ready तयार · $duplicates दोहोरिएका · $ignored प्रविष्टि नभएका';
  }

  @override
  String importWarnMixedSources(String sources) {
    return 'यी फाइलहरू फरक स्रोतका हुन् ($sources)। सबै यही खातामा जानेछन्।';
  }

  @override
  String importWarnChainGap(
    String from,
    String to,
    String closing,
    String opening,
  ) {
    return '$from $closing मा सकिन्छ, तर $to $opening बाट सुरु हुन्छ। बीचको विवरण छुटेको हुन सक्छ।';
  }

  @override
  String importPasswordSkipped(String file) {
    return 'पासवर्ड नहालेकाले $file छोडियो।';
  }

  @override
  String importFileUnreadable(String file) {
    return '$file पढ्न सकिएन।';
  }

  @override
  String get importThisBook => 'यो खाता';

  @override
  String get importBackToBook => 'खातामा फर्कनुहोस्';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रविष्टि आयात गर्नुहोस्',
    );
    return '$_temp0';
  }

  @override
  String importRef(String reference) {
    return 'सन्दर्भ $reference';
  }

  @override
  String get importDuplicateBadge => 'दोहोरिएको';

  @override
  String get calNoEntries => 'यो दिन कुनै प्रविष्टि छैन।';

  @override
  String get splashOffline => 'अफलाइनमै चल्छ · तपाईंको डाटा यही फोनमा रहन्छ';

  @override
  String get onboardBooksTitle => 'सबै खाता, एउटै खल्तीमा';

  @override
  String get onboardBooksBody =>
      'व्यक्तिगत खर्च, पसल र विदेश यात्राको हिसाब छुट्टाछुट्टै राख्नुहोस् — हरेक खाता आफ्नै मुद्रामा।';

  @override
  String get onboardImportTitle => 'विवरण आयात गर्नुहोस्, टाइप गर्ने झन्झट छैन';

  @override
  String get onboardImportBody =>
      'PDF वा XLS विवरण राख्नुहोस्। पहिले जाँच गर्नुहोस् — दोहोरिएका प्रविष्टि आफैं पत्ता लाग्छन्।';

  @override
  String get onboardGoalsTitle => 'हिसाब मिल्ने लक्ष्य र बाँडफाँड';

  @override
  String get onboardGoalsBody =>
      'आम्दानीलाई बचत लक्ष्यमा जोड्नुहोस्, साथीहरूसँग बिल बाँड्नुहोस्, र कसले कति तिर्नुपर्छ सधैं थाहा पाउनुहोस्।';

  @override
  String get onboardSkip => 'छोड्नुहोस्';

  @override
  String onboardPageOf(int page, int total) {
    return 'पृष्ठ $page / $total';
  }

  @override
  String onboardArtParsed(int count) {
    return 'पढियो · $count लाइन';
  }

  @override
  String get onboardArtReady => 'तयार';

  @override
  String get onboardArtDuplicates => 'दोहोरिएका';

  @override
  String get onboardArtSkipped => 'छोडिएका';

  @override
  String onboardArtImportEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रविष्टि आयात गर्नुहोस्',
    );
    return '$_temp0';
  }

  @override
  String onboardArtGoalProgress(String saved, String target) {
    return '$target मध्ये $saved';
  }

  @override
  String get profileTitle => 'तपाईंको विवरण';

  @override
  String get profileStepTitle => 'आफ्नो बारेमा बताउनुहोस्';

  @override
  String get profileStepBody =>
      'एपलाई तपाईं अनुकूल बनाउन र निर्यात गरिएका रिपोर्टमा तपाईंको नाम राख्न प्रयोग हुन्छ।';

  @override
  String get profileAvatarHint =>
      'तपाईंको नामका आद्याक्षर नै अवतार बन्छन्। फोटो पछि सेटिङबाट थप्न सक्नुहुन्छ।';

  @override
  String get profileFullName => 'पूरा नाम';

  @override
  String get profileNameHint => 'जस्तै: आरव श्रेष्ठ';

  @override
  String get profileMobile => 'मोबाइल नम्बर';

  @override
  String get profileEmail => 'इमेल';

  @override
  String get profilePrivacy =>
      'यो फोनमा मात्र सेभ हुन्छ। हामी तपाईंको विवरण कहिल्यै अपलोड वा सेयर गर्दैनौं।';

  @override
  String get profileValid => 'मान्य';

  @override
  String get profileNameRequired => 'कृपया आफ्नो नाम लेख्नुहोस्';

  @override
  String get profileEmailInvalid =>
      'इमेल अधुरो देखिन्छ — मिलाउनुहोस् वा खाली छोड्नुहोस्';

  @override
  String get profileSaved => 'विवरण सेभ भयो';

  @override
  String setupStepOf(int step, int total) {
    return 'चरण $step / $total';
  }

  @override
  String get setupTitle => 'पहिलो खाता बनाऔं';

  @override
  String get setupBody =>
      'खाताले पैसाको हिसाब छुट्टाछुट्टै राख्छ — व्यक्तिगत, पसल, यात्रा। हरेक खाताको आफ्नै मुद्रा हुन्छ।';

  @override
  String get setupLanguage => 'भाषा';

  @override
  String get setupBookName => 'खाताको नाम';

  @override
  String get setupBookNameHint => 'जस्तै: व्यक्तिगत';

  @override
  String get setupCurrency => 'मुद्रा';

  @override
  String get setupOpeningBalance => 'सुरुको मौज्दात';

  @override
  String setupSaveFailed(String error) {
    return 'खाता सेभ गर्न सकिएन: $error';
  }

  @override
  String get setupWelcome => 'Paisa Flow मा स्वागत छ';

  @override
  String get settingsAppearance => 'देखावट';

  @override
  String get settingsThemeSystem => 'सिस्टम';

  @override
  String get settingsThemeLight => 'उज्यालो';

  @override
  String get settingsThemeDark => 'अँध्यारो';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsCategories => 'वर्गहरू';

  @override
  String get settingsPaymentModes => 'भुक्तानी माध्यमहरू';

  @override
  String settingsItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वटा',
    );
    return '$_temp0';
  }

  @override
  String get settingsDefaultCurrency => 'नयाँ खाताको पूर्वनिर्धारित मुद्रा';

  @override
  String get settingsDefaultCurrencyTitle => 'पूर्वनिर्धारित मुद्रा';

  @override
  String get settingsExportAll => 'सबै डाटा निर्यात गर्नुहोस्';

  @override
  String get settingsAppLock => 'एप लक';

  @override
  String get settingsSoon => 'चाँडै';

  @override
  String get settingsStoredTitle => 'यो फोनमा मात्र सुरक्षित';

  @override
  String get settingsStoredBody =>
      'न अकाउन्ट, न क्लाउड। ब्याकअपका लागि नियमित निर्यात गर्नुहोस्।';

  @override
  String get goalNoDeadline => 'समय सीमा छैन';

  @override
  String goalDeadlineBy(String date) {
    return '$date सम्म';
  }

  @override
  String get goalNew => 'नयाँ लक्ष्य';

  @override
  String get goalEdit => 'लक्ष्य सम्पादन';

  @override
  String get goalSavedAcross => 'सबै खातामा गरिएको बचत';

  @override
  String goalOfTarget(String amount) {
    return '$amount मध्ये';
  }

  @override
  String get goalEmptyTitle => 'अहिलेसम्म कुनै लक्ष्य छैन';

  @override
  String get goalEmptyBody =>
      'बचत लक्ष्य राख्नुहोस् — आपत्कालीन कोष, ल्यापटप, दशैंका उपहार।';

  @override
  String get goalTagHint =>
      'कुनै पनि आम्दानी प्रविष्टिलाई लक्ष्यसँग जोड्नुहोस्, प्रगति आफैं अपडेट हुन्छ।';

  @override
  String get goalReachedBadge => 'पूरा भयो';

  @override
  String get goalReached => 'लक्ष्य पूरा भयो';

  @override
  String goalToGo(String amount) {
    return '$amount बाँकी';
  }

  @override
  String get goalNoLinked => 'कुनै प्रविष्टि जोडिएको छैन';

  @override
  String goalLinkedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रविष्टि जोडिएका',
    );
    return '$_temp0';
  }

  @override
  String get goalDeadlineKeep => 'हालकै राख्नुहोस्';

  @override
  String goalDeadlineMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महिना',
    );
    return '$_temp0';
  }

  @override
  String get goalNameRequired => 'लक्ष्यको नाम लेख्नुहोस्';

  @override
  String get goalTargetInvalid => 'लक्ष्य रकम शून्यभन्दा बढी हुनुपर्छ';

  @override
  String get goalUpdated => 'लक्ष्य अपडेट भयो';

  @override
  String goalCreated(String name) {
    return '“$name” लक्ष्य बनाइयो';
  }

  @override
  String goalDeleteTitle(String name) {
    return '“$name” मेटाउने?';
  }

  @override
  String get goalDeleteBody =>
      'जोडिएका प्रविष्टिहरू आफ्नै खातामा रहन्छन्; केवल यो लक्ष्यमा गनिन छोड्छन्।';

  @override
  String get goalDeleted => 'लक्ष्य मेटाइयो';

  @override
  String get goalName => 'लक्ष्यको नाम';

  @override
  String get goalNameHint => 'जस्तै: नयाँ स्कुटर';

  @override
  String get goalTargetAmount => 'लक्ष्य रकम';

  @override
  String get goalDeadline => 'समय सीमा';

  @override
  String get goalCreate => 'लक्ष्य बनाउनुहोस्';

  @override
  String get goalDelete => 'लक्ष्य मेटाउनुहोस्';

  @override
  String get reportTitle => 'रिपोर्ट';

  @override
  String get reportTypeAll => 'सबै प्रविष्टि';

  @override
  String get reportTypeDaily => 'दिनअनुसार';

  @override
  String get reportTypeCategory => 'वर्गअनुसार';

  @override
  String get reportColumnEntry => 'प्रविष्टि';

  @override
  String get reportColumnDay => 'दिन';

  @override
  String get reportColumnCategory => 'वर्ग';

  @override
  String get reportColumnMode => 'माध्यम';

  @override
  String get reportColumnAmount => 'रकम';

  @override
  String get reportFieldDate => 'मिति';

  @override
  String get reportFieldTitle => 'शीर्षक';

  @override
  String get reportFieldNotes => 'टिप्पणी';

  @override
  String get reportFieldBalance => 'मौज्दात';

  @override
  String get reportFieldReference => 'सन्दर्भ';

  @override
  String reportFieldsToExport(int selected, int total) {
    return 'निर्यात गर्ने विवरण · $total मध्ये $selected';
  }

  @override
  String get reportExportPdf => 'PDF निर्यात';

  @override
  String get reportExportExcel => 'Excel निर्यात';

  @override
  String get reportEmpty => 'यो अवधिमा कुनै प्रविष्टि छैन।';

  @override
  String reportMoreInExport(int count) {
    return '+ थप $count वटा निर्यातमा';
  }

  @override
  String get reportNet => 'खुद';

  @override
  String get insightsTitle => 'विश्लेषण';

  @override
  String insightsAllBooks(String currency) {
    return 'सबै $currency खाता';
  }

  @override
  String get insightsPrevMonth => 'अघिल्लो महिना';

  @override
  String get insightsNextMonth => 'अर्को महिना';

  @override
  String insightsActivityOn(String date) {
    return 'गतिविधि · $date';
  }

  @override
  String insightsTransactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कारोबार',
    );
    return '$_temp0';
  }

  @override
  String get insightsNoActivity => 'यो दिन कुनै गतिविधि छैन।';

  @override
  String get insightsTrends => 'प्रवृत्ति';

  @override
  String get insightsIncome => 'आम्दानी';

  @override
  String get insightsSpending => 'खर्च';

  @override
  String insightsSpendingSaved(int percent) {
    return 'खर्च · $percent% बचत';
  }

  @override
  String insightsNetFlow(String month) {
    return 'खुद प्रवाह · $month';
  }

  @override
  String get insightsCashFlowTrend => 'नगद प्रवाहको प्रवृत्ति';

  @override
  String get insightsLegendIn => 'आम्दानी';

  @override
  String get insightsLegendOut => 'खर्च';

  @override
  String insightsBarSemantics(String period, String inflow, String outflow) {
    return '$period: आम्दानी $inflow, खर्च $outflow';
  }

  @override
  String get insightsWhereItWent => 'पैसा कहाँ गयो';

  @override
  String get insightsNoSpending => 'यो अवधिमा कुनै खर्च छैन।';

  @override
  String get insightsByMode => 'भुक्तानी माध्यमअनुसार';

  @override
  String get splashSubtitle => 'तपाईंको पैसा, तपाईंको हिसाब।';

  @override
  String get profilePhoneRule =>
      '9 बाट सुरु हुने 10 अङ्कको मोबाइल नम्बर लेख्नुहोस्';

  @override
  String get goalDeadlineOneYear => '1 वर्ष';

  @override
  String get reportFieldsHint =>
      'यी विवरण “सबै प्रविष्टि” रिपोर्टमा मात्र लागू हुन्छन्; सारांशमा जम्मा रकम देखिन्छ।';

  @override
  String get insightsRange7d => '7 दिन';

  @override
  String get insightsRange30d => '30 दिन';

  @override
  String get insightsRange3m => '3 महिना';

  @override
  String get insightsRange1y => '1 वर्ष';

  @override
  String historyAmount(String from, String to) {
    return 'रकम $from → $to';
  }

  @override
  String historyTitle(String title) {
    return 'शीर्षक “$title” मा बदलियो';
  }

  @override
  String historyCategory(String from, String to) {
    return 'वर्ग $from → $to';
  }

  @override
  String historyMode(String from, String to) {
    return 'भुक्तानी माध्यम $from → $to';
  }

  @override
  String get historyTypeIn => 'प्रकार आम्दानीमा बदलियो';

  @override
  String get historyTypeOut => 'प्रकार खर्चमा बदलियो';

  @override
  String historyDate(String date) {
    return 'मिति $date मा बदलियो';
  }

  @override
  String get historyNotes => 'टिप्पणी अपडेट गरियो';

  @override
  String get historyGoal => 'लक्ष्य लिङ्क अपडेट गरियो';

  @override
  String get historyDeleted => 'प्रविष्टि मेटाइयो';

  @override
  String historySplitGroup(String group) {
    return '$group बाँडफाँडबाट बनाइयो';
  }

  @override
  String get historySplitBill => 'बिल बाँडफाँडबाट बनाइयो';

  @override
  String historySettled(String source) {
    return '$source को हिसाब मिलाउँदा बनाइयो';
  }

  @override
  String get uncategorised => 'वर्ग नतोकिएको';

  @override
  String get notSet => 'नतोकिएको';

  @override
  String insightsWeekBucket(int n) {
    return 'ह$n';
  }

  @override
  String insightsQuarterBucket(int n) {
    return 'त्रै$n';
  }

  @override
  String get weekdaysTwo => 'आइ,सोम,मंगल,बुध,बिही,शुक्र,शनि';
}
