require 'tempfile'

require_relative 'gitlab_config'
require_relative 'gitlab_logger'

class GitlabKeys
  attr_accessor :auth_file, :key

  def initialize
    @command = ARGV.shift
    @key_id = ARGV.shift
    @key = ARGV.shift
    @auth_file = GitlabConfig.new.auth_file
  end

  def exec
    case @command
    when 'add-key'; add_key
    when 'rm-key';  rm_key
    when 'clear';  clear
    else
      $logger.warn "Attempt to execute invalid gitlab-keys command #{@command.inspect}."
      puts 'not allowed'
      false
    end
  end

  protected

  def add_key
    $logger.info "Adding key #{@key_id} => #{@key.inspect}"
    cmd = "command=\"#{ROOT_PATH}/bin/gitlab-shell #{@key_id}\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty #{@key}"
    cmd = "echo \'#{cmd}\' >> #{auth_file}"
    system(cmd)
  end

  def rm_key
    $logger.info "Removing key #{@key_id}"
    Tempfile.open('authorized_keys') do |temp|
      cmd = "sed '/shell #{@key_id}\"/d' #{auth_file} > #{temp.path} && mv #{temp.path} #{auth_file}"
      system(cmd)
    end
  end

  def clear
    system("echo '# Managed by gitlab-shell' > #{auth_file}")
  end
end
