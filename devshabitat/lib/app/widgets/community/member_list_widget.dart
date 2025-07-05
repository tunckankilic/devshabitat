import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class MemberListWidget extends StatelessWidget {
  final List<UserModel> members;
  final bool isAdmin;
  final Function(UserModel)? onMemberTap;
  final Function(UserModel)? onRemoveMember;
  final Function(UserModel)? onPromoteToModerator;

  const MemberListWidget({
    Key? key,
    required this.members,
    this.isAdmin = false,
    this.onMemberTap,
    this.onRemoveMember,
    this.onPromoteToModerator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
            child: member.photoUrl == null && member.displayName != null
                ? Text(member.displayName!.characters.first.toUpperCase())
                : null,
          ),
          title: Text(member.displayName ?? member.email ?? 'İsimsiz Üye'),
          subtitle: member.metadata?['title'] != null
              ? Text(member.metadata!['title'] as String)
              : null,
          onTap: onMemberTap != null ? () => onMemberTap!(member) : null,
          trailing: isAdmin
              ? PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'remove':
                        if (onRemoveMember != null) onRemoveMember!(member);
                        break;
                      case 'promote':
                        if (onPromoteToModerator != null) {
                          onPromoteToModerator!(member);
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: const [
                          Icon(Icons.admin_panel_settings),
                          SizedBox(width: 8),
                          Text('Moderatör Yap'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: const [
                          Icon(Icons.person_remove),
                          SizedBox(width: 8),
                          Text('Üyelikten Çıkar'),
                        ],
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
