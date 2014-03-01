get 'projects/:project_id/calendar_subscription', :to => 'calendar_subscription#show', :as => 'project_calendar_subscription'
get 'calendar_subscription', :to => 'calendar_subscription#show'
