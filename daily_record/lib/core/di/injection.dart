import 'package:get_it/get_it.dart';
import 'package:daily_record/core/repositories/auth_repository.dart';
import 'package:daily_record/core/repositories/check_list_repository.dart';
import 'package:daily_record/core/repositories/daily_record_repository.dart';
import 'package:daily_record/core/repositories/impl/auth_repository_impl.dart';
import 'package:daily_record/core/repositories/impl/check_list_repository_impl.dart';
import 'package:daily_record/core/repositories/impl/daily_record_repository_impl.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<IAuthRepository>()) {
    return;
  }

  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(),
  );

  getIt.registerLazySingleton<IDailyRecordRepository>(
    () => DailyRecordRepositoryImpl(),
  );

  getIt.registerLazySingleton<ICheckListRepository>(
    () => CheckListRepositoryImpl(),
  );
}
