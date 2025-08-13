import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // State variables for the switches
  bool _isBgmOn = true;
  bool _isRewardNotificationOn = true;
  bool _isCustomGreetingOn = false;
  bool _isAppLockOn = true;
  bool _isVibrationOn = true;
  bool _isReminderOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          // Section: Background Music
          const _SectionHeader(title: '배경음악'),
          _SettingsTileWithSwitch(
            title: '배경음악 활성화',
            value: _isBgmOn,
            onChanged: (val) => setState(() => _isBgmOn = val),
          ),
          const SizedBox(height: 12),
          _MusicTrackTile(title: '산들바람', subtitle: 'Track 1', isPlaying: true),
          _MusicTrackTile(title: '전투준비', subtitle: 'Track 2', isPlaying: false),
          const Divider(height: 48),

          // Section: Greetings
          const _SectionHeader(title: '화내줄깨의 인사'),
          _SettingsTileWithSwitch(
            title: '채팅 리워드 알림',
            subtitle: '채팅 리워드가 가득 차면 알려드려요.',
            value: _isRewardNotificationOn,
            onChanged: (val) => setState(() => _isRewardNotificationOn = val),
          ),
          const Divider(height: 32, indent: 10, endIndent: 10),
          _SettingsTileWithSwitch(
            title: '화내줄깨의 자유 인사',
            subtitle: '평소 감정을 기록하는 시간을 파악해 알림을 보내드려요.',
            value: _isCustomGreetingOn,
            onChanged: (val) => setState(() => _isCustomGreetingOn = val),
          ),
          const Divider(height: 48),
          
          // Section: App Lock
          _SettingsTileWithSwitch(
            title: '앱 잠금',
            subtitle: '비밀번호 잠금',
            value: _isAppLockOn,
            onChanged: (val) => setState(() => _isAppLockOn = val),
          ),
          const Divider(height: 48),
          
          // Section: Environment
          const _SectionHeader(title: '환경'),
          _SettingsTileWithSwitch(
            title: '진동',
            value: _isVibrationOn,
            onChanged: (val) => setState(() => _isVibrationOn = val),
          ),
          const SizedBox(height: 16),
          _InfoTile(
            title: '앱버전 3.12.0',
            trailingText: '최신 버전 사용 중',
          ),
          const Divider(height: 48),
          
          // Section: Notifications
          const _SectionHeader(title: '알림'),
          _SettingsTileWithSwitch(
            title: '리마인드 알림',
            subtitle: '채팅을 입력한 이후 12시간 동안 활동하지 않으시면 리마인드 해드려요.',
            value: _isReminderOn,
            onChanged: (val) => setState(() => _isReminderOn = val),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Reusable widget for section titles
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Reusable widget for settings rows with a toggle switch
class _SettingsTileWithSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTileWithSwitch({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFF5B5B5B),
                fontSize: 14,
                fontFamily: 'Pretendard',
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFF544D4D),
      ),
    );
  }
}

// A custom tile for the music track selection
class _MusicTrackTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isPlaying;

  const _MusicTrackTile({
    required this.title,
    required this.subtitle,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isPlaying ? const Color(0xFF393232) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isPlaying ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isPlaying ? const Color(0xFFBBBBBB) : Colors.black54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (isPlaying)
            const Icon(Icons.graphic_eq, color: Color(0xFFC85555)),
        ],
      ),
    );
  }
}

// A simple info tile for things like app version
class _InfoTile extends StatelessWidget {
  final String title;
  final String trailingText;
  const _InfoTile({required this.title, required this.trailingText});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF6F6F6F), fontSize: 16),
      ),
      trailing: Text(
        trailingText,
        style: const TextStyle(color: Color(0xFF6F6F6F), fontSize: 16),
      ),
    );
  }
}