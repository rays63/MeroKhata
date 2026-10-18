import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:paisa_flow/data/description_cleaner.dart';

void main() {
  final cases = {
    // QR payments.
    'QR PAYMENT-23089117ue2W, MEGA MART NAGAUN': 'QR · Mega Mart Nagaun',
    'QR PAYMENT-5869619ab1, ALKA CANTEEN 2': 'QR · Alka Canteen',
    'MPAYFPQR,45658013Axac,L.N. AND SONS,artic': 'QR · L.N. AND Sons · artic',
    'MPAYFPQR,45733990hpiz,Baithak,chiya': 'QR · Baithak · chiya',
    'MPAY FPQR,': 'QR payment',
    'NQR-1234567,': 'QR payment',
    // Wallets.
    'LoadeSewa/368308647': 'eSewa load',
    'eSewa Load 9761613321,274810521': 'eSewa load',
    'Khalti Load/123456789/9800000000': 'Khalti load',
    'Load Wallet Khalti9813049975,276332353': 'Khalti load',
    'ESWWD:1234567890123:NARBNPKA': 'eSewa withdrawal',
    // Transfers.
    'CIPS//ACCOUNTFT:Sita Sharma/Loan Paid': 'IPS · Sita Sharma · Loan Paid',
    'ACCOUNTFT:': 'IPS transfer',
    'IPS/NMB/12.5%CBBLDIV8182043547': 'IPS · 12.5% CBBL dividend',
    'FPY:IBFT:1208383777:5036:BOALNPKA:JBBLNPKA:BIBEK M': 'Fonepay · Bibek M',
    'FPY:IBFT:1208383777:5036:1234567890:SIDDNPKA:': 'Fonepay transfer',
    'MoBank, Petrol ,TraceID-371190011': 'Mobile banking · Petrol',
    'MPAY NABIL,': 'Mobile banking · Nabil',
    'Fund transfer for CASBA : SHPDL': 'ASBA · SHPDL',
    '123456789 SITA SHARMA| IBFTCHARGES|': 'IBFT charges',
    '123456789 SITA SHARMA|987654321|IBFT|2026': 'IBFT · Sita Sharma',
    // Other.
    'NT Prepaid Topup,9841000000': 'Topup · NT prepaid',
    'Ncell Topup,306247549': 'Topup · Ncell',
    'ATM WDL/12345678/NABIL\\NABIL': 'ATM withdrawal',
    'CWDR/123456/4111XXXXXXXX1111': 'ATM withdrawal',
    'NPS/URP123#REMI12345678901/001': 'Remittance',
    'CEMT / 7028126109988494 / JPN': 'Remittance (JPN)',
  };

  for (final MapEntry(key: raw, value: title) in cases.entries) {
    test(raw, () => expect(cleanDescription(raw), title));
  }

  test('unknown descriptions only get their spacing tidied', () {
    expect(
      cleanDescription('Fund  Transferred by   Sita Sharma'),
      'Fund Transferred by Sita Sharma',
    );
    expect(cleanDescription('95,371805112'), '95,371805112');
  });

  test('imports keep the bank text in notes and categorise from it', () {
    final csv = utf8.encode(
      [
        'Date,Description,Debit,Credit,Balance',
        '2026-01-01,"Ncell Topup,306247549",100,,900',
        '2026-01-02,Chiya,25,,875',
      ].join('\n'),
    );
    final rows = ImportParser.readXls(
      fileName: 'jan.csv',
      bookId: 'book',
      bytes: csv,
    ).rows;

    expect(rows.first.title, 'Topup · Ncell');
    expect(rows.first.notes, 'Ncell Topup,306247549');
    expect(rows.first.category, 'Cellular topup');
    // Nothing to clean: title as it was, notes left empty.
    expect(rows.last.title, 'Chiya');
    expect(rows.last.notes, isEmpty);
  });
}
