#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteItem(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updateItem(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
function addinventory(var f)
{
    if(!f.hasKey("id") or !f.hasKey("type") or !f.hasKey("nou") or !f.hasKey("ppu"))
    {   
        print("Insfficient Parameters")
        return nil
    }
    var id = f["id"]
    if(id == "")
    {
        print("id cannot be NULL")
        return nil
    }
    var type = f["type"]
    var noofunits = f["nou"]
    var priceperunit = f["ppu"]
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("INSERT INTO inventory VALUES(%,'%',%,%)",id, type, noofunits, priceperunit)
        mysql.query(connection,query)
        printf(successAlert,"Success")
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
}

function removeinventory(var f)
{
    if(!f.hasKey("id"))
    {   
        print("Insfficient Parameters")
        return nil
    }
    var id = f["id"]
    if(id == "")
    {
        print("id cannot be NULL")
        return nil
    }
    else
    {
        try{
         var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("DELETE from inventory WHERE id = %;", id,)
        mysql.query(connection,query)
        printf(successAlert,"Success")
        }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
    }
}

function viewinventory(var f)
{
    var id = nil
    if(f.hasKey("id"))  
       id = f["id"]
    var connection = mysql.init()
    mysql.real_connect(connection,"localhost","root","password","hospital")
    var query = "SELECT * FROM inventory;"
    
    if( id != nil and id!="")
       query  = format("Select* from inventory where id = %; ",id)
    mysql.query(connection,query)
    var res = mysql.store_result(connection)
    var total = mysql.num_rows(res)
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Type</th><th>Units in Stock</th><th>Price</th><th></th><th></th></tr>")
    for(var i=1 to total step 1)
    {
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
          printf("<td onclick=\"updateItem(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
        print(trashIcon)
        print(updateIcon)
        print("</tr>")
    }
    print("</table>")
}
function updateinventory(var f)
{
    if(!f.hasKey("id") or !f.hasKey("type") or !f.hasKey("nou") or !f.hasKey("ppu"))
    {   
        print("Insfficient Parameters")
        return nil
    }
    var id = f["id"]
    if(id == "")
    {
        print("id cannot be NULL")
        return nil
    }
    var type = f["type"]
    var noofunits = f["nou"]
    var priceperunit = f["ppu"]
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("UPDATE inventory SET id = %, type = '%', no_of_units = %,price_per_unit = % where id = %;",id, type, noofunits, priceperunit, id)
        mysql.query(connection,query)
        printf(successAlert,"Success")
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        return nil
    }
}

##Execution starts from here##
print("Content-type: text/html\r\n\r\n")
checkSignin()

##Request Processing##
var formData = cgi.FormData()
if(!formData.hasKey("operation"))
{   
    print("No operation specified")
    exit()
}
var request = formData["operation"]
if(request == "add")
    addinventory(formData)
else if(request == "delete")
    removeinventory(formData)
else if(request == "view")
    viewinventory(formData)
else if(request == "update")
    updateinventory(formData)
else
    print("Unknown Operation")