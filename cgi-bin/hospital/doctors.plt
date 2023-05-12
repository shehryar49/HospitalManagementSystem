#!C:\plutonium\plutonium.exe
var theeti = false # change to true
#when running on theeti's computer upload path becomes D:\Database\....
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteDoctor(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updateDoctor(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
var level = nil # level of access to give
function addDoctor(var form)
{
  if(level != 2) #only admin can add doctor
  {
    printf(errAlert,"Access Denied")
    return nil
  }
  if(!hasFields(["name","cnic","dob","phone","salary","dept"],form))
  {
    printf(errAlert,"Bad Request")
    return nil
  }
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
    var dept = form["dept"]
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var upload_path = "c:\\xampp\\htdocs\\hospital\\Doctors\\"
    if(theeti)
      upload_path = "D:\\Database\\xampp\\htdocs\\hospital\\Doctors\\"
    var file = open(upload_path+cnic+"."+substr(find("/",img.type)+1,len(img.type)-1,img.type),"wb")
    fwrite(img.content,file)
    close(file)
    var query = format("INSERT INTO doctors VALUES('%','%','%','%',%);",name,cnic,phone,dob,salary)
    mysql.query(conn,query)
    query = format("insert into worksIn VALUES(%,'%');",dept,cnic)
    mysql.query(conn,query)
    query = format("insert into attendance VALUES('%',CURDATE(),'P',2);",cnic)
    mysql.query(conn,query)
    #insertion query does not return anything
    printf(successAlert,"Success!")
  }
  catch(err)
  {
    printf(errAlert,"Insertion failed."+err.msg)
    return nil
  }
}
function viewall()
{
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "select * from docView;"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Spec</th><th>Salary</th><th>Att(%)</th>")
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
        printf("<td onclick=\"updateDoctor(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
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
   query = "select * from docView where salary="+val+";"
  else if(name == "name")
      query = "select * from docView where name like '%"+val+"%';"
  else
    query = "SELECT * from docView where "+name+"='"+val+"';"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Spec</th><th>Salary</th><th>Att(%)</th>")
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
        printf("<td onclick=\"updateDoctor(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
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
    print("Bad Request")
    return nil
  }
  #there are SQL injection vulnerabilities
  #to be fixed later
  var query = format("Select * from appointments where d_id = '%' and start >= CURDATE();", form["cnic"]) #checks if doctor has any pending appointments
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var row = mysql.fetch_row_as_str(res)

    if(row == nil)
    {
      query = format("DELETE FROM doctors WHERE cnic='%';",form["cnic"])
      mysql.query(conn,query)
      printf(successAlert,"Delete QUERY executed.")
      viewall()
    }
    else
      printf(errAlert, "Doctor has pending appointments!")
  }
  catch(err)
  {
    printf(errAlert,"InternalError occurred")
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
  if(!form.hasKey("name") or !form.hasKey("cnic") or !form.hasKey("dob")  or !form.hasKey("phone")  or !form.hasKey("salary"))
  {
    printf(errAlert,"INVALID REQUEST! Insuffcient parameters!")
    return nil
  }
  var name = form["name"]
  var cnic = form["cnic"]
  var dob = form["dob"]
  var phone = form["phone"]
  var salary = form["salary"]
  var query = format("update doctors set name='%',cnic='%',dob='%',salary=%,phone='%' WHERE cnic='%';",name,cnic,dob,salary,phone,cnic)
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
    printf(errAlert,"Updation failed."+err.msg)
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
        <b>Phone No: </b>%",data[1],data[0],data[3],data[7],data[1],data[2])
  }
  catch(err)
  {
    printf(errAlert,"Operation failed"+err.msg)
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
function initdoc()
{
  try
  {
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      var query = "SELECT dept_id, deptname FROM departments;"
      mysql.query(conn,query)
      var res = mysql.store_result(conn)
      var total = mysql.num_rows(res)
      printf("<select class=\"form-select form-select-sm\" id=\"roomSelectAdd\" aria-label=\"Default select example\">
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
if(operation == "Add")
  addDoctor(form)
else if(operation == "delete")
  fireDoctor(form)
else if(operation == "view")
  viewall()
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
else if(operation == "init")
  initdoc()
else
  println("INVALID REQUEST! Unknown operation!")