import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/post_providers.dart';
import '../states/post_state.dart';
import 'post_detail_page.dart';
import '../../data/models/post_model.dart';

class PostListPage extends ConsumerStatefulWidget {
  const PostListPage({super.key});

  @override
  ConsumerState<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends ConsumerState<PostListPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data saat widget pertama kali dimuat
    Future.microtask(() {
      ref.read(postViewModelProvider.notifier).loadPosts();
    });
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Buat Post Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Isi', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              await ref.read(postViewModelProvider.notifier).createPost(
                title: titleCtrl.text,
                body: bodyCtrl.text,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch state secara efisien
    final postState = ref.watch(postViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM + Riverpod + Dio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(postViewModelProvider.notifier).loadPosts(),
          ),
        ],
      ),
      body: switch (postState.state) {
        ViewState.loading => const Center(child: CircularProgressIndicator()),
        ViewState.error => _ErrorView(
            message: postState.errorMessage,
            onRetry: () => ref.read(postViewModelProvider.notifier).loadPosts(),
          ),
        _ => _PostListView(posts: postState.posts),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Post Baru'),
      ),
    );
  }
}

// Sub-widget terpisah untuk daftar post
class _PostListView extends ConsumerWidget {
  final List<PostModel> posts;
  const _PostListView({required this.posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posts.isEmpty) {
      return const Center(child: Text('Belum ada post.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${post.id}'),
            ),
            title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => ref.read(postViewModelProvider.notifier).deletePost(post.id),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
            ),
          ),
        );
      },
    );
  }
}

// Sub-widget terpisah untuk tampilan Error
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
