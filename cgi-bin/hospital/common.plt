#!C:\plutonium\plutonium.exe
import regex
import cgi
import mysql

var successAlert = "<div id=\"sA\" class=\"alert alert-success alert-dismissible fade show\" role=\"alert\">%<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button></div>"
var errAlert = "<div id=\"eA\" class=\"alert alert-warning alert-dismissible fade show\" role=\"alert\">%<button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-label=\"Close\"><span aria-hidden=\"true\">&times;</span></button></div>"
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
function hasFields(var fields,var map)
{
  foreach(var field: fields)
  {
    if(!map.hasKey(field))
      return false
  }
  return true
}
function checkSignin()
{
  try
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
  catch(err)
  {
    htmlHeader()
    println(err.msg)
    exit()
  }
}
var map = {"0": 0," ": 0,",": 11,".": 111,"?": 1111,"!": 11111,"1": 1,"2": 2,"3": 3,"4": 4,"5": 5,"6": 6,"7": 7,"8": 8,"9": 9,"a": 22,"b": 222,"c": 2222,"d": 33,"e": 333,"f": 3333,"g": 44,"h": 444,"i": 4444,"j": 55,"k": 555,"l": 5555,"m": 66,"n": 666,"o": 6666,"p": 77,"q": 777,"r": 7777,"s": 77777,"t": 88,"u": 888,"v": 8888,"w": 99,"x": 999,"y": 9999,"z": 99999}
function hexEncode(var bytes)
{
    var res = ""
    foreach(var byte: bytes)
    {
      var a = ByteToInt((IntToByte(byte) & 0xf0)>>4)
      var b = ByteToInt(IntToByte(byte) & 0x0f)
      if(a<=9)
        res+=char(48+a)
      else
        res+=char(87+a)
      if(b<=9)
        res+=char(48+b)
      else
        res+=char(87+b)
    }
    return res
}
function rotateLeft(var list)
{
    var l = len(list)
    if(l == 0 or l==1)
      return nil
    var first = nil
    for(var i=0 to l-2 step 1)
    {
      if(i == 0)
        first = list[i]
      list[i] = list[i+1]
    }
    list[l-1] = first
}
function boomerHash(var str)
{
    var res = [0]*8 # 8 bytes output 
    while(len(str)%8 != 0)
        str = "0"+str
    var i = 0
    var l = len(str)
    for(var i=0 to l-8 step 8)
    {
        var chunk = substr(i,i+7,str)
        var k = 0
        foreach(var e: chunk)
        {
            var i = ascii(e)
            if(i>=65 and i<=90) # uppercase
              e = char(i+32)
            if(map.hasKey(e))
              res[k] = (res[k] + map[e]) & 255
            else
              res[k] = (res[k] + char(e)) & 255
            var p = i & 7
            res[p] = (res[p] + res[k]) & 255
            for(var j=1 to p step 1)
              rotateLeft(res)
            k+=1
        }      
    }
    return hexEncode(res)
}