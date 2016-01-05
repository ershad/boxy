require 'yaml'
require 'net/ssh'
require_relative 'system_command'
require_relative 'node_builder'

class BoxBuilder

  BASE_DIR = File.realpath(File.join(File.dirname(__FILE__), '..'))

  include SystemCommand

  attr_reader :nodes, :logger

  def initialize( logger)
    ensure_settings_file_exists
    @nodes = []
    @logger = logger
    init_nodes
  end

  def build
    nodes.each &:build
  end

  private

  def settings_file
    @_settings_file ||= File.join(BASE_DIR, 'config', 'settings.yml')
  end

  def ensure_settings_file_exists
    settings_file = File.join(BASE_DIR, 'config', 'settings.yml')

    unless File.exist? settings_file
      log "Config file `config/settings.yml` is missing. Execute below command to copy a sample file."
      log "cp config/settings.yml.example config/settings.yml"
      log "Do not forget to change the ip address and the root password in config/settings.yml"
      exit 1
    end
  end

  def ensure_settings_is_hash configs
    unless configs.is_a? Hash
      log "Error: The content of your config file `config/settings.yml` is wrong or empty."
      log "The example of `config/settings.yml` file is at `config/settings.yml.example`."
      exit 1
    end
  end

  def init_nodes
    return @nodes unless @nodes.empty?

    configs = YAML::load_file settings_file

    ensure_settings_is_hash configs

    configs.each do |node, options|
      @nodes << NodeBuilder.new(node, options.merge(logger: logger))
    end
  end

end
