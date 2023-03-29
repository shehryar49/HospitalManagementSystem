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
    if(!f.hasKey("cnic") or !f.hasKey("dt") or !f.hasKey("room")){
        print("all parameters not received")
        return nil
    }
    var cnic = f["cnic"]
    if(cnic == ""){
        print("CNIC cannot be null")
        return nil
    }
    var room = f["room"]
    if(room == ""){
        print("Room ID cannot be NUll")
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
            print("Patient not entered in database")
            return nil
        }
        if(row[0] == "deceased")
        {
            printf("Invalid! Patient records states patient has passed away")
            return nil
        }
        ##to check availability of room
        sqlquery = "select occ, totalBeds, perDay from rooms where id = " + room + " ;"
        mysql.query(connection,sqlquery)
        result = mysql.store_result(connection)
        row = mysql.fetch_row_as_str(result)
        if(row == nil)
        {
            print("Room does not exist")
            return nil
        }
        if(row[0] == row[1])
        {
            print("Room Full")
            return nil
        }

        ##update tables
        sqlquery = "Update patients Set status = 'Admit' where cnic = '"+cnic +"' ;"
        mysql.query(connection,sqlquery)

        sqlquery = "Update rooms Set occ = occ + 1 where id = "+room+" ;"
        mysql.query(connection,sqlquery)
        
        var datetime = f["dt"]
        if(datetime == ""){
            sqlquery = "Insert into records values (1,'"+ cnic +"', NOW(), NULL, NULL , NULL, '"+room+"') ;"
            mysql.query(connection,sqlquery)
        }
        else{
            sqlquery = "Insert into records values (1,'"+ cnic +"', '"+datetime+"' , NULL, NULL , NULL, '"+room+"') ;"
            mysql.query(connection,sqlquery)
        }

        printf(successAlert,"Success!")
    }
    catch(thrownerror){
        print(errAlert,"Operation failed: ", thrownerror)
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
    var status = f["status"];
     try{
        
        var connection = mysql.init()
        mysql.real_connect(connection, "localhost", "root", "password", "hospital")

        ##get total charges
        sqlquery = "select perDay from rooms where id = (Select r_id from patients where cnic = '"+cnic+"');"
        mysql.query(connection,sqlquery)
        var result = mysql.store_result(connection)
        var row = mysql.fetch_row_as_str(result)
        var totalcharges = float(row[0])

        #update tables
        var sqlquery = "update patients set status = '"+status+"' where cnic = '"+cnic+"';";
        var mysql.query(connection,sqlquery)

        sqlquery = o"Update records Set expiryDate = NOW(), perDay = datediff(CURDATE(),admitDate) *"+totalcharges+" where id = "+room+" ;"
        mysql.query(connection,sqlquery)

        sqlquery = "update rooms set occ = occ -1 where id = (Select r_id from patients where cnic = '"+cnic+"');"
        mysql.query(connection,sqlquery)
        

        printf(successAlert,"Success!")
    }
    catch(thrownerror){
        printf(errAlert,"Operation failed: ")
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