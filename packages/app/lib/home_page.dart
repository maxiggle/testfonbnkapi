import 'package:api_client/api_client.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Login'),
              onPressed: () async {
                await callRateApi();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> callRateApi() async {
    final logger = Logger();
    final authRepo = AuthenticationRepository(
      clientId: '6912c9d8113d11711dff8cf2',
      clientSecret: '01K9RP8XGWWGF49CFJFK0J6AMV',
    );

    final apiClient = ApiClient(
      baseUrl: 'https://sandbox-api.fonbnk.com',
      authRepository: authRepo,
    );

    final response = await apiClient.get(
      '/api/onramp/best-offer',
      queryParams: {
        'countryIsoCode': 'GH',
        'amount': '20',
        'currency': 'crypto',
        'network': 'LISK',
        'asset': 'USDT',
        'paymentChannel': 'airtime',
      },
    );

    logger.i(response.body);
    if (response.statusCode != 200) {
      logger.e('Failed to start transaction');
    }
  }
}
