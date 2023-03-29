#!C:\plutonium\plutonium.exe
import "common.plt"
function renderLoginPage(var msg="")
{
  var file = open("templates/login.html","r")
  var contents = read(file) + "<script>document.getElementById('msg').innerHTML = '"+msg+"';</script>"
  close(file)
  print("Content-type: text/html\r\n\r\n")
  write(contents,stdout)
}
function login(var uname,var pass)
{
  if(!isAlphanum(uname) or !isAlphanum(pass))
  {
    renderLoginPage("SQL INJECTION not allowed! You stupid!")
    return nil
  }
  var conn = mysql.init()
  var query = "SELECT password,level,id from users WHERE username='"+uname+"'" # uname = admin
  #' union select 'admin' as 'password',2 as 'level',3434 as 'id
  mysql.real_connect(conn,"localhost","root","password","hospital")
  mysql.query(conn,query)
  var res = mysql.store_result(conn) # row[0] = admin, row[1]=1
  #duplicate usernames are not allowed so it must be 1 row
  var row = mysql.fetch_row_as_str(res)
  if(row == nil)
  {
    renderLoginPage("Invalid Username")
    return nil
  }
  if(row[0]!=pass) #password mismatch
  {
    renderLoginPage("Invalid Password")
    return nil
  }
  mysql.close(conn)
  # login was successful
  # set cookies and redirect to dashboard.plt
  print("Set-cookie: user=",uname,"\r\n")
  print("Set-cookie: pass=",pass,"\r\n")
  print("Set-cookie: level=",row[1],"\r\n")
  print("Set-cookie: id=",row[2],"\r\n")
  
  print("location: dashboard.plt\r\n\r\n") #redirect to dashboard
}


#main starts here
var form = cgi.FormData()
if(!form.hasKey("username") or !form.hasKey("password"))
  renderLoginPage()
else
  login(form["username"],form["password"])