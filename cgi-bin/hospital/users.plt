#!C:\plutonium\plutonium.exe
import "common.plt"
import json

var cred = nil
function viewall()
{
  var payload = {"data": [],"status": 200} # 200 means success

  payload.emplace("headings",["user","level","cnic"])
  payload.emplace("editables", []) # add indexes of editable columns if you need any
  payload.emplace("deleteable", "yes") # rows are deleteable
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = "SELECT username,level,id FROM users;"
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    for(var i=1 to total step 1)
    {
      var row = mysql.fetch_row_as_str(res)
      payload["data"].push(row)
    }
  }
  catch(err)
  {
    payload["status"] = 500 # Internal Server Error
    payload.emplace("msg","Internal Server Error")
  }
  # json.dumps converts nil to javascript null
  # it basically retruns the json string version of a plutonium dict
  println(json.dumps(payload))
}
function addUser(var form)
{
  if(!hasFields(["username","cnic","level","password"],form))
  {
    print({"status": 500,"msg": "Bad Request"})
    return nil
  }
  try
  {
    var username = form["username"]
    var cnic = form["cnic"]
    var level = form["level"]
    var password = form["password"]
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = format("INSERT INTO users VALUES('%','%','%','%');",username,boomerHash(password),level,cnic)
    if(cnic == "")
      query = format("INSERT INTO users VALUES('%','%','%',NULL);",username,boomerHash(password),level)
    mysql.query(conn,query)
    #insertion query does not return anything
    println({"status": 200})
  }
  catch(err)
  {
   println({"status": 500,"msg": err.msg}) 
  }
}
function searchUser(var form)
{
  if(!form.hasKey("keyval") or !form.hasKey("keyname"))
  {
    print({"status":500,"msg": "Bad Request"})
    return nil
  }
  var payload = {"data": [],"status": 200} # 200 means success
  payload.emplace("headings",["user","level","cnic"])
  payload.emplace("editables", []) # add indexes of editable columns if you need any
  payload.emplace("deleteable", "yes") # rows are deleteable
  
  var val = form["keyval"]
  var name = form["keyname"]
  if(name == "cnic")
    name = "id" # thanks to Isbah,gotta remap this
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "SELECT username, level, id FROM users where "+name+" = "+" '"+val+"'"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var total = mysql.num_rows(res)
  for(var i=1 to total step 1)
  {
    var fields = mysql.fetch_row_as_str(res)
    payload["data"].push(fields)
  }
  println(json.dumps(payload))
}
function changePassword(var form )
{
  if(!hasFields(["old","new"],form))
  {
    println({"status": 500,"msg": "Bad Request"})
    return nil
  }
  ##Critical
  var old = form["old"]
  var new = form["new"]
  var oldhash = boomerHash(old)
  var newhash = boomerHash(new)
  var user = cred["user"]
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,"select password from users where username='"+user+"';")
    var res = mysql.store_result(conn)
    var row = mysql.fetch_row_as_str(res)
    if(row == nil)
    {
      println({"status": 500,"msg": "Username does not exist!"})
      return nil
    }
    if(row[0] != oldhash)
    {
      println({"status": 500,"msg": "Old Password Mismatch"})
      return nil
    }
    mysql.query(conn,"update users set password = '"+newhash+"' where username='"+user+"';")
    mysql.close(conn)
    println({"status": 200})
  }
  catch(err)
  {
   println({"status": 500,"msg": "Operation failed!"})
  }
}
function deleteUser(var form)
{
  # deletion is done by cnic(primary key)
  if(!form.hasKey("username"))
  {
    println({"status": 500,"msg": "Bad Request"})
    return nil
  }
  var user = cred["user"]
  if(user == form["username"])
  {
    println({"status": 500,"msg": "Fuck you! You cannot delete your own account."})
    return nil
  }
  var query = format("DELETE FROM users WHERE username='%';",form["username"])
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    mysql.close(conn)
    println({"status": 200})
  }
  catch(err)
  {
    println({"status": 500,"msg": "Deletion failed"})
    return nil
  }
}
#main starts from here
cred = checkSignin()
# this is very important
# set output type of script to json
print("Content-type: application/json\r\n\r\n")

## VALIDATE REQUEST ##
var form = cgi.FormData()

if(!form.hasKey("operation"))
{
  println({"status": 500,"msg": "Bad Request"})
  exit() #dont't use exit(1) server will not send the response back
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
else if(operation == "changePassword")
  changePassword(form)
else
  println({"status": 500,"msg": "Unknown Operation"})