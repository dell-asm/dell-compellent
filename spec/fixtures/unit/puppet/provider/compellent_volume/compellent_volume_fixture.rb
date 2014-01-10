class Compellent_volume_fixture
  attr_accessor :compellent_volume, :provider
  def initialize
    @compellent_volume = get_compellent_volume
    @provider = compellent_volume.provider
  end

  def  get_compellent_volume
    Puppet::Type.type(:compellent_volume).new(
	:name     => 'Windows 2012',
    :purge          => 'yes',
    :size           => '2g',
    :ensure         => 'absent',
    :boot           => false,
    :volumefolder   => '',
    :notes          => 'Test Space Notes',
    :replayprofile  => 'Sample',
    :storageprofile => 'Low Priority',
    )
  end

  public

  def  get_name
    @compellent_volume[:name]
  end
  
  def  get_purge
    @compellent_volume[:purge]
  end
  
  def  get_size
    @compellent_volume[:size]
  end
  
  def  get_boot
    @compellent_volume[:boot]
  end
  
  def  get_notes
    @compellent_volume[:notes]
  end

  def  get_volumefolder
    @compellent_volume[:volumefolder]
  end
  
   def  get_replayprofile
    @compellent_volume[:replayprofile]
  end
  
  def  get_storageprofile
    @compellent_volume[:storageprofile]
  end

end