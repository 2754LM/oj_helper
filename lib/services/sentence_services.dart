import 'package:oj_helper/services/api_service.dart';

class SentenceServices {
  final dio = ApiService.dio;
  Future<Map<String, dynamic>> getSentences() async {
    final url = 'https://v1.jinrishici.com/all.json';
    final response = await dio.get(url);
    return response.data;
  }
}

// {content: 空门寂寞汝思家，礼别云房下九华。, origin: 送童子下山, author: 金地藏, category: 古诗文-抒情-思念}
