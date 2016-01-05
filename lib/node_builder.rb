require 'forwardable'
require 'net/ssh'
require_relative 'options'
require_relative 'system_command'

class NodeBuilder

  class NodeConfigNotFound < StandardError; end

  BASE_DIR = File.realpath(File.join(File.dirname(__FILE__), '..'))
  DEFAULT_OPTIONS = {
    cleanup: true,
    verbose: false
  }.freeze

  include SystemCommand

  attr_accessor :options, :node

  extend Forwardable

  def_delegators :@options, :hostname

  def initialize(node, options={})
    @node    = node
    @options = Options.new(DEFAULT_OPTIONS.merge(options))
    @logger = @options.logger
    check_config_file!
  end

  def build
    log "Started setting up host: #{node}"

    if chef_installed?
      log 'Chef already installed. Skipping host preparation...'
    else
      prepare_host
    end
    setup_host
    cleanup_host if options[:cleanup_host]
  end

  def config
    JSON.parse File.read(config_file_path)
  end

  private

  def setup_host
    command = "bundle exec knife solo cook #{options.hostname} #{options.for_knife_solo(node)}"
    system_cmd command, ">> Setup host #{options.hostname}:\n"
  end

  def cleanup_host
    command = "bundle exec knife solo clean #{options.hostname} #{options.for_knife_solo(node)}"
    system_cmd command, ">> Clean #{options.hostname}:\n"
  end

  def prepare_host
    command = "bundle exec knife solo prepare #{options.hostname} #{options.for_knife_solo(node)}"
    system_cmd command,  ">> Install chef to the host #{node}(#{options.hostname}):\n"
  end

  def chef_installed?
    command = "ssh #{options.for_ssh_cli} #{options.hostname} '/usr/bin/chef-client --version'"
    exit_status = system_cmd command, ">> Check if Chef is already installed on #{options.hostname}:\n"
    exit_status == 0
  end

  def config_file_path
    File.join(BASE_DIR, 'nodes', "#{node}.json")
  end

  def check_config_file!
    unless File.exists?(config_file_path)
      raise NodeConfigNotFound, "Node config file #{config_file_path} was not found."
    end
  end
end
