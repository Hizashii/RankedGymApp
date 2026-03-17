import 'package:flutter/material.dart';
import 'package:ranked_gym/app/app.dart';
import 'package:ranked_gym/core/data/fitness_repository.dart';
import 'package:ranked_gym/core/data/models.dart';
import 'package:ranked_gym/core/models/quest.dart';

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _claimReward(FitnessRepository repo, Quest quest) {
    if (!quest.isClaimable) return;
    repo.claimQuest(quest.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF08111A),
        content: Text(
          '[ +${quest.rewardXp} XP  +${quest.rewardCoins} ◈ received ]',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Color(0xFF5AB4E0),
            letterSpacing: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendChat(FitnessRepository repo) {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    repo.sendQuestChatMessage(text);
    _chatController.clear();
  }

  void _getDailyQuest(FitnessRepository repo) {
    repo.deliverDailyQuestFromChat(force: false);
  }

  @override
  Widget build(BuildContext context) {
    final repo = FitnessScope.of(context);
    final wallet = repo.wallet;
    final quests = repo.quests;
    final messages = repo.questChatLog;

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _StatStrip(
                    xp: wallet.xp,
                    coins: wallet.coins,
                    streak: wallet.streakDays,
                  ),
                  _SystemBox(
                    messages: messages,
                    controller: _chatController,
                    onSend: () => _sendChat(repo),
                    onDailyQuest: () => _getDailyQuest(repo),
                  ),
                  _SectionLabel('ACTIVE QUESTS'),
                  ...quests.asMap().entries.map(
                    (e) => _QuestCard(
                      quest: e.value,
                      onClaim: () => _claimReward(repo, e.value),
                    ),
                  ),
                  if (quests.isEmpty) const _EmptyQuests(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Top Bar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF141414))),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MISSION BOARD',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF5AB4E0),
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'QUESTS',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEFEFEF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Stat Strip
// ─────────────────────────────────────────────
class _StatStrip extends StatelessWidget {
  const _StatStrip({
    required this.xp,
    required this.coins,
    required this.streak,
  });

  final int xp;
  final int coins;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF141414))),
      ),
      child: Row(
        children: [
          _StatCell(label: 'XP', value: '$xp', color: const Color(0xFF5AB4E0)),
          _StatCell(label: 'COINS', value: '$coins', color: const Color(0xFFB8920A)),
          _StatCell(label: 'STREAK', value: '${streak}D', color: const Color(0xFFEFEFEF), last: true),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
    this.last = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: !last
              ? const Border(right: BorderSide(color: Color(0xFF141414)))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                color: Color(0xFF383838),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// System Chat Box
// ─────────────────────────────────────────────
class _SystemBox extends StatelessWidget {
  const _SystemBox({
    required this.messages,
    required this.controller,
    required this.onSend,
    required this.onDailyQuest,
  });

  final List<ChatMessage> messages;
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onDailyQuest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF08111A),
        border: Border.all(color: const Color(0xFF1A2A38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1A2A38))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SYSTEM',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFF5AB4E0),
                    letterSpacing: 2.5,
                  ),
                ),
                _SystemButton(
                  label: 'DAILY QUEST ›',
                  onTap: onDailyQuest,
                ),
              ],
            ),
          ),

          // Messages
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (messages.isEmpty) ...[
                  _SystemLine('— ARISE SYSTEM ONLINE.', role: ChatRole.system),
                ] else
                  ...messages.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _SystemLine(m.content, role: m.role),
                      )),
              ],
            ),
          ),

          // Input
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1A2A38))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'type: daily quest / rank / mission',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF222222),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => onSend(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                GestureDetector(
                  onTap: onSend,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFF1A2A38)),
                      ),
                    ),
                    child: const Text(
                      '›',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        color: Color(0xFF5AB4E0),
                      ),
                    ),
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

class _SystemLine extends StatelessWidget {
  const _SystemLine(this.text, {required this.role});

  final String text;
  final ChatRole role;

  @override
  Widget build(BuildContext context) {
    if (role == ChatRole.system && text.toLowerCase().contains('daily quest')) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF081420),
          border: Border.all(color: const Color(0xFF1A2A38)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Color(0xFF5AB4E0),
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 11,
        color: role == ChatRole.user
            ? const Color(0xFF666666)
            : const Color(0xFF2E2E2E),
        height: 1.5,
      ),
    );
  }
}

