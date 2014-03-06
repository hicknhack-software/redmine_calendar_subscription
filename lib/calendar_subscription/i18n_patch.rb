require 'redmine/i18n'

module CalendarSubscription
  module I18nPatch
    extend ActiveSupport::Concern

    included do
      unloadable
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

unless Redmine::I18n.included_modules.include?(CalendarSubscription::I18nPatch)
  Redmine::I18n.send :include, CalendarSubscription::I18nPatch
end
