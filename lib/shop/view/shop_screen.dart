import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  final VoidCallback? onBackToHome; // 홈으로 돌아가는 콜백 추가
  
  const ShopScreen({super.key, this.onBackToHome});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedCategory = 0; // 0: 헤어, 1: 옷, 2: 무기
  int _selectedItemIndex = -1; // 선택된 아이템 인덱스 (-1은 선택 없음)
  bool _showMyItemsOnly = false; // 나의 아이템만 보기 토글 상태
  
  // 현재 적용된 아이템들 (카테고리별로 저장)
  final Map<int, int> _appliedItems = {
    0: -1, // 헤어: 기본값 (적용 안됨)
    1: -1, // 옷: 기본값 (적용 안됨)
    2: -1, // 무기: 기본값 (적용 안됨)
  };

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

  // 현재 적용된 아이템들로 캐릭터 이미지 생성
  Widget _buildCharacterWithItems() {
    return Stack(
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
        // 기본 캐릭터
        Image.asset(
          'assets/images/character_1.png',
          width: 130,
          height: 130,
          fit: BoxFit.contain,
        ),
        // 헤어 아이템 (캐릭터 위에 오버레이)
        if (_appliedItems[0] != null && _appliedItems[0]! >= 0)
          Positioned(
            top: -26, // 헤어는 더 위쪽에 위치
            left: -21, // 좌우 중앙 정렬
            child: Image.asset(
              _categoryItems[0][_appliedItems[0]!],
              width: 162, // 헤어는 약간 더 크게
              height: 162,
              fit: BoxFit.contain,
            ),
          ),
        // 옷 아이템 (캐릭터 위에 오버레이)
        if (_appliedItems[1] != null && _appliedItems[1]! >= 0)
          Positioned(
            top: -28, // 옷은 헤어보다 아래쪽에 위치
            left: -26.8, // 좌우 중앙 정렬
            child: Image.asset(
              _categoryItems[1][_appliedItems[1]!],
              width: 172, // 옷은 캐릭터와 비슷한 크기
              height: 172,
              fit: BoxFit.contain,
            ),
          ),
        // 무기 아이템 (캐릭터 위에 오버레이)
        if (_appliedItems[2] != null && _appliedItems[2]! >= 0)
          Positioned(
            top: 20, // 무기는 가장 아래쪽에 위치
            left: 0, // 좌우 중앙 정렬
            child: Image.asset(
              _categoryItems[2][_appliedItems[2]!],
              width: 130, // 무기는 기본 크기
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
      ],
    );
  }

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
                        'assets/icons/fire_icon.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '200',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Stack(
                        children: [
                          // 배경 토글 (항상 표시)
                          Image.asset(
                            'assets/icons/toggle_off.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          // 활성화된 토글 (조건부로 표시)
                          if (_showMyItemsOnly)
                            Positioned(
                              left: 8.5,
                              top: 0,
                              child: Image.asset(
                                'assets/icons/toggle_on.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                          // 터치 영역
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showMyItemsOnly = !_showMyItemsOnly;
                                });
                              },
                            ),
                          ),
                        ],
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '옷을 입혀보세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
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
                            // 현재 적용된 아이템들로 캐릭터 생성
                            _buildCharacterWithItems(),
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
                          _buildShopItem(_categoryItems[_selectedCategory][0], 200, 0),
                          _buildShopItem(_categoryItems[_selectedCategory][1], 200, 1),
                          _buildShopItem(_categoryItems[_selectedCategory][2], 200, 2),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShopItem(_categoryItems[_selectedCategory][3], 200, 3),
                          _buildShopItem(_categoryItems[_selectedCategory][4], 200, 4),
                          _buildShopItem(_categoryItems[_selectedCategory][5], 200, 5),
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
                      icon: Image.asset(
                        'assets/icons/back_btn.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F2F2F),
                          padding: const EdgeInsets.symmetric(vertical: 8), // 구입버튼 크기
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/fire_icon.png',
                              width: 30,
                              height: 30,
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
                      onPressed: () {
                        setState(() {
                          // 착용하고 있던 모든 아이템 해제
                          _appliedItems[0] = -1; // 헤어 해제
                          _appliedItems[1] = -1; // 옷 해제
                          _appliedItems[2] = -1; // 무기 해제
                          // 선택된 아이템도 초기화
                          _selectedItemIndex = -1;
                        });
                      },
                      icon: Image.asset(
                        'assets/icons/undo_btn.png',
                        width: 40,
                        height: 40,
                      ),
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

  Widget _buildShopItem(String imagePath, int price, int itemIndex) {
    final isSelected = _selectedItemIndex == itemIndex;
    final isApplied = _appliedItems[_selectedCategory] == itemIndex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItemIndex = itemIndex;
          // 한 번 탭으로 아이템 적용/해제
                  if (_appliedItems[_selectedCategory] == itemIndex) {
          // 이미 적용된 아이템이면 해제 (적용 안됨 상태로)
          _appliedItems[_selectedCategory] = -1;
        } else {
          // 새로운 아이템 적용
          _appliedItems[_selectedCategory] = itemIndex;
        }
        });
      },
      child: Container(
        width: 80,
        height: 110,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECECEC) : null, // 선택된 아이템: 회색, 그 외 없음
          borderRadius: BorderRadius.circular(8),
          border: (isApplied || isSelected)
              ? Border.all(
                  color: const Color(0xFFECECEC), // 선택 또는 적용: #ECECEC 테두리
                  width: 2,
                )
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(1.0),
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
                color: isSelected ? const Color(0xFFECECEC) : null,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/fire_icon.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    price.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}