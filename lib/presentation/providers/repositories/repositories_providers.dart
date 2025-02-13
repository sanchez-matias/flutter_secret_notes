import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_secret_notes/domain/repositories/local_db_repository.dart';
import 'package:flutter_secret_notes/infrastructure/datasources/local_db_datasource_impl.dart';
import 'package:flutter_secret_notes/infrastructure/repositories/local_db_repository_impl.dart';

part 'repositories_providers.g.dart';

@riverpod
LocalDbRepository storageRepository(Ref ref) {
  return LocalDbRepositoryImpl(LocalDbDatasourceImpl());
}
