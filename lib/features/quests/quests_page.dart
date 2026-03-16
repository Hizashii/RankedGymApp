import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/models.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Quests & Rewards', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Solo-style daily missions arrive through the system chatbox.'),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            title: Text('Wallet: ${repo.wallet.xp} XP • ${repo.wallet.coins} coins'),
            subtitle: Text('Streak: ${repo.wallet.streakDays} days'),
            trailing: const Icon(Icons.stars_rounded),
          ),
        ),
        const _QuestChatbox(),
        ...repo.quests.map((quest) => _QuestTile(quest: quest)),
      ],
    );
  }
}

class _QuestChatbox extends StatefulWidget {
  const _QuestChatbox();

  @override
  State<_QuestChatbox> createState() => _QuestChatboxState();
}

class _QuestChatboxState extends State<_QuestChatbox> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final log = repo.questChatLog;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Color(0xFF4DA3FF)),
                const SizedBox(width: 8),
                Text('System Chat', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => repo.deliverDailyQuestFromChat(force: false),
                  child: const Text('Get Daily Quest'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: log.length,
                itemBuilder: (context, index) {
                  final message = log[index];
                  final isSystem = message.role == ChatRole.system;
                  return Align(
                    alignment: isSystem ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSystem ? const Color(0xFF0F2542) : const Color(0xFF1B3458),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSystem ? const Color(0xFF2C78D0) : const Color(0xFF4DA3FF),
                        ),
                      ),
                      child: Text(message.content),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type: daily quest / rank / mission',
                    ),
                    onSubmitted: (_) => _send(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _send(context),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _send(BuildContext context) {
    final repo = FitnessScope.of(context);
    repo.sendQuestChatMessage(_controller.text);
    _controller.clear();
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({required this.quest});

  final Quest quest;

  Color _difficultyColor(DifficultyTier difficulty) {
    switch (difficulty) {
      case DifficultyTier.easy:
        return Colors.green;
      case DifficultyTier.moderate:
        return Colors.blue;
      case DifficultyTier.hard:
        return Colors.deepPurple;
      case DifficultyTier.elite:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final progress = quest.target == 0 ? 0.0 : (quest.progress / quest.target).clamp(0, 1).toDouble();
    final canClaim = quest.completed && !quest.claimed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(quest.title, style: Theme.of(context).textTheme.titleMedium),
                ),
                Chip(
                  backgroundColor: _difficultyColor(quest.difficulty).withValues(alpha: 0.12),
                  label: Text(quest.difficulty.name),
                ),
              ],
            ),
            Text(quest.description),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 4),
            Text(
              '${quest.progress.toStringAsFixed(2)} / ${quest.target.toStringAsFixed(2)} • ${quest.rewardXp} XP + ${quest.rewardCoins} coins',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: canClaim
                  ? () {
                      final ok = repo.claimQuest(quest.id);
                      if (!ok) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Claimed ${quest.title}!')),
                      );
                    }
                  : null,
              child: Text(quest.claimed ? 'Claimed' : 'Claim reward'),
            ),
          ],
        ),
      ),
    );
  }
}
