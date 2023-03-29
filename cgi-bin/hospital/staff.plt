#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteStaff(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updatestaff(this)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
##Funtions##
function addNewStaff(var f)
{
    if(!f.hasKey("name") or !f.hasKey("cnic") or !f.hasKey("phone") or !f.hasKey("desig") or !f.hasKey("salary") or !f.hasKey("start") or!f.hasKey("end") or !f.hasKey("dob"))
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
    var shift_start = f["start"]
    var shift_end =f["end"]
    var salary = f["salary"]
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("INSERT INTO staff VALUES('%','%','%','%','%','%','%',%)",name, cnic, phone, date_of_birth, designation, shift_start, shift_end, salary)
        mysql.query(connection,query)
        printf(successAlert,"Success")
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
}
function updateExistingStaff(var f)
{
    if(!f.hasKey("name") or !f.hasKey("cnic") or !f.hasKey("phone") or !f.hasKey("desig") or !f.hasKey("salary") or !f.hasKey("start") or!f.hasKey("end") or!f.hasKey("dob"))
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
    var shift_start = f["start"]
    var shift_end =f["end"]
    var salary = f["salary"]
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("UPDATE staff SET name = '%', cnic = '%', phone = '%',dob = '%', desig = '%', start = '%', end = '%', salary = % where cnic='%';",name, cnic, phone, date_of_birth, designation, shift_start, shift_end, salary,cnic)
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
  }
  catch(err)
  {
    printf(errAlert,"DELETION failed.")
    return nil
  }
}
function viewStaff(var f)
{
    var connection = mysql.init()
    mysql.real_connect(connection,"localhost","root","password","hospital")
    var query = "SELECT st.name,st.cnic,st.phone,st.dob,st.desig,st.start,st.end,st.salary,t.perc from staff as st join (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc from (SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic) as a,(SELECT cnic,COUNT(*) as total from attendance group by cnic) as b)t on
st.cnic = t.cnic;"
    mysql.query(connection,query)
    var res = mysql.store_result(connection)
    var total = mysql.num_rows(res)
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Desginatiion</th><th>Start Time</th><th>End Time</th><th>Salary</th><th>Att(%)</th><th></th><th></th></tr>")
    var all = []
    for(var i=1 to total step 1)
    {
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
        {
          printf("<td contentEditable=\"true\">%</td>",field)
        }
        print(trashIcon)
        print(updateIcon)
        print("</tr>")
    }
    print("</table>")
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
    query = "SELECT st.name,st.cnic,st.phone,st.dob,st.desig,st.start,st.end,st.salary,t.perc from staff as st join (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc from (SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic) as a,(SELECT cnic,COUNT(*) as total from attendance group by cnic) as b)t on
st.cnic = t.cnic and st."+name+"="+val+";"
  else
    query = "SELECT st.name,st.cnic,st.phone,st.dob,st.desig,st.start,st.end,st.salary,t.perc from staff as st join (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc from (SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic) as a,(SELECT cnic,COUNT(*) as total from attendance group by cnic) as b)t on
st.cnic = t.cnic and st."+name+"='"+val+"';"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Desginatiion</th><th>Start Time</th><th>End Time</th><th>Salary</th><th>Att(%)</th><th></th><th></th></tr>")
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
  viewStaff(formData)
else if(request == "search")
  searchStaff(formData)
else
  print("Unknown Operation")