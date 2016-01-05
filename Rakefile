dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

require 'rubygems'
require 'chef'
require 'json'
require 'lib/box_builder'

TOPDIR = File.expand_path(File.dirname(__FILE__))

Dir.glob(File.join(dir, 'lib', 'tasks', '**', '*.rake')).each do |file|
  load file
end

load 'chef/tasks/chef_repo.rake'
