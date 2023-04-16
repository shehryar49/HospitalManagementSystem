#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deletePatient(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updatePatient(this)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
var history = "<td><button class=\"btn btn-outline-secondary\" onclick = \"getHistory(this)\">Records</button></td>"
function addPatient(var form)
{
  if(!form.hasKey("name") or !form.hasKey("cnic") or !form.hasKey("dob") or !form.hasKey("status") or !form.hasKey("phone"))
    println("INVALID REQUEST! Insuffcient parameters!")
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
      if(k!= len(fields)-1)
        printf("<td contentEditable=\"true\">%</td>",field)
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
    print("Insufficient parameters!")
    return nil
  }
  var val = form["keyval"]
  var name = form["keyname"]
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT * FROM patients where "+name+" = "+" '"+val+"'"
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
    print("Insufficient parameters")
    return nil
  }
  #there are SQL injection vulnerabilities
  #to be fixed later
  var query = format("DELETE FROM patients WHERE cnic='%';",form["cnic"])
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    mysql.close(conn)
    printf(successAlert,"Delete QUERY executed.")
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
    print("Insuffcient parameters!")
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
    printf(successAlert,"Update QUERY executed.")
  }
  catch(err)
  {
    printf(errAlert,"Deletion failed.")
    return nil
  }
}

function getHistory(var f)
{
    if(!f.hasKey("cnic"))
    {
      printf(errAlert,"Insufficient Parameters received")
      return nil
    }
    try{
      var cnic = f["cnic"]
      var query = "Select d.name, r.d_id, TIME(r.admitDate), TIME(r.expiryDate),DATE(r.admitDate), r.fee from patients as p, records as r, doctors as d where d.cnic = r.d_id and p.cnic = r.cnic and type = 0 and p.cnic ='"+cnic+"';"
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      mysql.query(conn,query)

      var res = mysql.store_result(conn)
      var total = mysql.num_rows(res)
      print("<h2>Appointment History</h2><br>")
      print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Doctor Name</th><th>Doctor CNIC</th><th>Start Time</th><th>End Time</th><th>Date</th><th>Fee</th><th></th></tr>")
      var all = []
      for(var i=1 to total step 1)
      {
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
          printf("<td>%</td>",field)
        print(trashIcon)
        print("</tr>")
      }
      print("</table>")

      query = "Select d.name, r.d_id, r.admitDate, r.expiryDate, r.fee from patients as p, records as r, doctors as d, rooms as a where a.id = r.r_id and d.cnic = r.d_id and p.cnic = r.cnic and r.type = 1 and p.cnic ='"+cnic+"';"
      mysql.query(conn,query)
      res = mysql.store_result(conn)
      total = mysql.num_rows(res)
      print("<h2>Admission History</h2><br>")
      print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Doctor Name</th><th>Doctor CNIC</th><th>Admit</th><th>Discharge</th><th>Room Type</th><th>Fee</th><th></th></tr>")
      for(var i=1 to total step 1)
      {
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
          printf("<td>%</td>",field)
        print(trashIcon)
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

#main starts from here
checkSignin()
print("Content-type: text/html\r\n\r\n")
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
else
  println("INVALID REQUEST! Unknown operation!")
