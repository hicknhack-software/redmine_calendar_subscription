require 'redmine/i18n'

module CalendarSubscription
  module I18nPatch
    extend ActiveSupport::Concern

    included do
      unloadable
      alias_method_chain :format_date, :time_support
			alias_method_chain :format_time, :recursion_protection
		end

		def format_time_with_recursion_protection(*args)
			Thread.current[:in_format_time] = true
			format_time_without_recursion_protection(*args)
		ensure
			Thread.current[:in_format_time] = nil
		end

    def format_date_with_time_support(date)
      return nil unless date
			return format_time(date) if date.is_a?(Time) && !Thread.current[:in_format_time]
      format_date_without_time_support(date)
    end
  end
end

unless Redmine::I18n.included_modules.include?(CalendarSubscription::I18nPatch)
  Redmine::I18n.send :include, CalendarSubscription::I18nPatch
end
