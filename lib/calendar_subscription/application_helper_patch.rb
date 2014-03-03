require_dependency 'application_helper'

module CalendarSubscription
  module ApplicationHelperPatch
    extend ActiveSupport::Concern

    included do
      alias_method_chain :calendar_for, :time
    end

    def calendar_for_with_time(field_id)
      if 'issue_due_date' != field_id
        calendar_for_without_time(field_id)
      else
        include_calendar_time_headers_tags
        javascript_tag("$(function() { $('##{field_id}').attr('size', 25).datetimepicker(datetimePickerOptions); });") #.val($('##{field_id}').val().replace(/\\s[+-]\\d{4}$/, ''))
      end
    end

    def include_calendar_time_headers_tags
      include_calendar_headers_tags
      unless @calendar_headers_time_tags_included
        @calendar_headers_time_tags_included = true
        tags = javascript_include_tag('jquery-ui-timepicker-addon', :plugin => 'redmine_calendar_subscription')
        tags << stylesheet_link_tag('calendar_subscription', :plugin => 'redmine_calendar_subscription')
        content_for :header_tags do
          tags << javascript_tag(
              'var datetimePickerOptions = $.extend({}, datepickerOptions, {' +
                  "timeFormat: 'HH:mm:ss Z', parse: 'loose', " +
                  "controlType: 'select', stepMinute: 5, " +
                  'showSecond: false, showTimezone: false, showTime: false, ' +
                  'beforeShow: null});')
          jquery_locale = l('jquery.locale', :default => current_language.to_s)
          unless jquery_locale == 'en'
            tags << javascript_include_tag("i18n/jquery.ui.timepicker-#{jquery_locale}.js", :plugin => 'redmine_calendar_subscription')
          end
          tags
        end
      end
    end
  end
end

ApplicationHelper.send :include, CalendarSubscription::ApplicationHelperPatch
