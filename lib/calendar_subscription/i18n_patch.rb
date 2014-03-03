require 'redmine/i18n'

module CalendarSubscription
  module I18n
    extend ActiveSupport::Concern

    included do
      alias_method_chain :format_date, :time_support
      @@in_formate_date = false
    end

    def format_date_with_time_support(date)
      return nil unless date
      if date.is_a?(Time) && ! @@in_formate_date
        begin
          @@in_formate_date = true
          return format_time(date)
        ensure
          @@in_formate_date = false
        end
      end
      format_date_without_time_support(date)
    end
  end
end

Redmine::I18n.send :include, CalendarSubscription::I18n
