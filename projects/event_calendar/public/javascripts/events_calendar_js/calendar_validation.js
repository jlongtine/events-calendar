 function onChangeUntil(){
      var start=document.getElementById("start_date").value;
      var until=document.getElementById("repeat_until").value;
      if (Date.parse(start)>Date.parse(until+" 11:59 PM")){
        document.getElementById("repeat_until").style.color="red";
        return false;
      }else
      {
        document.getElementById("repeat_until").style.color="black";
        return true;
      }

    }

    function startDateOnchage(){
     
      onChangeDate();
      onChangeUntil();

    }

    function onChangeDate(){
      var start=document.getElementById("start_date").value;
      var end=document.getElementById("end_date").value;
      if (Date.parse(start)>Date.parse(end)){
        document.getElementById("start_date").style.color="red";
        document.getElementById("end_date").style.color="red";
        return false;
      }else
      {
        document.getElementById("start_date").style.color="black";
        document.getElementById("end_date").style.color="black";
        return true;
      }

    }  



    function validate(){
       if(document.getElementById("title").value==""){
         document.getElementById("errorText").innerHTML="Title field cannot be empty !";
         document.getElementById("title").focus();
         return false;
       }
       if(document.getElementById("where").value==""){
         document.getElementById("errorText").innerHTML="Where field cannot be empty !";
         document.getElementById("where").focus();
         return false;
       }
       if(!onChangeDate()){
         document.getElementById("errorText").innerHTML="Start time and End time are incorrect !";
         document.getElementById("start_date").focus();
         return false;
       }
       
       if(document.getElementById("repeats").value!="No Repeats"){
        
         if(!onChangeUntil()){     
            document.getElementById("errorText").innerHTML="Invaild Repeat until date !";
            document.getElementById("repeat_until").focus();
            return false;
         }
       }


      return true;
    }

    function validate_new_cal(){
       
       if(document.getElementById("calendar_title").value==""){
         document.getElementById("errorText").innerHTML="Title field cannot be empty !";
         document.getElementById("calendar_title").focus();
         return false;
       }
       return true;
    }

    function validate_update_cal(){

       if(document.getElementById("cal_title").value==""){
         document.getElementById("errorText").innerHTML="Title field cannot be empty !";
         document.getElementById("cal_title").focus();
         return false;
       }
       return true;
    }


    function validateEdit(){
       if(document.getElementById("event_title").value==""){
         document.getElementById("errorText").innerHTML="Title field cannot be empty !";
         document.getElementById("event_title").focus();
         return false;
       }
       if(document.getElementById("event_where").value==""){
         document.getElementById("errorText").innerHTML="Where field cannot be empty !";
         document.getElementById("event_where").focus();
         return false;
       }
       if(!onChangeDate()){
         document.getElementById("errorText").innerHTML="Start time and End time are incorrect !";
         document.getElementById("start_date").focus();
         return false;
       }

       if(document.getElementById("repeats").value!="No Repeats"){

         if(!onChangeUntil()){
            document.getElementById("errorText").innerHTML="Invaild 'Repeat Until' date !";
            document.getElementById("repeat_until").focus();
            return false;
         }
       }

      return true;
    }


    function validateRange(){
        
        if(!onChangeDate()){
            document.getElementById("errorText").innerHTML="Start time and End time are incorrect !"
            document.getElementById("start_date").focus();
            return false;
        }
     return true;

    }
