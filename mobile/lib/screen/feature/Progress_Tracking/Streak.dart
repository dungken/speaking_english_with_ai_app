import 'package:flutter/material.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  _StreakScreenState createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconPosition;

  @override
  void initState() {
    super.initState();

    // Khởi tạo AnimationController
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // Thời gian mỗi vòng quay
      vsync: this,
    );

    // Tạo Animation cho vị trí của icon
    _iconPosition = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut, // Tạo hiệu ứng mượt mà
      ),
    );

    // Lặp lại chuyển động
    _animationController.repeat(reverse: true); // Lặp lại và quay lại vị trí ban đầu
  }

  @override
  void dispose() {
    // Đảm bảo dừng AnimationController khi widget bị hủy
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, // Hide AppBar space
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: mq.width * 0.06),
        children: [
          SizedBox(height: mq.height * 0.02),

          // 🥳 Tiêu đề chúc mừng
          Text(
            'Yeye Chúc mừng bạn!',
            style: TextStyle(
              fontSize: mq.width * 0.055,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: mq.height * 0.01),
          Text(
            'Hoàn thành mục tiêu hôm nay rồi đó!',
            style: TextStyle(fontSize: mq.width * 0.04),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: mq.height * 0.04),

          // 🟠 Icon mặt cười với hiệu ứng chuyển động tự động
          Center(
            child: AnimatedBuilder(
              animation: _iconPosition,
              builder: (context, child) {
                return Stack(
                  children: [
                    Container(
                      height: mq.width * 0.4, // Kích thước container cho icon
                      width: mq.width * 0.4,  // Kích thước container cho icon
                      child: AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: _iconPosition.value * mq.width, // Di chuyển icon
                        top: 0,
                        child: Container(
                          height: mq.width * 0.2, // Kích thước icon
                          width: mq.width * 0.2, // Kích thước icon
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.sentiment_satisfied_alt,
                              size: mq.width * 0.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: mq.height * 0.04),

          // 📦 Thẻ mục tiêu học 7 ngày
          Container(
            padding: EdgeInsets.all(mq.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(mq.width * 0.06),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, mq.height * 0.005),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Học 7 ngày liên tiếp',
                  style: TextStyle(
                    fontSize: mq.width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: mq.height * 0.025),

                // 🔶 Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.width * 0.05),
                  child: LinearProgressIndicator(
                    minHeight: mq.height * 0.012,
                    value: 0.6,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),

                SizedBox(height: mq.height * 0.025),

                // 🗓️ Hàng ngày trong tuần với ngôi sao
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var day in ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'])
                      Column(
                        children: [
                          Icon(
                            Icons.star,
                            size: mq.width * 0.06,
                            color: (day == 'T4' || day == 'CN')
                                ? Colors.orange
                                : Colors.grey[300],
                          ),
                          SizedBox(height: mq.height * 0.005),
                          Text(
                            day,
                            style: TextStyle(fontSize: mq.width * 0.035),
                          ),
                        ],
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
