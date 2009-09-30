require "linklk.rb"

  class LinklkUser < Linklk
   
  def get_linklk_id_from_login(user_login)
    begin
      obj_xml_new = get_xml_obj_from_remote("api/users/login?email=" + user_login.to_s)
      if obj_xml_new.root.elements[1].nil?
        raise " No user found on linklk "
      end 
      obj_xml_new.root.elements[1].elements['id'].text 
   rescue Exception => exp
      puts "-------------------------------------------------------------------"
      puts exp.message
      false
   end
  end   

 
  def get_linklk_user_screen_name(id)
    begin
      obj_xml_new = get_xml_obj_from_remote("api/users/user?id=" + id.to_s)
      if obj_xml_new.root.elements[1].nil?
        raise " No user found on linklk "
      end 
      user = create_user_hash(obj_xml_new.root.elements[1].elements['id'].text ,obj_xml_new.root.elements[1].elements['screen-name'].text)
      user
   rescue Exception => exp
      puts "-------------------------------------------------------------------"
      puts exp.message
      false
   end
  end   
  
  private
  def create_user_hash(u_id,screen_name)
    
    user = Hash.new
    
    user={
      
      'user_id' => u_id.to_i,
      'screen_name' => screen_name
      
    }
    user
    
  end  
    
  
  end

