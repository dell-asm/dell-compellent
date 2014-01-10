class Compellent_hba_fixture
  attr_accessor :compellent_hba, :provider
  def initialize
    @compellent_hba = get_compellent_hba
    @provider = compellent_hba.provider
  end

  def  get_compellent_hba
    Puppet::Type.type(:compellent_hba).new(
    :name         => 'DemoAlias',
    :ensure       => 'present',
	:porttype     => '1234',
	:manual       => 'true',
    :wwn          => 'WWN',
	:serverfolder => '',
    )
  end

  public

  def  get_name
    @compellent_hba[:name]
  end

  def  get_porttype
    @compellent_hba[:porttype]
  end
  
  def  get_manual
    @compellent_hba[:manual]
  end
  
  def  get_wwn
    @compellent_hba[:wwn]
  end
  
  def  get_serverfolder
    @compellent_hba[:serverfolder]
  end

end