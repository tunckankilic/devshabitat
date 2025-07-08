import 'package:devshabitat/app/models/user_profile_model.dart';
import 'package:flutter/material.dart';

class MemberListWidget extends StatelessWidget {
  final List<UserProfile> members;
  final bool isAdmin;
  final Function(UserProfile)? onMemberTap;
  final Function(UserProfile)? onRemoveMember;
  final Function(UserProfile)? onPromoteToModerator;

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
            child: member.photoUrl == null && member.fullName != ""
                ? Text(member.fullName.characters.first.toUpperCase())
                : null,
          ),
          title: Text(member.fullName),
          subtitle: member.title != null ? Text(member.title!) : null,
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
