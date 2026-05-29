import 'package:drift/drift.dart';

class TransactionsTable extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // credit, debit
  TextColumn get category => text()(); // category enum name
  TextColumn get merchant => text().nullable()();
  TextColumn get upiApp => text().nullable()(); // upiApp enum name
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get source => text()(); // sms, notification, manual, imported
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get rawSmsBody => text().nullable()(); // stored encrypted

  @override
  Set<Column> get primaryKey => {id};
}
