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

class PeopleRatesControllerTest < ActionController::TestCase
  include RedminePeople::TestCase::TestHelper
  include Redmine::I18n

  fixtures :users
  RedminePeople::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_people).directory + '/test/fixtures/', [:time_entries, :people_rates])

  def setup
    Setting.plugin_redmine_people = {}
    @admin = User.find(1)
    @user = User.find(2)
    @person = Person.find(4)
    @people_rate = PeopleRate.find(2)
    @people_rate_params_old = { rate_type: PeopleRate::COST_RATE, rate: 10, from_date: '2017-02-01'.to_date, project_id: '' }
    @people_rate_params_new = { rate_type: PeopleRate::BILL_RATE, rate: 20.567, from_date: '2017-06-01'.to_date, project_id: '' }
    @people_rate_attributes_old = { rate_type: PeopleRate::COST_RATE, rate: 10, from_date: '2017-02-01'.to_date, project_id: 1 }
    @people_rate_attributes_new = { rate_type: PeopleRate::BILL_RATE, rate: 20.567, from_date: '2017-06-01'.to_date, project_id: nil }
  end

  def test_should_get_new
    @request.session[:user_id] = @admin.id
    compatible_request :get, :new, person_id: @person
    assert_response :success
  end

  def test_should_not_access_new
    compatible_request :get, :new, person_id: @person
    assert_response :redirect
  end

  def test_should_not_access_new_without_permission_edit_rates
    @request.session[:user_id] = @user.id
    compatible_request :get, :new, person_id: @person
    assert_response :forbidden
  end

  def test_should_access_new_with_permission_edit_rates
    PeopleAcl.create(@user.id, ['edit_rates'])
    @request.session[:user_id] = @user.id
    compatible_request :get, :new, person_id: @person
    assert_response :success
  end

  def test_should_create_people_rate
    @request.session[:user_id] = @admin.id
    should_create_people_rate
  end

  def test_should_not_create_people_rate
    should_not_create_people_rate
  end

  # user_id, rate_type, from_date and project_id should be unique
  def test_should_not_create_people_rate_with_the_same_params
    @request.session[:user_id] = @admin.id
    should_not_create_people_rate :success, @people_rate_params_old
    @people_rate_params_old[:rate] = 100
    should_not_create_people_rate :success, @people_rate_params_old
  end

  def test_should_create_people_rate_with_the_same_params_for_other_person
    @request.session[:user_id] = @admin.id
    should_create_people_rate Person.find(2), @people_rate_params_old
  end

  def test_should_not_access_create_without_permission_edit_rates
    @request.session[:user_id] = @user.id
    should_not_create_people_rate :forbidden
  end

  def test_should_access_create_with_permission_edit_rates
    PeopleAcl.create(@user.id, ['edit_rates'])
    @request.session[:user_id] = @user.id
    should_create_people_rate
  end

  def test_should_get_edit
    @request.session[:user_id] = @admin.id
    compatible_request :get, :edit, id: @people_rate, person_id: @person
    assert_response :success
  end

  def test_should_not_access_edit
    compatible_request :get, :edit, id: @people_rate, person_id: @person
    assert_response :redirect
  end

  def test_should_not_access_edit_without_permission_edit_rates
    @request.session[:user_id] = @user.id
    compatible_request :get, :edit, id: @people_rate, person_id: @person
    assert_response :forbidden
  end

  def test_should_access_edit_with_permission_edit_rates
    PeopleAcl.create(@user.id, ['edit_rates'])
    @request.session[:user_id] = @user.id
    compatible_request :get, :edit, id: @people_rate, person_id: @person
    assert_response :success
  end

  def test_should_update_people_rate
    @request.session[:user_id] = @admin.id
    should_update_people_rate
  end

  def test_should_not_update_people_rate
    should_not_update_people_rate
  end

  def test_should_not_access_update_without_permission_edit_rates
    @request.session[:user_id] = @user.id
    should_not_update_people_rate :forbidden
  end

  def test_should_access_update_with_permission_edit_rates
    PeopleAcl.create(@user.id, ['edit_rates'])
    @request.session[:user_id] = @user.id
    should_update_people_rate
  end

  def test_should_destroy_people_rate
    @request.session[:user_id] = @admin.id
    assert_difference('PeopleRate.count', -1) do
      compatible_request :delete, :destroy, id: @people_rate, person_id: @person
    end
    assert_redirected_to tabs_person_path(@person, 'rates')
    assert_equal flash[:notice], l(:notice_people_rate_successfully_destroyed)
  end

  def test_should_not_destroy_people_rate
    assert_difference('PeopleRate.count', 0) do
      compatible_request :delete, :destroy, id: @people_rate, person_id: @person
    end
    assert_response :redirect
  end

  def test_should_not_access_destroy_without_permission_edit_rates
    @request.session[:user_id] = @user.id
    assert_difference('PeopleRate.count', 0) do
      compatible_request :delete, :destroy, id: @people_rate, person_id: @person
    end
    assert_response :forbidden
  end

  def test_should_access_destroy_with_permission_edit_rates
    PeopleAcl.create(@user.id, ['edit_rates'])
    @request.session[:user_id] = @user.id
    assert_difference('PeopleRate.count', -1) do
      compatible_request :delete, :destroy, id: @people_rate, person_id: @person
    end
    assert_redirected_to tabs_person_path(@person, 'rates')
    assert_equal flash[:notice], l(:notice_people_rate_successfully_destroyed)
  end

  private

  def should_create_people_rate(person = @person, params = @people_rate_params_new)
    assert_difference('PeopleRate.count') do
      compatible_request :post, :create, person_id: person, people_rate: params
    end
    assert_redirected_to tabs_person_path(person, 'rates')
    assert_equal flash[:notice], l(:notice_successful_create)
  end

  def should_not_create_people_rate(response_status = :redirect, params = @people_rate_params_new)
    assert_difference('PeopleRate.count', 0) do
      compatible_request :post, :create, person_id: @person, people_rate: params
    end
    assert_response response_status
  end

  def should_update_people_rate
    @people_rate_attributes_old.each { |attr, val| assert_equal @people_rate.send(attr), val }
    compatible_request :post, :update, id: @people_rate, person_id: @person, people_rate: @people_rate_params_new
    @people_rate.reload
    @people_rate_attributes_new.each { |attr, val| assert_equal @people_rate.send(attr), val }
    assert_redirected_to tabs_person_path(@person, 'rates')
    assert_equal flash[:notice], l(:notice_successful_update)
  end

  def should_not_update_people_rate(response_status = :redirect)
    compatible_request :post, :update, id: @people_rate, person_id: @person, people_rate: @people_rate_params_new
    assert_response response_status
    @people_rate.reload
    @people_rate_attributes_old.each { |attr, val| assert_equal @people_rate.send(attr), val }
  end
end
