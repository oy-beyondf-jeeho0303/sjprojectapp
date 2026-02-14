class AppLocale {
  static const Map<String, Map<String, String>> data = {
    'ko': {
      'header_basic_info': '기본 정보',
      'btn_load': '불러오기',
      'label_birthdate': '생년월일',
      'label_birthtime': '태어난 시',
      'label_city': '태어난 도시 (위도/경도 보정)',
      'gender_male': '남성',
      'gender_female': '여성',
      'btn_save_info': '현재 정보 저장',

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

      // ========== 공통 버튼/다이얼로그 ==========
      'btn_cancel': '취소',
      'btn_confirm': '확인',
      'btn_close': '닫기',

      // ========== 메시지 (SnackBar / Error) ==========
      'msg_monthly_arrived': '월별 운세가 도착했습니다!',
      'msg_payment_complete': '결제가 완료되었습니다! 분석 결과를 확인하세요.',
      'msg_payment_verify_fail': '결제 검증에 실패했습니다. 고객센터에 문의해주세요.',
      'msg_analyze_first': '먼저 운세를 분석해주세요!',
      'msg_share_fail': '공유하기 실패: 권한을 확인해주세요.',
      'msg_profile_saved': '프로필이 안전하게 저장되었습니다.',
      'msg_server_error': '서버 오류',
      'msg_connect_fail': '서버 연결 실패',
      'msg_analysis_fail': '분석 실패: 서버 오류가 발생했습니다.',
      'msg_network_error': '네트워크 오류가 발생했습니다.',
      'msg_payment_fail': '결제 실패',
      'msg_payment_start': '결제가 완료되었습니다! 분석을 시작합니다.',
      'msg_payment_server_fail': '결제는 됐으나 서버 저장에 실패했습니다.',
      'msg_error': '오류가 발생했습니다',
      'msg_info_saved': '현재 정보가 저장되었습니다.',
      'msg_info_loaded': '저장된 정보를 불러왔습니다.',
      'msg_monthly_network_error': '월별 운세 네트워크 오류',
      'msg_monthly_fail': '월별 운세 분석 실패: 서버 오류',
      'msg_payment_failed': '결제에 실패했습니다',

      // ========== 프로필 저장/불러오기 ==========
      'dialog_save_name': '이름 저장',
      'dialog_name_hint': '예: 남편, 우리 딸',
      'profile_list_title': '저장된 사주 목록',
      'profile_list_empty': '저장된 목록이 없습니다.',
      'gender_m_short': '남',
      'gender_f_short': '여',
      'calendar_lunar': '음',
      'calendar_solar': '양',

      // ========== 월별 운세 배너 ==========
      'monthly_title': '월별 상세 운세',
      'monthly_desc': '올해 나의 달별 기운은 어떻게 흐를까요?\n지금 바로 상세한 월별 흐름을 확인해보세요.',
      'monthly_btn': '월별 상세 운세 확인하기 (₩5,900)',
      'monthly_order_name': '월별 상세 운세',

      // ========== 리포트 하단 ==========
      'report_disclaimer': '이 운세는 사주 명리학 이론을 바탕으로 분석한 결과입니다.',

      // ========== 도시 검색 ==========
      'search_no_result': '검색 결과가 없습니다.',
      'search_hint': '도시를 검색하세요 (예: Seoul, LA, Tokyo)',

      // ========== 결제 ==========
      'payment_title': '결제하기',
      'payment_redirecting': '결제 페이지로 이동 중...',

      // ========== 일별 운세 카드 ==========
      'daily_subscribed_title': '내일의 맞춤 운세 도착',
      'daily_unsubscribed_title': "내 사주로 분석한 '내일의 운세'",
      'daily_loading': '운세 데이터를 가져오는 중입니다.',
      'daily_analyzed': '정통 명리학 분석 완료',
      'daily_desc': "방금 확인하신 사주 원국을 바탕으로\n매일 달라지는 '하루의 기운'을 알려드립니다.",
      'daily_subscribe_btn': '월 9,600원으로 매일 받아보기',
      'daily_subscribe_success': '구독 성공! 내일의 운세가 열렸습니다.\n매일 아침 8시에 알림이 도착해요.',

      // ========== 구독 배너 ==========
      'sub_subscribed_title': '내일의 맞춤 운세가 도착했어요!',
      'sub_unsubscribed_title': "내 사주로 보는 '내일의 운세'",
      'sub_loading': '운세 데이터를 불러오는 중...',
      'sub_auto_refresh': '매일 아침 7시에 자동 갱신됩니다.',
      'sub_desc': "지금 보신 사주 원국을 바탕으로\n매일 달라지는 '하루의 흐름'을 분석해드립니다.",
      'sub_btn': '월 9,600원으로 매일 받아보기',
    },
    'ja': {
      'header_basic_info': '基本情報',
      'btn_load': '読み込み',
      'label_birthdate': '生年月日',
      'label_birthtime': '出生時間',
      'label_city': '出生地 (緯度/経度)',
      'gender_male': '男性',
      'gender_female': '女性',
      'btn_save_info': '情報を保存',

      // ヘッダー
      'header_input': '命式情報の入力',
      'header_manse': '私の命式 (万年暦)',
      'header_daewoon': '大運 (10年ごとの運気、大運数: {num})',
      'header_seun': '年運 (1年ごとの運気)',
      'header_analysis': '五行の分析と分布',
      'header_yongsin': '核心となる気 (用神)',
      'header_diagram': '五行の相生・相剋図',
      'header_report': '詳細運勢レポート',
      'btn_analyze': '運勢分析スタート',

      // 万年暦テーブル
      'label_siju': '時柱',
      'label_ilju': '日柱',
      'label_wolju': '月柱',
      'label_yeonju': '年柱',
      'label_gan': '天干',
      'label_ji': '地支',
      'label_shipseong': '通変星',

      // 五行
      'wood': '木(Tree)',
      'fire': '火(Fire)',
      'earth': '土(Earth)',
      'metal': '金(Metal)',
      'water': '水(Water)',

      // 五行の状態
      'status_excess': '過多',
      'status_lack': '不足',
      'status_proper': '適正',

      // 用神カード
      'yongsin_desc_1': '私の日干({elem})を助ける',
      'yongsin_desc_2': ' 気が必要です。',
      'yongsin_sub': 'この気を活用すれば、命式のバランスが整います。',
      'unknown': '不明',

      // ダイアグラム
      'diagram_standard': '基準: {elem} (日干)',
      'diagram_saeng': '生 (助ける)',
      'diagram_geuk': '剋 (抑える)',

      // 通変星
      '비견': '比肩', '겁재': '劫財',
      '식신': '食神', '상관': '傷官',
      '편재': '偏財', '정재': '正財',
      '편관': '偏官', '정관': '正官',
      '편인': '偏印', '정인': '印綬',
      '본원': '日主',

      // ========== 共通ボタン/ダイアログ ==========
      'btn_cancel': 'キャンセル',
      'btn_confirm': '確認',
      'btn_close': '閉じる',

      // ========== メッセージ ==========
      'msg_monthly_arrived': '月別運勢が届きました！',
      'msg_payment_complete': '決済が完了しました！分析結果をご確認ください。',
      'msg_payment_verify_fail': '決済の検証に失敗しました。カスタマーセンターにお問い合わせください。',
      'msg_analyze_first': 'まず運勢を分析してください！',
      'msg_share_fail': '共有に失敗しました。権限をご確認ください。',
      'msg_profile_saved': 'プロフィールが保存されました。',
      'msg_server_error': 'サーバーエラー',
      'msg_connect_fail': 'サーバー接続に失敗しました',
      'msg_analysis_fail': '分析に失敗しました。サーバーエラーが発生しました。',
      'msg_network_error': 'ネットワークエラーが発生しました。',
      'msg_payment_fail': '決済に失敗しました',
      'msg_payment_start': '決済が完了しました！分析を開始します。',
      'msg_payment_server_fail': '決済は完了しましたが、サーバー保存に失敗しました。',
      'msg_error': 'エラーが発生しました',
      'msg_info_saved': '情報が保存されました。',
      'msg_info_loaded': '保存された情報を読み込みました。',
      'msg_monthly_network_error': '月別運勢のネットワークエラー',
      'msg_monthly_fail': '月別運勢の分析に失敗しました',
      'msg_payment_failed': '決済に失敗しました',

      // ========== プロフィール保存/読み込み ==========
      'dialog_save_name': '名前を保存',
      'dialog_name_hint': '例: 夫、娘',
      'profile_list_title': '保存された命式一覧',
      'profile_list_empty': '保存された一覧がありません。',
      'gender_m_short': '男',
      'gender_f_short': '女',
      'calendar_lunar': '旧暦',
      'calendar_solar': '新暦',

      // ========== 月別運勢バナー ==========
      'monthly_title': '月別詳細運勢',
      'monthly_desc': '今年の月ごとの気の流れは？\n今すぐ詳しい月別の流れをチェック！',
      'monthly_btn': '月別詳細運勢を確認する (¥590)',
      'monthly_order_name': '月別詳細運勢',

      // ========== レポート下部 ==========
      'report_disclaimer': 'この運勢は四柱推命の理論に基づいて分析した結果です。',

      // ========== 都市検索 ==========
      'search_no_result': '検索結果がありません。',
      'search_hint': '都市を検索 (例: Seoul, LA, Tokyo)',

      // ========== 決済 ==========
      'payment_title': '決済',
      'payment_redirecting': '決済ページに移動中...',

      // ========== 日別運勢カード ==========
      'daily_subscribed_title': '明日の運勢が届きました',
      'daily_unsubscribed_title': '四柱で分析した「明日の運勢」',
      'daily_loading': '運勢データを読み込み中です。',
      'daily_analyzed': '本格命理学分析完了',
      'daily_desc': '先ほど確認された命式をもとに\n日々変わる「一日の気」をお届けします。',
      'daily_subscribe_btn': '月額¥960で毎日受け取る',
      'daily_subscribe_success': '購読成功！明日の運勢が開放されました。\n毎朝8時に通知が届きます。',

      // ========== 購読バナー ==========
      'sub_subscribed_title': '明日の運勢が届きました！',
      'sub_unsubscribed_title': '四柱で見る「明日の運勢」',
      'sub_loading': '運勢データを読み込み中...',
      'sub_auto_refresh': '毎朝7時に自動更新されます。',
      'sub_desc': '先ほどご覧の命式をもとに\n日々変わる「一日の流れ」を分析します。',
      'sub_btn': '月額¥960で毎日受け取る',
    },
    'en': {
      'header_basic_info': 'Basic Info',
      'btn_load': 'Load',
      'label_birthdate': 'Birth Date',
      'label_birthtime': 'Birth Time',
      'label_city': 'Birth City',
      'gender_male': 'Male',
      'gender_female': 'Female',
      'btn_save_info': 'Save Info',

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
      'label_gan': 'Heaven',
      'label_ji': 'Earth',
      'label_shipseong': 'Deity',

      // Elements
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
      'diagram_saeng': 'Support(生)',
      'diagram_geuk': 'Control(剋)',

      // Shipseong
      '비견': 'Friend', '겁재': 'Rival',
      '식신': 'Output', '상관': 'Rebel',
      '편재': 'Windfall', '정재': 'Wealth',
      '편관': 'Power', '정관': 'Officer',
      '편인': 'Intuition', '정인': 'Wisdom',
      '본원': 'Me',

      // ========== Common Buttons/Dialog ==========
      'btn_cancel': 'Cancel',
      'btn_confirm': 'OK',
      'btn_close': 'Close',

      // ========== Messages ==========
      'msg_monthly_arrived': 'Monthly fortune is ready!',
      'msg_payment_complete': 'Payment complete! Check your analysis results.',
      'msg_payment_verify_fail': 'Payment verification failed. Please contact support.',
      'msg_analyze_first': 'Please analyze your fortune first!',
      'msg_share_fail': 'Failed to share. Please check permissions.',
      'msg_profile_saved': 'Profile saved successfully.',
      'msg_server_error': 'Server error',
      'msg_connect_fail': 'Failed to connect to server',
      'msg_analysis_fail': 'Analysis failed: Server error occurred.',
      'msg_network_error': 'A network error occurred.',
      'msg_payment_fail': 'Payment failed',
      'msg_payment_start': 'Payment complete! Starting analysis.',
      'msg_payment_server_fail': 'Payment succeeded but server save failed.',
      'msg_error': 'An error occurred',
      'msg_info_saved': 'Information saved.',
      'msg_info_loaded': 'Saved information loaded.',
      'msg_monthly_network_error': 'Monthly fortune network error',
      'msg_monthly_fail': 'Monthly fortune analysis failed',
      'msg_payment_failed': 'Payment failed',

      // ========== Profile Save/Load ==========
      'dialog_save_name': 'Save Name',
      'dialog_name_hint': 'e.g., Husband, My Daughter',
      'profile_list_title': 'Saved Profiles',
      'profile_list_empty': 'No saved profiles.',
      'gender_m_short': 'M',
      'gender_f_short': 'F',
      'calendar_lunar': 'Lunar',
      'calendar_solar': 'Solar',

      // ========== Monthly Fortune Banner ==========
      'monthly_title': 'Monthly Detailed Fortune',
      'monthly_desc': 'How will your monthly energy flow this year?\nCheck your detailed monthly forecast now.',
      'monthly_btn': 'Unlock Monthly Fortune (\$5.90)',
      'monthly_order_name': 'Monthly Detailed Fortune',

      // ========== Report Footer ==========
      'report_disclaimer': 'This fortune is analyzed based on traditional Saju theory.',

      // ========== City Search ==========
      'search_no_result': 'No results found.',
      'search_hint': 'Search for city (e.g., Seoul, LA, Tokyo)',

      // ========== Payment ==========
      'payment_title': 'Payment',
      'payment_redirecting': 'Redirecting to payment...',

      // ========== Daily Fortune Card ==========
      'daily_subscribed_title': "Tomorrow's Fortune Arrived",
      'daily_unsubscribed_title': "Tomorrow's Fortune by Your Saju",
      'daily_loading': 'Loading fortune data...',
      'daily_analyzed': 'Expert Analysis Complete',
      'daily_desc': "Based on your Four Pillars chart,\nwe'll deliver daily energy insights.",
      'daily_subscribe_btn': 'Subscribe for \$9.60/month',
      'daily_subscribe_success': 'Subscribed! Tomorrow\'s fortune is unlocked.\nNotifications arrive every morning at 8 AM.',

      // ========== Subscription Banner ==========
      'sub_subscribed_title': "Tomorrow's fortune has arrived!",
      'sub_unsubscribed_title': "Tomorrow's Fortune by Your Saju",
      'sub_loading': 'Loading fortune data...',
      'sub_auto_refresh': 'Auto-refreshed every morning at 7 AM.',
      'sub_desc': "Based on your Four Pillars chart,\nwe analyze the daily energy flow for you.",
      'sub_btn': 'Subscribe for \$9.60/month',
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
