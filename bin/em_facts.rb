#!/opt/puppet/bin/ruby
require 'trollop'
require 'json'
require 'pathname'
require 'xmlsimple'

puppet_dir = File.join(Pathname.new(__FILE__).parent.parent,'lib','puppet')
require "#{puppet_dir}/files/CommonLib"
require "#{puppet_dir}/files/ResponseParser"
require "#{puppet_dir}/compellent/transport"

opts = Trollop::options do
  opt :server, 'EM IP Address / Hostname', :type => :string, :required => true
  opt :port, 'EM Port', :default => 3033
  opt :username, 'EM API username', :type => :string, :required => true
  opt :password, 'EM API password', :type => :string, :required => true
  opt :timeout, 'command timeout', :default => 180
  opt :scheme, 'connection scheme', :default => 'https'
  opt :discovery_type, 'Discovery type Storage_Center / EM', :default => 'EM'
end

@file_path = File.join(Pathname.new(__FILE__).parent.parent,'lib','files')
@seperator = ' '

@transport ||= Puppet::Compellent::Transport.new(opts)

def retrieve
  facts = {}

  enterprise_manager = @transport.get_url('EnterpriseManager/EmDataCollector')
  enterprise_manager_info = @transport.post_request(enterprise_manager,'{}','get')
  facts['enterprise_manager_info'] = enterprise_manager_info

  storage_center_url = @transport.get_url('StorageCenter/ScConfiguration/GetList')
  storage_center_info = @transport.post_request(storage_center_url,'{}','post')
  facts['storage_center_info'] = storage_center_info


  facts
end

begin
  results = retrieve.to_json
  p results
  exit 0
rescue Exception => e
  puts e.message
  puts e.backtrace
  exit 1
ensure
  results ||= {}
  compellent_cache = '/opt/Dell/ASM/cache'
  Dir.mkdir(compellent_cache) unless Dir.exists? compellent_cache
  file_path = File.join(compellent_cache, "#{opts[:server]}.json")
  File.write(file_path, results) unless results.empty?
end
