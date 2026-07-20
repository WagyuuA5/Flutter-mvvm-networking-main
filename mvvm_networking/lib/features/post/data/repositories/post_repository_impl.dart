import 'package:dio/dio.dart';
import '../../../../core/result/result.dart';
import '../models/post_model.dart';
import '../../domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final Dio _dio;
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  PostRepositoryImpl(this._dio);

  @override
  Future<Result<List<PostModel>>> getPosts({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get('$_baseUrl/posts', cancelToken: cancelToken);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final posts = data.map((json) => PostModel.fromJson(json)).toList();
        return Success(posts);
      }
      return Failure('Gagal memuat data. Status code: ${response.statusCode}');
      
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const Failure('Request dibatalkan');
      }
      return Failure('Koneksi bermasalah: ${e.message}');
    } catch (e) {
      return Failure('Terjadi kesalahan tak terduga: $e');
    }
  }

  @override
  Future<Result<PostModel>> getPostById(int id, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get('$_baseUrl/posts/$id', cancelToken: cancelToken);
      if (response.statusCode == 200) {
        return Success(PostModel.fromJson(response.data));
      }
      return const Failure('Gagal memuat detail post.');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const Failure('Request dibatalkan');
      }
      return Failure('Koneksi bermasalah: ${e.message}');
    }
  }

  @override
  Future<Result<PostModel>> createPost({required String title, required String body, CancelToken? cancelToken}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/posts',
        data: {
          'title': title,
          'body': body,
          'userId': 1,
        },
        cancelToken: cancelToken,
      );
      
      if (response.statusCode == 201) {
        return Success(PostModel.fromJson(response.data));
      }
      return const Failure('Gagal membuat post.');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const Failure('Request dibatalkan');
      }
      return Failure('Koneksi bermasalah: ${e.message}');
    }
  }

  @override
  Future<Result<bool>> deletePost(int id, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.delete('$_baseUrl/posts/$id', cancelToken: cancelToken);
      if (response.statusCode == 200) {
        return const Success(true);
      }
      return const Failure('Gagal menghapus post.');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return const Failure('Request dibatalkan');
      }
      return Failure('Koneksi bermasalah: ${e.message}');
    }
  }
}
