#!C:\plutonium\plutonium.exe

#Only this api returns json
import "common.plt"

print("Content-type: application/json\r\n\r\n")
try
{
  var conn = mysql.init()
  mysql.real_connect(conn,"localhost","root","password","hospital")
  var query = "select COUNT(*) from doctors;"
  mysql.query(conn,query)
  var res = mysql.store_result(conn)
  var docs = mysql.fetch_row_as_str(res)[0]
  query = "select COUNT(*) from staff;"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var totalstaff = mysql.fetch_row_as_str(res)[0]
  query = "select COUNT(*) from patients;"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var patients = mysql.fetch_row_as_str(res)[0]
  query = "select COUNT(*) from patients where status ='Admit';"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var admitPatients = mysql.fetch_row_as_str(res)[0]
  query = "select COUNT(*) from patients where status ='Deceased';"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var deceasedPatients = mysql.fetch_row_as_str(res)[0]
  query = "select SUM(fee) from records where fee IS NOT NULL;"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var revenue = mysql.fetch_row_as_str(res)[0]
  if(revenue == nil)
    revenue = 0
  query = "select COUNT(*) from rooms;"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var totalRooms = mysql.fetch_row_as_str(res)[0]
  query = "select COUNT(*) from rooms where occ=totalBeds;"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var fullRooms = mysql.fetch_row_as_str(res)[0]
  
  query = " SELECT FLOOR(AVG(perc)) from (
    SELECT DISTINCT a.cnic,a.total/b.total * 100 as perc from (
      SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic
      ) as a,
      (SELECT cnic,COUNT( *) as total from attendance group by cnic
      ) as b 
    where b.cnic = a.cnic)L;"
  mysql.query(conn,query)
  res = mysql.store_result(conn)
  var avgStaffAtt = int(mysql.fetch_row_as_str(res)[0])
  mysql.close(conn)
  printf("{
    \"labels\": [
      \"totalDoctors\",
      \"totalStaff\",
      \"avgStaffAttendance\",
      \"totalPatients\",
      \"deceasedPatients\",
      \"AdmitPatients\",
      \"totalRooms\",
      \"fullRooms\"
    ],  
    \"data\": [
      %,
      %,
      %,
      %,
      %,
      %,
      %,
      %
    ],
    \"revenue\": %,
    \"code\": 200
  }",docs,totalstaff,avgStaffAtt,patients,deceasedPatients,admitPatients,totalRooms,fullRooms,revenue)

}
catch(err)
{
    printf("{\"code\": 100}")
}
