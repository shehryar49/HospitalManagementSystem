#!/usr/bin/plutonium
#!C:\plutonium\plutonium.exe
import cgi

var cookies = cgi.cookies()
if(cookies.hasKey("user") and cookies.hasKey("pass") and cookies.hasKey("level"))
{
  print("Set-Cookie: user=deleted; expires=Thu, 01 Jan 1970 00:00:00 GMT\r\n")
  print("Set-Cookie: pass=deleted; expires=Thu, 01 Jan 1970 00:00:00 GMT\r\n")
  print("Set-Cookie: level=deleted; expires=Thu, 01 Jan 1970 00:00:00 GMT\r\n")
}
print("location: login.plt\r\n\r\n")
