import 'package:path/path.dart';
import 'package:rusticgram/LocalDB/db_name.dart';
import 'package:rusticgram/Model/local_data_model.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  late final Database _imageDB;
  List<Map<String, dynamic>> imageList = [];
  List<ImageDBModel> totalImageList = [];
  final DBName _dbName = DBName();
  String dbPath = "";

  Future<void> openingImageDB() async {
    dbPath = await getDatabasesPath(); // data/user/0/com.rusticgram.app/databases
    try {
      _imageDB = await openDatabase(
        join(dbPath, _dbName.imageDBName),
        onCreate: (db, version) async {
          await db.execute("CREATE TABLE ${_dbName.imageTableName}(imageName TEXT PRIMARY KEY, imagePath TEXT)");
        },
        version: 1,
      );
    } on DatabaseException catch (exception, stack) {
      CommonFunction.recordingError(exception: exception, stack: stack, functionName: "openingImageDB()", error: "Something went wrong. Please try again.");
    }
  }

  Future<void> insertRecordImageTable({required ImageDBModel imageDBModel}) async {
    try {
      await _imageDB.insert(_dbName.imageTableName, imageDBModel.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    } on DatabaseException catch (exception, stack) {
      CommonFunction.recordingError(exception: exception, stack: stack, functionName: "updatingImageDB()", error: "Something went wrong. Please try again.");
    }
  }

  Future<void> fetchingDB() async {
    totalImageList = [];
    imageList = await _imageDB.query(_dbName.imageTableName);
    for (Map<String, dynamic> imageDetails in imageList) {
      totalImageList.add(ImageDBModel.fromJson(imageDetails));
    }
  }
}
