import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:imphenhackaton/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:imphenhackaton/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:imphenhackaton/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:imphenhackaton/features/auth/domain/repositories/auth_repository.dart';
import 'package:imphenhackaton/features/auth/domain/usecases/get_current_user.dart';
import 'package:imphenhackaton/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:imphenhackaton/features/auth/domain/usecases/sign_out.dart';
import 'package:imphenhackaton/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imphenhackaton/features/counter/data/datasources/counter_local_data_source.dart';
import 'package:imphenhackaton/features/counter/data/repositories/counter_repository_impl.dart';
import 'package:imphenhackaton/features/counter/domain/repositories/counter_repository.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/decrement_counter.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/get_counter.dart';
import 'package:imphenhackaton/features/counter/domain/usecases/increment_counter.dart';
import 'package:imphenhackaton/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:imphenhackaton/features/generate_caption/data/datasources/generate_caption_local_data_source.dart';
import 'package:imphenhackaton/features/generate_caption/data/datasources/generate_caption_remote_data_source.dart';
import 'package:imphenhackaton/features/generate_caption/data/repositories/generate_caption_repository_impl.dart';
import 'package:imphenhackaton/features/generate_caption/domain/repositories/generate_caption_repository.dart';
import 'package:imphenhackaton/features/generate_caption/presentation/bloc/generate_caption_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator instance.
final sl = GetIt.instance;
Future<void> initDependencies() async {
  // ==================== Features - Counter ====================
  sl
    ..registerFactory(
      () => CounterCubit(
        getCounter: sl(),
        incrementCounter: sl(),
        decrementCounter: sl(),
      ),
    )

    // Use Cases

    ..registerLazySingleton(() => GetCounter(sl()))
    ..registerLazySingleton(() => IncrementCounter(sl()))
    ..registerLazySingleton(() => DecrementCounter(sl()))

    // Repository
    ..registerLazySingleton<CounterRepository>(
      () => CounterRepositoryImpl(localDataSource: sl()),
    )

    // Data Sources
    ..registerLazySingleton<CounterLocalDataSource>(
      CounterLocalDataSourceImpl.new,
    )

    // BLoC
    ..registerFactory(
      () => GenerateCaptionBloc(repository: sl(), authLocalDataSource: sl()),
    )

    // Repository
    ..registerLazySingleton<GenerateCaptionRepository>(
      () => GenerateCaptionRepositoryImpl(
        localDataSource: sl(),
        remoteDataSource: sl(),
        authLocalDataSource: sl(),
      ),
    )

    // Data Sources
    ..registerLazySingleton<GenerateCaptionLocalDataSource>(
      () => GenerateCaptionLocalDataSourceImpl(imagePicker: sl()),
    )
    ..registerLazySingleton<GenerateCaptionRemoteDataSource>(
      GenerateCaptionRemoteDataSourceImpl.new,
    )

    // BLoC
    ..registerFactory(
      () => AuthBloc(
        signInWithGoogle: sl(),
        signOut: sl(),
        getCurrentUser: sl(),
      ),
    )

    // Use Cases
    ..registerLazySingleton(() => SignInWithGoogle(sl()))
    ..registerLazySingleton(() => SignOut(sl()))
    ..registerLazySingleton(() => GetCurrentUser(sl()))

    // Repository
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ),
    )

    // Data Sources
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        googleSignIn: sl(),
        httpClient: sl(),
      ),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
    )

    // External dependencies
    ..registerLazySingleton(ImagePicker.new)
    ..registerLazySingleton(http.Client.new)
    ..registerLazySingleton(
      () => GoogleSignIn(
        clientId:
            // '407102384608-0vd8pr9ffkdnecrcnoq62l6tfousl9o0.apps.googleusercontent.com',
            // '407102384608-0vd8pr9ffkdnecrcnoq62l6tfousl9o0.apps.googleusercontent.com',
            '407102384608-kel71m49pg4rtu71niea2k40o79kvoee.apps.googleusercontent.com', //local
        scopes: ['email', 'profile'],
      ),
    );

  // SharedPreferences needs async initialization
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
