# RcaplSecurityPlugin

require 'net/http'
require 'uri'

module Secure_rcapl

  @@rcapl_host = LINKLK_HOST
  @@rcapl_port = LINKLK_PORT
  
  CONFIG = YAML::load(ERB.new(IO.read("config/rcapl_conf.yml")).result).freeze
  
  def rcapl_get_resource_det(usr_resource_url)
      
      response = nil
    
      resource_url = create_actual_resource_url(usr_resource_url)
    
      Net::HTTP.start(@@rcapl_host, @@rcapl_port) do |http|
        
        auth_string = create_auth_string(resource_url)
      
        response = http.get( resource_url + 'rcapl=' + auth_string , 'Accept' => 'text/xml')
        
      end 
      
      return_reponse_data(response)
    
  end  
  
  def rcapl_post_resource_det(resource_url,xml_string)
      
      response = nil
      
      uri = URI.parse(resource_url) 
      
      #uri_path = create_actual_resource_url(uri)
    
      Net::HTTP.start(@@rcapl_host, @@rcapl_port) do |http|
             
        auth_string = create_auth_string(xml_string)
        
        req = Net::HTTP::Post.new(uri.path + '?rcapl=' + auth_string)
        req['Content-Type'] =  "application/xml"
        req.body = xml_string
        response = http.request(req)
        
      end 
    
     response unless response.nil?

  end
  
  private
  def create_auth_string(value)
    
    request_digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'),CONFIG['RCAPL_SECRET_KEY'].to_s, value )
    
    auth_string =  request_digest.to_s + ':' + CONFIG['RCAPL_ACCESS_KEY'].to_s
    
    auth_string
    
  end
  
  private
  def create_actual_resource_url(usr_resource_url)
    
    params_occureance = usr_resource_url.index('?')
    
    params_occureance.nil? ? usr_resource_url + '?' : usr_resource_url + '&'
    
  end
  
  private
  def return_reponse_data(response=nil)
   
     response.body unless response.nil?
      
  end
  
  private
  def get_question_or_ampasant_mark(res_url)
    
    result = res_url.scan(/[?]/)
    
    result.length > 0 ? "&" : "?"
    
  end
  
end
