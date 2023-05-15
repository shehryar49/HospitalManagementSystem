#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"cancelAppointment(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var booknow = "<button class=\"btn btn-outline-dark btn-sm mt-2\" onclick=\"addAppointment(this)\">Book Now</button>"
var cred = nil
function searchApp(var start,var end,var all,var doc)
{
    var k = 0
    foreach(var record: all)
    {
        var a = str(start)
        var b = str(end)
        if(len(a) == 1)
          a = "0"+a
        if(len(b) == 1)
          b = "0"+b
        a+=":00:00"
        b+=":00:00"
        if(a == record[1] and b==record[2] and record[4]==doc)
          return true
        k+=1
    }
    return false
}
function showAvailable(var f)
{
    if(!f.hasKey("dept") or !f.hasKey("date"))
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var dept = f["dept"]
    var date = f["date"]
    if(dept == "Department" or !isNum(dept))
    {
        printf(errAlert,"Select a department!")
        return nil
    }
    if(date == "")
    {
      printf(errAlert,"Select a date")
      return nil
    }
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = format("select WEEKDAY('%'),'%' < CURDATE();",date,date)
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var P = mysql.fetch_row_as_str(res)
    if(P == nil)
    {
      printf(errAlert,"Something wrong with SQL Server")
      return nil
    }
    if(P[0] == "6") # Sunday
    {
        printf(errAlert,"Appointment can't be scheduled on Sunday.")
        return nil
    }
    if(P[1] == "1")
    {
        printf(errAlert,"Can't book appointment on past date.")
        return nil
    }
    query = format("select a.name,a.cnic from doctors as a join worksin as b on a.cnic=b.d_id and b.dept_id = %;",dept)
    mysql.query(conn,query)
    res = mysql.store_result(conn)
    var totalDocs = mysql.num_rows(res) 
    if(totalDocs == 0) # NO Doctor of requested department
    {
        printf(errAlert,"No Doctor")
        return nil
    }
    var docs = [] # all docs of requested department
    for(var i=1 to totalDocs step 1)
      docs.push(mysql.fetch_row_as_str(res))
    #Query to get all appointments of a specific department on a given date
    query = format("select doctors.name,t.start,t.end,t.app_date,doctors.cnic from(
        select * from appointments where dept_id=%)t 
    join doctors on t.d_id=doctors.cnic and app_date='%';",dept,date)
    mysql.query(conn,query)
    res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    if(total != 0) # there are appointments on given date,try to find a free slot
    {
        var all = []
        for(var i=1 to total step 1)
        {
          var row = mysql.fetch_row_as_str(res)
          all.push(row)
        }
        
        print("<table class=\"table table-bordered table-responsive\" id=\"data\"><th>Doctor</th><th>Start</th><th>End</th><th>Doctor CNIC</th><th></th>")
        foreach(var row: docs)
        {
            var start = 9
            while(start<=20)
            {
                var k = searchApp(start,start+1,all,row[1]) #check if this doctor has the slot free
                if(!k)
                    printf("<tr><td>%</td><td>%:00</td><td>%:00</td><td>%</td><td>%</td></tr>",row[0],start,start+1,row[1],booknow)
                start+=1
            }
        }

        print("</table>")
    }
    else #we have the doctor but no appointment on given date,i.e whole day is free
    {
      print("<table class=\"table table-bordered table-responsive\" id=\"data\"><th>Doctor</th><th>Start</th><th>End</th><th>Doctor CNIC</th><th></th>")
      foreach(var doc: docs)
      {
        var start = 9
        while(start<=20)
        {
          printf("<tr><td>%</td><td>%:00</td><td>%:00</td><td>%</td><td>%</td></tr>",doc[0],start,start+1,doc[1],booknow)
          start+=1
        }
      }
      print("</table>")
    }
}
function addAppointment(var f)
{
    if(!hasFields(["name","p_id","start","dob","app_date","fee","start","end","phone","dept"],f))
    {   
        printf(errAlert,"Bad Request")
        return nil
    }
    var cnic = f["p_id"]
    var dept = f["dept"]
    var fee = f["fee"]
    var dob = f["dob"]
    var phone = f["phone"]
    var name = f["name"] 
    if(!isNum(fee))
    {
      printf(errAlert,"Enter a valid fee")
      return nil
    }
    var app_date = f["app_date"]
    if(cnic == "" or dept == "" or app_date == "" )
    {
        printf(errAlert, "CNIC, Department and Date are required")
        return nil
    }

    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection, "localhost", "root", "password", "hospital")
        ##to see if patient is entered in database
        
        var sqlquery = "select status from patients where cnic = '" + cnic + "' ;"
        mysql.query(connection,sqlquery)
        var result = mysql.store_result(connection)
        var row = mysql.fetch_row_as_str(result)
        if(row == nil) # 
        {
           if(!isDate(dob) or dob=="")
           {
             printf(errAlert,"Select a valid DOB")
             return nil
           }
           if(phone=="")
           {
             printf(errAlert,"Enter phone number")
             return nil
           }
           if(name == "")
           {
             printf(errAlert,"Enter Patient name")
             return nil
           }
           var k = formatCheck(f)
           if(k != nil)
           {
             printf(errAlert,"Invalid format of "+k)
             return nil
           }         
           sqlquery = "insert into patients(name, cnic, phone, dob, status) values('"+name+"','"+cnic+"','"+phone+"','"+dob+"','Not Admit');"
           mysql.query(connection,sqlquery)
           sqlquery = "select status from patients where cnic = '" + cnic + "' ;"
           mysql.query(connection,sqlquery)
           result = mysql.store_result(connection)
           row = mysql.fetch_row_as_str(result)
        }
        if(row[0] == "Deceased")
        {
            printf(errAlert,"Patient deceased. Press button again to join him/her")
            return nil
        }

        var start = f["start"]
        var admit = app_date+" "+start ##datetime
        ##println(admit,"<br>")
        var end = app_date+" "+f["end"]
        var d_id = f["d_id"]
        connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("INSERT INTO records VALUES(0,'%','%','%',%,'%',NULL,%)",cnic, admit, end,fee, d_id,dept)
        mysql.query(connection,query)
        printf(successAlert,"Success")
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
}
function searchAppointment(var f)
{  
    try
    {
        if(!f.hasKey("keyval") or !f.hasKey("keyname"))
        {
            printf(errAlert,"Bad request")
            return nil
        }
        var keyval = f["keyval"]
        var keyname = f["keyname"]
        var level = int(cred["level"])
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = nil
        if(level == 3)
          query  = format("select * from appView where % = '%' and d_id = '%';",keyname,keyval,cred["id"])
        else
          query  = format("select * from appView where % = '%'",keyname,keyval)
        
        if(keyname == "PName" or keyname == "DName")
        {
          if(level == 3)
            query  = "select * from appView where "+keyname+" like '%"+keyval+"%' and d_id='"+cred["id"]+"';"
          else
            query  = "select * from appView where "+keyname+" like '%"+keyval+"%';"
        }
        mysql.query(connection,query)
        var res = mysql.store_result(connection)
        var total = mysql.num_rows(res)
        print("<table class=\"table table-bordered table-responsive\" 
                id=\"data\"><tr><th>DName</th>
                <th>PName</th><th>Start Time</th>
                <th>End Time</th><th>Date</th><th>DID</th>
                <th>PID</th>")
        if(level != 3)
          print("<th></th>")
        print("</tr>")
        for(var i=1 to total step 1)
        {
            var fields = mysql.fetch_row_as_str(res)
            print("<tr>")
            foreach(var field: fields)
              printf("<td>%</td>",field)
            if(level != 3)
              print(trashIcon)
            print("</tr>")
        }
        print("</table>")
    }
    catch(er)
    {
        printf(errAlert,"Operation Failed: "+er.msg)
    }
}
function viewAppointments(var f)
{  
    try
    {
        var level = int(cred["level"])
        var conn = mysql.init()
        mysql.real_connect(conn,"localhost","root","password","hospital")
        if(level==3) # doctor
          mysql.query(conn,"select * from appView where d_id='"+cred["id"]+"' order by app_date desc;")
        else
          mysql.query(conn,"select * from appView order by app_date desc;")
        var res = mysql.store_result(conn)
        var total = mysql.num_rows(res)
        print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>DName</th><th>PName</th><th>Start Time</th><th>End Time</th><th>Date</th><th>DID</th><th>PID</th>")
        if(level != 3)
          println("<th></th>")
        println("</tr>")
        for(var i=1 to total step 1)
        {
            var fields = mysql.fetch_row_as_str(res)
            print("<tr>")
            foreach(var field: fields)
              printf("<td>%</td>",field)
            if(level!=3)
              print(trashIcon)
            print("</tr>")
        }
        print("</table>")
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed: "+err.msg)
    }
}
function cancelAppointment(var f)
{
    if(!f.hasKey("d_id") or !f.hasKey("start") or !f.hasKey("app_date"))
    {   
        printf(errAlert,"Bad Request")
        viewAppointments(f)
        return nil
    }
    var app_date = f["app_date"]
    var d_id = f["d_id"]
    var start = f["start"]
    if(app_date == "" or d_id == "" or start == "")
    {
        print(errAlert,"Insufficient Parameters")
        viewAppointments(f)
        return nil
    }
    else
    {
        try{
            var dt = app_date+" "+start
            var connection = mysql.init()
            mysql.real_connect(connection,"localhost","root","password","hospital")
            var query = format("DELETE from records WHERE d_id = '%' AND admitDate = '%';", d_id, dt)
            mysql.query(connection,query)
            printf(successAlert,"Success")
            viewAppointments(f)
        }
        catch(err)
        {
            printf(errAlert,"Operation Failed")
            viewAppointments(f)
            return nil
        }
    }
}
function viewSpec(var form)
{
    var cookies = cgi.cookies()
    if(!cookies.hasKey("id"))
    {  
        #don't write stupid error messages
        #println("User is not a Doctor....idk how he got here\n")
        printf(errAlert,"Bad Request")
        return nil
    }
    var date = nil
    if(form.hasKey("date"))
      date = form["date"]
    var id = cookies["id"]
    var connection = mysql.init()
    mysql.real_connect(connection,"localhost","root","password","hospital")
    var query = nil
    if(date == nil)
    {
      query  = format("select doctors.name,
        patients.name,a.start,a.end,a.app_date,
        a.d_id,a.p_id from appointments as
         a inner join doctors on doctors.cnic = a.d_id
          and a.d_id='%' inner join patients on patients.cnic=a.p_id;",id)
    }
    else
    {
      query  = format("select doctors.name,
        patients.name,a.start,a.end,a.app_date,
        a.d_id,a.p_id from appointments as
         a inner join doctors on doctors.cnic = a.d_id
          and a.d_id='%' inner join patients on patients.cnic=a.p_id and a.app_date = '%';",id,date)
    }
    mysql.query(connection,query)
    var res = mysql.store_result(connection)
    var total = mysql.num_rows(res)
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>DName</th><th>PName</th><th>Start Time</th><th>End Time</th><th>Date</th><th>DID</th><th>PID</th><th></th></tr>")
    var all = []
    for(var i=1 to total step 1)
    {
        var fields = mysql.fetch_row_as_str(res)
        print(format("<tr><td>%</td><td>%</td><td>%</td><td>%</td><td>%</td><td>%</td><td>%</td>",fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],fields[6]))
        print(trashIcon)
        print("</tr>")
    }
    print("</table>")
}
function initApt()
{
  try
  {
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      var query = "SELECT dept_id, deptname FROM departments;"
      mysql.query(conn,query)
      var res = mysql.store_result(conn)
      var total = mysql.num_rows(res)
      printf("<select class=\"form-select form-select-sm\" id=\"appDeptSelect\" aria-label=\"Default select example\">
                <option selected>Department</option>")
      for(var i = 1 to total step 1)
      {
          var fields = mysql.fetch_row_as_str(res)
          printf("<option value=\"%\">%</option>",fields[0],fields[1])
      }
      printf("</select>")
    }
  catch(err)
  {
    printf(errAlert,"Failed to load card body")
    return nil
  }
}
##Execution starts from here##
cred = checkSignin()
htmlHeader()
##Request Processing##
var formData = cgi.FormData()
if(!formData.hasKey("operation"))
{   
    print("No operation specified")
    exit()
}
var request = formData["operation"]
if(request == "add")
    addAppointment(formData)
else if(request == "delete")
    cancelAppointment(formData)
else if(request == "view")
    viewAppointments(formData)
else if(request == "viewkey")
    searchAppointment(formData)
else if(request == "viewspecific")
  viewSpec(formData)
else if(request == "showAvailable")
  showAvailable(formData)
else if(request == "init")
  initApt()
else
    print("INVALID REQUEST! Unknown operation!")