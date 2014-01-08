# Utility Class - command method

class CommonLib

  def self.get_log_path(num)
    temp_path = Pathname.new(__FILE__).parent
    Puppet.debug("Temp PATH - #{temp_path}")
    $i = 0
    #$num = num
    path = Pathname.new(temp_path)
    while $i < $num  do
		path = Pathname.new(temp_path)
		temp_path = path.dirname
		$i +=1
    end
    temp_path = temp_path.join('logs')
    Puppet.debug("Log Path #{temp_path}")
    return  temp_path
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
    temp_path = temp_path.join('files/CompCU-6.3.jar')
    Puppet.debug("Path #{temp_path}")
    return  temp_path
  end
end
