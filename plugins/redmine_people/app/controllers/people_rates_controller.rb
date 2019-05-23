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

class PeopleRatesController < ApplicationController
  before_action :require_login
  before_action :set_person
  before_action :check_permissions
  before_action :set_people_rate, only: [:show, :edit, :update, :destroy]

  def new
    @people_rate = PeopleRate.new(from_date: Date.today)
  end

  def edit
  end

  def create
    @people_rate = PeopleRate.new(user_id: @person.id)
    @people_rate.safe_attributes = params[:people_rate]

    if @people_rate.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to tabs_person_path(@person, 'rates')
    else
      render :new
    end
  end

  def update
    @people_rate.safe_attributes = params[:people_rate]
    if @people_rate.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to tabs_person_path(@person, 'rates')
    else
      render :edit
    end
  end

  def destroy
    @people_rate.destroy
    redirect_to tabs_person_path(@person, 'rates'), notice: l(:notice_people_rate_successfully_destroyed)
  end

  private
    def set_people_rate
      @people_rate = PeopleRate.find(params[:id])
    end

    def check_permissions
      render_403 unless User.current.allowed_people_to?(:edit_rates, @person)
    end
end
