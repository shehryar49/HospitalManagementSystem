#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteStaff(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updatestaff(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
##Functions##
function viewStaff()
{
    var connection = mysql.init()
    mysql.real_connect(connection,"localhost","root","password","hospital")
    var query = "select * from staffView;"
    mysql.query(connection,query)
    var res = mysql.store_result(connection)
    var total = mysql.num_rows(res)
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Desginatiion</th><th>Salary</th><th>Att(%)</th><th></th><th></th></tr>")
    for(var i=1 to total step 1)
    {
      var fields = mysql.fetch_row_as_str(res)
      print("<tr>")
      var k = 0
      foreach(var field: fields)
      {
        if(k!= 1)
          printf("<td onclick=\"updatePatient(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
        else
          printf("<td >%</td>",field)
        k+=1
      }
      print(trashIcon)
      print(updateIcon)
      print("</tr>")
    }
  print("</table>")
}
function addNewStaff(var f)
{
    if(!f.hasKey("name") or !f.hasKey("cnic") or !f.hasKey("phone") or !f.hasKey("desig") or !f.hasKey("salary") or !f.hasKey("dob"))
    {   
        print("Insfficient Parameters")
        return nil
    }
    var name = f["name"]
    var cnic = f["cnic"]
    if(cnic == "")
    {
        print("cnic field cannot be empty")
        return nil
    }
    var phone = f["phone"]
    var date_of_birth = f["dob"]
    var designation = f["desig"]
    var salary = f["salary"]
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("INSERT INTO staff VALUES('%','%','%','%','%',%)",name, cnic, phone, date_of_birth, designation, salary)
        mysql.query(connection,query)
        query = format("insert into attendance values('%',CURDATE(),'P',1);",cnic)
        mysql.query(connection,query)
        printf(successAlert,"Success")
        viewStaff()
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
}
function updateExistingStaff(var f)
{
    if(!f.hasKey("name") or !f.hasKey("cnic") or !f.hasKey("phone") or !f.hasKey("desig") or !f.hasKey("salary") or !f.hasKey("dob"))
    {   
        print("Insfficient Parameters")
        return nil
    }
    var name = f["name"]
    var cnic = f["cnic"]
    if(cnic == "")
    {
        print("cnic cannot be NULL")
        return nil
    }
    var phone = f["phone"]
    var date_of_birth = f["dob"]
    var designation = f["desig"]
    var salary = f["salary"]
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("UPDATE staff SET name = '%', cnic = '%', phone = '%',dob = '%', desig = '%',  salary = % where cnic='%';",name, cnic, phone, date_of_birth, designation, salary,cnic)
        mysql.query(connection,query)
        printf(successAlert,"Success")
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
}
function deleteExistingStaff(var form)
{
  if(!form.hasKey("cnic"))
  {
    print("Insufficient parameters")
    return nil
  }
  #there are SQL injection vulnerabilities
  #to be fixed later
  var query = format("DELETE FROM staff WHERE cnic='%';",form["cnic"])
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    printf(successAlert,"Delete QUERY executed.")
    viewStaff()
  }
  catch(err)
  {
    printf(errAlert,"DELETION failed.")
    return nil
  }
}
function searchStaff(var form)
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
    query = "select * from staffView where "+name+"="+val+";"
  else
    query = "select * from staffView where "+name+" like '%"+val+"%';"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Desginatiion</th><th>Salary</th><th>Att(%)</th><th></th><th></th></tr>")
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
    foreach(var field: fields)
      printf("<td contentEditable=\"true\">%</td>",field)
    print(trashIcon)
    print(updateIcon)
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
  addNewStaff(formData)
else if(request == "update")
  updateExistingStaff(formData)
else if(request == "delete")
  deleteExistingStaff(formData)
else if(request == "view")
  viewStaff()
else if(request == "search")
  searchStaff(formData)
else
  print("Unknown Operation")