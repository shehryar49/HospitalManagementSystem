#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"cancelAppointment(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
function searchApp(var start,var end,var all,var doc)
{
    var k = 0
    foreach(var record: all)
    {
        if(format("%:00:00",str(start)) == record[1] and format("%:00:00",str(end))==record[2] and record[0]==doc)
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
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = format("select t.name,k.start,k.end
     from(select a.cnic,a.name,b.dept_id,c.deptname 
    from doctors as a join worksin as b on a.cnic = b.d_id 
    join departments as c on c.dept_id=b.dept_id)t 
    join appointments as k where t.deptname='%' and k.d_id=cnic and k.app_date='%';",dept,date)
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    var all = []
    for(var i=1 to total step 1)
    {
      var row = mysql.fetch_row_as_str(res)
     # print(row,"<br>")
      all.push(row)
    }
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><th>Doctor</th><th>Start</th><th>End</th>")
    foreach(var row: all)
    {
        var start = 9
        while(start<=16)
        {
            var k = searchApp(start,start+1,all,row[0]) #check if this doctor has the slot free
            if(!k)
                printf("<tr><td>%</td><td>%</td><td>%</td></tr>",row[0],start,start+1)
            start+=1
        }
    }
    print("</table>")
}
function addAppointment(var f)
{
    if(!f.hasKey("p_id") or !f.hasKey("d_id") or !f.hasKey("start") or !f.hasKey("end") or !f.hasKey("app_date"))
    {   
        printf(errAlert,"Insfficient Parameters")
        return nil
    }
    var app_date = f["app_date"]
    var d_id = f["d_id"]
    var start = f["start"]

    var admit = app_date+" "+start
    ##println(admit,"<br>")
    if(app_date == "" or d_id == "" or start == "")
    {
        printf(errAlert,"doctor cnic, app_date, start time cannot be NULL")
        return nil
    }
    var p_id = f["p_id"]
    var end =f["end"]
    var expire = app_date+" "+end
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("INSERT INTO records VALUES(0,'%','%','%', NULL ,'%',NULL)",p_id, admit, expire, d_id)
        mysql.query(connection,query)
        printf(successAlert,"Success")
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
}

function cancelAppointment(var f)
{
    if(!f.hasKey("d_id") or !f.hasKey("start") or !f.hasKey("app_date"))
    {   
        print("Insufficient Parameters")
        return nil
    }
    var app_date = f["app_date"]
    var d_id = f["d_id"]
    var start = f["start"]
    if(app_date == "" or d_id == "" or start == "")
    {
        print("doctor cnic, app_date, start time cannot be NULL")
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
        }
    catch(err)
    {
        print(errAlert,"Operation Failed")
        return nil
    }
        }
}

function viewkeyAppointment(var f)
{  
    try{
        if(!f.hasKey("keyval") or !f.hasKey("keyname"))
        {
            printf(errAlert,"Insufficient Parameters Passed!")
            return nil
        }
        var keyval = f["keyval"]
        var keyname = f["keyname"]
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query  = format("select d.name, p.name, a.start, a.end, a.app_date, d.cnic, p.cnic FROM appointments as a, patients as p, doctors as d where d.cnic = a.d_id and p.cnic = a.p_id and % = '%'",keyname,keyval)
        mysql.query(connection,query)
        var res = mysql.store_result(connection)
        var total = mysql.num_rows(res)
        print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>DName</th><th>PName</th><th>Start Time</th><th>End Time</th><th>Date</th><th>DID</th><th>PID</th><th></th></tr>")
        for(var i=1 to total step 1)
        {
            var fields = mysql.fetch_row_as_str(res)
            print("<tr>")
            foreach(var field: fields)
              printf("<td contentEditable=\"true\">%</td>",field)
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
function viewAppointment(var f)
{  
    try{
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        # Guess what strings in plutonium are multiline by default
        var query = "select doctors.name,patients.name,a.start,a.end,a.app_date,a.d_id,
        a.p_id from appointments as a
         inner join doctors on doctors.cnic = a.d_id inner join 
         patients on patients.cnic=a.p_id;"
        mysql.query(connection,query)
        var res = mysql.store_result(connection)
        var total = mysql.num_rows(res)
        print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>DName</th><th>PName</th><th>Start Time</th><th>End Time</th><th>Date</th><th>DID</th><th>PID</th><th></th></tr>")
        var all = []
        for(var i=1 to total step 1)
        {
            var fields = mysql.fetch_row_as_str(res)
            print("<tr>")
            foreach(var field: fields)
              printf("<td contentEditable=\"true\">%</td>",field)
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

##Execution starts from here##
checkSignin()
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
    viewAppointment(formData)
else if(request == "viewkey")
    viewkeyAppointment(formData)
else if(request == "viewspecific")
  viewSpec(formData)
else if(request == "showAvailable")
  showAvailable(formData)
else
    print("Unknown Operation")