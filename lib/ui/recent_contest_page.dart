import 'package:flutter/material.dart';
import 'package:oj_helper/models/contest.dart' show Contest;
import 'package:oj_helper/providers/contest_provider.dart';
import 'package:oj_helper/ui/widgets/dialog_checkbox.dart' show DialogCheckbox;
import 'package:oj_helper/utils/contest_utils.dart' show ContestUtils;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/sentence_services.dart';

class RecentContestPage extends StatefulWidget {
  @override
  State<RecentContestPage> createState() => _RecentContestPageState();
}

class _RecentContestPageState extends State<RecentContestPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final platForms = ['Codeforces', 'AtCoder', '洛谷', '蓝桥云课', '力扣', '牛客'];
  final sentenceServices = SentenceServices();
  Map<String, dynamic> sentence = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContestProvider>(context, listen: false).loadFavorites();
      _loadContests();
    });
  }

  void _loadContests() async {
    final contestProvider = Provider.of<ContestProvider>(context, listen: false);
    contestProvider.setLoading(true);
    _getSentences();
    try {
      List<List<Contest>> nowContests = await ContestUtils.getRecentContests(
          day: 7, contestProvider: contestProvider);
      contestProvider.setContests(nowContests);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('获取比赛信息失败，请检查网络')),
        );
      }
    } finally {
      contestProvider.setLoading(false);
    }
  }

  void _getSentences() async {
    final s = await sentenceServices.getSentences();
    if (mounted) {
      setState(() {
        sentence = s;
      });
    }
  }

  void _wait() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('全速加载中，老大别急喵'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final contestProvider = Provider.of<ContestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('近期比赛'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            color: Colors.blue,
            iconSize: 35,
            onPressed: _showPlatformSelection,
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.blue,
            iconSize: 35,
            onPressed: contestProvider.isLoading ? _wait : _loadContests,
          ),
        ],
      ),
      body: contestProvider.isLoading
          ? _buildLoadingIndicator()
          : _buildBody(contestProvider),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              sentence['content'] ?? '风落吴江雪，纷纷入酒杯。',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.black),
        ],
      ),
    );
  }

  void _showPlatformSelection() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ContestProvider>(
          builder: (context, provider, _) => SimpleDialog(
            title: const Text('筛选与设置'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            children: [
              SwitchListTile(
                title: const Text('显示无赛程日', style: TextStyle(fontSize: 18)),
                value: provider.showEmptyDay,
                onChanged: (value) => provider.toggleShowEmptyDay(value),
              ),
              const Divider(),
              ListTile(
                title: const Text('提醒提前时间', style: TextStyle(fontSize: 18)),
                trailing: DropdownButton<int>(
                  value: provider.notificationLeadTime,
                  items: [5, 10, 15, 30, 60].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value 分钟'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      provider.updateNotificationLeadTime(newValue);
                    }
                  },
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1.5),
              ...platForms.map((name) => DialogCheckbox(
                    title: name,
                    value: provider.selectedPlatforms[name] ?? true,
                    onChanged: (value) =>
                        provider.updatePlatformSelection(name, value ?? true),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ContestProvider provider) {
    return ListView.builder(
      itemCount: provider.timeContests.length,
      itemBuilder: (context, index) => _buildCard(index, provider.timeContests[index], provider),
      padding: const EdgeInsets.all(5.0),
    );
  }

  Widget _buildCard(int index, List<Contest> contests, ContestProvider provider) {
    final filteredContests = contests.where((c) => provider.selectedPlatforms[c.platform] ?? true).toList();
    
    if (!provider.showEmptyDay && filteredContests.isEmpty) return const SizedBox.shrink();

    final dayName = ContestUtils.getDayName(index);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.blueAccent, width: 3),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(dayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const Divider(color: Colors.blueAccent, thickness: 3),
          if (filteredContests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('这里没有比赛喵~', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ...filteredContests.asMap().entries.map((entry) {
            final contest = entry.value;
            final isLast = entry.key == filteredContests.length - 1;
            return Column(
              children: [
                _buildContestItem(contest, provider),
                if (!isLast) const Divider(color: Colors.blueAccent, thickness: 1),
              ],
            );
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildContestItem(Contest contest, ContestProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Image.asset('assets/platforms/${contest.platform}.jpg', width: 30, height: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _confirmLaunchUrl(contest.link),
                  child: Text(
                    contest.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${contest.startHourMinute} - ${contest.endHourMinute}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => provider.toggleFavorite(contest),
            icon: Icon(
              provider.isFavorite(contest.name) ? Icons.star : Icons.star_border,
              color: provider.isFavorite(contest.name) ? Colors.amber : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLaunchUrl(String? url) {
    if (url == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认访问？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse(url));
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
