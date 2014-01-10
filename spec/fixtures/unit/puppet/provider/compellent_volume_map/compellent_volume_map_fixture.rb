class Compellent_volume_map_fixture
  attr_accessor :compellent_volume_map, :provider
  def initialize
    @compellent_volume_map = get_compellent_volume_map
    @provider = compellent_volume_map.provider
  end

  def  get_compellent_volume_map
    Puppet::Type.type(:compellent_volume_map).new(
	:name  => 'Windows 2012',
    :ensure            => 'present',
    :boot              => true,
    :volumefolder 	   => '',
    :serverfolder      => '',
    :servername        => 'Test_Server',
    :lun               => '',
    :localport         => '',
    :force             => true,
    :singlepath        => true,
    :readonly          => true,
    )
  end

  public

  def  get_name
    @compellent_volume_map[:name]
  end
  
  def  get_boot
    @compellent_volume_map[:boot]
  end
  
  def  get_volumefolder
    @compellent_volume_map[:volumefolder]
  end
  
  def  get_serverfolder
    @compellent_volume_map[:serverfolder]
  end
  
  def  get_servername
    @compellent_volume_map[:servername]
  end
  
  def  get_lun
    @compellent_volume_map[:lun]
  end

  def  get_localport
    @compellent_volume_map[:localport]
  end
  
   def  get_force
    @compellent_volume[:force]
  end
  
  def  get_singlepath
    @compellent_volume[:singlepath]
  end
  
  def  get_readonly
    @compellent_volume[:readonly]
  end

end