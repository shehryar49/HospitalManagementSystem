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
  if(uname == "")
  {
    renderLoginPage("Username cannot be empty")
    return nil
  }
  if(pass == "")
  {
    renderLoginPage("Password cannot be empty")
    return nil
  }
  if(!isAlphanum(uname) or !isAlphanum(pass))
  {
    renderLoginPage("SQL INJECTION not allowed! You stupid!")
    return nil
  }
  var conn = mysql.init()
  var query = "SELECT password,level,id from users WHERE username='"+uname+"'"
  mysql.real_connect(conn,"localhost","root","password","hospital")
  mysql.query(conn,query)
  var res = mysql.store_result(conn) 
  # duplicate usernames are not allowed so it must be 1 row
  var row = mysql.fetch_row_as_str(res)
  if(row == nil)
  {
    renderLoginPage("Invalid Username")
    return nil
  }
  if(row[0]!=boomerHash(pass)) #password hash mismatch
  {
    renderLoginPage("Invalid Password")
    return nil
  }
  mysql.close(conn)
  # login was successful
  # set cookies and redirect to dashboard.plt
  # this method is probably not the best security wise
  # but as mentioned in README.md this project is for educational purposes
  # JWTs coud be used but that requires an encryption library which as of today 13 May 2023
  # plutonium does not have
  print("Set-cookie: user=",uname,"; HttpOnly\r\n")
  print("Set-cookie: pass=",row[0],"; HttpOnly\r\n")
  print("Set-cookie: level=",row[1],"; HttpOnly\r\n")
  print("Set-cookie: id=",row[2],"; HttpOnly\r\n")
  
  print("location: dashboard.plt\r\n\r\n") #redirect to dashboard
}

#main starts here
if(getenv("HTTP_COOKIE")!=nil)
{
  var cookies = cgi.cookies()
  if(cookies.hasKey("user") and cookies.hasKey("pass") and cookies.hasKey("level"))
    redirect("dashboard.plt")
}
var form = cgi.FormData()
if(!form.hasKey("username") or !form.hasKey("password"))
  renderLoginPage()
else
  login(form["username"],form["password"])