module CalendarSubscription
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_index_bottom, :partial => 'calendar_subscription/other_format_link'
    render_on :view_projects_show_sidebar_bottom, :partial => 'calendar_subscription/sidebar'
  end
end
