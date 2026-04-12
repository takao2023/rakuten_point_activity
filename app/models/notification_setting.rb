class NotificationSetting < ApplicationRecord
  belongs_to :user

  # reminder_hours カラムを JSON 配列として扱う（例: [8, 11, 18, 22]）
  serialize :reminder_hours, coder: JSON

  before_save :clean_reminder_hours

  # 指定された時刻（hour）がリマインド対象かどうかを判定
  def should_remind_at?(hour)
    hours = reminder_hours.presence || []
    # 旧仕様（morning_reminder_time）との後方互換性を維持
    if hours.empty? && morning_reminder_time.present?
      return morning_reminder_time.hour == hour
    end
    hours.include?(hour)
  end

  private

  def clean_reminder_hours
    return if reminder_hours.nil?
    # 文字列を整数に変換し、重複と空文字を除去、昇順にソートして保存
    self.reminder_hours = reminder_hours.map(&:to_i).uniq.sort.reject { |h| h < 0 || h > 23 }
  end
end
