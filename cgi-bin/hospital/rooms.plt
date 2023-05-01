#!C:\plutonium\plutonium.exe
import "common.plt"


function show(var f)
{
    try{
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")

        var query = "select dept.deptname, r.id, r.occ, r.totalBeds, r.perDay from rooms as r join departments as dept on dept.dept_id = r.dept_id;"

        var deptname = ""
        mysql.query(connection,query)
        var result = mysql.store_result(connection)
        var row = mysql.num_rows(result)
        for(var i=1 to row step 1)
        {
            var fields = mysql.fetch_row_as_str(result)
            if(fields[0] != deptname)
            {
                if(deptname != "")
                    print("</table>")
                deptname = fields[0]
                print("<h2>", deptname,"</h2>")
                print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Occupied Beds</th><th>Total Beds</th><th>Price Per Day</th></tr>") 
            }
            printf("<tr><td>%</td><td>%</td><td>%</td><td>%</td></tr>",fields[1],fields[2],fields[3],fields[4])
        }
        print("</table>")
    }
    catch(error)
    {
        printf(errAlert, "Operation failed: ", error)
        return nil
    }
}

function search(var f)
{
    if(!f.hasKey("id"))
    {
        printf("Insufficient parameters!")
        return nil
    }
    var id = f["id"]
    if(id == "")
    {
        printf("ID cannot be NULL")
        return nil
    }
    try{
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")

        var query = "select* from rooms where id = "+id+";"
        mysql.query(connection,query)
        var result = mysql.store_result(connection)
        printf("<h3>Room Details</h3><br>")
        print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Type</th><th>Occupied Beds</th><th>Total Beds</th><th>Price Per Day</th></tr>")
        var fields = mysql.fetch_row_as_str(result)
        print("<tr>")
        foreach(var field: fields)
        printf("<td>%</td>",field)
        print("</tr>")
        print("</table>")
        printf("<br><h3>Patients in Room</h3><br>")

        query = "select cnic, name, phone, dob from rooms as r, patients as p where r.id = "+id+" and r.id = p.r_id;"
        mysql.query(connection,query)
        result = mysql.store_result(connection)
        print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Name</th><th>Phone</th><th>DOB</th></tr>")
        fields = mysql.fetch_row_as_str(result)
        print("<tr>")
        if(fields != nil)
        {
            foreach(var field: fields)
            printf("<td>%</td>",field)
            print("</tr>")
            print("</table>")
        }
       
    }
    catch(error)
    {
        printf(errAlert, "Operation failed: "+error.msg)
        return nil
    }

}

print("Content-type: text/html\r\n\r\n")
checkSignin()

var sentdata = cgi.FormData()
if(!sentdata.hasKey("operation"))
{
    printf("operation undefined!")
    exit()
}
var torun = sentdata["operation"]
if(torun == "show")
    show(sentdata)
else if(torun == "search")
    search(sentdata)
else
    printf("undefined operation")

