import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_screen.dart';
import 'change_password_dialog.dart';
import 'logout_confirmation_screen.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  // To trigger refresh after editing
  Future<void> _refreshProfile() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (uid == null) {
      return const Center(child: Text("Not signed in"));
    }
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final dataRaw = snapshot.data?.data();
        final data = dataRaw is Map<String, dynamic> ? dataRaw : <String, dynamic>{};
        final String? profileImageUrl = data['profileImageUrl'];
        final String fullName = data['name'] ?? "Incomplete Profile";
        final String educationLevel = data['educationLevel'] ?? "Not set";
        final String classGrade = data['classGrade'] ?? "Not set";
        final String phone = data['phone'] ?? "Not set";
        final String memberSince = data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate().toString().split(' ').first
            : "N/A";
        final int topicsMastered = data['topicsMastered'] ?? 0;
        final int quizzesCompleted = data['quizzesCompleted'] ?? 0;
        final String lastActivity = data['lastActivity'] ?? "N/A";

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.transparent,
              body: RefreshIndicator(
                onRefresh: _refreshProfile,
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Picture, Name, Email
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 44,
                                  backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : const AssetImage('assets/images/profile_icon.png') as ImageProvider,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                fullName,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                email,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // User info and stats
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.09),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Status",
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _ProfileInfoBlock(
                                  icon: Icons.school,
                                  label: "Educational Level",
                                  value: educationLevel,
                                ),
                                _ProfileInfoBlock(
                                  icon: Icons.class_,
                                  label: "Class/Grade",
                                  value: classGrade,
                                ),
                                _ProfileInfoBlock(
                                  icon: Icons.phone,
                                  label: "Phone",
                                  value: phone,
                                ),
                                _ProfileInfoBlock(
                                  icon: Icons.calendar_today,
                                  label: "Member Since",
                                  value: memberSince,
                                ),
                                const SizedBox(height: 25),
                                Text(
                                  "Progress",
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _ProfileStatBlock(
                                  icon: Icons.check_circle_outline,
                                  label: "Topics Mastered",
                                  value: "$topicsMastered",
                                ),
                                _ProfileStatBlock(
                                  icon: Icons.quiz_outlined,
                                  label: "Quizzes Completed",
                                  value: "$quizzesCompleted",
                                ),
                                _ProfileStatBlock(
                                  icon: Icons.access_time,
                                  label: "Last Activity",
                                  value: lastActivity,
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _ProfileActionButton(
                                      icon: Icons.edit,
                                      label: "Edit Profile",
                                      onTap: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditProfileScreen(initialData: data),
                                          ),
                                        );
                                        if (updated == true) {
                                          _refreshProfile();
                                        }
                                      },
                                    ),
                                    _ProfileActionButton(
                                      icon: Icons.lock_rounded,
                                      label: "Change Password",
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => ChangePasswordDialog(email: email),
                                        );
                                      },
                                    ),
                                    _ProfileActionButton(
                                      icon: Icons.logout_rounded,
                                      label: "Logout",
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const LogoutConfirmationScreen(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfoBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStatBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: Colors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Ink(
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.purple),
            onPressed: onTap,
            iconSize: 24,
          ),
        ),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}