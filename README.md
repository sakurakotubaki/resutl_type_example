# resutl_type_example

sealed class:
```dart
/// Base Result class
/// [S] represents the type of the success value
/// [E] should be [Exception] or a subclass of it
sealed class Result<S, E extends Exception> {
  const Result();
}

final class Success<S, E extends Exception> extends Result<S, E> {
  const Success(this.value);
  final S value;
}

final class Failure<S, E extends Exception> extends Result<S, E> {
  const Failure(this.exception);
  final E exception;
}
```

```dart
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
```

StatefulWidget:
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:resutl_type_example/api/result.dart';
import 'package:resutl_type_example/api/zip_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final TextEditingController _zipCodeController = TextEditingController();
  String _address = '';

  void _fetchAddress() async {
    final zipCode = _zipCodeController.text;
    final result = await ZipApi().zipCodeToAddress(zipCode);
    if (result is Success<String, Exception>) {
      setState(() {
        _address = result.value;
      });
    } else if (result is Failure<String, Exception>) {
      setState(() {
        _address = '住所を取得できませんでした。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('住所検索'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _zipCodeController,
              decoration: const InputDecoration(
                hintText: '郵便番号を入力してください',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 7,
              onSubmitted: (value) => _fetchAddress(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAddress,
              child: const Text('検索'),
            ),
            const SizedBox(height: 20),
            Text(_address),
          ],
        ),
      ),
    );
  }
}
```

flutter_hooks:
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:resutl_type_example/api/result.dart';
import 'package:resutl_type_example/api/zip_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoPage(),
    );
  }
}

class DemoPage extends HookWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final zipCodeController = useTextEditingController();
    final address = useState('');

    // useMemoizedを使って、zipCodeToAddressメソッドをキャッシュする
    // キャッシュすることで、zipCodeToAddressメソッドが再生成されることを防ぐ
    final zipCodeToAddress = useMemoized(() => ZipApi().zipCodeToAddress);
    // zipCodeToAddressメソッドを呼び出すfetchAddressメソッドを定義
    Future<void> fetchAddress() async {
      final zipCode = zipCodeController.text;
      final result = await zipCodeToAddress(zipCode);
      if (result is Success<String, Exception>) {
        address.value = result.value;
      } else if (result is Failure<String, Exception>) {
        address.value = '住所を取得できませんでした。';
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('住所検索'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: zipCodeController,
              decoration: const InputDecoration(
                hintText: '郵便番号を入力してください',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 7,
              onSubmitted: (value) => fetchAddress(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchAddress,
              child: const Text('検索'),
            ),
            const SizedBox(height: 20),
            Text(address.value),
          ],
        ),
      ),
    );
  }
}
```