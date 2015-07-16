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

  # Enterprise Manager Information
  enterprise_manager = @transport.get_url('EnterpriseManager/EmDataCollector')
  enterprise_manager_info = @transport.post_request(enterprise_manager,'{}','get')
  enterprise_manager_info.keys.each do |em_key|
    facts[em_key] = enterprise_manager_info[em_key]
  end
  storage_center_fact = get_storage_center_facts
  facts['storage_centers'] = JSON.pretty_generate(storage_center_fact[0])
  facts['storage_center_info'] = JSON.pretty_generate(storage_center_fact[1])

  # iSCSI Interface information
  facts['storage_center_iscsi_fact'] = JSON.pretty_generate(get_storage_center_iscsi_facts(storage_center_fact[0]))
  facts['iscsi_fault_domain_fact'] = JSON.pretty_generate(get_iscsi_fault_domain_facts(storage_center_fact))
  facts
end

def get_storage_center_facts
  # Storage Center information
  storage_centers = []
  storage_center_info = {}
  storage_centers_url = @transport.get_url('StorageCenter/ScConfiguration/GetList')
  storage_centers_info = @transport.post_request(storage_centers_url,'{}','post')
  if storage_centers_info
    storage_centers_info.each do |sc|
      sc_instance_url = @transport.get_url("StorageCenter/ScController/#{sc['instanceId']}")
      storage_center_instance_info = @transport.post_request(sc_instance_url,'{}','get')
      storage_centers.push(sc['scSerialNumber'])
      storage_center_info[sc['scSerialNumber']] = storage_center_instance_info
    end
  end
  [storage_centers,storage_centers_info]
end

def get_iscsi_fault_domain_facts(storage_center_facts)
  iscsi_fault_domain_info = {}
  storage_centers = storage_center_facts[0]
  iscsi_fault_domain_url = @transport.get_url("StorageCenter/ScIscsiFaultDomain/GetList")
  storage_centers.each_with_index do |storage_center,index|
    storage_center_info = storage_center_facts[1][index]
    instance_id = storage_center_info['instanceId']

    iscsi_fault_domain_info[storage_center] = @transport.post_request(iscsi_fault_domain_url,
                                                                      iscsi_filter(storage_center),
                                                                      'post')
  end
  iscsi_fault_domain_info
end

def get_storage_center_iscsi_facts(storage_centers)
  iscsi_port_facts = {}
  url = @transport.get_url('StorageCenter/ScControllerPortIscsiConfiguration/GetList')
  (storage_centers || []).each do |sc|
    iscsi_port_info = @transport.post_request(url,iscsi_filter(sc),'post')
    iscsi_port_facts[sc] = iscsi_port_info
  end
  iscsi_port_facts
end

def iscsi_filter(storage_center)
  {
      "filterType" => "AND",
      "filters" => [
          {
              "attributeName" => "scSerialNumber",
              "attributeValue" => storage_center,
              "filterType" => "Equals"
          }
      ]
  }.to_json
end

begin
  results = retrieve.to_json
  p results
  exit 0
ensure
  results ||= {}
  compellent_cache = '/opt/Dell/ASM/cache'
  Dir.mkdir(compellent_cache) unless Dir.exists? compellent_cache
  file_path = File.join(compellent_cache, "#{opts[:server]}.json")
  File.write(file_path, results) unless results.empty?
end

