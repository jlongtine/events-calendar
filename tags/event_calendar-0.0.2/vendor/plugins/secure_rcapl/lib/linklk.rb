require 'rexml/document'
include REXML

require "secure_rcapl.rb"

class Linklk
  include Secure_rcapl
      attr_accessor :linklk_host
      attr_accessor :resueElement 
    
      def initialize
        @linklk_host  = "http://192.168.0.212:4000/"
        @resueElement = "No remote respond from linklk"
        
      end
    
      def self.create_xml_pair(element_name,value,xml_obj)
        new_element = Element.new element_name
        new_element.text = value
        xml_obj.root.add_element new_element
      end
      
      protected
      def get_xml_obj_from_remote(resource_suffix)
        response_from_remorte = self.rcapl_get_resource_det(@linklk_host + resource_suffix)
        @obj_xml = create_xml_object(response_from_remorte)
        @obj_xml
      end
      
      protected
      def post_xml_obj_to_remote(resource_suffix,xml_string)
        response_from_remorte = self.rcapl_post_resource_det(@linklk_host + resource_suffix, xml_string)
##        puts response_from_remorte.code
##        @obj_xml = create_xml_object(response_from_remorte)
##        @obj_xml
        response_from_remorte
      end

      protected
      def create_xml_object(response_from_remorte)
        xmlDoc = Document.new(response_from_remorte)
        return xmlDoc
      end

      protected
      def seperate_element_values(xmlObj,element_val,elementNode_txt)
        xmlObj.elements[element_val].elements[elementNode_txt].text
      end  
      
      protected
      def create_validate_hash(value)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'),CONFIG['RCAPL_SECRET_KEY'].to_s, value)
      end
end
