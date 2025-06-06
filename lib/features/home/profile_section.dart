import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy user data – replace with real user provider/model as needed
    const String profileImage = 'assets/images/JAY_2589_transcpr_1.jpg';
    const String fullName = "Jude Chika";
    const String email = "jude2chika@gmail.com";
    const String educationLevel = "Senior Secondary";
    const String classGrade = "SS3";
    const String memberSince = "Jan 2025";
    const int topicsMastered = 12;
    const int quizzesCompleted = 8;
    const String lastActivity = "2d ago";

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture, Name, Email stacked without vertical space
                    Column(
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: AssetImage(profileImage),
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

                    /// All user info and stats in a single white container
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
                          // Education and Class/Grade
                          const _ProfileInfoBlock(
                            icon: Icons.school,
                            label: "Educational Level",
                            value: educationLevel,
                          ),
                          const _ProfileInfoBlock(
                            icon: Icons.class_,
                            label: "Class/Grade",
                            value: classGrade,
                          ),
                          const _ProfileInfoBlock(
                            icon: Icons.calendar_today,
                            label: "Member Since",
                            value: memberSince,
                          ),
                          const SizedBox(height: 25),
                          // Progress / Stats
                          Text(
                            "Progress",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const _ProfileStatBlock(
                            icon: Icons.check_circle_outline,
                            label: "Topics Mastered",
                            value: "$topicsMastered",
                          ),
                          const _ProfileStatBlock(
                            icon: Icons.quiz_outlined,
                            label: "Quizzes Completed",
                            value: "$quizzesCompleted",
                          ),
                          const _ProfileStatBlock(
                            icon: Icons.access_time,
                            label: "Last Activity",
                            value: lastActivity,
                          ),

                          const SizedBox(height: 25),
                          // Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ProfileActionButton(
                                icon: Icons.edit,
                                label: "Edit Profile",
                                onTap: () {
                                  // TODO: Implement Edit Profile
                                },
                              ),
                              _ProfileActionButton(
                                icon: Icons.lock_rounded,
                                label: "Change Password",
                                onTap: () {
                                  // TODO: Implement Change Password
                                },
                              ),
                              _ProfileActionButton(
                                icon: Icons.logout_rounded,
                                label: "Logout",
                                onTap: () {
                                  // TODO: Implement Logout
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
      ],
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
