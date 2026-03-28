import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:oj_helper/providers/solved_num_provider.dart';
import 'package:oj_helper/ui/widgets/platform_help.dart';
import 'package:provider/provider.dart';

class SolvedNumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SolvedNumProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('题数统计'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            color: Colors.blue,
            iconSize: 35,
            onPressed: () => _showPieChart(context, provider),
          ),
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
          return PlatformSolvedCard(platform: platform);
        },
      ),
    );
  }

  void _showPieChart(BuildContext context, SolvedNumProvider provider) {
    final size = MediaQuery.of(context).size;
    final chartSize = size.shortestSide * 0.8;

    List<PieChartSectionData> sections = [];
    int total = 0;

    for (var platform in provider.platforms) {
      final solved = provider.solvedNums[platform] ?? 0;
      if (solved > 0) {
        total += solved;
        sections.add(PieChartSectionData(
          title: provider.shortNames[platform],
          value: solved.toDouble(),
          color: provider.platformColors[platform]!,
          radius: chartSize * 0.4,
          titleStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ));
      }
    }

    if (total == 0) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('提示'),
          content: Text('暂无数据，请先查询题目'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('解题统计 (总计: $total)'),
        children: [
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 0,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlatformSolvedCard extends StatelessWidget {
  final String platform;

  const PlatformSolvedCard({Key? key, required this.platform})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SolvedNumProvider>(context);
    final isLoading = provider.isLoading[platform] ?? false;
    final infoMessage = provider.infoMessages[platform] ?? '';
    final controller = provider.controllers[platform]!;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildHeader(BuildContext context, SolvedNumProvider provider) {
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
            onPressed: () => provider.querySolvedNum(platform),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
      SolvedNumProvider provider, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        enabled: !(provider.isLoading[platform] ?? false),
        decoration: InputDecoration(
          labelText: (platform == '牛客' || platform == '蓝桥云课') ? 'id' : '用户名',
          hintText: '多用户用;分隔',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
    final isError = message.contains('查询失败');
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
