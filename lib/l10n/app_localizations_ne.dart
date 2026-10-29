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
  String get splitRecordTitle => 'यो भुक्तानी रेकर्ड गर्नुहोस्';

  @override
  String splitRecordPaidMessage(String amount) {
    return 'तपाईंले $amount तिर्नुभयो। रेकर्ड गर्ने खाता छान्नुहोस्।';
  }

  @override
  String get splitDontRecord => 'खातामा रेकर्ड नगर्नुहोस्';

  @override
  String splitNoBookInCurrency(String currency) {
    return 'तपाईंसँग अहिलेसम्म $currency खाता छैन।';
  }

  @override
  String splitCreateBookIn(String currency) {
    return '$currency खाता बनाउनुहोस्';
  }

  @override
  String splitSettledToast(String amount, String name) {
    return '$name सँग $amount हिसाब मिलाइयो';
  }

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
  String get bookRename => 'खाता सम्पादन';

  @override
  String get bookEmptyTitle => 'आफ्नो पहिलो खाता थप्नुहोस्';

  @override
  String get bookEmptyBody =>
      'हातको नगद, NIC Asia खाता, eSewa वा कार्ड। हरेकको आफ्नै मौज्दात र मुद्रा हुन्छ।';

  @override
  String get bookEmptyImport => 'वा विवरण आयात गर्नुहोस्';

  @override
  String get bookCurrencyLocked =>
      'खातामा प्रविष्टि भएपछि मुद्रा परिवर्तन गर्न मिल्दैन';

  @override
  String get bookUntitled => 'शीर्षकविहीन खाता';

  @override
  String get bookRenamed => 'खाता अपडेट भयो';

  @override
  String bookCreated(String name, String currency) {
    return '“$name” $currency मा बनाइयो';
  }

  @override
  String get bookRenameTitle => 'खाता सम्पादन';

  @override
  String get bookNameLabel => 'खाताको नाम';

  @override
  String get bookNameHint => 'जस्तै: eSewa';

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
  String importSummaryReport(String file) {
    return '$file सारांश रिपोर्ट हो (दिन, श्रेणी वा भुक्तानी माध्यमको जम्मा), यसमा छुट्टाछुट्टै प्रविष्टि छैनन्। आयात गर्न \"सबै प्रविष्टि\" रिपोर्ट निर्यात गर्नुहोस्।';
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
      'नगद, बैंक, eSewa, कार्ड वा ऋण — हरेक खाता आफ्नै मुद्रामा।';

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
      'खाताले पैसाको हिसाब छुट्टाछुट्टै राख्छ — नगद, बैंक, eSewa। हरेक खाताको आफ्नै मुद्रा हुन्छ।';

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
      'लगइन छैन, क्लाउड छैन। ब्याकअप बनाएर एउटा प्रति सुरक्षित ठाउँमा राख्नुहोस्।';

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

  @override
  String get accountTypeLabel => 'खाताको प्रकार';

  @override
  String get accountTypeCash => 'नगद';

  @override
  String get accountTypeBank => 'बैंक';

  @override
  String get accountTypeWallet => 'वालेट';

  @override
  String get accountTypeCard => 'कार्ड';

  @override
  String get accountTypeLoan => 'ऋण';

  @override
  String get accountTypeSavings => 'बचत';

  @override
  String get accountTypeOther => 'अन्य';

  @override
  String get accountSetType => 'प्रकार तोक्नुहोस्';

  @override
  String get accountTypePrompt => 'खाताहरू समूहमा राख्न प्रकार तोक्नुहोस्';

  @override
  String accountTypePromptBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count खाता अझै “अन्य” मा छन्।',
      one: '1 खाता अझै “अन्य” मा छ।',
    );
    return '$_temp0 बैंक, वालेट, कार्ड छान्नुहोस्, ताकि सम्पत्ति र दायित्व सही जोडियोस्।';
  }

  @override
  String get accountLegacyNote =>
      'यो खाता प्रकारहरू आउनुअघि बनाइएको हो, त्यसैले अहिलेलाई “अन्य” मा छ।';

  @override
  String get accountLiabilityNote =>
      'यसलाई दायित्व मानिन्छ। यसको मौज्दातले तपाईंले तिर्न बाँकी रकम देखाउँछ र खुद सम्पत्तिबाट घटाइन्छ।';

  @override
  String get accountAmountOwed => 'तिर्न बाँकी रकम';

  @override
  String get accountBalance => 'मौज्दात';

  @override
  String get accountOutstanding => 'तिर्न बाँकी';

  @override
  String accountCredit(String amount) {
    return 'क्रेडिट $amount';
  }

  @override
  String get accountAssets => 'सम्पत्ति';

  @override
  String get accountLiabilities => 'दायित्व';

  @override
  String get accountTotal => 'जम्मा';

  @override
  String get accountOwed => 'तिर्न बाँकी';

  @override
  String accountOwedAmount(String amount) {
    return 'तिर्न बाँकी $amount';
  }

  @override
  String homeNetWorth(String currency) {
    return 'खुद सम्पत्ति · $currency';
  }

  @override
  String homeAssetsOwed(String assets, String owed) {
    return 'सम्पत्ति $assets − तिर्न बाँकी $owed';
  }

  @override
  String get homeOtherCurrencies => 'अन्य मुद्रा';

  @override
  String get later => 'पछि';

  @override
  String get homeRecentActivity => 'हालैका कारोबार';

  @override
  String get allEntriesTitle => 'सबै कारोबार';

  @override
  String get feedIncome => 'आम्दानी';

  @override
  String get feedExpenses => 'खर्च';

  @override
  String get feedEmptyTitle => 'अहिलेसम्म कुनै कारोबार छैन';

  @override
  String get feedEmptyBody =>
      'पहिलो आम्दानी वा खर्च थप्नुहोस्, वा बैंक स्टेटमेन्ट आयात गर्नुहोस्। सबै खाताका कारोबार यहाँ देखिन्छन्।';

  @override
  String get feedAddEntry => 'कारोबार थप्नुहोस्';

  @override
  String feedMonthEmptyTitle(String month) {
    return '$month मा केही छैन';
  }

  @override
  String get feedMonthEmptyBody => 'यो महिना कुनै पनि खातामा कारोबार भएन।';

  @override
  String get feedGoToThisMonth => 'यो महिनामा जानुहोस्';

  @override
  String get feedPreviousMonth => 'अघिल्लो महिना';

  @override
  String get feedNextMonth => 'अर्को महिना';

  @override
  String get transfer => 'ट्रान्सफर';

  @override
  String get transferEditTitle => 'ट्रान्सफर सम्पादन';

  @override
  String get transferFrom => 'पठाउने खाता';

  @override
  String get transferTo => 'पाउने खाता';

  @override
  String get transferSwap => 'खाता साटफेर गर्नुहोस्';

  @override
  String transferAmountIn(String currency) {
    return 'रकम · $currency';
  }

  @override
  String get transferFee => 'शुल्क';

  @override
  String get transferFeeHint => 'शुल्क पठाउने खातामा खर्चको रूपमा लेखिन्छ';

  @override
  String get transferNotesHint => 'जस्तै: eSewa लोड';

  @override
  String get transferExplain =>
      'ट्रान्सफरले तपाईंकै खाताहरूबीच पैसा सार्छ। यसलाई आम्दानी वा खर्चमा गनिँदैन।';

  @override
  String get transferCardPay => 'कार्डको बिल भुक्तानी';

  @override
  String get transferWalletLoad => 'वालेट लोड';

  @override
  String get transferCashWithdrawal => 'नगद निकासी';

  @override
  String get transferLoanRepayment => 'ऋण भुक्तानी';

  @override
  String transferBalanceChange(String account, String before, String after) {
    return '$account $before → $after';
  }

  @override
  String transferOwedChange(String account, String before, String after) {
    return '$account · तिर्न बाँकी $before → $after';
  }

  @override
  String transferCrossTitle(String from, String to) {
    return 'फरक मुद्रा · $from → $to';
  }

  @override
  String get transferCrossBody =>
      'एउटा खाताबाट गएको र अर्कोमा आएको रकम दुवै लेख्नुहोस्। एपले आफैं रूपान्तरण गर्दैन।';

  @override
  String transferReceived(String currency) {
    return 'प्राप्त रकम · $currency';
  }

  @override
  String transferRate(String from, String rate, String to) {
    return '1 $from = $rate $to · तपाईंका रकमबाट निकालिएको';
  }

  @override
  String get transferRateNeeded => 'दुवै रकम चाहिन्छ। दर आफैं निकालिन्छ।';

  @override
  String get transferErrorSame => 'दुई फरक खाता छान्नुहोस्';

  @override
  String get transferErrorReceived => 'आइपुगेको रकम लेख्नुहोस्';

  @override
  String get transferNeedTwo => 'पैसा सार्न अर्को खाता थप्नुहोस्।';

  @override
  String get transferSaved => 'ट्रान्सफर सेभ भयो · मौज्दात अपडेट भयो';

  @override
  String transferRowTitle(String from, String to) {
    return '$from → $to';
  }

  @override
  String get transferDeletedAccount => 'मेटिएको खाता';

  @override
  String get transferDelete => 'ट्रान्सफर मेटाउनुहोस्';

  @override
  String get transferDeleteNote =>
      'दुवै खाताबाट र यसको शुल्कको कारोबारबाट पनि हटाउँछ।';

  @override
  String get transferDeleteTitle => 'यो ट्रान्सफर मेटाउने?';

  @override
  String get transferDeletedToast =>
      'ट्रान्सफर मेटियो · मौज्दात फेरि हिसाब भयो';

  @override
  String transferFeePart(String from, String to) {
    return 'ट्रान्सफर $from → $to को अंश। यो शुल्क मेटाउँदा ट्रान्सफर रहन्छ।';
  }

  @override
  String get transferReceivedShort => 'प्राप्त';

  @override
  String get ledgerTransfers => 'ट्रान्सफर';

  @override
  String get historyTransferCreated => 'ट्रान्सफर बनाइयो';

  @override
  String get historyTransferUpdated => 'ट्रान्सफर अपडेट भयो';

  @override
  String importLooksTransferTo(String account) {
    return '$account मा ट्रान्सफर जस्तो देखिन्छ';
  }

  @override
  String importLooksTransferFrom(String account) {
    return '$account बाट ट्रान्सफर जस्तो देखिन्छ';
  }

  @override
  String get importMakeTransfer => 'ट्रान्सफर बनाउनुहोस्';

  @override
  String get importWillTransfer =>
      'ट्रान्सफरको रूपमा सेभ हुन्छ · आम्दानी वा खर्च होइन';

  @override
  String get importUndo => 'पूर्ववत्';

  @override
  String get importAsTransfers => 'ट्रान्सफरको रूपमा';

  @override
  String get tags => 'ट्याग';

  @override
  String get tagAdd => 'ट्याग थप्नुहोस्';

  @override
  String get tagSearchHint => 'ट्याग खोज्नुहोस् वा बनाउनुहोस्';

  @override
  String tagCreate(String tag) {
    return '#$tag बनाउनुहोस्';
  }

  @override
  String get tagUsedBefore => 'पहिले प्रयोग भएका';

  @override
  String get tagNoneYet =>
      'अहिलेसम्म ट्याग छैन। माथि टाइप गर्नुहोस्, जस्तै #wedding वा #japan-trip।';

  @override
  String tagRemove(String tag) {
    return '#$tag हटाउनुहोस्';
  }

  @override
  String get tagsHint =>
      'ट्यागले पैसा केका लागि खर्च भयो भन्छ, जुनसुकै खाताबाट भए पनि। नाम बदल्दा सबै कारोबार अपडेट हुन्छन्; मिलाउँदा कारोबार अर्को ट्यागमा सर्छन्।';

  @override
  String get tagsEmpty =>
      'अहिलेसम्म ट्याग छैन। यहाँ वा कारोबार फारमबाट थप्नुहोस् — जस्तै #wedding वा #japan-trip।';

  @override
  String get tagNew => 'नयाँ ट्याग';

  @override
  String tagOpenSummary(String tag) {
    return '#$tag खोल्नुहोस्';
  }

  @override
  String tagMerge(String tag) {
    return '#$tag मिलाउनुहोस्';
  }

  @override
  String tagDeleteAction(String tag) {
    return '#$tag मेटाउनुहोस्';
  }

  @override
  String tagMergeTitle(String tag) {
    return '#$tag लाई कुन ट्यागमा मिलाउने?';
  }

  @override
  String tagMergeBody(String tag) {
    return '#$tag भएका कारोबार तपाईंले छानेको ट्यागमा सर्छन्, र #$tag हट्छ।';
  }

  @override
  String tagMerged(String from, String to) {
    return '#$from लाई #$to मा मिलाइयो';
  }

  @override
  String tagRenamed(String tag) {
    return '#$tag मा नाम बदलियो';
  }

  @override
  String tagDeleteTitle(String tag) {
    return '#$tag मेटाउने?';
  }

  @override
  String tagDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कारोबारबाट हट्छ; कारोबार रहन्छन्।',
      one: '1 कारोबारबाट हट्छ; कारोबार रहन्छ।',
      zero: 'कुनै कारोबारमा छैन।',
    );
    return '$_temp0';
  }

  @override
  String tagDeleted(String tag) {
    return '#$tag मेटियो';
  }

  @override
  String get tagSpent => 'खर्च';

  @override
  String get tagReceived => 'प्राप्त';

  @override
  String get tagEmpty => 'यो ट्याग अहिलेसम्म कुनै कारोबारमा छैन।';

  @override
  String tagRenameTitle(String tag) {
    return '#$tag को नाम बदल्नुहोस्';
  }

  @override
  String importTagAll(int count) {
    return 'सबै $count पङ्क्तिमा ट्याग राख्नुहोस्…';
  }

  @override
  String importTaggedAll(String tags) {
    return 'सबै पङ्क्तिमा $tags ट्याग';
  }

  @override
  String get insightsTagsTitle => 'ट्याग';

  @override
  String get insightsTagsEmpty =>
      'हरेक योजना वा कार्यक्रममा कति लाग्यो हेर्न कारोबारमा ट्याग राख्नुहोस् (#wedding, #japan-trip)।';

  @override
  String get insightsTransfersNote =>
      'तपाईंका खाताबीचका ट्रान्सफर यहाँ गनिँदैनन्।';

  @override
  String get historyTags => 'ट्याग अपडेट भयो';

  @override
  String get clear => 'हटाउनुहोस्';

  @override
  String get search => 'खोज्नुहोस्';

  @override
  String get searchHint => 'शीर्षक, टिप्पणी, रकम, रेफरेन्स';

  @override
  String get searchRecent => 'हालैका खोजहरू';

  @override
  String get searchTip =>
      'सबै खातामा खोज्छ। पसलको नाम, टिप्पणी, 5000 जस्तो रकम, वा NEFT-88213 जस्तो रेफरेन्स खोज्नुहोस्।';

  @override
  String searchResults(int count) {
    return '$count नतिजा';
  }

  @override
  String searchNoneTitle(String query) {
    return '“$query” को नतिजा भेटिएन';
  }

  @override
  String get searchNoneBody =>
      'कुनै खातामा मिल्दो कारोबार छैन। हिज्जे जाँच्नुहोस्, वा अल्पविराम बिना रकम खोज्नुहोस्।';

  @override
  String get searchClear => 'खोज हटाउनुहोस्';

  @override
  String get searchClearRecent => 'हालैका खोजहरू हटाउनुहोस्';

  @override
  String get feedFilterAccount => 'खाता';

  @override
  String get feedFilterAccountType => 'खाताको प्रकार';

  @override
  String get feedFilterKind => 'आम्दानी / खर्च';

  @override
  String get feedAllAccounts => 'सबै खाता';

  @override
  String get feedAllTypes => 'सबै प्रकार';

  @override
  String get feedAllTags => 'सबै ट्याग';

  @override
  String get feedEverything => 'आम्दानी, खर्च र ट्रान्सफर';

  @override
  String get feedNoMatchBody =>
      'अर्को खाता वा वर्ग छान्नुहोस्, वा फिल्टर हटाउनुहोस्।';

  @override
  String get entrySaveAnother => 'सेभ गरेर अर्को थप्नुहोस्';

  @override
  String get entrySavedKeepGoing => 'सेभ भयो · अर्कोका लागि विवरण राखियो';

  @override
  String get templateStar => 'टेम्प्लेट';

  @override
  String get templateStarHint => 'टेम्प्लेटको रूपमा सेभ गर्नुहोस्';

  @override
  String templateSaved(String title, String amount) {
    return 'टेम्प्लेट सेभ भयो · $title · $amount';
  }

  @override
  String get templateNeedsFields => 'पहिले रकम र शीर्षक लेख्नुहोस्';

  @override
  String get templates => 'टेम्प्लेट';

  @override
  String get templatesHint =>
      'दोहोरिने कारोबार सेभ गर्न फारममा ★ थिच्नुहोस्। टेम्प्लेट फारमको माथि देखिन्छन्, एक थिचाइमा भरिन्छ।';

  @override
  String get templatesManage => 'व्यवस्थापन';

  @override
  String get templateUse => 'प्रयोग';

  @override
  String templateDelete(String title) {
    return '$title टेम्प्लेट मेटाउनुहोस्';
  }

  @override
  String get templateDeleted => 'टेम्प्लेट मेटियो';

  @override
  String get templatesEmptyTitle => 'अहिलेसम्म टेम्प्लेट छैन';

  @override
  String get templatesEmptyBody =>
      '“Momo · Rs 450 · Cafe · Cash” जस्तो कारोबार भरेर ★ थिच्नुहोस्।';

  @override
  String get templatesNewCashOut => 'नयाँ खर्च';

  @override
  String entrySuggestion(String title) {
    return '“$title” प्रयोग गर्नुहोस्';
  }

  @override
  String get backupTitle => 'ब्याकअप र रिस्टोर';

  @override
  String get backupLast => 'पछिल्लो ब्याकअप';

  @override
  String get backupCreate => 'ब्याकअप बनाउनुहोस्';

  @override
  String get backupRestore => 'ब्याकअपबाट रिस्टोर गर्नुहोस्';

  @override
  String get backupIncludes =>
      'ब्याकअपमा खाता, कारोबार, ट्याग, टेम्प्लेट, लक्ष्य र बाँडफाँड समावेश हुन्छन्। एउटा प्रति यो फोनबाहिर राख्नुहोस् — Drive, इमेल वा कम्प्युटरमा।';

  @override
  String get restoreMerge => 'मिलाउनुहोस् (दोहोरिएका छोड्ने)';

  @override
  String get restoreMergeBody =>
      'नभएका मात्र थपिन्छन्। फोनमा भएका कारोबार रहन्छन्, दोहोरिएका छोडिन्छन्।';

  @override
  String get restoreReplace => 'सबै बदल्नुहोस्';

  @override
  String get restoreReplaceBody =>
      'यो फोनको सबै डाटा मेटाएर फाइलबाट रिस्टोर गर्छ।';

  @override
  String get restoreReplaceWarnTitle => 'यो फिर्ता गर्न सकिँदैन';

  @override
  String get restoreReplaceWarnBody =>
      'यो फोनमा भएका सबै डाटा मेटिनेछन् र ब्याकअपले बदलिनेछन्।';

  @override
  String get restoreUnderstand => 'मैले बुझें। मेरो डाटा मेटाएर बदल्नुहोस्।';

  @override
  String get restoreRunning => 'रिस्टोर हुँदैछ…';

  @override
  String get restoreDone => 'रिस्टोर सम्पन्न भयो';

  @override
  String get restoreContinue => 'अगाडि बढ्नुहोस्';

  @override
  String get backupNudgeBody =>
      'तपाईंको डाटा यही फोनमा मात्र छ। ब्याकअप गर्न 5 सेकेन्ड लाग्छ।';

  @override
  String get backupNow => 'अहिले ब्याकअप गर्नुहोस्';

  @override
  String get restoreFileHas => 'यो फाइलमा के छ';

  @override
  String get restoreHow => 'कसरी रिस्टोर गर्ने?';

  @override
  String get restoreRecommended => 'सिफारिस';

  @override
  String get restoreGoHome => 'गृहमा जानुहोस्';

  @override
  String get restoreTryOther => 'अर्को फाइल छान्नुहोस्';

  @override
  String get restoreRange => 'मिति दायरा';

  @override
  String get restoreCreated => 'बनाइएको';

  @override
  String get restoreVersion => 'एप संस्करण';

  @override
  String get restoreErrWrongTitle => 'यो Paisa Flow ब्याकअप होइन';

  @override
  String get restoreErrWrongBody =>
      'सेटिङ → ब्याकअप र रिस्टोरबाट बनाइएको .pfbak फाइल छान्नुहोस्। बैंक स्टेटमेन्ट थप्न आयात प्रयोग गर्नुहोस्।';

  @override
  String get restoreErrBadTitle => 'यो ब्याकअप बिग्रिएको छ';

  @override
  String get restoreErrBadBody =>
      'फाइल अधुरो छ, त्यसैले केही पनि रिस्टोर भएन। ब्याकअपको अर्को प्रति प्रयास गर्नुहोस्।';

  @override
  String get restoreErrNewTitle => 'नयाँ संस्करणबाट बनाइएको';

  @override
  String get restoreUnchanged => 'यो फोनको डाटा परिवर्तन भएको छैन।';

  @override
  String get backupProtect => 'पासवर्डले सुरक्षित गर्नुहोस् (सिफारिस)';

  @override
  String get backupProtectBody =>
      'फाइल पाउने जो कोहीलाई रिस्टोर गर्न यो पासवर्ड चाहिन्छ।';

  @override
  String get backupPassword => 'ब्याकअप पासवर्ड';

  @override
  String get backupPasswordAgain => 'फेरि टाइप गर्नुहोस्';

  @override
  String get backupPasswordLost =>
      'बिर्सिएको पासवर्ड कसैले पनि फिर्ता दिन सक्दैन। सुरक्षित ठाउँमा लेखेर राख्नुहोस्।';

  @override
  String get backupNoPasswordTitle =>
      'पासवर्डबिना ब्याकअप लुकेको हुन्छ, तर पूर्ण सुरक्षित हुँदैन';

  @override
  String get backupNoPasswordBody =>
      'फाइल इन्क्रिप्ट हुन्छ, अरू एपले पढ्न सक्दैनन्, तर Paisa Flow भएका जो कोहीले रिस्टोर गर्न सक्छन्।';

  @override
  String get backupEncrypted =>
      'ब्याकअप सधैं कम्प्रेस र इन्क्रिप्ट हुन्छन्। Paisa Flow मा मात्र खुल्छन्।';

  @override
  String get backupPasswordsMatch => 'पासवर्ड मिल्यो';

  @override
  String get restoreLockedTitle => 'यो ब्याकअप पासवर्डले सुरक्षित छ';

  @override
  String get restoreLockedBody => 'ब्याकअप बनाउँदा राखेको पासवर्ड हाल्नुहोस्।';

  @override
  String get restoreWrongPassword =>
      'गलत पासवर्ड। ठूलो/सानो अक्षर जाँचेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get restoreUnlock => 'ब्याकअप खोल्नुहोस्';

  @override
  String get restoreForgotPassword =>
      'बिर्सनुभयो? पासवर्ड फिर्ता हुँदैन — अर्को ब्याकअप फाइल प्रयास गर्नुहोस्।';

  @override
  String get backupOnPhone => 'अहिले यो फोनमा';

  @override
  String get restoreKeepOpen =>
      'Paisa Flow खुला राख्नुहोस्। केही सेकेन्ड लाग्छ।';

  @override
  String get restoreNotSure =>
      'पक्का हुनुहुन्न? पछाडि गएर मिलाउनुहोस् छान्नुहोस् — यसले केही मेटाउँदैन।';

  @override
  String backupNudgeTitle(int days) {
    return '$days दिनदेखि ब्याकअप छैन';
  }

  @override
  String get backupNever => 'कहिल्यै होइन';

  @override
  String backupDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिनअघि',
      one: 'हिजो',
      zero: 'आज',
    );
    return '$_temp0';
  }

  @override
  String tagCount(int count) {
    return '$count ट्याग';
  }

  @override
  String get backupCreateProtected => 'पासवर्डसहित ब्याकअप बनाउनुहोस्';

  @override
  String backupSaved(String file) {
    return 'ब्याकअप सेभ भयो · $file';
  }

  @override
  String backupSaveFailed(String error) {
    return 'ब्याकअप सेभ भएन: $error';
  }

  @override
  String get backupPasswordTooShort => 'कम्तीमा 6 अक्षर प्रयोग गर्नुहोस्';

  @override
  String get backupPasswordsDiffer => 'पासवर्ड मिलेन';

  @override
  String get backupStrengthWeak => 'कमजोर';

  @override
  String get backupStrengthOkay => 'ठीकै';

  @override
  String get backupStrengthStrong => 'बलियो';

  @override
  String get backupShowPassword => 'पासवर्ड देखाउनुहोस्';

  @override
  String get backupHidePassword => 'पासवर्ड लुकाउनुहोस्';

  @override
  String restoreErrNewBody(String version) {
    return 'यो ब्याकअप Paisa Flow $version बाट बनाइएको हो। Play Store बाट एप अपडेट गरेर फेरि रिस्टोर गर्नुहोस्।';
  }

  @override
  String restoreMergeStat(String added, String existing) {
    return '$added थपिन्छ · $existing पहिले नै छ';
  }

  @override
  String restoreReplaceStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'यो फोनका $count कारोबार मेटिनेछन्',
      zero: 'यो फोनबाट केही मेटिँदैन',
    );
    return '$_temp0';
  }

  @override
  String restoreDoneMerge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कारोबार थपियो। यो फोनबाट केही हटाइएन।',
      zero: 'ब्याकअपका सबै कुरा पहिले नै थिए। केही हटाइएन।',
    );
    return '$_temp0';
  }

  @override
  String restoreDoneReplace(String date) {
    return 'तपाईंको डाटा अब $date को ब्याकअपसँग मिल्छ।';
  }

  @override
  String get restoreStepCheck => 'फाइल जाँच्दै';

  @override
  String get restoreStepData => 'खाता र कारोबार रिस्टोर गर्दै';

  @override
  String get restoreStepBalances => 'मौज्दात फेरि हिसाब गर्दै';

  @override
  String get restoreReading => 'ब्याकअप पढ्दै…';

  @override
  String get restoreAccountsLabel => 'खाता';

  @override
  String get restoreEntriesLabel => 'कारोबार';

  @override
  String get lockTitle => 'एप लक';

  @override
  String get lockSetPin => '4 अङ्कको PIN सेट गर्नुहोस्';

  @override
  String get lockEnterPin => 'आफ्नो PIN हाल्नुहोस्';

  @override
  String get lockConfirmPin => 'PIN फेरि हाल्नुहोस्';

  @override
  String get lockBiometrics => 'औंठाछाप वा अनुहारले खोल्नुहोस्';

  @override
  String get lockAfterLabel => 'एप पृष्ठभूमिमा गएपछि लक हुने समय';

  @override
  String get lockImmediately => 'तुरुन्तै';

  @override
  String get lockAfter1 => '1 मिनेटपछि';

  @override
  String get lockAfter5 => '5 मिनेटपछि';

  @override
  String get lockChangePin => 'PIN परिवर्तन गर्नुहोस्';

  @override
  String get lockTurnOff => 'एप लक बन्द गर्नुहोस्';

  @override
  String get lockNoRecoveryTitle => 'बिर्सिएको PIN फिर्ता पाउने उपाय छैन';

  @override
  String get lockNoRecoveryBody =>
      'तपाईंको डाटा यही फोनमा मात्र छ। PIN बिर्सिनुभयो भने एप फेरि इन्स्टल गर्नुपर्छ, र ब्याकअपबाट मात्र डाटा फर्काउन सकिन्छ।';

  @override
  String get lockIntro =>
      'PIN, औंठाछाप वा अनुहारले आफ्ना खाता सुरक्षित राख्नुहोस्।';

  @override
  String get lockOn => 'एप लक सक्रिय छ';

  @override
  String get lockPinsDiffer => 'PIN मिलेन। फेरि प्रयास गर्नुहोस्।';

  @override
  String get lockForgot => 'PIN बिर्सनुभयो?';

  @override
  String get lockGoToBackup => 'ब्याकअप र रिस्टोरमा जानुहोस्';

  @override
  String get lockFeaturePin => '4 अङ्कको PIN';

  @override
  String get lockFeatureBiometrics => 'औंठाछाप वा अनुहारले खोल्ने';

  @override
  String get lockFeatureSwitcher => 'एप स्विचरमा लुकाइन्छ';

  @override
  String get lockNow => 'अहिले लक गर्नुहोस्';

  @override
  String get lockOffNeedsPin =>
      'बिर्सिएको PIN फिर्ता पाउन सकिँदैन। लक बन्द गर्न PIN चाहिन्छ।';

  @override
  String lockWrongPin(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'गलत PIN · $left पटक बाँकी',
    );
    return '$_temp0';
  }

  @override
  String lockTooMany(int seconds) {
    return 'धेरै पटक गलत प्रयास · $seconds सेकेन्डमा फेरि प्रयास गर्नुहोस्';
  }

  @override
  String lockStep(int step) {
    return 'चरण $step / 2';
  }

  @override
  String get lockNewPin => 'नयाँ PIN हाल्नुहोस्';

  @override
  String get lockCurrentPin => 'हालको PIN हाल्नुहोस्';

  @override
  String get lockOnToast => 'एप लक सक्रिय भयो';

  @override
  String get lockOffToast => 'एप लक बन्द भयो';

  @override
  String get lockChangedToast => 'PIN परिवर्तन भयो';

  @override
  String get lockBiometricReason => 'Paisa Flow खोल्नुहोस्';

  @override
  String get lockUseBiometrics => 'औंठाछाप वा अनुहार प्रयोग गर्नुहोस्';

  @override
  String get lockDeleteDigit => 'अङ्क मेटाउनुहोस्';

  @override
  String lockStatus(String method, String after) {
    return '$method · $after';
  }

  @override
  String get lockMethodPin => 'PIN';

  @override
  String get lockMethodPinBio => 'PIN र औंठाछाप वा अनुहार';

  @override
  String get lockHidden => 'सामग्री लुकाइएको';

  @override
  String get settingsOn => 'सक्रिय';

  @override
  String get settingsOff => 'बन्द';

  @override
  String get emiTitle => 'EMI क्याल्कुलेटर';

  @override
  String get emiEntryBody => 'मासिक किस्ता हिसाब गरेर रिमाइन्डर राख्नुहोस्';

  @override
  String get emiPrincipal => 'ऋण रकम (साँवा)';

  @override
  String get emiRate => 'ब्याज दर · वार्षिक';

  @override
  String get emiTenure => 'अवधि';

  @override
  String get emiTotalInterest => 'कुल ब्याज';

  @override
  String get emiTotalPayable => 'कुल तिर्नुपर्ने';

  @override
  String get emiRepeat => 'मासिक ट्रान्सफरको रूपमा दोहोर्याउनुहोस्';

  @override
  String get emiRepeatBody =>
      'हरेक EMI पुष्टि गर्न पपअप आउँछ। आफैं केही थपिँदैन।';

  @override
  String get emiNote =>
      'घट्दो मौज्दात विधिबाट अनुमान। शुल्क र राउन्डिङले बैंकको रकम अलि फरक पर्न सक्छ।';

  @override
  String get repeatLabel => 'दोहोर्याउने';

  @override
  String get repeatConfirmEach => 'हरेक पटक तपाईंलाई सोधिन्छ';

  @override
  String get repeatNever => 'कहिल्यै होइन';

  @override
  String get repeatDaily => 'हरेक दिन';

  @override
  String get repeatWeekly => 'हरेक हप्ता';

  @override
  String get repeatMonthly => 'हरेक महिना';

  @override
  String get repeatYearly => 'हरेक वर्ष';

  @override
  String repeatSaved(String when) {
    return 'सेभ भयो · $when दोहोरिन्छ';
  }

  @override
  String get repeatingTitle => 'दोहोरिने कारोबार';

  @override
  String get repeatingHint =>
      'यी आफैं थपिँदैनन्। समय भएपछि Paisa Flow ले पुष्टि गर्न सोध्छ।';

  @override
  String get repeatingEmpty =>
      'अहिलेसम्म केही दोहोरिँदैन। कारोबार फारममा “दोहोर्याउने” छान्नुहोस्, वा ऋणको EMI राख्नुहोस्।';

  @override
  String repeatingNext(String date) {
    return 'अर्को: $date';
  }

  @override
  String repeatingStop(String title) {
    return '$title दोहोर्याउन रोक्नुहोस्';
  }

  @override
  String get repeatingStopped => 'दोहोर्याउन रोकियो';

  @override
  String dueTitle(int count) {
    return '$count कारोबार बाँकी';
  }

  @override
  String get dueBody => 'चिन्ह लगाइएका थपिन्छन्। नतिरेको भए चिन्ह हटाउनुहोस्।';

  @override
  String get dueToday => 'आज';

  @override
  String dueDaysAgo(int days) {
    return '$days दिनअघि';
  }

  @override
  String dueAdd(int count) {
    return '$count कारोबार थप्नुहोस्';
  }

  @override
  String get dueSkip => 'यी छोड्नुहोस्';

  @override
  String get dueLater => 'पछि सोध्नुहोस्';

  @override
  String dueAdded(int count) {
    return '$count कारोबार थपियो';
  }

  @override
  String dueEdit(String title) {
    return 'थप्नुअघि $title सम्पादन गर्नुहोस्';
  }

  @override
  String dueTick(String title) {
    return '$title थप्नुहोस्';
  }

  @override
  String emiOutstanding(String loan, String amount) {
    return '$loan · तिर्न बाँकी $amount';
  }

  @override
  String emiUseOutstanding(String amount) {
    return 'तिर्न बाँकी $amount प्रयोग गर्नुहोस्';
  }

  @override
  String emiYears(int months) {
    return 'वर्ष · $months महिना';
  }

  @override
  String emiYearsChip(int years) {
    return '$years वर्ष';
  }

  @override
  String emiMonthly(int months) {
    return 'मासिक किस्ता · $months महिना';
  }

  @override
  String get emiMonth => 'महिना';

  @override
  String get emiPrincipalCol => 'साँवा';

  @override
  String get emiInterestCol => 'ब्याज';

  @override
  String get emiBalanceCol => 'बाँकी';

  @override
  String emiPayFrom(int day) {
    return 'हरेक महिनाको $day गते यहाँबाट तिर्ने';
  }

  @override
  String emiSetUp(String amount) {
    return 'मासिक EMI राख्नुहोस् · $amount';
  }

  @override
  String get emiDone => 'सकियो';

  @override
  String get emiSaved => 'EMI राखियो · हरेक पटक पुष्टि गर्नुहुनेछ';

  @override
  String get emiErrAmount => 'ऋण रकम लेख्नुहोस्';

  @override
  String get emiErrTenure => 'कम्तीमा 1 महिनाको अवधि लेख्नुहोस्';

  @override
  String get emiErrRate => '0 देखि 60% बीचको वार्षिक दर लेख्नुहोस्';

  @override
  String get emiNoFrom => 'EMI तिर्न बैंक, नगद वा वालेट खाता थप्नुहोस्।';

  @override
  String get historyRepeated => 'दोहोरिने कारोबारबाट थपियो';

  @override
  String get insightsCustomize => 'मिलाउनुहोस्';

  @override
  String get chartFlow => 'प्रवाह';

  @override
  String get chartCalendar => 'पात्रो';

  @override
  String get chartPace => 'गति';

  @override
  String get chartShowList => 'सूचीमा देखाउनुहोस्';

  @override
  String get chartShowChart => 'चार्टमा देखाउनुहोस्';

  @override
  String get chartsRule =>
      'हरेक चार्टमा एउटै मुद्रा। ट्रान्सफर र सुरुको मौज्दात गनिँदैनन्।';

  @override
  String flowTitle(String month) {
    return '$month को प्रवाह';
  }

  @override
  String flowSub(String income, String spent) {
    return '$income आयो · $spent गयो';
  }

  @override
  String flowSaved(String amount, int percent) {
    return 'तपाईंले $amount बचाउनुभयो · आएको $percent%';
  }

  @override
  String flowOver(String amount) {
    return 'आएभन्दा $amount बढी खर्च भयो, मौज्दातबाट';
  }

  @override
  String flowEmpty(String month) {
    return '$month मा केही आएन, केही गएन।';
  }

  @override
  String get flowIncome => 'आम्दानी';

  @override
  String get flowSpending => 'खर्च';

  @override
  String get flowSavedNode => 'बचत';

  @override
  String get flowFromBalance => 'मौज्दातबाट';

  @override
  String get flowOthers => 'अन्य';

  @override
  String get paceTitle => 'खर्चको गति';

  @override
  String paceSpentBy(String date) {
    return '$date सम्म खर्च';
  }

  @override
  String paceProjected(String amount) {
    return 'यो महिना करिब $amount पुग्ने';
  }

  @override
  String get paceThisMonth => 'यो महिना';

  @override
  String get paceLastMonth => 'गत महिना';

  @override
  String get paceProjection => 'अनुमान';

  @override
  String get paceBudget => 'बजेट';

  @override
  String paceMore(String amount) {
    return 'गत महिनाको यही दिनभन्दा $amount बढी';
  }

  @override
  String paceLess(String amount) {
    return 'गत महिनाको यही दिनभन्दा $amount कम';
  }

  @override
  String get paceSame => 'गत महिनाको यही दिनजत्तिकै';

  @override
  String get paceNoBudget => 'अहिलेसम्म बजेट छैन। बजेट छिट्टै आउँदैछ।';

  @override
  String paceEmpty(String month) {
    return '$month वा अघिल्लो महिनामा खर्च छैन।';
  }

  @override
  String get paceDay => 'दिन';

  @override
  String calListTitle(String month) {
    return '$month दिनअनुसार';
  }

  @override
  String get boxesTap => 'वर्ग हेर्न बाकस थिच्नुहोस्';

  @override
  String get placesTitle => 'धेरै खर्च भएका ठाउँ';

  @override
  String placesSub(String month) {
    return '$month मा सबैभन्दा धेरै खर्च';
  }

  @override
  String placesMeta(int count, String category) {
    return '$count पटक · $category';
  }

  @override
  String placesEmpty(String month) {
    return '$month मा अहिलेसम्म खर्च छैन।';
  }

  @override
  String get layoutTitle => 'विश्लेषण मिलाउनुहोस्';

  @override
  String get layoutIntro =>
      'तीरले कार्डको क्रम मिलाउनुहोस्, नचाहिनेलाई लुकाउनुहोस्।';

  @override
  String get layoutPinned => 'खाता र महिना सधैं माथि रहन्छ';

  @override
  String get layoutReset => 'सुरुकै क्रममा फर्काउनुहोस्';

  @override
  String layoutHidden(int count) {
    return '$count कार्ड लुकाइएको · मिलाउनुहोस्';
  }

  @override
  String get layoutAllHiddenTitle => 'सबै कार्ड लुकाइएका छन्';

  @override
  String get layoutAllHiddenBody => 'मिलाउनुहोस्मा केही फेरि देखाउनुहोस्।';

  @override
  String layoutUp(String card) {
    return '$card माथि सार्नुहोस्';
  }

  @override
  String layoutDown(String card) {
    return '$card तल सार्नुहोस्';
  }

  @override
  String layoutShow(String card) {
    return '$card देखाउनुहोस्';
  }

  @override
  String get cardCharts => 'प्रवाह, पात्रो र गति';

  @override
  String get cardTrends => 'प्रवृत्ति';

  @override
  String get cardModes => 'भुक्तानी माध्यमअनुसार';

  @override
  String get catLast6 => 'पछिल्ला 6 महिना';

  @override
  String get catAverage => 'औसत';

  @override
  String catMore(String amount) {
    return 'सामान्यभन्दा $amount बढी';
  }

  @override
  String catLess(String amount) {
    return 'सामान्यभन्दा $amount कम';
  }

  @override
  String get catUsual => 'सामान्यजस्तै';

  @override
  String catEntries(String month) {
    return '$month का कारोबार';
  }

  @override
  String catNone(String category, String month) {
    return '$month मा $category मा केही खर्च भएन।';
  }

  @override
  String get budgetsTitle => 'बजेट';

  @override
  String get budgetScope => 'बजेट कसका लागि';

  @override
  String budgetScopeAll(String currency) {
    return 'सबै $currency खाता';
  }

  @override
  String budgetMonth(String month) {
    return '$month · 1 गते फेरि सुरु हुन्छ';
  }

  @override
  String get budgetEmptyTitle => 'अहिलेसम्म बजेट छैन';

  @override
  String get budgetEmptyBody =>
      'कुनै वर्ग वा सबैका लागि मासिक सीमा राख्नुहोस्। खर्च गर्दै जाँदा कति बाँकी छ देखिन्छ।';

  @override
  String get budgetExample => 'उदाहरणका लागि';

  @override
  String get budgetFirst => 'वर्गको बजेट राख्नुहोस्';

  @override
  String get budgetAddOverall => 'कुल बजेट राख्नुहोस्';

  @override
  String get budgetOverall => 'कुल बजेट';

  @override
  String get budgetByCategory => 'वर्गअनुसार';

  @override
  String get budgetAddCategory => 'वर्गको बजेट थप्नुहोस्';

  @override
  String budgetLeft(String amount) {
    return '$amount बाँकी';
  }

  @override
  String budgetOver(String amount) {
    return '$amount बढी';
  }

  @override
  String budgetOf(String spent, String limit) {
    return '$limit मध्ये $spent';
  }

  @override
  String get budgetAllOk => 'यो महिना सबै बजेटभित्र छ।';

  @override
  String budgetNear(String category, int percent) {
    return '$category बजेटको $percent% पुग्यो';
  }

  @override
  String budgetOverNote(String category, String amount) {
    return '$category बजेटभन्दा $amount बढी';
  }

  @override
  String get budgetRule =>
      'हरेक बजेट एउटै मुद्रामा, रूपान्तरण हुँदैन। ट्रान्सफर र सुरुको मौज्दात गनिँदैन। सूचना पठाइँदैन।';

  @override
  String budgetNoAccountsTitle(String currency) {
    return '$currency खाता छैन';
  }

  @override
  String get budgetNoAccountsBody =>
      'बजेटले यो मुद्राका खाताको खर्च गन्छ। खाता थप्नुहोस्, वा अर्को छान्नुहोस्।';

  @override
  String get budgetAddAccount => 'खाता थप्नुहोस्';

  @override
  String get budgetOtherScope => 'अर्को छान्नुहोस्';

  @override
  String get budgetNew => 'नयाँ बजेट';

  @override
  String get budgetEdit => 'बजेट सम्पादन';

  @override
  String get budgetCategoryLabel => 'केका लागि';

  @override
  String get budgetHas => 'छ';

  @override
  String get budgetLimit => 'मासिक सीमा';

  @override
  String get budgetErrAmount => 'शून्यभन्दा बढी सीमा लेख्नुहोस्';

  @override
  String budgetHint(String amount) {
    return 'तपाईं प्रायः करिब $amount खर्च गर्नुहुन्छ';
  }

  @override
  String get budgetHintSub => 'पछिल्ला 3 महिनाको औसत';

  @override
  String get budgetUseIt => 'यही राख्नुहोस्';

  @override
  String budgetSpentSoFar(String amount) {
    return 'यो महिना अहिलेसम्म $amount खर्च';
  }

  @override
  String get budgetNoCarry => 'नचलेको बजेट सर्दैन; हरेक महिना नयाँ सुरु हुन्छ।';

  @override
  String get budgetSaved => 'बजेट सेभ भयो';

  @override
  String get budgetDeleted => 'बजेट मेटियो';

  @override
  String get budgetDelete => 'बजेट मेटाउनुहोस्';

  @override
  String get budgetBadgeOver => 'बढी';

  @override
  String get paceSetBudget => 'बजेट राख्नुहोस्';

  @override
  String paceWithin(String amount) {
    return 'बजेटभित्र · $amount बाँकी';
  }

  @override
  String paceGoingOver(String amount) {
    return 'यही गतिमा बजेटभन्दा $amount बढी जान्छ';
  }

  @override
  String paceOverBudget(String amount) {
    return 'बजेटभन्दा $amount बढी';
  }

  @override
  String get paceNoBudgetSet => 'यसका लागि बजेट छैन।';

  @override
  String catBudgetLine(String amount) {
    return 'बजेट $amount';
  }

  @override
  String get catNoBudget => 'यो वर्गको बजेट छैन।';

  @override
  String subJust(String category) {
    return '$category मात्र';
  }

  @override
  String subNone(String category) {
    return '$category (उपवर्ग छैन)';
  }

  @override
  String get subcategories => 'उपवर्ग';

  @override
  String get subAdd => 'उपवर्ग थप्नुहोस्';

  @override
  String get subTitle => 'वर्गहरू';

  @override
  String get subIntro =>
      'उपवर्ग मिलाउन वर्ग थिच्नुहोस्। नाम बदल्दा सबै कारोबार अपडेट हुन्छन्।';

  @override
  String subCount(int count) {
    return '$count उपवर्ग';
  }

  @override
  String get subNoneTitle => 'अहिलेसम्म उपवर्ग छैन';

  @override
  String get subNoneBody => 'तल थप्नुहोस्, जस्तै Food मुनि Lunch वा Groceries।';

  @override
  String subNewHint(String category) {
    return '$category मुनि नयाँ उपवर्ग';
  }

  @override
  String subDeleteNote(String category) {
    return 'उपवर्ग मेटाउँदा यसका कारोबार $category मा सर्छन्।';
  }

  @override
  String subDeleteTitle(String name) {
    return '$name मेटाउने?';
  }

  @override
  String subDeleteBody(int count, String category) {
    return '$count कारोबार $category मा सर्छन्।';
  }

  @override
  String subRename(String name) {
    return '$name को नाम बदल्नुहोस्';
  }

  @override
  String subMoveUp(String name) {
    return '$name माथि सार्नुहोस्';
  }

  @override
  String subMoveDown(String name) {
    return '$name तल सार्नुहोस्';
  }

  @override
  String get subAddFor => 'उपवर्ग थप्नुहोस्';

  @override
  String get subPickOne => 'उपवर्ग छान्नुहोस्';

  @override
  String subEntryUses(int count) {
    return '$count कारोबार';
  }

  @override
  String get subManageCategories => 'वर्ग मिलाउनुहोस्';

  @override
  String get amountInvalid =>
      '1250 वा 1250.50 जस्तो अङ्क लेख्नुहोस् (एउटा दशमलव, बढीमा 2 अङ्क)।';

  @override
  String amountTooLarge(String max) {
    return 'रकम बढीमा $max सम्म हुन सक्छ।';
  }
}
