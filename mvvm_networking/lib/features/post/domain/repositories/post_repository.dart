import 'package:dio/dio.dart';
import '../../../../core/result/result.dart';
import '../../data/models/post_model.dart';

abstract class PostRepository {
  Future<Result<List<PostModel>>> getPosts({CancelToken? cancelToken});
  Future<Result<PostModel>> getPostById(int id, {CancelToken? cancelToken});
  Future<Result<PostModel>> createPost({required String title, required String body, CancelToken? cancelToken});
  Future<Result<bool>> deletePost(int id, {CancelToken? cancelToken});
}
