import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/feed_controller.dart';

class CommentModal extends StatelessWidget {
  final String postId;
  final TextEditingController _commentController = TextEditingController();
  final FeedController _feedController = Get.find<FeedController>();

  CommentModal({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Yorumlar'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Bir hata oluştu'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment =
                        comments[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          comment['userPhotoUrl'] ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                      title: Text(comment['userName'] ?? 'Kullanıcı'),
                      subtitle: Text(comment['text']),
                      trailing:
                          comment['userId'] == _feedController.currentUserId
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(postId)
                                        .collection('comments')
                                        .doc(comments[index].id)
                                        .delete();
                                  },
                                )
                              : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Yorumunuzu yazın...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_commentController.text.trim().isEmpty) return;

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(_feedController.currentUserId)
                        .get();

                    final userData = userDoc.data();

                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .collection('comments')
                        .add({
                      'text': _commentController.text.trim(),
                      'userId': _feedController.currentUserId,
                      'userName': userData?['displayName'] ?? 'Kullanıcı',
                      'userPhotoUrl': userData?['photoURL'] ?? '',
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    _commentController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
