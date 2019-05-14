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

class PeopleRate < ActiveRecord::Base
  include Redmine::SafeAttributes

  COST_RATE = 'cost_rate'.freeze
  BILL_RATE = 'bill_rate'.freeze
  RATE_TYPES = [COST_RATE, BILL_RATE]

  belongs_to :project
  belongs_to :person, foreign_key: :user_id

  validates :rate_type, :rate, :from_date, :user_id, presence: true
  validates :rate_type, inclusion: { in: RATE_TYPES }
  validates :rate, numericality: true
  validates :rate_type, uniqueness: { scope: [:user_id, :from_date, :project_id] }

  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'rate_type', 'rate', 'currency', 'from_date', 'project_id', 'user_id'

  scope :cost_rates, -> { where(rate_type: COST_RATE).order('from_date desc') }
  scope :bill_rates, -> { where(rate_type: BILL_RATE).order('from_date desc') }

  def self.prefix(type)
    { COST_RATE => 'cost', BILL_RATE => 'bill' }[type]
  end

  def self.current_rate(rates, date = User.current.today)
    rates.sort { |a, b| b.from_date <=> a.from_date }
      .each { |rate| return rate if rate.from_date <= date }

    nil
  end

  def self.current_rates(rates, date = User.current.today)
    rates.group_by(&:project_id).map { |project_id, _rates| current_rate(_rates, date) }.compact
  end

  def self.cost_rate_for(person, date = User.current.today, project = nil)
    current_rate(person.rates.cost_rates.where(project_id: project), date).try(:rate)
  end

  def self.bill_rate_for(person, date = User.current.today, project = nil)
    current_rate(person.rates.bill_rates.where(project_id: project), date).try(:rate)
  end
end
