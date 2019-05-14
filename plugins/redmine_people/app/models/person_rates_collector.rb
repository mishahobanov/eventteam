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

class PersonRatesCollector
  def initialize(person, date = User.current.today)
    @person = person
    @today = date
    start_of_week = Setting.start_of_week.blank? ? 7 : Setting.start_of_week.to_i
    start_day = Date::DAYS_INTO_WEEK.key(start_of_week - 1)
    @beginning_of_week = @today.beginning_of_week(start_day)
    @rates_by_days = rates_by_days(@person.rates.cost_rates, @today.beginning_of_month.ago(1.month).to_date, @today)
  end

  def default_cost_rate
    @default_cost_rate ||= PeopleRate.cost_rate_for(@person, @today)
  end

  def default_bill_rate
    @default_bill_rate ||= PeopleRate.bill_rate_for(@person, @today)
  end

  def weekly_cost
    @weekly_cost ||= calculate_cost(@beginning_of_week, @today)
  end

  def previous_weekly_cost
    @previous_weekly_cost ||= calculate_cost(@beginning_of_week.ago(7.days).to_date, @today.ago(7.days).to_date)
  end

  def monthly_cost
    @monthly_cost ||= calculate_cost(@today.beginning_of_month, @today)
  end

  def previous_monthly_cost
    @previous_monthly_cost ||= calculate_cost(@today.beginning_of_month.ago(1.month).to_date, @today.ago(1.month).to_date)
  end

  private

  def calculate_cost(from, to)
    @person.time_entries.where('spent_on BETWEEN ? AND ?', from, to).inject(0) do |sum, time_entry|
      rate = cost_rate_by(time_entry.spent_on, time_entry.project_id)
      return unless rate # Return nil, because it is not possible to calculate the cost
      sum + (time_entry.hours * rate)
    end
  end

  def cost_rate_by(date, project)
    @rates_by_days[date][project] || @rates_by_days[date][nil] # nil is a key for default rate on date
  end

  def rates_by_days(rates, from, to)
    (from..to).inject({}) do |hash, date|
      rates_by_projects = PeopleRate.current_rates(rates, date).group_by(&:project_id)
      rates_by_projects.each { |project_id, rates| rates_by_projects[project_id] = rates.first.rate }
      hash[date] = rates_by_projects
      hash
    end
  end
end
