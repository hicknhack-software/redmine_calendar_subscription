require_dependency 'issue'
require_dependency 'journal_detail'
require_dependency 'issues_helper'

class DateTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    before_type_cast = record.attributes_before_type_cast[attribute.to_s]
    if before_type_cast.is_a?(String) && before_type_cast.present?
      # TODO: #*_date_before_type_cast returns a Mysql::Time with ruby1.8+mysql gem
      unless before_type_cast =~ /\A\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2}( \+?\d{4})?)?\z/ && value
        record.errors.add attribute, :not_a_date
      end
    end
  end
end

module CalendarSubscription
  module IssuePatch
    extend ActiveSupport::Concern

    included do
      # remove validates :due_date, :date => true
      _validators.reject!{ |key, _| key == :due_date }
      _validate_callbacks.reject! do |callback|
        callback.raw_filter.is_a?(DateValidator) && callback.raw_filter.attributes == [:due_date]
      end

      validates :due_date, :date_time => true
    end
  end

  module JournalDetailPatch
    extend ActiveSupport::Concern

    included do
      private
      alias_method :normalize_before_cs, :normalize
      def normalize(v)
        case v
          when Time
            v.strftime('%F %T')
          else
            normalize_before_cs(v)
        end
      end
    end
  end

  module IssuesHelperPatch
    extend ActiveSupport::Concern

    included do
      alias_method :show_detail_before_cs, :show_detail
      def show_detail(detail, no_html=false, options={})
        if detail.property == 'attr' && detail.prop_key == 'due_date'
          field = detail.prop_key.to_s.gsub(/\_id$/, "")
          label = l(("field_" + field).to_sym)
          value = format_time(detail.value.to_time) if detail.value
          old_value = format_time(detail.old_value.to_time) if detail.old_value
        else
          return show_detail_before_cs(detail, no_html, options)
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
  end
end

Issue.send :include, CalendarSubscription::IssuePatch
IssuesHelper.send :include, CalendarSubscription::IssuesHelperPatch
JournalDetail.send :include, CalendarSubscription::JournalDetailPatch
