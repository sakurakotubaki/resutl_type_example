// zip_code_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:resutl_type_example/api/result.dart';

class ZipApi {
  final _dio = Dio();
  Future<Result<String, Exception>> zipCodeToAddress(String zipCode) async {
    if (zipCode.length != 7) {
      return Failure(Exception('Invalid zip code'));
    }
    try {
      final response = await _dio.get(
        'https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode',
      );
      if (response.statusCode != 200) {
        return Failure(Exception('Failed to fetch address'));
      }
      final result = jsonDecode(response.data);
      if (result['results'] == null) {
        return Failure(Exception('Failed to fetch address'));
      }
      final addressMap = (result['results'] as List).first;
      final address =
          '${addressMap['address1']} ${addressMap['address2']} ${addressMap['address3']}';
      return Success(address);
    } catch (e) {
      return Failure(Exception('Failed to fetch address'));
    }
  }
}
