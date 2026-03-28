import 'package:flutter/material.dart';
import 'package:oj_helper/providers/rating_provider.dart';
import 'package:oj_helper/ui/widgets/platform_help.dart';
import 'package:oj_helper/ui/widgets/rating_history_chart.dart';
import 'package:provider/provider.dart';

class RatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RatingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分数查询'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.blue,
            iconSize: 35,
            onPressed: provider.queryAll,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 480,
          mainAxisExtent: 160,
        ),
        itemCount: provider.platforms.length,
        itemBuilder: (context, index) {
          final platform = provider.platforms[index];
          return PlatformRatingCard(platform: platform);
        },
      ),
    );
  }
}

class PlatformRatingCard extends StatelessWidget {
  final String platform;

  const PlatformRatingCard({Key? key, required this.platform})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RatingProvider>(context);
    final isLoading = provider.isLoading[platform] ?? false;
    final infoMessage = provider.infoMessages[platform] ?? '';
    final controller = provider.controllers[platform]!;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeader(context, provider),
          const SizedBox(height: 13),
          _buildInput(provider, controller),
          if (isLoading) _buildLoadingIndicator(),
          if (infoMessage.isNotEmpty) _buildInfoMessage(infoMessage),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RatingProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(172, 211, 218, 220),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Image.asset('assets/platforms/$platform.jpg', width: 27, height: 27),
          const SizedBox(width: 10),
          Text(
            platform,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (platform == '牛客')
            IconButton(
              onPressed: () => getNowcoderPlatformHelp(context),
              icon: const Icon(Icons.help),
            ),
          if (platform == '力扣')
            IconButton(
              onPressed: () => getLeetcodePlatformHelp(context),
              icon: const Icon(Icons.help),
            ),
          IconButton(
            onPressed: () => provider.queryRating(platform),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _showHistoryChart(context, provider),
            icon: const Icon(Icons.show_chart),
          ),
        ],
      ),
    );
  }

  void _showHistoryChart(BuildContext context, RatingProvider provider) async {
    final username = provider.controllers[platform]!.text;
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户名后再查看历史')),
      );
      return;
    }

    // Fetch history if not already fetched or empty
    if (provider.ratingHistory[platform]?.isEmpty ?? true) {
      await provider.fetchRatingHistory(platform);
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('$platform - $username 评分历史'),
            content: Consumer<RatingProvider>(
              builder: (context, p, _) {
                final history = p.ratingHistory[platform] ?? [];
                if (p.isLoading[platform] ?? false) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return RatingHistoryChart(history: history, platform: platform);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
              TextButton(
                onPressed: () => provider.fetchRatingHistory(platform),
                child: const Text('刷新数据'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildInput(
      RatingProvider provider, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: platform == '牛客' ? 'id' : '用户名',
          labelStyle: const TextStyle(color: Colors.grey),
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () => provider.clearUsername(platform),
                  icon: const Icon(Icons.highlight_off),
                ),
        ),
        onChanged: (text) {
          provider.updateInfoMessage(platform, '');
          provider.saveUsername(platform, text);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: LinearProgressIndicator(
        backgroundColor: Color.fromARGB(255, 126, 186, 213),
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildInfoMessage(String message) {
    final isError = message == '查询失败，请检查网络或用户名是否正确';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: isError ? Colors.red : Colors.green,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
    );
  }
}
