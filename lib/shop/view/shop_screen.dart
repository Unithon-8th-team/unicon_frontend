import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  final VoidCallback? onBackToHome; // 홈으로 돌아가는 콜백 추가
  
  const ShopScreen({super.key, this.onBackToHome});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedCategory = 0; // 0: 헤어, 1: 옷, 2: 무기

  // 카테고리별 아이템 데이터
  final List<List<String>> _categoryItems = [
    // 헤어 아이템들
    [
      'assets/images/hair_1.png',
      'assets/images/hair_2.png',
      'assets/images/hair_3.png',
      'assets/images/hair_4.png',
      'assets/images/hair_5.png',
      'assets/images/hair_6.png',
    ],
    // 옷 아이템들
    [
      'assets/images/clothes_1.png',
      'assets/images/clothes_2.png',
      'assets/images/clothes_3.png',
      'assets/images/clothes_4.png',
      'assets/images/clothes_5.png',
      'assets/images/clothes_6.png',
    ],
    // 무기 아이템들 (임시로 헤어 이미지 사용, 실제 무기 이미지가 있다면 교체)
    [
      'assets/images/hair_1.png',
      'assets/images/hair_2.png',
      'assets/images/hair_3.png',
      'assets/images/hair_4.png',
      'assets/images/hair_5.png',
      'assets/images/hair_6.png',
    ],
  ];

  final List<String> _categoryNames = ['헤어', '옷', '무기'];
  final List<String> _categoryIcons = [
    'assets/icons/hair.png',
    'assets/icons/clothes.png',
    'assets/icons/wepon.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9CF),
      body: Column(
        children: [
          // 상단 바 (좌측: 재화, 우측: 토글)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 좌측: 불 이모티콘과 재화
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/fire_icon.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '200',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // 우측: 나의 아이템만 토글
                  Row(
                    children: [
                      const Text(
                        '나의 아이템만',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: false,
                        onChanged: (value) {},
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 중앙 텍스트 (캐릭터 위)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(
                  '${_categoryNames[_selectedCategory]} 고르기',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '옷을 입혀보세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // 캐릭터와 배경 영역
          Expanded(
            child: Stack(
              children: [
                // 배경 레이어 (벽과 바닥)
                Column(
                  children: [
                    // 벽 배경
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFFFF9CF), // 벽 색상
                      ),
                    ),
                    // 바닥 배경
                    Container(
                      width: double.infinity,
                      height: 150,
                      color: const Color(0xFFE3DB9F), // 바닥 색상
                    ),
                  ],
                ),
                
                // 캐릭터와 메뉴 레이어
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 50, // 바닥 높이만큼 위로
                  child: Stack(
                    children: [
                      // 캐릭터 (중앙 하단에 배치)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 캐릭터와 그림자를 겹치게 배치
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // 캐릭터 그림자 (타원형)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 120,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0x4D060606), // #0606064D
                                      borderRadius: BorderRadius.all(Radius.elliptical(80, 24)),
                                    ),
                                  ),
                                ),
                                // 캐릭터 이미지
                                Image.asset(
                                  'assets/images/character_1.png',
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // (메뉴는 바깥 레이어로 이동)
                    ],
                  ),
                ),
                // 좌측 아이템 메뉴: 캐릭터와 분리된 바깥 레이어에 배치하여 잘리지 않도록 함
                Positioned(
                  left: 20,
                  // 바닥 높이(150) 내에 자연스럽게 보이도록 위치 조정
                  bottom: 0,
                  child: Column(
                    children: [
                      for (int i = 0; i < _categoryIcons.length; i++)
                        _buildMenuItem(i, _selectedCategory == i),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 하단 아이템 그리드 (고정 크기)
          Container(
            height: 300,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShopItem(_categoryItems[_selectedCategory][0], 200),
                          _buildShopItem(_categoryItems[_selectedCategory][1], 200),
                          _buildShopItem(_categoryItems[_selectedCategory][2], 200),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShopItem(_categoryItems[_selectedCategory][3], 200),
                          _buildShopItem(_categoryItems[_selectedCategory][4], 200),
                          _buildShopItem(_categoryItems[_selectedCategory][5], 200),
                        ],
                      ),
                    ],
                  ),
                ),
                // 구입 버튼
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // X 버튼 클릭 시 홈 화면으로 이동
                        if (widget.onBackToHome != null) {
                          widget.onBackToHome!();
                        }
                      },
                      icon: const Icon(Icons.close, size: 30),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/fire_icon.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '200으로 구입하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.undo, size: 30),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int categoryIndex, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryIndex;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(
            _categoryIcons[categoryIndex],
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildShopItem(String imagePath, int price) {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/fire_icon.png',
                  width: 12,
                  height: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  price.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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