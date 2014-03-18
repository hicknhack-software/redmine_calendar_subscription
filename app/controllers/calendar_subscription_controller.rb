Time::DATE_FORMATS[:ical] = "%Y%m%dT%H%M00Z"

class CalendarSubscriptionController < ApplicationController

  before_filter :find_optional_project

  accept_rss_auth :show

  include QueriesHelper
  include SortHelper

  def show
    start_date = Date.today - Setting.plugin_redmine_calendar_subscription[:past_days].to_i.days
    end_date = Date.today + Setting.plugin_redmine_calendar_subscription[:future_days].to_i.days
    limit = Setting.plugin_redmine_calendar_subscription[:maximum_issues].to_i

    retrieve_query
    @query.group_by = nil

    calendar = Icalendar::Calendar.new
    #calendar.publish

    if @query.valid?
      issues = @query.issues(:include => [:tracker, :author, :assigned_to, :priority, :fixed_version],
                             :conditions => Issue.arel_table[:due_date].in(start_date..end_date).and(Issue.arel_table[Issue.left_column_name].eq(Issue.arel_table[Issue.right_column_name] - 1)),
                             :limit => limit, :offset => 0)
      issues.each do |issue|
        next unless issue.due_date && issue.estimated_hours
        calendar.add_event issue_to_event(issue)
      end
      #@events += @query.versions(:conditions => { :effective_date => [start_date, end_date] })
    end

    render :text => calendar.to_ical, :content_type => :ics
  end

  private

  def issue_to_event(issue)
    event = Icalendar::Event.new
    event.tzid = 'UTC'
    event.klass = 'CONFIDENTIAL' # TODO: Check for public (no login) project
    event.start (issue.due_date - issue.estimated_hours.hours).to_s(:ical)
    event.end issue.due_date.to_s(:ical)
    event.uid = issue_url(issue, plugin: 'redmine_calendar_subscription')
    event.url = issue_url(issue)

    event.summary = "[#{issue.project.name}] #{issue.tracker.name}: #{issue.subject} (##{issue.id})"
    event.description = issue.description unless issue.description.blank?
    event.priority = ics_priority issue.priority
    event.sequence = issue.lock_version
    if issue.fixed_version.nil?
      event.add_category issue.project.name
    else
      event.add_category "#{issue.project.name} - #{issue.fixed_version.name}"
    end

    event.created = issue.created_on.to_s(:ical)
    event.last_modified = issue.updated_on.to_s(:ical) unless issue.updated_on.nil?
    event.add_contact issue.assigned_to.name, {'ALTREP' => issue.assigned_to.mail} unless issue.assigned_to.nil?

    event.organizer "mailto:#{issue.author.mail}", {'CN' => issue.author.name}

    event.status = issue.assigned_to ? 'CONFIRMED' : 'TENTATIVE' unless issue.closed?
    event.transp = 'TRANSPARENT'

    event
  end

  def ics_priority(priority)
    ics_priority_map[priority.position]
  end

  def ics_priority_map
    # [position] => ICS-Priority (1 - highest, 9 - lowest)
    @priority_map ||=
        begin
          priorities = IssuePriority.where(:active => true).all.sort_by(&:position)
          max = priorities.size-1
          map = {}
          if priorities.any?
            default = priorities.index(&:is_default?) || ((priorities.size - 1) / 2)
            priorities.each_with_index do |priority, index|
              map[priority.position] = case index
                                         when 0
                                           9
                                         when 1..default-1
                                           8-(3.0/(default-1)*(index-1)).floor
                                         when default
                                           5
                                         when default+1..max-1
                                           4-(3.0/(max - default - 2)*(1 + index - default)).floor
                                         when max
                                           1
                                         else
                                           1
                                       end
            end
          end
          map
        end
  end
end
