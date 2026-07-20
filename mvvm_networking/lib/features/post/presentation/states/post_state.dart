import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/post_model.dart';

part 'post_state.freezed.dart';

enum ViewState { idle, loading, success, error }

@freezed
sealed class PostState with _$PostState {
  const factory PostState({
    @Default(ViewState.idle) ViewState state,
    @Default([]) List<PostModel> posts,
    @Default('') String errorMessage,
  }) = _PostState;
}