class _SystemButton extends StatefulWidget {
  const _SystemButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_SystemButton> createState() => _SystemButtonState();
}

class _SystemButtonState extends State<_SystemButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF0D1E28) : Colors.transparent,
          border: Border.all(color: const Color(0xFF1A2A38)),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: Color(0xFF5AB4E0),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: Color(0xFF333333),
          letterSpacing: 3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quest Card
// ─────────────────────────────────────────────
class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest, required this.onClaim});

  final Quest quest;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final isComplete = quest.isComplete;
    final isActive = quest.progress > 0 && !isComplete;

    final Color accentColor = isComplete
        ? quest.difficulty == DifficultyTier.hard
            ? const Color(0xFFB8920A)
            : const Color(0xFF5AB4E0)
        : Colors.transparent;

    final Color progressColor = isComplete
        ? quest.difficulty == DifficultyTier.hard
            ? const Color(0xFFB8920A)
            : const Color(0xFF5AB4E0)
        : quest.difficulty == DifficultyTier.hard
            ? const Color(0xFF402C10)
            : const Color(0xFF223040);

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: (isComplete || isActive)
            ? const Color(0xFF090F14)
            : const Color(0xFF0D0D0D),
        border: Border(
          left: BorderSide(color: accentColor, width: 2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + difficulty
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  quest.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: (isComplete || isActive)
                        ? const Color(0xFFEFEFEF)
                        : const Color(0xFFAAAAAA),
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _DiffBadge(difficulty: quest.difficulty),
            ],
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            quest.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: (isComplete || isActive)
                  ? const Color(0xFF555555)
                  : const Color(0xFF383838),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 2,
            color: const Color(0xFF181818),
            child: FractionallySizedBox(
              widthFactor: quest.progressFraction.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(color: progressColor),
            ),
          ),

          const SizedBox(height: 10),

          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isComplete
                    ? 'COMPLETE · +${quest.rewardXp} XP +${quest.rewardCoins} ◈'
                    : '${quest.progressLabel} · +${quest.rewardXp} XP +${quest.rewardCoins} ◈',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: isComplete
                      ? quest.difficulty == DifficultyTier.hard
                          ? const Color(0xFFB8920A)
                          : const Color(0xFF5AB4E0)
                      : const Color(0xFF333333),
                  letterSpacing: 0.5,
                ),
              ),
              _ClaimButton(
                quest: quest,
                onTap: onClaim,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  const _DiffBadge({required this.difficulty});
  final DifficultyTier difficulty;

  @override
  Widget build(BuildContext context) {
    final isHard = difficulty == DifficultyTier.hard ||
        difficulty == DifficultyTier.elite;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isHard
              ? const Color(0xFF402010)
              : const Color(0xFF1A3040),
        ),
      ),
      child: Text(
        difficulty.name.toUpperCase(),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9,
          letterSpacing: 2,
          color: isHard
              ? const Color(0xFFB07030)
              : const Color(0xFF4A9ABF),
        ),
      ),
    );
  }
}

class _ClaimButton extends StatefulWidget {
  const _ClaimButton({required this.quest, required this.onTap});

  final Quest quest;
  final VoidCallback onTap;

  @override
  State<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends State<_ClaimButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final canClaim = widget.quest.isClaimable;
    final isGold = widget.quest.difficulty == DifficultyTier.hard ||
        widget.quest.difficulty == DifficultyTier.elite;

    final Color borderColor = !canClaim
        ? const Color(0xFF1E1E1E)
        : isGold
            ? const Color(0xFFB8920A)
            : const Color(0xFF5AB4E0);

    final Color textColor = !canClaim
        ? const Color(0xFF2A2A2A)
        : isGold
            ? const Color(0xFFB8920A)
            : const Color(0xFF5AB4E0);

    return GestureDetector(
      onTapDown: canClaim ? (_) => setState(() => _pressed = true) : null,
      onTapUp: canClaim ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: canClaim ? () => setState(() => _pressed = false) : null,
      onTap: canClaim ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: _pressed
              ? isGold
                  ? const Color(0xFF0E0A02)
                  : const Color(0xFF081420)
              : Colors.transparent,
          border: Border.all(color: borderColor),
        ),
        child: Text(
          'CLAIM',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────
class _EmptyQuests extends StatelessWidget {
  const _EmptyQuests();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '— No active quests.',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Color(0xFF2A2A2A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Ask the system for a daily quest to begin.',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}