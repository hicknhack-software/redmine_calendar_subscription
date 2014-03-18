# encoding: utf-8

Redmine::Plugin.register :redmine_calendar_subscription do
  name 'Redmine Calendar Subscription plugin'
  url 'https://github.com/hicknhack-software/redmine_calendar_subscription'
  author 'HicknHack Software GmbH'
  author_url 'http://www.hicknhack-software.com'
  description 'Enables calendar subscriptions to planned issue resolutions'
  version '0.3.1'

  requires_redmine :version_or_higher => '2.4.0'

  settings :default => {:past_days => '30', :future_days => '90', :maximum_issues => '1000'}, :partial => 'settings/calendar_subscription'

  Redmine::AccessControl.map do |map|
    map.project_module :calendar_subscription_plugin do |mod|
      mod.permission :subscribe_calendar, { :calendar_subscription => :show }, :read => true
    end
  end
end

require 'redmine_calendar_subscription'
