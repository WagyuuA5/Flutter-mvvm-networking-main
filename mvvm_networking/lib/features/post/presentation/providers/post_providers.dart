import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_provider.dart';
import '../../domain/repositories/post_repository.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../viewmodels/post_viewmodel.dart';
import '../states/post_state.dart';

// Provider untuk Repository
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(ref.watch(dioProvider));
});

// StateNotifierProvider untuk ViewModel & State
final postViewModelProvider = StateNotifierProvider<PostViewModel, PostState>((ref) {
  final cancelToken = CancelToken();
  ref.onDispose(() {
    cancelToken.cancel();
  });
  return PostViewModel(ref.watch(postRepositoryProvider), cancelToken);
});
