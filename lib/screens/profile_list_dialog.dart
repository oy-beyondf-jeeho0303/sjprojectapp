import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/profile_service.dart';

class ProfileListDialog extends StatefulWidget {
  final Function(SajuProfile) onSelect; // 선택 시 실행할 함수

  const ProfileListDialog({super.key, required this.onSelect});

  @override
  State<ProfileListDialog> createState() => _ProfileListDialogState();
}

class _ProfileListDialogState extends State<ProfileListDialog> {
  final _profileService = ProfileService();
  List<SajuProfile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() async {
    final list = await _profileService.getProfiles();
    setState(() => _profiles = list);
  }

  void _deleteProfile(String id) async {
    await _profileService.deleteProfile(id);
    _loadProfiles(); // 목록 갱신
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("저장된 사주 목록"),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _profiles.isEmpty
            ? const Center(child: Text("저장된 목록이 없습니다."))
            : ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final p = _profiles[index];
                  String birthStr = DateFormat("yy.MM.dd").format(p.birthDate);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          p.gender == "M" ? Colors.blue[100] : Colors.pink[100],
                      child: Text(p.gender == "M" ? "남" : "여",
                          style: TextStyle(
                              color:
                                  p.gender == "M" ? Colors.blue : Colors.pink,
                              fontSize: 12)),
                    ),
                    title: Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "$birthStr ${p.birthTime} (${p.isLunar ? '음' : '양'})"),
                    onTap: () {
                      widget.onSelect(p); // 부모에게 선택된 사람 전달
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _deleteProfile(p.id),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("닫기"),
        ),
      ],
    );
  }
}
