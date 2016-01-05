require 'ostruct'

class Options < OpenStruct

  def for_knife_solo(node)
    ["-N #{node}", "--ssh-user #{user}"].tap do |opts|
      opts << "--ssh-port #{ssh_port}" if ssh_port
      opts << "--identity-file #{ssh_identity_file}" if ssh_identity_file
      opts << '-V'
    end.join(' ')
  end

  def for_ssh_cli
    ["-l #{user}"].tap do |opts|
      opts << "-p #{ssh_port}" if ssh_port
      opts << "-i #{ssh_identity_file}" if ssh_identity_file
    end.join(' ')
  end

  def for_capistano_ssh
    {
      user: 'deployer',
      auth_methods: %w(publickey),
      forward_agent: true
    }.tap do |opts|
      opts[:keys] = [ssh_identity_file] if ssh_identity_file
      opts[:port] = ssh_port if ssh_port
    end
  end
end
