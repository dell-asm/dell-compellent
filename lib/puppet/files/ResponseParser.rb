# Utility Class - parsing XML

require 'rexml/document'

include REXML

class ResponseParser

  attr_accessor :response_map,:seperator
  def initialize(seperator)
    @response_map = Hash.new
    @seperator=seperator
  end

  public

  def parse_exitcode(output_file_name)
    @seperator=""
    result_file = File.new(output_file_name)
    output_doc = Document.new(result_file)
    index=1;
    output_doc.root.each_element do |system|
      key= #{system.name()
      read_node(system,key)
      if index > 0 then index+=1 end
    end
    @response_map
  end

  def parse_discovery(result_file_name, output_file_name,index)
    result_file = File.new(result_file_name)
    result_doc = Document.new(result_file)
    result= XPath.first(result_doc, "//Success")
    if result.text.eql?'TRUE'
      result_file = File.new(output_file_name)
      output_doc = Document.new(result_file)
      #index=1;
      output_doc.root.each_element do |system|
        if index > 0 then key= "#{system.name()}#{@seperator}#{index}" else key= "#{system.name()}"
        end
        read_node(system,key)
        if index > 0 then index+=1 end
      end
    end
    @response_map
  end

  def read_node(node,key_name)
    if node.has_elements?
      node.each_element do |child|
        read_node(child,key_name)
      end
    else
      key_name="#{key_name}#{@seperator}#{node.name()}"
      self.response_map[key_name]=node.text
    end
    key_name
  end

  def parse_diskfolder_xml(result_file_name, output_file_name)
    result_file = File.new(result_file_name)
    result_doc = Document.new(result_file)
    result= XPath.first(result_doc, "//Success")
    if result.text.eql?'TRUE'
      result_file = File.new(output_file_name)
      output_doc = Document.new(result_file)
      index=1;
      output_doc.root.each_element do |system|
        key= "#{system.name()}#{@seperator}#{index}"
        read_diskfolder_node(system,key)
        index=index+1
      end
    end
    @response_map
  end

  def trim_spaces(element_array)
    index=0
    while index<element_array.size do
      element_array[index]=element_array[index].strip
      index+=1
    end
    element_array
  end

  def retrieve_server_properties(server_file_name)
    server_file = File.new(server_file_name)
    result_doc = Document.new(server_file)
    prop_map=Hash.new
    result= XPath.first(result_doc, "//server/Name")
    prop_map[result.name]=result.text
    result= XPath.first(result_doc, "//server/Index")
    prop_map[result.name]=result.text
    result= XPath.first(result_doc, "//server/WWN_List")
    module_path_list=result.text.split(',')
    prop_map[result.name]=trim_spaces(module_path_list)
    volume_list=Array.new
    index=0
    result= XPath.each(result_doc, "//server/Mappings/mapping/Volume") do |volume|
      volume_list[index] = volume.text
      index+=1
    end
    prop_map["Volume"]=volume_list
    volume_id=Array.new
    index=0
    result= XPath.each(result_doc, "//server/Mappings/mapping/DeviceID") do |deviceid|
      volume_id[index] = deviceid.text
      index+=1
    end
    prop_map["Volume_ID"]=volume_id
    prop_map
  end

  def read_diskfolder_node(node,key_name)
    if node.has_elements?
      node.each_element do |child|
        read_diskfolder_node(child,key_name)
      end
    else
      if node.parent.name().eql?"StorageType" then  key_name="#{key_name}#{@seperator}StorageType#{@seperator}#{get_index_value(node.parent)}#{@seperator}#{node.name()}"
      else
        key_name="#{key_name}#{@seperator}#{node.name()}"
      end
      self.response_map[key_name]=node.text
    end
    key_name
  end

  def get_index_value(node)
    node.elements["Index"].text
  end

  public

  def return_response
    @response_map
  end

  def retrieve_empty_folder_volume_properties(server_file_name, volume_name)
    prop_map=Hash.new
    server_file = File.new(server_file_name)
    result_doc = Document.new(server_file)
    result=false
    XPath.each(result_doc, "//volume") do |volume_element|
      if volume_element.elements["Name"].text.eql?"#{volume_name}"
        if volume_element.elements["Folder"].text.nil?
          read_element(volume_element,prop_map,nil)
          index=0
          XPath.each(result_doc, "//volume/Mappings/Mappings") do |mapping_element|
            read_element(mapping_element,prop_map,index)
            index+=1
          end
          result= true
          break
        end
      end
    end
    prop_map
  end

  def read_element(xml_element,prop_map,index)
    xml_element.each_element do |child|
      if not(child.has_elements?)
        if index.nil?
          key="#{xml_element.name()}_#{child.name()}"
        else
          key="#{xml_element.name()}_#{index}_#{child.name()}"
        end
        prop_map[key]=child.text
      end
    end
  end

  def retrieve_empty_folder_server_properties(server_file_name, server_name)
    prop_map=Hash.new
    server_file = File.new(server_file_name)
    result_doc = Document.new(server_file)
    #puts  result_doc.content.to_json
    result=false
    XPath.each(result_doc, "//server") do |volume_element|
      if volume_element.elements["Name"].text.eql?"#{server_name}"
        if volume_element.elements["Folder"].text.nil?
          read_server_element(volume_element,prop_map)
          deviceId_list=Array.new
          index=0
          XPath.each(result_doc, "//server/Mappings/mapping/DeviceID") do |deviceId_element|
            if deviceId_element.parent.parent.parent == volume_element
              deviceId_list[index]=deviceId_element.text
              index+=1
            end
          end
          prop_map['DeviceId']=deviceId_list
          result= true
          break
        end
      end
    end
    prop_map
  end

  def read_server_element(xml_element,prop_map)
    xml_element.each_element do |child|
      if not(child.has_elements?)
        value=child.text
        if not(value.nil?)
          value_list=value.split(',')
          prop_map["#{child.name()}"]=trim_spaces(value_list)
        end
      end
    end
  end

end
