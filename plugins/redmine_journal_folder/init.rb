require 'redmine'

Redmine::Plugin.register :redmine_journal_folder do
  name 'Redmine journal folder plugin'
  author 'Turucame ltd.'
  description 'This plug-in allows to fold comments of tickets.'
  version '0.0.1'
  url 'https://git.turucame.info/turucame/redmine_journal_folder.git'
  author_url 'http://turucame.jp/'
end

require_dependency 'redmine_journal_folder/hooks'
