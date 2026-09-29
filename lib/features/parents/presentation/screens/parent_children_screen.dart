import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/app_user.dart';
import '../../../players/data/models/player.dart';
import '../../../players/data/player_result_service.dart';
import '../../../players/data/services/player_firestore_service.dart';
import '../../../students/data/models/student.dart';
import '../../../students/data/student_service.dart';
import '../../../dashboard/presentation/widgets/premium_ui.dart';

class ParentChildrenScreen extends StatelessWidget {
  const ParentChildrenScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final playersStream = PlayerFirestoreService.instance.getPlayersByParent(user.uid);
    final studentsStream = StudentService().watchStudents(parentId: user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Children')),
      body: StreamBuilder<List<Player>>(
        stream: playersStream,
        builder: (context, playerSnapshot) {
          if (playerSnapshot.hasError) {
            return _ErrorView(message: 'Unable to load your children.\n${playerSnapshot.error}');
          }

          return StreamBuilder<List<Student>>(
            stream: studentsStream,
            builder: (context, studentSnapshot) {
              if (studentSnapshot.hasError) {
                return _ErrorView(message: 'Unable to load your children.\n${studentSnapshot.error}');
              }
              if (playerSnapshot.connectionState == ConnectionState.waiting &&
                  studentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final players = playerSnapshot.data ?? const <Player>[];
              final students = studentSnapshot.data ?? const <Student>[];

              if (players.isEmpty && students.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'No children have been linked to your parent account yet.\n\nPlease contact the academy administrator.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                children: [
                  PremiumHero(
                    eyebrow: 'Family Portal',
                    title: 'Your children, one place.',
                    subtitle: 'Live results appear here as soon as the academy administrator publishes them. Only children linked to your account are shown.',
                    image: 'assets/images/football.jpg',
                    icon: Icons.family_restroom_rounded,
                  ),
                  const SizedBox(height: 18),
                  if (students.isNotEmpty) ...[
                    const _SectionHeader(title: 'Students', icon: Icons.school_rounded),
                    const SizedBox(height: 8),
                    ...students.map((student) => _StudentChildCard(student: student, parentId: user.uid)),
                    const SizedBox(height: 10),
                  ],
                  if (players.isNotEmpty) ...[
                    const _SectionHeader(title: 'Players', icon: Icons.sports_soccer_rounded),
                    const SizedBox(height: 8),
                    ...players.map((player) => _PlayerChildCard(player: player, parentId: user.uid)),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StudentChildCard extends StatelessWidget {
  const _StudentChildCard({required this.student, required this.parentId});
  final Student student;
  final String parentId;

  @override
  Widget build(BuildContext context) {
    final service = StudentService();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.school_rounded)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text('${student.studentId} · ${student.className.isEmpty ? student.gradeLevel : student.className}'),
            ])),
          ]),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 6),
          const Text('Published results', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: service.watchResults(student.id, parentId: parentId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Unable to load results: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator());
              }
              final results = snapshot.data ?? const <Map<String, dynamic>>[];
              if (results.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No result has been published yet.'));
              return Column(children: results.map((result) => _ResultTile(
                title: '${result['term'] ?? ''} · ${result['session'] ?? ''}',
                subtitle: 'Official academic report',
                onOpenPdf: () => _openStudentResult(context, student, result),
              )).toList());
            },
          ),
        ]),
      ),
    );
  }
}

class _PlayerChildCard extends StatelessWidget {
  const _PlayerChildCard({required this.player, required this.parentId});
  final Player player;
  final String parentId;

  @override
  Widget build(BuildContext context) {
    final service = PlayerResultService();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(child: Icon(Icons.sports_soccer_rounded)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(player.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              Text('${player.registrationNo.isEmpty ? player.id : player.registrationNo} · ${player.position.isEmpty ? 'Player' : player.position}'),
            ])),
          ]),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 6),
          const Text('Published results', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: service.watchResults(player.id, parentId: parentId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Unable to load results: ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator());
              }
              final results = snapshot.data ?? const <Map<String, dynamic>>[];
              if (results.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('No result has been published yet.'));
              return Column(children: results.map((result) => _ResultTile(
                title: '${result['term'] ?? ''} · ${result['session'] ?? ''}',
                subtitle: 'Official player performance report',
                onOpenPdf: () => _openPlayerResult(context, player, result),
              )).toList());
            },
          ),
        ]),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.title, required this.subtitle, required this.onOpenPdf});
  final String title;
  final String subtitle;
  final VoidCallback onOpenPdf;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 4),
    leading: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(.08), borderRadius: BorderRadius.circular(13)),
      child: Icon(Icons.picture_as_pdf_rounded, color: Theme.of(context).colorScheme.primary),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(subtitle),
    trailing: FilledButton.tonalIcon(
      onPressed: onOpenPdf,
      icon: const Icon(Icons.download_rounded, size: 18),
      label: const Text('Download'),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 21),
    const SizedBox(width: 8),
    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
  ]);
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(message, textAlign: TextAlign.center)));
}

Future<void> _openPublishedPdf(BuildContext context, String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the published PDF. Please try again.')),
      );
    }
  }
}

Future<void> _openStudentResult(BuildContext context, Student student, Map<String, dynamic> result) async {
  final publishedUrl = result['pdfUrl']?.toString().trim() ?? '';
  if (publishedUrl.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The official PDF has not been published yet.')),
      );
    }
    return;
  }
  await _openPublishedPdf(context, publishedUrl);
}

Future<void> _openPlayerResult(BuildContext context, Player player, Map<String, dynamic> result) async {
  final publishedUrl = result['pdfUrl']?.toString().trim() ?? '';
  if (publishedUrl.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The official PDF has not been published yet.')),
      );
    }
    return;
  }
  await _openPublishedPdf(context, publishedUrl);
}
