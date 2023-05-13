#!C:/plutonium/plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deletePatient(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updatePatient(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
var history = "<td><button class=\"btn btn-outline-secondary\" onclick = \"getHistory(this)\">Records</button></td>"
function viewall()
{
  try
  {
    var conn = mysql.init()
    mysql.real_connect(conn,"localhost","root","password","hospital")
    var query = "SELECT name,cnic,phone,dob,status FROM patients;"
    mysql.query(conn,query)
    var res = mysql.store_result(conn)
    var total = mysql.num_rows(res)
    print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Status</th><th></th><th></th><th></th></tr>")
    for(var i=1 to total step 1)
    {
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        var k = 0
        foreach(var field: fields)
        {
            if(k!= len(fields)-1 and k != 1)
                printf("<td onclick=\"updatePatient(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
            else
                printf("<td >%</td>",field)
            k+=1
        }
        print(trashIcon)
        print(updateIcon)
        print(history)
        print("</tr>")
    }
    print("</table>")
  }
  catch(err)
  {
    printf(errAlert,"Operation failed.")
  }
}
function show(var f)
{
    if(!f.hasKey("cnic"))
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var cnic = f["cnic"]
    if(cnic == "")
    {
        printf(errAlert,"CNIC field cannot be empty!")
        return nil
    }
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection, "localhost", "root", "password", "hospital")
        var sqlquery = "select * from patients, rooms where r_id = id and cnic = '" + cnic + "' ;"
        mysql.query(connection,sqlquery)
        var result = mysql.store_result(connection)
        var total = mysql.num_rows(result)

        print("<table spellcheck=\"false\" class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>Name</th><th>Cnic</th><th>Phone</th><th>DOB</th><th>Status</th><th>Room ID</th><th>Room Type</th><th>Per Day Charges</th></tr>")
        for(var i=1 to total step 1)
        {
            var fields = mysql.fetch_row_as_str(result)
            var num = len(fields)

            print("<tr>")
            for(var loopvar = 0 to (num-1) step 1)
            {
                if(loopvar == 5 or loopvar == 8 or loopvar == 9)
                {
                    loopvar+=1
                    continue
                }
                else
                    printf("<td>%</td>",fields[loopvar])
            }
            print("</tr>")
        }
    }
    catch(err)
    {
        printf(errAlert,"Operation failed. ")
        return nil
    }
}
function admit(var f)
{
    if(!hasFields(["cnic","name","phone","dob","room"],f))
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var cnic = f["cnic"]
    var room = f["room"]
    if(cnic == "" or room == "" or room == "Room")
    {
        printf(errAlert, "CNIC and Room fields are mandatory!")
        return nil
    }
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection, "localhost", "root", "password", "hospital")
        ##to see if patient is entered in database
        var sqlquery = "select status from patients where cnic = '" + cnic + "' ;"
        mysql.query(connection,sqlquery)
        var result = mysql.store_result(connection)
        var row = mysql.fetch_row_as_str(result)
        if(row == nil)
        {
           var dob = f["dob"]
           var phone = f["phone"]
           var name = f["name"] 
           sqlquery = "insert into patients(name, cnic, phone, dob, status) values('"+name+"','"+cnic+"','"+phone+"','"+dob+"','Discharged');"
           mysql.query(connection,sqlquery)
        }

        sqlquery = "select status from patients where cnic = '" + cnic + "' ;"
        mysql.query(connection,sqlquery)
        result = mysql.store_result(connection)
        row = mysql.fetch_row_as_str(result)

        if(row[0] == "Deceased")
        {
            printf(errAlert,"Invalid! Patient records states patient has passed away")
            return nil
        }
        if(row[0] == "Admit")
        {
            printf(errAlert,"Patient already admit")
            return nil
        }
        ##to check availability of room
        sqlquery = "select id from rooms where dept_id = " + room + " and totalBeds != occ;"
        

        mysql.query(connection,sqlquery)
        result = mysql.store_result(connection)
        row = mysql.fetch_row_as_str(result)
        if(row == nil)
        {
            print("Empty room not found")
            return nil
        }
        ##update tables
        var roomid = row[0]
        sqlquery = "Update rooms Set occ = occ + 1 where dept_id = "+room+" and id ="+roomid+";"
        mysql.query(connection,sqlquery)

         sqlquery = "Update patients Set status = 'Admit', r_id = "+roomid+", dept_id = "+room+" where cnic = '"+cnic +"';"
        mysql.query(connection,sqlquery)
    
        sqlquery = "Insert into records values (1,'"+ cnic +"',NOW(), NULL, NULL,NULL,"+roomid+","+room+");"
        mysql.query(connection,sqlquery)
        printf(successAlert,"Success!")
        viewall()
    }
    catch(err)
    {
        printf(errAlert,"Operation failed: "+err.msg)
        return nil
    }
}
function discharge(var f)
{
    if(!f.hasKey("cnic") or !f.hasKey("status"))
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var cnic = f["cnic"]
    var status = f["status"]
    if(cnic == "" or status == "Status")
    {
        printf(errAlert, "Insufficient Parameters")
        return nil
    }
    try
    {    
        var connection = mysql.init()
        mysql.real_connect(connection, "localhost", "root", "password", "hospital")

        var sqlquery = "select status from patients where cnic = '" + cnic + "' ;"
        #println(sqlquery,"<br>")
        mysql.query(connection,sqlquery)
        var result = mysql.store_result(connection)
        var patstatus = mysql.fetch_row_as_str(result)
        #print(patstatus)
        if(patstatus == nil)
        {
            printf(errAlert,"Patient not found in Records")
            return nil
        }
        if(patstatus[0] != "Admit")
        {
            printf(errAlert,"Patient is not admitted, cannot set status as "+status)
            return nil
        }

        ##get total charges
        sqlquery = "select id, dept_id, perDay from rooms where id = (Select r_id from patients where cnic = '"+cnic+"') and dept_id =  (Select dept_id from patients where cnic = '"+cnic+"');"
        #print(sqlquery)
        mysql.query(connection,sqlquery)
        result = mysql.store_result(connection)
        var row = mysql.fetch_row_as_str(result)
        var totalcharges = row[2]
        var id = row[0]
        var dept_id = row[1]

        #update tables
        sqlquery = "update patients set status = '"+status+"' where cnic = '"+cnic+"';"
        mysql.query(connection,sqlquery)

        sqlquery = "Update records Set expiryDate = NOW(), fee = CEILING((TIMESTAMPDIFF(SECOND,'23/4/18 00:00:00', NOW()))/86400)*"+totalcharges+" where r_id = "+id+" and dept_id = "+dept_id+" and cnic = '"+cnic+"' ;"
        #print(sqlquery)       
        mysql.query(connection,sqlquery)

        sqlquery = "update rooms set occ = occ -1 where id = (Select r_id from patients where cnic = '"+cnic+"') and dept_id =  (Select dept_id from patients where cnic = '"+cnic+"');"
        mysql.query(connection,sqlquery)
        
        printf(successAlert,"Success!")
        viewall()
    }
    catch(err)
    {
        printf(errAlert,err.msg)#"Operation failed: Make sure patient status is set correctly")
        return nil
    }
}


checkSignin()
htmlHeader()
var form = cgi.FormData()
if(!form.hasKey("operation"))
{
    printf(errAlert,"Bad Request")
    exit()
}
var op = form["operation"]
if(op == "show")
    show(form)
else if(op == "admit")
    admit(form)
else if(op == "discharge")
    discharge(form)
else
    print("INVALID REQUEST! Unknown operation!")