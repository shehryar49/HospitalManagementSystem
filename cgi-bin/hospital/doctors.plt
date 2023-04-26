#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteDoctor(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updateDoctor(this)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
var level = nil # level of access to give
function addDoctor(var form)
{
  if(level != 2) #only admin can add doctor
  {
    printf(errAlert,"Access Denied")
    return nil
  }
  if(!form.hasKey("name") or !form.hasKey("cnic") or !form.hasKey("dob") or !form.hasKey("start") or !form.hasKey("phone") or !form.hasKey("end") or !form.hasKey("salary"))
    printf(errAlert,"INVALID REQUEST! Insuffcient parameters!")
  var img = form["img"]
  if(!isInstanceOf(img,cgi.File) or (img.type!="image/jpeg" and img.type!="image/jpg" and img.type!="image/png"))
  {
    printf(errAlert,"UPLOAD a proper JPG/JPEG image!You think i'm stupid?")
    return nil
  } 
  try
  {
    var name = form["name"]
    var cnic = form["cnic"]
    var dob = form["dob"]
    var phone = form["phone"]
    var salary = form["salary"]
    var start = form["start"]
    var end = form["end"]
    var spec = form["spec"]
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var file = open("D:\\Database\\xampp\\htdocs\\hospital\\Doctors"+cnic+"."+substr(find("/",img.type)+1,len(img.type)-1,img.type),"wb")
    fwrite(img.content,file)
    close(file)
    var query = format("INSERT INTO doctors VALUES('%','%','%','%','%','%','%',%);",name,cnic,phone,dob,spec,start,end,salary)
    mysql.query(conn,query)
    #insertion query does not return anything
    printf(successAlert,"Success!")
  }
  catch(err)
  {
    printf(errAlert,"Insertion failed.")
    return nil
  }
}
function viewall(var form)
{
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT st.name,st.cnic,st.phone,st.dob,departments.deptname,st.start,st.end,st.salary,t.perc from doctors as st join (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc from (SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic) as a,(SELECT cnic,COUNT(*) as total from attendance group by cnic) as b)t on
st.cnic = t.cnic join worksin on st.cnic=worksin.d_id join departments on worksin.dept_id=departments.dept_id;"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Spec</th><th>Shift Start</th><th>Shift End</th><th>Salary</th><th>Att(%)</th>")
  if(level == 2)
    print("<th></th><th></th>")
  print("</tr>")
  
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
    foreach(var field: fields)
    {
      if(level == 2)
        printf("<td contentEditable=\"true\">%</td>",field)
      else
        printf("<td>%</td>",field)
    }
    if(level == 2)
    {
      print(trashIcon)
      print(updateIcon)
    }
    print("</tr>")
  }
  print("</table>")
}
function searchDoctor(var form)
{
  if(!form.hasKey("keyval") or !form.hasKey("keyname"))
  {
    print("Insufficient parameters!")
    return nil
  }
  var val = form["keyval"]
  var name = form["keyname"]
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = ""
  if(name == "salary")
   query = "SELECT st.name,st.cnic,st.phone,st.dob,st.spec,st.start,st.end,st.salary,t.perc from doctors as st join (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc from (SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic) as a,(SELECT cnic,COUNT(*) as total from attendance group by cnic) as b)t on
       st.cnic = t.cnic and st.salary="+val+";"
  else
    query = "SELECT st.name,st.cnic,st.phone,st.dob,st.spec,st.start,st.end,
             st.salary,t.perc from doctors as st
             join (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc 
             from (SELECT cnic,COUNT(*) as total from attendance
             where status='P' group by cnic) as a,(SELECT cnic,COUNT(*) 
             as total from attendance group by cnic) as b)t on
             st.cnic = t.cnic and st."+name+"='"+val+"';"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Spec</th><th>Shift Start</th><th>Shift End</th><th>Salary</th><th>Att(%)</th>")
  if(level == 2)
    print("<th></th><th></th>")
  print("</tr>")
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
    foreach(var field: fields)
    {
      if(level == 2)
        printf("<td contentEditable=\"true\">%</td>",field)
      else
        printf("<td>%</td>",field)
          
    }
    if(level == 2)
    {
      print(trashIcon)
      print(updateIcon)
    }  
    print("</tr>")
  }
  print("</table>")
}
function fireDoctor(var form)
{
  if(level != 2)
  {
    print("Access Denied")
    return nil
  }
  if(!form.hasKey("cnic"))
  {
    print("Insufficient parameters")
    return nil
  }
  #there are SQL injection vulnerabilities
  #to be fixed later
  var query = format("DELETE FROM doctors WHERE cnic='%';",form["cnic"])
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    printf(successAlert,"Delete QUERY executed.")
  }
  catch(err)
  {
    printf(errAlert,"DELETION failed. Make sure the doctor has no appointment.")
    return nil
  }
}
function updateDoctor(var form)
{
  if(level != 2)
  {
    print("Access Denied")
    return nil
  }
  if(!form.hasKey("name") or !form.hasKey("cnic") or !form.hasKey("dob") or !form.hasKey("start") or !form.hasKey("phone") or !form.hasKey("end") or !form.hasKey("salary"))
  {
    printf(errAlert,"INVALID REQUEST! Insuffcient parameters!")
    return nil
  }
  var name = form["name"]
  var cnic = form["cnic"]
  var dob = form["dob"]
  var phone = form["phone"]
  var salary = form["salary"]
  var start = form["start"]
  var end = form["end"]
  var spec = form["spec"]
  var query = format("update doctors set name='%',cnic='%',dob='%',salary=%,phone='%',spec='%',start='%',end='%' WHERE cnic='%';",name,cnic,dob,salary,phone,spec,start,end,cnic)
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    mysql.close(conn)
    printf(successAlert,"Update query executed.")
  }
  catch(err)
  {
    printf(errAlert,"Updation failed.")
    return nil
  }
}
function getAttPerc(var form)
{
  var cookies = cgi.cookies()
  if(!cookies.hasKey("id"))
  {
    println("Access denied!")
    return nil
  }
  try
  {
    var cnic = cookies["id"]
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = format("select b.present/a.total*100 from 
    (select COUNT(*) as total from attendance where cnic='%')a,
    (select COUNT(*) as present from attendance where cnic ='%' 
    and status='P')b;",cnic,cnic)
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    if(total != 1)
      throw @UnknownError,"Invalid response from DB"
    mysql.close(conn)
    var row = mysql.fetch_row_as_str(res)
    print(row[0])

  }
  catch(err)
  {
    println("Unknown error ocurred.")
  }
}
function getallInfo()
{
  if(level != 3)
  {
    print("Access Denied")
    return nil
  }
  var cookies = cgi.cookies()
  if(!cookies.hasKey("id"))
  {  
    printf(errAlert,"User is not a Doctor....idk how he got here\n")
    return nil
  }
  var id = cookies["id"]
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = "SELECT *,FLOOR(datediff(NOW(),dob)/360) as age FROM doctors where cnic = '"+id+"';"
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    var data = mysql.fetch_row_as_str(res)
    printf("<br>
        <img height=\"300\" class=\"float-right\" src=\"http://localhost/hospital/Doctors/%.jpeg\"><br><br>
        <b>Name: </b>%<br><br>
        <b>Date of Birth: </b>%<br><br>
        <b>Age: </b>%<br><br>
        <b>CNIC: </b>%<br><br>
        <b>Phone No: </b>%<br><br>
        <b>Specialization: </b>%",data[1],data[0],data[3],data[8],data[1],data[2], data[4])
  }
  catch(err)
  {
    printf(errAlert,"Operation failed")
    return nil
  }
}
function getatt(var f)
{
  var cookies = cgi.cookies()
  if(!cookies.hasKey("id"))
  {  
    printf(errAlert,"User is not a Doctor....idk how he got here")
    return nil
  }
  var id = cookies["id"]
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = "SELECT date, DAYNAME(date) as Day, status FROM attendance where cnic = '"+id+"' and type = 2;"
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Date</th><th>Day</th><th>Status</th></tr>")
    for(var i=1 to total step 1)
    {
      var fields = mysql.fetch_row_as_str(res)
      var num = len(fields)
      print("<tr>")
      for( var loopvar = 0 to (num-1) step 1)
      {
        if(loopvar == 2)
          {
            if(fields[loopvar] == "P")
              printf("<td>Present</td>")
            else
              printf("<td>Absent</td>")
          }
          else
            printf("<td>%</td>",fields[loopvar])
      }
      print("</tr>")
    }
    print("</table>")
  }
  catch(err)
  {
    printf(errAlert,"Operation failed")
    return nil
  }
}
checkSignin()
print("Content-type: text/html\r\n\r\n")
level = int(cgi.cookies()["level"])
## VALIDATE REQUEST ##
var form = cgi.FormData()
if(!form.hasKey("operation"))
{
    print("No operation specified!")
    exit()
}
var operation = form["operation"]
if(operation == "add")
  addDoctor(form)
else if(operation == "delete")
  fireDoctor(form)
else if(operation == "view")
  viewall(form)
else if(operation == "search")
  searchDoctor(form)
else if(operation == "update")
  updateDoctor(form)
else if(operation == "info")
  getallInfo()
else if(operation == "attinfo")
  getAttPerc(form)
else if(operation == "attendance")
  getatt(form)
else
  println("INVALID REQUEST! Unknown operation!")
