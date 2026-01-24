class AppLocale {
  static const Map<String, Map<String, String>> data = {
    'ko': {
      // 헤더
      'header_input': '사주 정보 입력',
      'header_manse': '내 사주 원국 (만세력)',
      'header_daewoon': '대운 (10년마다 바뀌는 운, 대운수: {num})',
      'header_seun': '세운 (매년 바뀌는 운)',
      'header_analysis': '오행 분석 및 분포',
      'header_yongsin': '핵심 기운 (용신)',
      'header_diagram': '오행 생극 관계도',
      'header_report': '상세 운세 리포트',
      'btn_analyze': '운세 분석 시작',

      // 만세력 테이블
      'label_siju': '시주',
      'label_ilju': '일주',
      'label_wolju': '월주',
      'label_yeonju': '연주',
      'label_gan': '천간',
      'label_ji': '지지',
      'label_shipseong': '십성',

      // 오행
      'wood': '목(Tree)',
      'fire': '화(Fire)',
      'earth': '토(Earth)',
      'metal': '금(Metal)',
      'water': '수(Water)',

      // 오행 상태
      'status_excess': '과다',
      'status_lack': '부족',
      'status_proper': '적정',

      // 용신 카드
      'yongsin_desc_1': '나의 일간({elem})을 돕는',
      'yongsin_desc_2': ' 기운이 필요합니다.',
      'yongsin_sub': '이 기운을 활용하면 사주의 균형이 잡힙니다.',
      'unknown': '알 수 없음',

      // 다이어그램
      'diagram_standard': '기준: {elem} 일간',
      'diagram_saeng': '생(生)',
      'diagram_geuk': '극(剋)',

      // 십성 (한글)
      '비견': '비견', '겁재': '겁재', '식신': '식신', '상관': '상관',
      '편재': '편재', '정재': '정재', '편관': '편관', '정관': '정관',
      '편인': '편인', '정인': '정인', '본원': '본원',
    },
    'en': {
      // Header
      'header_input': 'Input Birth Data',
      'header_manse': 'Four Pillars Chart (Manse-Ryok)',
      'header_daewoon': '10-Year Luck Cycles (Daewoon: {num})',
      'header_seun': 'Yearly Luck (Seun)',
      'header_analysis': '5 Elements Analysis',
      'header_yongsin': 'Key Balancing Element (Yongsin)',
      'header_diagram': 'Interaction Diagram',
      'header_report': 'AI Detailed Report',
      'btn_analyze': 'Analyze Fortune',

      // Table Labels
      'label_siju': 'Time',
      'label_ilju': 'Day',
      'label_wolju': 'Month',
      'label_yeonju': 'Year',
      'label_gan': 'Heaven', // 천간 -> Heaven Stem
      'label_ji': 'Earth', // 지지 -> Earth Branch
      'label_shipseong': 'Deity', // 십성 -> Deity/Star

      // 오행 - Elements
      'wood': '목(Tree)',
      'fire': '화(Fire)',
      'earth': '토(Earth)',
      'metal': '금(Metal)',
      'water': '수(Water)',

      // Status
      'status_excess': 'Excess',
      'status_lack': 'Lack',
      'status_proper': 'Good',

      // Yongsin
      'yongsin_desc_1': 'To support your Day Master ({elem}),',
      'yongsin_desc_2': ' energy is needed.',
      'yongsin_sub': 'Using this element balances your life.',
      'unknown': 'Unknown',

      // Diagram
      'diagram_standard': 'Day Master: {elem}',
      'diagram_saeng': 'Support(生)', // 생
      'diagram_geuk': 'Control(剋)', // 극

      // Shipseong (English Mapping)
      '비견': 'Friend', '겁재': 'Rival',
      '식신': 'Output', '상관': 'Rebel',
      '편재': 'Windfall', '정재': 'Wealth',
      '편관': 'Power', '정관': 'Officer',
      '편인': 'Intuition', '정인': 'Wisdom',
      '본원': 'Me',
    }
  };

  // 헬퍼 함수: 현재 언어에 맞는 텍스트 가져오기
  static String get(String lang, String key, {Map<String, String>? params}) {
    String text = data[lang]?[key] ?? key; // 없으면 키 그대로 반환
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }
}
