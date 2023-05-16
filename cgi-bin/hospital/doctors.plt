#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteDoctor(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updateDoctor(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
var level = nil # level of access to give
var theeti = false # change to true
#when running on theeti's computer upload path becomes D:\Database\....
var cred = nil
function addDoctor(var form)
{
  if(level != 2) #only admin can add doctor
  {
    print("Access Denied")
    return nil
  }
  if(!hasFields(["name","cnic","dob","phone","salary","dept"],form))
  {
    print("Bad Request")
    return nil
  }
  var img = form["img"]
  if(!isInstanceOf(img,cgi.File) or (img.type!="image/jpeg"))
  {
    printf("UPLOAD a proper JPEG image!You think i'm stupid?")
    return nil
  } 
  var k = formatCheck(form)
  if(k!=nil)
  {
    println("Invalid format of "+k)
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
    if(dept == "Department" or !isNum(dept))
    {
      println("Select a department!")
      return nil
    }
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var upload_path = "c:\\xampp\\htdocs\\hospital\\Doctors\\"
    if(theeti)
      upload_path = "D:\\Database\\xampp\\htdocs\\hospital\\Doctors\\"
    var file = open(upload_path+cnic+"."+substr(find("/",img.type)+1,len(img.type)-1,img.type),"wb")
    #img.content is a bytearray
    fwrite(img.content,file)
    close(file)
    mysql.query(conn,"START TRANSACTION")
    var query = format("INSERT INTO doctors VALUES('%','%','%','%',%);",name,cnic,phone,dob,salary)
    mysql.query(conn,query)
    query = format("insert into worksIn VALUES(%,'%');",dept,cnic)
    mysql.query(conn,query)
    query = format("insert into attendance VALUES('%',CURDATE(),'P',2);",cnic)
    mysql.query(conn,query)
    mysql.query(conn,"COMMIT")
    #insertion query does not return anything
    print("Success!")
  }
  catch(err)
  {
    var msg = "Insertion failed"
    if(level == 2)
      msg += ": "+err.msg
    print(msg)
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
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Department</th><th>Salary</th><th>Att(%)</th>")
  if(level == 2)
    print("<th></th><th></th>")
  print("</tr>")
  
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
    var i = 0
    foreach(var field: fields)
    {
      if(level == 2 and (i == 0 or i == 2 or i==3 or i==5))
          printf("<td onclick=\"updateDoctor(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
      else
        printf("<td>%</td>",field)
      i+=1
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
    printf(errAlert,"Bad Request")
    return nil
  }
  var val = form["keyval"]
  if(val == "")
  {
    printf(errAlert,"Search field is empty")
    return nil
  }
  var name = form["keyname"]
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = ""
  if(name == "name" or name == "deptname")
    query = "SELECT * from docView where "+name+" like '%"+val+"%';"
  else
    query = "SELECT * from docView where "+name+"='"+val+"';"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  if(total == 0)
  {
    println("<h2>No results</h2><br>")
    return nil
  }
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Department</th><th>Salary</th><th>Att(%)</th>")
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
    printf(errAlert,"Access Denied")
    return nil
  }
  if(!form.hasKey("cnic"))
  {
    printf(errAlert,"Bad Request")
    return nil
  }
  var query = format("Select * from appointments where d_id = '%' and app_date >= CURDATE();", form["cnic"]) #checks if doctor has any pending appointments
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var row = mysql.fetch_row_as_str(res)
    if(row == nil)
    {
      mysql.query(conn,"start transaction")
      query = format("DELETE FROM doctors WHERE cnic='%';",form["cnic"])
      mysql.query(conn,query)
      query = format("DELETE FROM attendance WHERE cnic='%';",form["cnic"])
      mysql.query(conn,query)
      query = format("DELETE FROM worksIn WHERE d_id='%';",form["cnic"])
      mysql.query(conn,query)

      mysql.query(conn,"commit")
      printf(successAlert,"Delete QUERY executed.")
    }
    else
      printf(errAlert, "Doctor has pending appointments!")
    viewall()
  }
  catch(err)
  {
    printf(errAlert,"Operation failed")
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
  if(!hasFields(["name","cnic","dob","phone","salary"],form))
  {
    printf(errAlert,"Bad Request!")
    return nil
  }
  var k = formatCheck(form)
  if(k!=nil)
  {
    printf(errAlert,"Invalid format of "+k)
    viewall()
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
    viewall()
    printf(successAlert,"Update query executed.")
  }
  catch(err)
  {
    printf(errAlert,"Updation failed."+err.msg)
    viewall()
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
    printf("
        <img class=\"image-cover float-right\" height=\"300\" class=\"float-right\" src=\"/hospital/Doctors/%.jpeg\">
        <b>Name: </b>%<br><br>
        <b>Date of Birth: </b>%<br><br>
        <b>Age: </b>%<br><br>
        <b>CNIC: </b>%<br><br>
        <b>Phone No: </b>%",data[1],data[0],data[3],data[5],data[1],data[2])
  }
  catch(err)
  {
    printf(errAlert,"Operation failed"+err.msg)
    return nil
  }
}
function getatt(var f)
{
  var id = cred["id"]
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = "SELECT date, DAYNAME(date) as Day, status FROM attendance where cnic = '"+id+"' and type = 2 order by date desc;"
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
cred = checkSignin()
level = int(cred["level"])
htmlHeader()
## VALIDATE REQUEST ##
var form = nil
try
{
  form = cgi.FormData()
}
catch(err)
{
  println("Operation failed. Make sure all fields were filled!")
  exit()
}
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