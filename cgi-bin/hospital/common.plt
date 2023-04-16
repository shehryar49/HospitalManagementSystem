import regex
import cgi
import mysql

##this is a comment

var successAlert = "<div class=\"alert alert-success alert-dismissible fade show\" role=\"alert\">%<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button></div>"
var errAlert = "<div class=\"alert alert-warning alert-dismissible fade show\" role=\"alert\">%<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button></div>"
function isAlpha(var str)
{
    return regex.match(str,"[a-zA-Z ]+")
}
function isAlphanum(var str)
{
  return regex.match(str,"[a-zA-Z0-9 ]+")
}
function isNum(var str)
{
    return regex.match(str,"[0-9]+")
}
function isDate(var str)
{
    return regex.match(str,"[0-9]+-[0-9]+-[0-9]+")
}
function isTime(var str)
{
    return regex.match(str,"[0-9]+:[0-9]+")
}
function htmlHeader()
{
    print("Content-type: text/html\r\n\r\n")
}
function redirect(var url = "https://plutonium-lang.000webhostapp.com")
{
    printf("location: %\r\n\r\n",url)
    exit()
}
function checkSignin()
{
  var cookies = cgi.cookies()
  if(!cookies.hasKey("user") or !cookies.hasKey("pass") or !cookies.hasKey("level"))
  {
    #user is not signed In
    #redirect to login page
    print("location: login.plt\r\n\r\n")
    exit()
  }
  var level = int(cookies["level"])
  if(level < 1) #not possible but still
  {
    print("Content-type: text/html\r\n\r\n")
    print("Access denied")
    exit()
  }
}
