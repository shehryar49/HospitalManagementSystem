#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteUser(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updateUser(this)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
function addUser(var form)
{
  if(!form.hasKey("username") or !form.hasKey("cnic") or !form.hasKey("level") or !form.hasKey("password"))
    println("INVALID REQUEST! Insuffcient parameters!")
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
  }
  catch(err)
  {
    printf(errAlert,"Insertion failed."+err.msg)
    return nil
  }
}
function viewall(var form)
{
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT username,level,id FROM users;"
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
      printf("<td contentEditable=\"true\">%</td>",field)
    }
    print(trashIcon)
    print(updateIcon)
    print("</tr>")
  }
  print("</table>")
}
function searchUser(var form)
{
  if(!form.hasKey("keyval") or !form.hasKey("keyname"))
  {
    print("Insufficient parameters!")
    return nil
  }
  var val = form["keyval"]
  var name = form["keyname"]
  if(name == "cnic")
    name = "id" #thanks to Isbah,gotta remap this
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT * FROM users where "+name+" = "+" '"+val+"'"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Username</th><th>Password</th><th>Level</th><th>CNIC</th><th></th><th></th></tr>")
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
    printf(successAlert,"Delete QUERY executed.")
  }
  catch(err)
  {
    printf(errAlert,"Deletion failed.")
    return nil
  }
}
function update(var form)
{
  if(!form.hasKey("cnic") or !form.hasKey("username") or !form.hasKey("password") or !form.hasKey("level"))
  {
    print("Insuffcient parameters!")
    return nil
  }
  var cnic = form["cnic"] 
  var username = form["username"] 
  var level = form["level"]
  var password = form["password"]
  var query = format("update users set username='%',id='%',password='%',level='%' WHERE username='%';",username,cnic,password,level,username)
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
  viewall(form)
else if(operation == "search")
  searchUser(form)
else if(operation == "update")
  update(form)
else
  println("INVALID REQUEST! Unknown operation!")