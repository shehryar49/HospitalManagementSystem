#!C:\plutonium\plutonium.exe
import mysql
function renderQueryRespAsJSON(var query)
{
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    var data = []
    for(var i=1 to total step 1)
    data.push(mysql.fetch_row_as_str(res))
    var response = {"status": "ok","data": data,"headings": ["username","level","cnic"]}
    println(response)
}
print("Content-type: application/json\r\n\r\n")
renderQueryRespAsJSON("select username,level,id from users;")