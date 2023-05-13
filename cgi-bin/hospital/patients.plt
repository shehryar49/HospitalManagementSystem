#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deletePatient(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updatePatient(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
var history = "<td><button class=\"btn btn-outline-secondary\" onclick = \"getHistory(this)\">Records</button></td>"
function addPatient(var form)
{
  if(!form.hasKey("name") or !form.hasKey("cnic") or !form.hasKey("dob") or !form.hasKey("status") or !form.hasKey("phone"))
    printf(errAlert,"Bad Request")
  try
  {
    var name = form["name"]
    var cnic = form["cnic"]
    var dob = form["dob"]
    var phone = form["phone"]
    var status = form["status"]
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = format("INSERT INTO patients VALUES('%','%','%','%','%',NULL);",name,cnic,phone,dob,status)
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
function viewall()
{
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT name,cnic,phone,dob,status FROM patients;"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Status</th><th></th><th></th><th></th></tr>")
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
    var k = 0
    foreach(var field: fields)
    {
      if(k!= len(fields)-1 and k != 1)
        printf("<td onclick=\"updatePatient(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
      else
        printf("<td >%</td>",field)
      k+=1
    }
    print(trashIcon)
    print(updateIcon)
    print(history)
    print("</tr>")
  }
  print("</table>")
}
function searchPatient(var form)
{
  if(!form.hasKey("keyval") or !form.hasKey("keyname"))
  {
    print(errAlert,"Bad Request")
    return nil
  }
  var val = form["keyval"]
  var name = form["keyname"]
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = ""
  if(name == "name" or name == "dob" or name == "phone")
    query = "SELECT name,cnic,phone,dob,status FROM patients where "+name+" LIKE '%"+val+"%';"
  else
    query = "SELECT name,cnic,phone,dob,status FROM patients where "+name+" = "+" '"+val+"';"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Status</th></tr>")
  var all = []
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
    foreach(var field: fields)
      printf("<td contentEditable=\"true\">%</td>",field)
    print(trashIcon)
    print(updateIcon)
    print(history)
    print("</tr>")
  }
  print("</table>")
}
function deletePatient(var form)
{
  #deletion is done by cnic(primary key)
  if(!form.hasKey("cnic"))
  {
    print(errAlert,"Bad Request")
    return nil
  }
  #there are SQL injection vulnerabilities
  #to be fixed later
  var query = format("SELECT status FROM patients WHERE cnic='%';", form["cnic"])
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
     mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var patstatus = mysql.fetch_row_as_str(res)
    if(patstatus[0] == "Admit")
    {
      printf(errAlert, "Patient is Admit, record cannot be deleted")
      viewall()
      return nil
    }
    query = format("DELETE FROM patients WHERE cnic='%';",form["cnic"])
    mysql.query(conn,query)
    mysql.close(conn)
    printf(successAlert,"Delete Query executed.")
    viewall() #view changed table
  }
  catch(err)
  {
    printf(errAlert,"Deletion failed."+err.msg)
    viewall()
    return nil
  }
}
function update(var form)
{
  if(!form.hasKey("cnic") or !form.hasKey("name") or !form.hasKey("dob") or !form.hasKey("status"))
  {
    print(errAlert,"Bad Request")
    return nil
  }
  var cnic = form["cnic"] 
  var name = form["name"] 
  var dob = form["dob"]
  var phone = form["phone"]
  var status = form["status"]
  var query = format("update patients set name='%',cnic='%',dob='%',status='%',phone='%' WHERE cnic='%';",name,cnic,dob,status,phone,cnic)
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    printf(successAlert,"Update Query executed.")
  }
  catch(err)
  {
    printf(errAlert,"Updation failed.")
    return nil
  }
}
function getHistory(var f)
{
    viewall()
    if(!f.hasKey("cnic"))
    {
      printf(errAlert,"Bad Request")
      return nil
    }
    try{
      var cnic = f["cnic"]
      var query = "select d.name, dept.deptname, TIME(r.admitDate), TIME(r.expiryDate),DATE(r.admitDate), r.fee from doctors as d, records as r, departments as dept where r.type = 0 and r.dept_id = dept.dept_id and  d.cnic = r.d_id and r.cnic ='"+cnic+"';"
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      mysql.query(conn,query)

      var res = mysql.store_result(conn)
      var total = mysql.num_rows(res)
      print("<h2>Appointment History</h2><br>")
      print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Doctor Name</th><th>Department</th><th>Start Time</th><th>End Time</th><th>Date</th><th>Fee</th></tr>")
      for(var i=1 to total step 1)
      {
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
          printf("<td>%</td>",field)
        print("</tr>")
      }
      print("</table>")

      query = "Select  dept.deptname, r.r_id, r.admitDate, r.expiryDate, r.fee from records as r, departments as dept where dept.dept_id = r.dept_id and r.type = 1 and r.cnic ='"+cnic+"';"
      mysql.query(conn,query)
      res = mysql.store_result(conn)
      total = mysql.num_rows(res)
      print("<h2>Admission History</h2><br>")
      print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Department</th><th>Room No</th><th>Admit</th><th>Discharge</th><th>Fee</th></tr>")
      for(var i=1 to total step 1)
      {
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
        {
          if(field == nil)
            printf("<td>-</td>")
          else
            printf("<td>%</td>",field)
        }
        print("</tr>")
      }
      print("</table>")
    }
    catch(err)
    {
      printf(errAlert,"Fetch history failed: "+err.msg)
      return nil
    }
}
function initAdmit()
{
  try{
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      var query = "SELECT dept_id, deptname FROM departments;"
      mysql.query(conn,query)
      var res = mysql.store_result(conn)
      var total = mysql.num_rows(res)
      printf(" <select class=\"form-select form-select-sm\" id=\"roomSelect\" aria-label=\"Default select example\">
              <option selected>Room</option>")
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
#main starts from here
checkSignin()
htmlHeader()
## VALIDATE REQUEST ##
var form = cgi.FormData()
if(!form.hasKey("operation"))
{
    print("No operation specified!")
    exit()
}
var operation = form["operation"]
if(operation == "add")
  addPatient(form)
else if(operation == "delete")
  deletePatient(form)
else if(operation == "view")
  viewall()
else if(operation == "search")
  searchPatient(form)
else if(operation == "update")
  update(form)
else if(operation == "history")
  getHistory(form)
else if(operation == "init")
  initAdmit()
else
  println("INVALID REQUEST! Unknown operation!")