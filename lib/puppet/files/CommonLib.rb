# Utility Class - command method

require 'fileutils'
require 'puppet'

class CommonLib
  def self.get_log_path(num)
    base_path = '/opt/Dell/ASM/logs/compellent'
    if !File.exists?(base_path)
      Puppet.debug "Running for the first time"
      FileUtils.mkdir_p(base_path)
      Puppet.debug("Changing permission")
      FileUtils.chmod_R(0777,base_path)
      Puppet.debug("Changing ownership")
      FileUtils.chown_R('pe-puppet','pe-puppet',base_path)
    end
    return  base_path
  end

  def self.get_unique_refid()
    randno = Random.rand(100000)
    pid = Process.pid
    return "#{randno}_PID_#{pid}"
  end

  def self.get_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    $num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
      path = Pathname.new(temp_path)
      temp_path = path.dirname
      $i +=1
    end
    temp_path = temp_path.join('files/CompCU.jar')
    Puppet.debug("Path #{temp_path}")
    return  temp_path
  end
end
