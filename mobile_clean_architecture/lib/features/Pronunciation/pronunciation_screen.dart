import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/presentation/widgets/buttons/mic_button.dart';

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({Key? key}) : super(key: key);

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  bool isRecording = false;
  bool isProcessing = false;
  double score = 0.61; // demo
  bool showScore = false;

  void _onRecordingStarted() {
    setState(() {
      isRecording = true;
      isProcessing = false;
      showScore = false;
    });
    // TODO: Bắt đầu ghi âm thực tế
  }

  void _onRecordingStopped() {
    setState(() {
      isRecording = false;
      isProcessing = true;
    });
    // TODO: Xử lý ghi âm xong, chuyển sang trạng thái chấm điểm
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isProcessing = false;
        showScore = true;
      });
    });
  }

  void _onWordTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PronunciationErrorAnalysisScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luyện phát âm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Đến lượt bạn!', style: TextStyles.h3(context)),
            const SizedBox(height: 8),
            Text('Tap the ', style: TextStyles.body(context)),
            Row(
              children: [
                Icon(Icons.mic, color: AppColors.primary, size: 20),
                Text(' và ghi âm giọng nói của bạn.', style: TextStyles.body(context)),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: showScore ? _onWordTap : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'salad',
                    style: TextStyles.h1(context).copyWith(
                      color: showScore ? (score >= 0.8 ? Colors.green : Colors.red) : Colors.black,
                    ),
                  ),
                  if (showScore)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text('61%', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('/sæ.ləd/', style: TextStyles.body(context)),
                const SizedBox(width: 8),
                Icon(Icons.info_outline, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.volume_up, color: AppColors.primary),
                const SizedBox(width: 8),
                Icon(Icons.record_voice_over, color: AppColors.primary),
                const SizedBox(width: 8),
                Icon(Icons.add, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 16),
            Text('món rau trộn', style: TextStyles.body(context)),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: isProcessing
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          Text('Đang xử lý...', style: TextStyles.body(context)),
                        ],
                      )
                    : MicButton(
                        isRecording: isRecording,
                        onRecordingStarted: _onRecordingStarted,
                        onRecordingStopped: _onRecordingStopped,
                        pulseAnimation: true,
                        size: 80,
                        activeColor: AppColors.error,
                        inactiveColor: AppColors.primary,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PronunciationErrorAnalysisScreen extends StatelessWidget {
  const PronunciationErrorAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sẽ được tách ra file riêng nếu cần
    return Scaffold(
      appBar: AppBar(title: const Text('Phân tích lỗi phát âm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('salad', style: TextStyles.h1(context).copyWith(color: Colors.red)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('61%', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('/sæ.ləd/', style: TextStyles.body(context)),
                const SizedBox(width: 8),
                Icon(Icons.info_outline, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 24),
            Table(
              border: TableBorder.all(color: Colors.grey.shade200),
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Âm', style: TextStyles.body(context, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Bạn nói', style: TextStyles.body(context, fontWeight: FontWeight.bold)),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('/s/', style: TextStyles.body(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Không đúng', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        Text('Phát âm "s" ở đây với âm /s/. Để không khí lưu thông ra ngoài một cách trôi chảy mà không bị dừng lại.', style: TextStyles.body(context)),
                      ],
                    ),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('/æ/', style: TextStyles.body(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Chính xác!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('/l/', style: TextStyles.body(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Chính xác!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('/ə/', style: TextStyles.body(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Chính xác!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('/d/', style: TextStyles.body(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('/p/', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        Text('Đây là âm thanh /d/. Ấn lưỡi vào lợi trên để ngăn luồng không khí lưu thông. Bạn cũng có thể nhả luồng hơi ra nếu muốn, nhưng điều này là không bắt buộc khi kết thúc một từ.', style: TextStyles.body(context)),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 