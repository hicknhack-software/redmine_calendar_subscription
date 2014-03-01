require_dependency 'application_controller'

module CalendarSubscription
  module ApplicationControllerPatch
    extend ActiveSupport::Concern

    included do
      alias_method_chain :find_current_user, :ics
    end

    # enable rss key auth also for ics format
    def find_current_user_with_ics
      result = find_current_user_without_ics
      return result if result
      if params[:format] == 'ics' && params[:key] && request.get? && accept_rss_auth?
        User.find_by_rss_key(params[:key])
      end
    end
  end
end

ApplicationController.send(:include, CalendarSubscription::ApplicationControllerPatch)
