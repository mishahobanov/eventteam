# encoding: utf-8
#
# This file is a part of Redmine People (redmine_people) plugin,
# humanr resources management plugin for Redmine
#
# Copyright (C) 2011-2018 RedmineUP
# http://www.redmineup.com/
#
# redmine_people is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_people is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_people.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../../test_helper', __FILE__)

class PersonRatesTest < ActiveSupport::TestCase
  fixtures :users, :projects, :roles, :members, :member_roles

  RedminePeople::TestCase.create_fixtures(
    Redmine::Plugin.find(:redmine_people).directory + '/test/fixtures/', [:time_entries, :people_rates]
  )

  def setup
    Setting.plugin_redmine_people = {}
    @admin = Person.find(1)
    @person = Person.find(4)
  end

  def test_person_rates_not_set_and_person_not_worked
    [1, 5, 7].each do |start_of_week|
      check_person_rates_metrics @person, '2017-01-04', start_of_week, {
        default_cost_rate: nil,
        default_bill_rate: nil,
        weekly_cost: 0,
        previous_weekly_cost: 0,
        monthly_cost: 0,
        previous_monthly_cost: 0
      }
    end
  end

  def test_person_rates_already_set_but_person_not_worked
    [1, 5, 7].each do |start_of_week|
      check_person_rates_metrics @person, '2017-02-08', start_of_week, {
        default_cost_rate: 5,
        default_bill_rate: 20,
        weekly_cost: 0,
        previous_weekly_cost: 0,
        monthly_cost: 0,
        previous_monthly_cost: 0
      }
    end
  end

  def test_person_rates_not_set_but_person_has_worked
    [1, 5, 7].each do |start_of_week|
      check_person_rates_metrics @admin, '2017-03-27', start_of_week, {
        default_cost_rate: nil,
        default_bill_rate: nil,
        weekly_cost: nil,
        previous_weekly_cost: 0,
        monthly_cost: nil,
        previous_monthly_cost: 0
      }
    end
  end

  def test_person_rates_already_set_and_person_has_worked
    [1, 5, 7].each do |start_of_week|
      check_person_rates_metrics @person, '2017-03-29', start_of_week, {
        default_cost_rate: 10,
        default_bill_rate: 20,
        weekly_cost: 15 * (6 + 6.75 + 7),
        previous_weekly_cost: 0,
        monthly_cost: 15 * (6 + 6.75 + 7),
        previous_monthly_cost: 0
      }

      check_person_rates_metrics @person, '2017-03-30', start_of_week, {
        default_cost_rate: 10,
        default_bill_rate: 20,
        weekly_cost: 15 * (6 + 6.75 + 7 + 7.25),
        previous_weekly_cost: 0,
        monthly_cost: 15 * (6 + 6.75 + 7 + 7.25),
        previous_monthly_cost: 0
      }
    end

    [1, 7].each do |start_of_week|
      check_person_rates_metrics @person, '2017-04-04', start_of_week, {
        default_cost_rate: 10,
        default_bill_rate: 20,
        weekly_cost: 15 * (7.25 + 8.5),
        previous_weekly_cost: 15 * (6 + 6.75),
        monthly_cost: 15 * (7.25 + 8.5),
        previous_monthly_cost: 0
      }

      check_person_rates_metrics @person, '2017-04-08', start_of_week, {
        default_cost_rate: 15,
        default_bill_rate: 25,
        weekly_cost: 15 * (7.25 + 8.5) + 20 * (8 + 1.75 + 5.5 + 8),
        previous_weekly_cost: 15 * (6 + 6.75 + 7 + 7.25 + 9.5),
        monthly_cost: 15 * (7.25 + 8.5) + 20 * (8 + 1.75 + 5.5 + 8),
        previous_monthly_cost: 0
      }
    end
  end

  def test_person_rates_already_set_and_person_has_worked_and_start_of_week_is_friday
    check_person_rates_metrics @person, '2017-04-04', 5, {
      default_cost_rate: 10,
      default_bill_rate: 20,
      weekly_cost: 15 * (9.5 + 7.25 + 8.5),
      previous_weekly_cost: 15 * (6 + 6.75),
      monthly_cost: 15 * (7.25 + 8.5),
      previous_monthly_cost: 0
    }

    check_person_rates_metrics @person, '2017-04-13', 5, {
      default_cost_rate: 15,
      default_bill_rate: 25,
      weekly_cost: 20 * (5.5 + 8),
      previous_weekly_cost: 15 * (9.5 + 7.25 + 8.5) + 20 * (8 + 1.75),
      monthly_cost: 15 * (7.25 + 8.5) + 20 * (8 + 1.75 + 5.5 + 8),
      previous_monthly_cost: 0
    }
  end

  private

  def check_person_rates_metrics(person, date, start_of_week, metrics)
    with_settings start_of_week: start_of_week do
      collector = PersonRatesCollector.new(person, date.to_date)
      [:default_cost_rate, :default_bill_rate, :weekly_cost, :previous_weekly_cost, :monthly_cost, :previous_monthly_cost].each do |metric|
        assert_equal metrics[metric], collector.send(metric), "collector.#{metric} does not match"
      end
    end
  end
end
