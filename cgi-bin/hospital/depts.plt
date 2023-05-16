#!C:\plutonium\plutonium.exe
import "common.plt"
var updateIcon = "<td><button onclick=\"updatedept(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
function show()
{
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = "select v.dept_id, v.deptname, COUNT(w.d_id), v.name, v.hod from deptView as v left join worksIn as w  ON v.dept_id = w.dept_id group by dept_id;"
        mysql.query(connection,query)
        var result = mysql.store_result(connection)
        var row = mysql.num_rows(result)
        print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Name</th><th>Number of Doctors</th><th>Head of Department</th><th>Head of Department(cnic)</th></tr>")
        for(var i=1 to row step 1)
        {
            var fields = mysql.fetch_row_as_str(result)
            print("<tr>")
            var k = 0
            foreach(var field: fields)
            {
                if(k!= 0 and k!= 2 and k != 3)
                    printf("<td onclick=\"updatedept(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
                else
                    printf("<td >%</td>",field)
                k+=1
            }
            print(updateIcon)
            print("</tr>")
        }
        print("</table>")
    }
    catch(error)
    {
        printf(errAlert, "Operation failed"+error.msg)
        return nil
    }
}
function search(var form)
{
  if(!form.hasKey("keyval") or !form.hasKey("keyname"))
  {
    print(errAlert,"Bad Request")
    return nil
  }
  var val = form["keyval"]
  var name = form["keyname"]
  try{
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = ""
    if(name == "name" or name == "deptname")
        query = "select v.dept_id, v.deptname, COUNT(w.d_id), v.name, v.hod from deptView as v left join worksIn as w  ON v.dept_id = w.dept_id where v."+name+" like "+" '%"+val+"%' group by dept_id;"
    else
        query = "select v.dept_id, v.deptname, COUNT(w.d_id), v.name, v.hod from deptView as v left join worksIn as w  ON v.dept_id = w.dept_id where v."+name+" = "+" '"+val+"' group by dept_id;"
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Name</th><th>Number of Doctors</th><th>Head of Department</th><th>Head of Department(cnic)</th></tr>")
        for(var i=1 to total step 1)
        {
            var fields = mysql.fetch_row_as_str(res)
            print("<tr>")
            var k = 0
            foreach(var field: fields)
            {
                if(k!= 0 and k!= 2 and k != 3)
                    printf("<td onclick=\"updatedept(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
                else
                    printf("<td >%</td>",field)
                k+=1
            }
            print(updateIcon)
            print("</tr>")
        }
        print("</table>")
    }
    catch(err)
    {
        printf(errAlert, "Search failed")
        return nil
    }
}
function update(var form)
{
  if(!form.hasKey("ID") or !form.hasKey("deptname") or !form.hasKey("hod"))
  {
    print(errAlert,"Bad Request")
    return nil
  }
  var ID = form["ID"] 
  var deptname = form["deptname"] 
  var hod = form["hod"]
  var query = "Select dept_id from worksIn where d_id = '"+hod+"';"
  if(ID == "" or !isNum(ID))
  {
    printf(errAlert,"Invalid format of ID")
    return nil
  }
  if(hod == "" or (!isCNIC(hod) and hod!="nil"))
  {
    printf(errAlert,"Invalid format of HOD CNIC")
    return nil
  }
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    var result = mysql.store_result(conn)
    var row = mysql.fetch_row_as_str(result)
    if(hod == "nil") # NO HOD
    {
        var query = format("update departments set deptname='%',hod=NULL WHERE dept_id='%';",deptname,ID)
        mysql.query(conn,query)
        printf(successAlert,"Update Query executed.")
    }
    else if(row == nil) # HOD no in worksIN
    {
        printf(errAlert,"HOD CNIC not of any known doctor!")
    }
    else if(row[0] == ID)
    {
        var query = format("update departments set deptname='%',hod='%' WHERE dept_id='%';",deptname,hod,ID)
        mysql.query(conn,query)
        printf(successAlert,"Update Query executed.")
    }
    else
        throw @UnknownError,"Doctor does not belong to this department"
  }
  catch(err)
  {
    printf(errAlert,"Updation failed."+err.msg)
    return nil
  }
}
function add(var form)
{
    if(!form.hasKey("name"))
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var deptname = form["name"]
    if(deptname == "")
    {
        printf(errAlert, "Enter a department name!")
        return nil
    }
    if(!isAlpha(deptname))
    {
        printf(errAlert,"Invalid format of department name!")
        return nil
    }
    try
    {
        var conn = mysql.init()
        mysql.real_connect(conn,"localhost","root","password","hospital")
        var query = "Insert into departments(deptname) values('"+deptname+"');"
        mysql.query(conn,query)
        printf(successAlert,"Insertion Succesful")
        show()
    }
    catch(err)
    {
        printf(errAlert,"Insertion failed")
        return nil
    }
}

checkSignin()
htmlHeader()
var form = cgi.FormData()
if(!form.hasKey("operation"))
{
    printf("No operation specified!")
    exit()
}
var operation = form["operation"]
if(operation == "show")
    show()
else if(operation == "search")
    search(form)
else if(operation == "update")
    update(form)
else if(operation == "add")
    add(form)
else
    println("INVALID REQUEST! Unknown operation!")