#!C:\plutonium\plutonium.exe
import cgi
var cookies = cgi.cookies()
if(!cookies.hasKey("user") or !cookies.hasKey("pass") or !cookies.hasKey("level"))
{
  print("location: login.plt\r\n\r\n")
  exit()
}
var level = int(cookies["level"])
## Render dashboard based on privelege level
if(level == 1) #simple employee/receptionist
{
  var file = open("templates/dsh1/DashboardReceptionist.html","r")
  print("Content-type: text/html\r\n\r\n")
  write(read(file),stdout)
  close(file)
}
else if(level == 3) # doctors
{
  var file = open("templates/dsh3/homeDoctors.html","r")
  print("Content-type: text/html\r\n\r\n")
  write(read(file),stdout)
  close(file)
}
else if(level == 2) # admin
{
  var file = open("templates/dsh2/home.html","r")
  print("Content-type: text/html\r\n\r\n")
  write(read(file),stdout)
  close(file)
}