import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:flutter/material.dart';

class MembershipRequestWidget extends StatelessWidget {
  final List<UserProfile> pendingMembers;
  final Function(UserProfile) onAccept;
  final Function(UserProfile) onReject;

  const MembershipRequestWidget({
    super.key,
    required this.pendingMembers,
    required this.onAccept,
    required this.onReject,
  });

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
                  backgroundImage: member.photoUrl != null
                      ? NetworkImage(member.photoUrl!)
                      : null,
                  child: member.photoUrl == null && member.fullName != ""
                      ? Text(member.fullName.characters.first.toUpperCase())
                      : null,
                ),
                title: Text(member.fullName),
                subtitle: Text(member.title.toString()),
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
