import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pos/table/models/table.dart';

class TableController extends GetxController  {


List  tableList = [] ;

final Dio _dio = Dio();


final String _pinUrl = 'http://127.0.0.1:3000/table';


Future<void>   getTableList()async {
  try {
    final response = await _dio.get(
      _pinUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Handle the response
    if (response.statusCode == 200) {
      // PIN sent successfully
      Logger().i(response.data) ;
    //Map<String, dynamic> jsonMap =   tableFromJson(response.data) ;

  print('PIN sent successfully');
    } else {
      // Handle other status codes
      print('Failed to send PIN: ${response.statusCode}');
    }
  } on DioError catch (e) {
    // Handle Dio errors
    print('Dio error: ${e.message}');
  } catch (e) {
    // Handle other exceptions
    print('Exception: $e');
  }
}
// function t o get all the tables









}