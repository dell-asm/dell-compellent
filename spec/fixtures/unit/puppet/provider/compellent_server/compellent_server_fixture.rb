class Compellent_server_fixture
  attr_accessor :compellent_server, :provider
  def initialize
    @compellent_server = get_compellent_server
    @provider = compellent_server.provider
  end

  def  get_compellent_server
    Puppet::Type.type(:compellent_server).new(
	:name     => 'Windows 2012',
    :operatingsystem => 'Windows 2012',
    :ensure          => 'present',
    :serverfolder    => '',
    :notes           => '',
    :wwn             => '21000024FF44486F',
    )
  end

 public

  def  get_name
    @compellent_server[:name]
  end
  
  def  get_operatingsystem
    @compellent_server[:operatingsystem]
  end
  
  def  get_notes
    @compellent_server[:notes]
  end

  def  get_wwn
    @compellent_server[:wwn]
  end
  
  def  get_serverfolder
    @compellent_server[:serverfolder]
  end

end