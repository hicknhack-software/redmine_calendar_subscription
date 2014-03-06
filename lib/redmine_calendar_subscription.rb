
ActionDispatch::Reloader.to_prepare do
  require_dependency 'calendar_subscription/i18n_patch'
  require_dependency 'calendar_subscription/application_helper_patch'
  require_dependency 'calendar_subscription/application_controller_patch'
  require_dependency 'calendar_subscription/issue_patch'
end

require_dependency 'calendar_subscription/hooks'

module RedmineCalendarSubscription
  def self.settings
    Setting[:plugin_redmine_calendar_subscription].blank? ? {} : Setting[:plugin_redmine_calendar_subscription]
  end
end

