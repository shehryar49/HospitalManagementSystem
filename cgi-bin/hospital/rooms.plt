#!C:\plutonium\plutonium.exe
import "common.plt"


function show()
{
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")

        var query = "select * from roomView;"

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
                print("<table class=\"table table-bordered table-responsive w-auto\" id=\"data\"><tr><th>Room no.</th><th>Occupied Beds</th><th>Total Beds</th><th>Price Per Day</th></tr>") 
            }
            printf("<tr><td>%</td><td>%</td><td>%</td><td>%</td></tr>",fields[1],fields[2],fields[3],fields[4])
        }
        print("</table>")
    }
    catch(error)
    {
        printf(errAlert, "Operation failed: "+ error)
        return nil
    }
}

function search(var f)
{
    if(!f.hasKey("deptname"))
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var deptname = f["deptname"]
    if(deptname == "")
    {
        printf(errAlert,"Empty search field!")
        return nil
    }
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")

        var query = "select * from roomView where deptname like '"+deptname+"%';"

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
                print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Room no.</th><th>Occupied Beds</th><th>Total Beds</th><th>Price Per Day</th></tr>") 
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

function initroom()
{
  try
  {
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
        printf(errAlert, "Fill all the fields!")
        return nil
    }
    var dept_id = f["dept_id"]
    if(dept_id == "Department")
    {
        printf(errAlert, "Invalid Value for Department")
        return nil
    }
    if(!isNum(beds))
    {
        printf(errAlert,"Invalid format of total beds")
        return nil
    }
    if(!isNum(price))
    {
        printf(errAlert,"Invalid format of price per day")
        return nil
    }
    try
    {
      var conn = mysql.init()
      mysql.real_connect(conn,"localhost","root","password","hospital")
      var query = "SELECT id from rooms as a where dept_id = "+dept_id+" and 0 = (Select COUNT(*) from rooms as b where dept_id = "+dept_id+" and a.id < b.id);"
      mysql.query(conn,query)
      var res = mysql.store_result(conn)
      var row = mysql.fetch_row_as_str(res)
      var i = 0
      if(row!= nil)
        i =  int(row[0])
      i = i+1
      query = format("Insert into rooms values(%,%,0,%,%);", i, dept_id, beds, price)
      mysql.query(conn,query)
      show()
      printf(successAlert,"Insertion Successful")
    }
    catch(err)
    {
        printf(errAlert, err.msg)
        return nil
    }
}

checkSignin()
htmlHeader()
var sentdata = cgi.FormData()
if(!sentdata.hasKey("operation"))
{
    printf("operation undefined!")
    exit()
}
var torun = sentdata["operation"]
if(torun == "show")
{
    show()
}
else if(torun == "search")
    search(sentdata)
else if(torun == "init")
    initroom()
else if(torun == "add")
    add(sentdata)
else
    printf("undefined operation")
