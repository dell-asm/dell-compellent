# Utility Class - command method

module CommonLib

  def CommonLib.temp_path
	Puppet.debug("in method temp_path in file CommonLib #############################################################")
  end


  def CommonLib.get_log_path(num)
     Puppet.debug("In method get_log_path in file CommonLib @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")	
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
    temp_path = temp_path.join('logs')
    Puppet.debug("Log Path #{temp_path}")
    return  temp_path
  end
	

  def CommonLib.get_unique_refid()
	Puppet.debug("In method get_unique_refid in file CommonLib @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    randno = Random.rand(100000)
    pid = Process.pid
    return "#{randno}_PID_#{pid}"
  end

 def CommonLib.get_path(num)
 Puppet.debug("In method get_path  in file CommonLib @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
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
    temp_path = temp_path.join('lib/CompCU-6.3.jar')
    Puppet.debug("Path #{temp_path}")
    return  temp_path
  end

end
