require_relative 'util'

module SystemCommand
  include Util

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def system_cmd(cmd, prompt='COMMAND:')
    log "\e[1;33m#{prompt} \e[0;32m#{cmd}\e[0m"
    exit_status = 1
    Open3.popen2e(cmd) do |i, oe, t|
      oe.each { |line| log line }
      exit_status = t.value
    end
    exit_status
  end

  def bundle_install
    system_cmd 'bundle install', '>>'
  end

  def berkshelf_update_cookbooks
    system_cmd 'bundle exec berks vendor cookbooks', '>>'
  end

end
