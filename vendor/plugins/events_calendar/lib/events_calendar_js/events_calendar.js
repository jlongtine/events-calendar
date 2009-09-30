
function load_calendar(year,month){
   
    until_load_calendar();
    $('#calendar_div').load('/calendar_clients/client_page?year=' + year + '&month=' + month);
}

function until_load_calendar(){
    document.getElementById("calendar_div").innerHTML="<img src='/images/calendar_images/ajax-loader_2.gif' align='middle' width='66' height='66' style='margin-top:80px;'/><div align='center'style='margin-top:10px; color:red;'>Loading...</div>";

}

var d = new Date();
var curr_month = d.getMonth();
var curr_year = d.getFullYear()


until_load_calendar();

load_calendar(curr_year,curr_month+1);


