require_dependency 'issue'
require_dependency 'issues_helper'
require_dependency 'journal_detail'

class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    before_type_cast = record.attributes_before_type_cast[attribute.to_s]
    if before_type_cast.is_a?(String) && before_type_cast.present?
      # TODO: #*_date_before_type_cast returns a Mysql::Time with ruby1.8+mysql gem
      unless before_type_cast =~ /\A\d{4}-\d{2}-\d{2}( \d{2}:\d{2}(:\d{2})?( [+-]?\d{2}:?\d{2})?)?\z/ && value
        record.errors.add attribute, :not_a_date
      end
    end
  end
end

module CalendarSubscription
  # Issue validates due_date as date_time
  module IssuePatch
    extend ActiveSupport::Concern

    included do
      unloadable
      
      # remove validates :due_date, :date => true
      _validators.reject!{ |key, _| key == :due_date }
      _validate_callbacks.reject! do |callback|
        callback.raw_filter.is_a?(DateValidator) && callback.raw_filter.attributes == [:due_date]
      end

      validates :due_date, :date_time => true
    end
  end

  # interpret due_date with .to_time
  module IssuesHelperPatch
    extend ActiveSupport::Concern

    included do
      unloadable
      alias_method_chain :show_detail, :due_date_time
    end

    def show_detail_with_due_date_time(detail, no_html=false, options={})
      if detail.property == 'attr' && detail.prop_key == 'due_date'
        field = detail.prop_key.to_s.gsub(/\_id$/, "")
        label = l(("field_" + field).to_sym)
        value = format_date(detail.value.to_time) if detail.value
        old_value = format_date(detail.old_value.to_time) if detail.old_value
      else
        return show_detail_without_due_date_time(detail, no_html, options)
      end

      call_hook(:helper_issues_show_detail_after_setting,
                {:detail => detail, :label => label, :value => value, :old_value => old_value })

      unless no_html
        label = content_tag('strong', label)
        old_value = content_tag("i", h(old_value)) if detail.old_value
        if detail.old_value && detail.value.blank? && detail.property != 'relation'
          old_value = content_tag("del", old_value)
        end
        value = content_tag("i", h(value)) if value
      end

      if detail.value.present?
        if detail.old_value.present?
          l(:text_journal_changed, :label => label, :old => old_value, :new => value).html_safe
        else
          l(:text_journal_set_to, :label => label, :value => value).html_safe
        end
      else
        l(:text_journal_deleted, :label => label, :old => old_value).html_safe
      end
    end
  end

  # Display time changes in the issue change journal
  module JournalDetailPatch
    extend ActiveSupport::Concern

    included do
      unloadable
      alias_method_chain :normalize, :time
    end

    def normalize_with_time(v)
      case v
        when Time
          v.strftime('%F %T')
        else
          normalize_without_time(v)
      end
    end
  end
end

unless Issue.included_modules.include?(CalendarSubscription::IssuePatch)
  Issue.send :include, CalendarSubscription::IssuePatch
end
unless IssuesHelper.included_modules.include?(CalendarSubscription::IssuesHelperPatch)
  IssuesHelper.send :include, CalendarSubscription::IssuesHelperPatch
end
unless JournalDetail.included_modules.include?(CalendarSubscription::JournalDetailPatch)
  JournalDetail.send :include, CalendarSubscription::JournalDetailPatch
end
