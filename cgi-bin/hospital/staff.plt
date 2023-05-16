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
        if(k!= 1 and k!= 6)
          printf("<td onclick=\"updatestaff(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
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
  
    if(!hasFields(["name","dob","cnic","phone","desig","salary"],f))
    {   
        printf(errAlert,"Bad Request")
        return nil
    }
    var name = f["name"]
    var cnic = f["cnic"]
    var phone = f["phone"]
    var date_of_birth = f["dob"]
    var designation = f["desig"]
    var salary = f["salary"]
    if(cnic == "" or name=="" or date_of_birth=="" or phone=="" or designation=="" or salary=="")
    {
        printf(errAlert,"All fields are mandatory")
        return nil
    }
    var k = formatCheck(f)
    if(k != nil)
    {
      printf(errAlert,"Invalid format of "+k)
      return nil
    }
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
        printf(errAlert,"Bad Request")
        return nil
    }
    var name = f["name"]
    var cnic = f["cnic"]
    if(cnic == "")
    {
        print("CNIC field can not be empty!")
        viewStaff()
        return nil
    }
    var phone = f["phone"]
    var date_of_birth = f["dob"]
    var designation = f["desig"]
    var salary = f["salary"]
    var k = formatCheck(f)
    if(k != nil)
    {
      viewStaff()
      printf(errAlert,"Invalid format of "+k)
      return nil
    }
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("UPDATE staff SET name = '%', cnic = '%', phone = '%',dob = '%', desig = '%',  salary = % where cnic='%';",name, cnic, phone, date_of_birth, designation, salary,cnic)
        mysql.query(connection,query)
        printf(successAlert,"Success")
        viewStaff()
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        viewStaff()
        return nil
    }
}
function deleteExistingStaff(var form)
{
  if(!form.hasKey("cnic"))
  {
    printf(errAlert,"Bad Request")
    viewStaff()
    return nil
  }
  var cnic = form["cnic"]
  if(!isCNIC(cnic))
  {
    printf(errAlert,"Invalid format of CNIC")
    viewStaff()
    return nil
  }
  var query = format("DELETE FROM staff WHERE cnic='%';",cnic)
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
    printf(errAlert,"Bad Request!")
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
  if(name == "salary")
    query = "select * from staffView where "+name+"="+val+";"
  else if(name == "name" or name == "desig")
    query = "select * from staffView where "+name+" like '%"+val+"%';"
  else
    query = "select * from staffView where "+name+"='"+val+"';"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Desginatiion</th><th>Salary</th><th>Att(%)</th><th></th><th></th></tr>")
   for(var i=1 to total step 1)
    {
      var fields = mysql.fetch_row_as_str(res)
      print("<tr>")
      var k = 0
      foreach(var field: fields)
      {
        if(k!= 1 and k!= 6)
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
##Execution starts from here##
var cred = checkSignin()
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
  print("Bad Request")