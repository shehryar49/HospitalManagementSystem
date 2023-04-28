#!C:/plutonium/plutonium.exe
import "common.plt"

function show(var f)
{
    if(!f.hasKey("cnic"))
    {
        print("CNIC not received")
        return nil
    }
    var cnic = f["cnic"]
    if(cnic == "")
    {
        print("CNIC cannot be null")
        return nil
    }
    
    try{
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
            for( var loopvar = 0 to (num-1) step 1)
            {
                if(loopvar == 5 or loopvar == 8 or loopvar == 9)
                {
                    loopvar = loopvar + 1
                    continue
                }
                else
                    printf("<td>%</td>",fields[loopvar])
            }
            print("</tr>")
        }
    }
    catch(thrownerror)
    {
        print(errAlert,"Operation failed: ", thrownerror)
        return nil
    }
}

function admit(var f)
{
    if(!f.hasKey("cnic") or !f.hasKey("name") or !f.hasKey("phone") or !f.hasKey("dob") or !f.hasKey("room")){
        print("all parameters not received")
        return nil
    }
    var cnic = f["cnic"]
    if(cnic == ""){
        print("CNIC cannot be blank")
        return nil
    }
    var room = f["room"]
    if(room == ""){
        print("Room ID cannot be blank")
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
           sqlquery = "insert into patients(name, cnic, phone, dob, status) values('"+name+"','"+cnic+"','"+phone+"','"+dob+"','not admit');"
           mysql.query(connection,sqlquery)
        }

        sqlquery = "select status from patients where cnic = '" + cnic + "' ;"
        mysql.query(connection,sqlquery)
        result = mysql.store_result(connection)
        row = mysql.fetch_row_as_str(result)

        if(row[0] == "deceased")
        {
            printf("Invalid! Patient records states patient has passed away")
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
        println(sqlquery)
        mysql.query(connection,sqlquery)
        printf(successAlert,"Success!")
    }
    catch(thrownerror){
        printf(errAlert,"Operation failed: "+thrownerror.msg)
        return nil
    }
}

function discharge(var f)
{
    if(!f.hasKey("cnic") or !f.hasKey("status")){
        print("all parameters not received")
        return nil
    }
    var cnic = f["cnic"]
    if(cnic == ""){
        print("CNIC cannot be null")
        return nil
    }
    var status = f["status"]
     try{
        
        var connection = mysql.init()
        mysql.real_connect(connection, "localhost", "root", "password", "hospital")

        var sqlquery = "Select status from patients where cnic = '"+cnic+"';"
        mysql.query(connection,sqlquery)
        var result = mysql.store_result(connection)
        var patstatus = mysql.fetch_row_as_str(result)
        if(patstatus[0] != "Admit")
        {
            printf(errAlert,"Patient is not admitted, cannot set status as "+status)
            return nil
        }

        ##get total charges
        sqlquery = "select id, dept_id, perDay from rooms where id = (Select r_id from patients where cnic = '"+cnic+"') and dept_id =  (Select dept_id from patients where cnic = '"+cnic+"');"
        mysql.query(connection,sqlquery)
        result = mysql.store_result(connection)
        var row = mysql.fetch_row_as_str(result)
        var totalcharges = row[2]
        var id = row[0]
        var dept_id = row[1]

        #update tables
        sqlquery = "Update records Set expiryDate = NOW(), fee = CEILING((TIMESTAMPDIFF(SECOND,'23/4/18 00:00:00', NOW()))/86400)*"+totalcharges+" where r_id = "+id+" and dept_id = "+dept_id+" and cnic = '"+cnic+"' ;"
        mysql.query(connection,sqlquery)

        sqlquery = "update patients set status = '"+status+"' where cnic = '"+cnic+"';"
        mysql.query(connection,sqlquery)

        sqlquery = "update rooms set occ = occ -1 where id = (Select r_id from patients where cnic = '"+cnic+"') and dept_id =  (Select dept_id from patients where cnic = '"+cnic+"');"
        mysql.query(connection,sqlquery)
        

        printf(successAlert,"Success!")
    }
    catch(thrownerror){
        printf(errAlert,"Operation failed:"+thrownerror.msg)
        return nil
    }
}



checkSignin()
print("Content-type: text/html\r\n\r\n")

var receivedform = cgi.FormData()

if(!receivedform.hasKey("operation"))
{
    print("Error! operation undefined")
    exit()
}
var definedoperation = receivedform["operation"]
if(definedoperation == "show")
    show(receivedform)
else if(definedoperation == "admit")
    admit(receivedform)
else if(definedoperation == "discharge")
    discharge(receivedform)
else
    print("Unknown operation")