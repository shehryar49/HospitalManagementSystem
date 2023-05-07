#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteUser(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updateUser(this)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
function viewall()
{
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT username,level,id FROM users;"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Username</th><th>Level</th><th>CNIC</th><th></th></tr>")
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
    foreach(var field: fields)
    {
      if(field == nil)
        field = "-"
      printf("<td>%</td>",field)
    }
    print(trashIcon)
    print("</tr>")
  }
  print("</table>")
}
function addUser(var form)
{
  if(!form.hasKey("username") or !form.hasKey("cnic") or !form.hasKey("level") or !form.hasKey("password"))
    print(errAlert,"Bad Request")
  try
  {
    var username = form["username"]
    var cnic = form["cnic"]
    var level = form["level"]
    var password = form["password"]
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = format("INSERT INTO users VALUES('%','%','%','%');",username,boomerHash(password),level,cnic)
    mysql.query(conn,query)
    #insertion query does not return anything
    printf(successAlert,"Success!")
    viewall()
  }
  catch(err)
  {
    print(errAlert,"Insertion failed."+err.msg)
    viewall()
    return nil
  }
}
function searchUser(var form)
{
  if(!form.hasKey("keyval") or !form.hasKey("keyname"))
  {
    print(errAlert,"Bad Request")
    return nil
  }
  var val = form["keyval"]
  var name = form["keyname"]
  if(name == "cnic")
    name = "id" #thanks to Isbah,gotta remap this
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT username, level, id FROM users where "+name+" = "+" '"+val+"'"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Username</th><th>Level</th><th>CNIC</th><th></th><th></th></tr>")
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    print("<tr>")
     foreach(var field: fields)
    {
      if(field == nil)
        field = "-"
      printf("<td>%</td>",field)
    }
    print(trashIcon)
    print(updateIcon)
    print("</tr>")
  }
  print("</table>")
}
function deleteUser(var form)
{
  #deletion is done by cnic(primary key)
  if(!form.hasKey("username"))
  {
    print("Insufficient parameters")
    return nil
  }
  #there are SQL injection vulnerabilities
  #to be fixed later
  var query = format("DELETE FROM users WHERE username='%';",form["username"])
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    mysql.close(conn)
    printf(successAlert,"Delete Query executed.")
    viewall()
  }
  catch(err)
  {
    printf(errAlert,"Deletion failed.")
    viewall()
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
  addUser(form)
else if(operation == "delete")
  deleteUser(form)
else if(operation == "view")
  viewall()
else if(operation == "search")
  searchUser(form)
else
  println("INVALID REQUEST! Unknown operation!")
