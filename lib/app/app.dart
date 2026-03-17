import 'package:flutter/material.dart';
import 'package:ranked_gym/core/data/fitness_repository.dart';
import 'package:ranked_gym/core/design/app_theme.dart';
import 'package:ranked_gym/core/services/system_message/startup_gate.dart';

class RankedGymApp extends StatefulWidget {
  const RankedGymApp({super.key});

  @override
  State<RankedGymApp> createState() => _RankedGymAppState();
}

class _RankedGymAppState extends State<RankedGymApp> {
  late final FitnessRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = FitnessRepository.bootstrap();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FitnessScope(
      repository: _repository,
      child: MaterialApp(
        title: 'RankedGym',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.animeTheme(),
        home: StartupGate(repository: _repository),
      ),
    );
  }
}

class FitnessScope extends InheritedNotifier<FitnessRepository> {
  const FitnessScope({
    super.key,
    required FitnessRepository repository,
    required super.child,
  }) : super(notifier: repository);

  static FitnessRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FitnessScope>();
    final repository = scope?.notifier;
    if (repository == null) {
      throw StateError('FitnessScope not found in widget tree.');
    }
    return repository;
  }
}
