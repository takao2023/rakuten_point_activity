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
            text: "連携ありがとうございます！ポイ活の通知はこちらに届きます。\n詳しい設定やポイ活の完了報告はWebアプリのマイページから行ってください！"
          })
        end
      when Line::Bot::Event::Follow
        message = {
          type: 'text',
          text: "友達追加ありがとうございます！✨\n楽天ポイ活マネジメントです。\n\nリマインド通知を受け取るには、マイページからLINE連携を行ってくださいね。"
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::Postback
        handle_postback(event)
      end
    end

    head :ok
  end

  private

  def handle_postback(event)
    data = event['postback']['data']
    params = Rack::Utils.parse_query(data)
    
    line_user_id = event['source']['userId']
    profile = LineProfile.find_by(line_user_id: line_user_id)
    user = profile&.user
    
    return unless user

    case params['action']
    when 'complete_activity'
      service_master = ServiceMaster.find_by(legacy_point_activity_id: params['point_activity_id'])
      if service_master
        ActivityLog.create!(
          user: user,
          service_master: service_master,
          action: 'completed',
          report_type: 'delayed',
          source: 'line',
          via_notification: true
        )
        # ストリーク更新
        streak = user.user_streak || user.create_user_streak
        streak.update_streak! if streak.respond_to?(:update_streak!)
        
        client.reply_message(event['replyToken'], {
          type: 'text',
          text: "✅「#{service_master.name}」の完了を記録しました！"
        })
      end
    when 'skip_activity'
      service_master = ServiceMaster.find_by(legacy_point_activity_id: params['point_activity_id'])
      if service_master
        ActivityLog.create!(
          user: user,
          service_master: service_master,
          action: 'skipped',
          report_type: 'delayed',
          source: 'line',
          via_notification: true
        )
        client.reply_message(event['replyToken'], {
          type: 'text',
          text: "⏭️「#{service_master.name}」をスキップしました。"
        })
      end
    end
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_BOT_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_BOT_CHANNEL_TOKEN"]
    }
  end
end
