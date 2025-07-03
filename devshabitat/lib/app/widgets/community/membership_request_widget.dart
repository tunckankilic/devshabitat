import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class MembershipRequestWidget extends StatelessWidget {
  final List<UserModel> pendingMembers;
  final Function(UserModel) onAccept;
  final Function(UserModel) onReject;

  const MembershipRequestWidget({
    Key? key,
    required this.pendingMembers,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pendingMembers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Bekleyen üyelik talebi bulunmamaktadır.'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Üyelik Talepleri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingMembers.length,
            itemBuilder: (context, index) {
              final member = pendingMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.photoURL != null
                      ? NetworkImage(member.photoURL!)
                      : null,
                  child: member.photoURL == null
                      ? Text(member.displayName[0].toUpperCase())
                      : null,
                ),
                title: Text(member.displayName),
                subtitle: member.title != null ? Text(member.title!) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle),
                      color: Colors.green,
                      onPressed: () => onAccept(member),
                      tooltip: 'Kabul Et',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.red,
                      onPressed: () => onReject(member),
                      tooltip: 'Reddet',
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
