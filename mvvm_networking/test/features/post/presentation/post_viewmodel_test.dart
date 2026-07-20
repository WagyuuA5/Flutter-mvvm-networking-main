import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mvvm_networking/features/post/domain/repositories/post_repository.dart';
import 'package:mvvm_networking/features/post/data/models/post_model.dart';
import 'package:mvvm_networking/core/result/result.dart';
import 'package:mvvm_networking/features/post/presentation/states/post_state.dart';
import 'package:mvvm_networking/features/post/presentation/providers/post_providers.dart';
import 'package:dio/dio.dart';

// 1. Buat Fake Repository untuk mengontrol output API
class FakePostRepository implements PostRepository {
  bool shouldFail = false;

  @override
  Future<Result<List<PostModel>>> getPosts({CancelToken? cancelToken}) async {
    if (shouldFail) {
      return const Failure('Error koneksi simulasi');
    }
    return const Success([
      PostModel(id: 1, userId: 1, title: 'Test Title', body: 'Test Body'),
    ]);
  }

  @override
  Future<Result<PostModel>> createPost({required String title, required String body, CancelToken? cancelToken}) async {
    return Success(PostModel(id: 2, userId: 1, title: title, body: body));
  }

  @override
  Future<Result<bool>> deletePost(int id, {CancelToken? cancelToken}) async => const Success(true);

  @override
  Future<Result<PostModel>> getPostById(int id, {CancelToken? cancelToken}) async {
    return const Success(PostModel(id: 1, userId: 1, title: 'Test', body: 'Test'));
  }
}

void main() {
  late FakePostRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakePostRepository();
    // 2. Override Provider asli dengan Fake Repository menggunakan ProviderContainer
    container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('Kondisi awal ViewModel harus memuat state default', () {
    final state = container.read(postViewModelProvider);
    expect(state.state, ViewState.idle);
    expect(state.posts, isEmpty);
  });

  test('loadPosts() berhasil mengubah state menjadi ViewState.success dan mengisi data', () async {
    final viewModel = container.read(postViewModelProvider.notifier);

    await viewModel.loadPosts();

    final state = container.read(postViewModelProvider);
    expect(state.state, ViewState.success);
    expect(state.posts.length, 1);
    expect(state.posts.first.title, 'Test Title');
  });

  test('loadPosts() gagal mengubah state menjadi ViewState.error dan menampilkan pesan', () async {
    fakeRepository.shouldFail = true;
    final viewModel = container.read(postViewModelProvider.notifier);

    await viewModel.loadPosts();

    final state = container.read(postViewModelProvider);
    expect(state.state, ViewState.error);
    expect(state.errorMessage, 'Error koneksi simulasi');
  });
}
