import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/result.dart';
import '../../data/models/post_model.dart';
import '../../domain/repositories/post_repository.dart';
import '../states/post_state.dart';

class PostViewModel extends StateNotifier<PostState> {
  final PostRepository _repository;
  final CancelToken _cancelToken;

  PostViewModel(this._repository, this._cancelToken) : super(const PostState());

  @override
  void dispose() {
    _cancelToken.cancel('ViewModel disposed');
    super.dispose();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(state: ViewState.loading);
    
    final result = await _repository.getPosts(cancelToken: _cancelToken);
    switch (result) {
      case Success<List<PostModel>>():
        state = state.copyWith(
          state: ViewState.success,
          posts: result.data,
        );
      case Failure<List<PostModel>>():
        if (result.message != 'Request dibatalkan') {
          state = state.copyWith(
            state: ViewState.error,
            errorMessage: result.message,
          );
        }
    }
  }

  Future<void> createPost({required String title, required String body}) async {
    final result = await _repository.createPost(title: title, body: body, cancelToken: _cancelToken);
    if (result is Success<PostModel>) {
      state = state.copyWith(
        posts: [result.data, ...state.posts],
      );
    }
  }

  Future<void> deletePost(int id) async {
    final result = await _repository.deletePost(id, cancelToken: _cancelToken);
    if (result is Success<bool>) {
      state = state.copyWith(
        posts: state.posts.where((p) => p.id != id).toList(),
      );
    }
  }
}
