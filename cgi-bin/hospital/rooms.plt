#!C:\plutonium\plutonium.exe
import "common.plt"
function show()
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
function initroom()
{
  try{
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      var query = "SELECT dept_id, deptname FROM departments;"
      mysql.query(conn,query)
      var res = mysql.store_result(conn)
      var total = mysql.num_rows(res)
      printf(" <select class=\"form-select form-select-sm\" id=\"roomDeptSelect\" name=\"dept\" aria-label=\"Default select example\">
                <option selected>Department</option>")
      for(var i = 1 to total step 1)
      {
          var fields = mysql.fetch_row_as_str(res)
          printf("<option value=\"%\">%</option>",fields[0],fields[1])
      }
      printf("</select>")
    }
  catch(err)
  {
    printf(errAlert,"Failed to load card body")
    return nil
  }
}
function add(var f)
{
    if(!f.hasKey("dept_id") or !f.hasKey("beds") or !f.hasKey("price"))
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var beds = f["beds"]
    var price = f["price"]
    if(beds == "" or price == "")
    {
        printf(errAlert, "Insufficient Parameters")
        return nil
    }
    var dept_id = f["dept_id"]
    if(dept_id == "Department")
    {
        printf(errAlert, "Invalid Value for Department")
        return nil
    }
    try{
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      var query = "SELECT id from rooms as a where dept_id = "+dept_id+" and 0 = (Select COUNT(*) from rooms as b where dept_id = "+dept_id+" and a.id < b.id);"
      mysql.query(conn,query)
      var res = mysql.store_result(conn)
      var row = mysql.fetch_row_as_str(res)
      var i = 0
      if(row[0] != nil)
        i =  int(row[0])
      i = i+1
      query = format("Insert into rooms values(%,%,0,%,%);", i, dept_id, beds, price)
      mysql.query(conn,query)
      printf(successAlert,"Insertion Successful")
      show()
    }
    catch(err)
    {
        printf(errAlert, err.msg)
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
    show()
else if(torun == "search")
    search(sentdata)
else if(torun == "init")
    initroom()
else if(torun == "add")
    add(sentdata)
else
    printf("undefined operation")

