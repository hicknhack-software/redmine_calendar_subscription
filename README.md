[![Dependency Status](https://gemnasium.com/hicknhack-software/redmine_calendar_subscription.png)](https://gemnasium.com/hicknhack-software/redmine_calendar_subscription)
[![Code Climate](https://codeclimate.com/github/hicknhack-software/redmine_calendar_subscription.png)](https://codeclimate.com/github/hicknhack-software/redmine_calendar_subscription)

# Redmine Calendar Subscription Plugin

Calendar subscription is a Redmine plugin that helps you keep an overview over the planned issues.

It enhances the planning capabilities of Redmine to times and provides ICS calendar subscriptions for projects, filters or the entire Redmine installation.

## Features

* working iCalender (ICS) subscriptions of planned tickets
* RSS-key based authentication
* due date is enhanced with planned finish time
* start time is calculated from planned finish time and estimated hours

## Getting the plugin

Most current version is available at: [GitHub](https://github.com/hicknhack-software/redmine_calendar_subscription).

## Requirements

* Redmine 2.4.x

## Install

1. Follow the Redmine plugin installation steps at http://www.redmine.org/wiki/redmine/Plugins Make sure the plugin is installed to `#{RAILS_ROOT}/plugins/redmine_calendar_subscription`
1. Rerun `bundle install` to install all necessarry gems
1. Setup the database using the migrations. `rake redmine:plugins:migrate RAILS_ENV=production`
1. Log into your Redmine as an Administrator
1. Setup the "subscribe calendar" permissions for your roles
1. Add "Calendar Subscription" to the enabled modules for your project
1. See "Usage" for your calendar options

## Update via Git

1. Open a shell to your Redmine's `#{RAILS_ROOT}/plugins/redmine_calendar_subscription` folder
1. Update your git copy with `git pull`
1. Update the database using the migrations. `redmine:plugins:migrate RAILS_ENV=production`
1. Restart your Redmine

## Usage

Permissions required to perform a calendar subscriptions

* view the tickets
* the project has the 'Calendar Subscription'-module
* 'subscribe_calendar' permission for the current user

If the right permissions are provided, you get access these calendar subscriptions:

1. On the project overview page you get a calendar link to all open tickets of your poject
1. At the bottom of each tickets list you have the option to create a calendar with the current filter options
1. If you go to /issues of your redmine you can view all the tickets you have access to. There you can get a link to all your tickets.

###Settings

The plugin offers a list of settings at the Redmine roles and permission settings page.

## Version History

* 0.1.0 initial release (after an idea of ZwoBit GbR)
