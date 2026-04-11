require 'line/bot'

class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          client.reply_message(event['replyToken'], {
            type: 'text',
            text: "連携ありがとうございます！ポイ活の通知はこちらに届きます。\n詳しい設定はWebアプリのマイページから行ってください！"
          })
        end
      when Line::Bot::Event::Follow
        # 友達追加時に実行したい処理
        message = {
          type: 'text',
          text: "友達追加ありがとうございます！✨\n楽天ポイ活マネジメントです。\n\nリマインド通知を受け取るには、マイページからLINE連携を行ってくださいね。"
        }
        client.reply_message(event['replyToken'], message)
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_BOT_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_BOT_CHANNEL_TOKEN"]
    }
  end
end
