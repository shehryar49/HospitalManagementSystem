#!C:\plutonium\plutonium.exe
import "common.plt"
var trashIcon = "<td><button onclick=\"deleteItem(this)\" class=\"delBtn\"><i class=\"fa fa-trash\"></i></button></td>"
var updateIcon = "<td><button onclick=\"updateItem(this.parentElement.parentElement)\" class=\"updateBtn\"><i class=\"fa fa-edit\"></i></button></td>"
function viewinventory()
{
    
    var connection = mysql.init()
    mysql.real_connect(connection,"localhost","root","password","hospital")
    var query = "SELECT * FROM inventory;"
    mysql.query(connection,query)
    var res = mysql.store_result(connection)
    var total = mysql.num_rows(res)
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Type</th><th>Units in Stock</th><th>Price</th><th></th><th></th></tr>")
    for(var i=1 to total step 1)
    {
        var k = 0
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
        {  if(k != 0)
                printf("<td onclick=\"updateItem(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
            else 
                printf("<td>%</td>", field)
            k = k+1
        }
        print(trashIcon)
        print(updateIcon)
        print("</tr>")
    }
    print("</table>")
}
function search(var f)
{
    if(!f.hasKey("id"))  
    {
        printf(errAlert,"Bad Request")
        return nil
    }
    var id = f["id"]
    if(id == "")
    {
        printf(errAlert, "Empty search field!")
        return nil
    }
    if(!isNum(id))
    {
        printf(errAlert,"Invalid format of ID")
        return nil
    }
    var query = "Select * from INVENTORY where id = "+id+";"
    var connection = mysql.init()
    mysql.real_connect(connection,"localhost","root","password","hospital")
    mysql.query(connection,query)
    var res = mysql.store_result(connection)
    var total = mysql.num_rows(res)
    print("<table class=\"table table-bordered table-responsive\" id=\"data\"><tr><th>ID</th><th>Type</th><th>Units in Stock</th><th>Price</th><th></th><th></th></tr>")
    for(var i=1 to total step 1)
    {
        var k = 0
        var fields = mysql.fetch_row_as_str(res)
        print("<tr>")
        foreach(var field: fields)
        {  if(k != 0)
                printf("<td onclick=\"updateItem(this.parentElement,false)\" contentEditable=\"true\">%</td>",field)
            else 
                printf("<td>%</td>", field)
            k = k+1
        }
        print(trashIcon)
        print(updateIcon)
        print("</tr>")
    }
    print("</table>")

}
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
        printf(errAlert,"ID field is mandatory")
        return nil
    }
    var type = f["type"]
    var noofunits = f["nou"]
    var priceperunit = f["ppu"]
    if(!isNum(id))
    {
        printf(errAlert,"Invalid format of id")
        return nil
    }
    if(!isAlpha(type))
    {
        printf(errAlert,"Invalid format of type")
        return nil
    }
    if(!isNum(noofunits))
    {
        printf(errAlert,"Invalid format of number of units")
        return nil
    }
    if(!isNum(priceperunit))
    {
        printf(errAlert,"Invalid format of price per unit")
        return nil
    }
    
    try
    {
        var connection = mysql.init()
        mysql.real_connect(connection,"localhost","root","password","hospital")
        var query = format("INSERT INTO inventory VALUES(%,'%',%,%)",id, type, noofunits, priceperunit)
        mysql.query(connection,query)
        printf(successAlert,"Success")
        viewinventory()
    }
    catch(err)
    {
        printf(errAlert,"Operation Failed")
        viewinventory()
        return nil
    }
}
function removeinventory(var f)
{
    if(!f.hasKey("id"))
    {   
        printf(errAlert,"Bad Request")
        return nil
    }
    var id = f["id"]
    if(id == "")
    {
        print("ID field cannot be empty")
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
            viewinventory()
        }
        catch(err)
        {
            printf(errAlert,"Operation Failed")
            viewinventory()
            return nil
        }
    }
}
function updateinventory(var f)
{
    if(!f.hasKey("id") or !f.hasKey("type") or !f.hasKey("nou") or !f.hasKey("ppu"))
    {   
        printf(errAlert,"Bad Request")
        return nil
    }
    var id = f["id"]
    if(id == "")
    {
        print("ID field is mandatory!")
        return nil
    }
    var type = f["type"]
    var noofunits = f["nou"]
    var priceperunit = f["ppu"]
    if(!isNum(id))
    {
        printf(errAlert,"Invalid format of ID")
        return nil
    }
    if(!isAlpha(type))
    {
        printf(errAlert,"Invalid format of type")
        return nil
    }
    if(!isNum(noofunits))
    {
        printf(errAlert,"Invalid format of number of units")
        return nil
    }
    if(!isNum(priceperunit))
    {
        printf(errAlert,"Invalid format of price per unit")
        return nil
    }
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
checkSignin()
htmlHeader()
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
    viewinventory()
else if (request == "search")
    search(formData)
else if(request == "update")
    updateinventory(formData)
else
    print("Unknown Operation")