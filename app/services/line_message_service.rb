class LineMessageService
  # リマインド用の Flex Message テンプレートを生成
  def self.remind_flex_message(user, reminders)
    {
      type: 'flex',
      altText: "【リマインド】本日のポイ活は残り#{reminders.count}件です！✨",
      contents: {
        type: "bubble",
        header: {
          type: "box",
          layout: "horizontal",
          contents: [
            {
              type: "box",
              layout: "vertical",
              contents: [
                {
                  type: "text",
                  text: "P",
                  color: "#ffffff",
                  align: "center",
                  gravity: "center",
                  size: "xl",
                  weight: "bold"
                }
              ],
              width: "40px",
              height: "40px",
              cornerRadius: "100px",
              borderWidth: "2px",
              borderColor: "#ffffff",
              backgroundColor: "#ff9800"
            },
            {
              type: "text",
              text: "楽天ポイ活マネジメント",
              weight: "bold",
              size: "sm",
              color: "#ffffff",
              margin: "md",
              gravity: "center"
            }
          ],
          backgroundColor: "#ff9800",
          paddingAll: "lg"
        },
        body: {
          type: "box",
          layout: "vertical",
          contents: [
            {
              type: "text",
              text: "本日のポイ活リマインド",
              weight: "bold",
              size: "lg",
              margin: "md"
            },
            {
              type: "text",
              text: "残り目標: #{reminders.count}件",
              size: "sm",
              color: "#aaaaaa",
              margin: "xs"
            },
            {
              type: "separator",
              margin: "lg"
            },
            {
              type: "box",
              layout: "vertical",
              margin: "lg",
              spacing: "sm",
              contents: reminders.take(5).map do |activity|
                {
                  type: "box",
                  layout: "horizontal",
                  contents: [
                    {
                      type: "text",
                      text: "●",
                      size: "xs",
                      color: "#ff9800",
                      flex: 0
                    },
                    {
                      type: "text",
                      text: activity.point_activity_title,
                      size: "sm",
                      color: "#666666",
                      margin: "md",
                      flex: 1
                    }
                  ]
                }
              end
            },
            (reminders.count > 5 ? {
              type: "text",
              text: "...他",
              size: "xs",
              color: "#aaaaaa",
              margin: "sm"
            } : nil)
          ].compact
        },
        footer: {
          type: "box",
          layout: "vertical",
          spacing: "sm",
          contents: [
            {
              type: "button",
              style: "primary",
              height: "sm",
              color: "#ff9800",
              action: {
                type: "uri",
                label: "ダッシュボードを開く",
                uri: ENV.fetch("APP_URL", "http://localhost:3000")
              }
            }
          ],
          flex: 0
        }
      }
    }
  end
end
