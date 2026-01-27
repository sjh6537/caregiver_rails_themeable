class WelcomeTianfuController < ApplicationController
  layout false
  def index
    # --- 模擬資料準備 (建議之後搬移至 Controller) --- [cite: 1]
    @user_images = {
      hero_bg: "469979.jpg",
      care_section: "image_601b8c.jpg"
    } [cite: 1]

    @news_data = [
      {
        id: 1, tag: '活動', title: '關聖帝君聖誕祝壽', date: '農曆六月二十四',
        summary: '恭祝關聖帝君聖誕千秋，舉辦祈福誦經與平安點燈儀式。',
        content: '活動時間：農曆六月二十四日全天。當日備有平安湯圓，歡迎信眾回宮參拜祝壽，共沐神恩。',
        image: 'https://images.unsplash.com/photo-1598337766528-762283a22839?auto=format&fit=crop&q=80&w=800'
      },
      {
        id: 2, tag: '活動', title: '天福宮 × 食農DIY體驗日', date: '2024-08-15',
        summary: '體驗柚香皂、蜜柑皮乾與蘿蔔煎餅製作，感受西湖在地風味。',
        content: '本次活動結合西湖在地農產，邀請社區媽媽親手教學。費用：200元/人，地點：天福宮前廣場。',
        image: 'https://images.unsplash.com/photo-1623945448360-1d88258eb25c?auto=format&fit=crop&q=80&w=800'
      },
      {
        id: 3, tag: '招募', title: '耆老口述歷史訪談＆社區共筆記錄者', date: '2024-07-10',
        summary: '徵求青年、新住民與婦女，一同記錄西湖老街的故事。',
        content: '培訓在地記錄者，採集口述歷史、整理老照片。歡迎對地方文化有興趣的夥伴加入。',
        image: 'https://images.unsplash.com/photo-1531608139434-1912ae0797bb?auto=format&fit=crop&q=80&w=800'
      }
    ]

    @services_data = [
      { title: "天福安太歲", price: "200元／年", icon: "flame", desc: "建議準備：姓名、生日（農曆／國曆皆可）、聯絡方式。", color: "red" },
      { title: "天福平安燈", price: "200元／年", icon: "sparkles", desc: "燈別：平安燈（單一燈種）。祈求整年元辰光彩，平安順遂。", color: "amber" },
      { title: "送餐支持", price: "捐款支持", icon: "hand-heart", desc: "用途：餐食與物資、配送與關懷服務。依個人能力自由捐助。", color: "green" }
    ]
    
    @fortune_poems_json = [
      { title: "大吉籤", poem: "關聖帝君護佑深，忠義存心福自臨。\n萬里鵬程君去路，貴人接引好佳音。", explain: "正氣凜然，所求必應，有貴人相助，前途光明。" },
      { title: "上吉籤", poem: "桃園結義義千秋，信義為人百世修。\n若問前程何處去，心安理得即無憂。", explain: "只要行事光明磊落，講究信用，困難自然迎刃而解。" },
      { title: "中平籤", poem: "眼前雖有雲遮月，靜守安常待時通。\n莫把心機強用事，撥開雲霧見青天。", explain: "目前時運稍滯，建議保守行事，勿強求，等待時機轉好。" },
      { title: "吉籤", poem: "青龍偃月顯神威，斬斷荊棘路不迷。\n心正自然邪不擾，平安富貴日相隨。", explain: "堅定信念，排除萬難，神明庇佑，平安順遂。" }
    ].to_json
  end
end
