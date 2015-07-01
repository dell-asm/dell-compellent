#!/opt/puppet/bin/ruby

require 'uri'
require 'net/https'
require 'trollop'
require 'pathname'
require 'timeout'

opts = Trollop::options do
  opt :server, 'equallogic server address', :type => :string, :required => true
  opt :port, 'equallogic server port', :default => 443
  opt :username, 'equallogic server username', :type => :string, :required => true
  opt :password, 'equallogic server password', :type => :string, :required => true
  opt :timeout, 'command timeout', :default => 240
  opt :credential_id, 'credential_id'
  opt :asm_decrypt, 'asm_decrypt'
  opt :scheme, 'connection scheme', :default => 'https'
  opt :community_string, 'community string' #This is a stub and shouldnt be used
  opt :file, 'write to file'
  opt :discovery_type, 'Discovery type Storage_Center / EM', :default => 'Storage_Center'
end
response = ''
opts[:port] == 443 ? discovery_type = 'Storage_Center' : discovery_type = 'EM'

begin
  Timeout.timeout(opts[:timeout]) do
    # intentionally doing this to let it finish
    folder = Pathname.new(__FILE__).parent
    if discovery_type == 'EM'
      fact_retrieve_command = "#{folder}/em_facts.rb --server #{opts[:server]} --scheme #{opts[:scheme]} --username '#{opts[:username]}' "\
      "--password '#{opts[:password]}'"
    else
      fact_retrieve_command = "#{folder}/compellent_facts.rb --server #{opts[:server]} --scheme #{opts[:scheme]} --username '#{opts[:username]}' "\
      "--password '#{opts[:password]}'"
    end

    response = `#{fact_retrieve_command}`
  end
rescue Timeout::Error
  exit 1
rescue => ex
  puts ex.message
  puts ex.backtrace
ensure
  equallogic_json = File.join('/opt/Dell/ASM/cache', "#{opts[:server]}.json")
  if File.exists? equallogic_json
    puts File.read(equallogic_json) if !opts[:file]
    exit 0
  else
    puts response
    exit 1
  end
end
