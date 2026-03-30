import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'providers/plan_provider.dart';
import 'services/api_service.dart';
import 'services/esim_service.dart';

class EsimApp extends StatelessWidget {
  const EsimApp({super.key});

  @override
  Widget build(BuildContext context) {
    final EsimService esimService =
        AppConfig.useMockData ? MockEsimService() : MockEsimService();

    final ApiService apiService =
        AppConfig.useMockData ? MockApiService() : MockApiService();
    // TODO: replace second branches with real implementations.

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlanProvider(esimService)),
        Provider<ApiService>.value(value: apiService),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.shell,
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
