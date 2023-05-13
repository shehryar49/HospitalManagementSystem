use hospital;
--drop view appointments;24243-1009440-4ttendance;
--drop table records;
--drop table rooms;
--drop table patients;
--drop table doctors;
--drop table inventory;
--drop table staff;
--drop table users;

--doctors that currently work at hospital
create table doctors(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,salary int);
insert into doctors values('Dr. Zabago','32910-1927181-7','03253416969','1987-09-09',690000);
insert into doctors values('Dr. Nasir Ahmad', '35202-7555101-1','0321-6241789', '1995-01-08', 900000);
insert into doctors values('Dr. Asiya Bhatti','34212-3810353-4','0302-1829104', '1992-11-21', 1000000);
insert into doctors values('Dr. Saad Asif', '32019-8917101-6','0332-6364156', '1990-12-10',  850000);
insert into doctors values('Dr. Asa Butterfield','32019-8917101-7','0332-6765193','1995-12-10',231220);


insert into doctors values('Dr. Ali Hamza', '19820-0174516-2', '0301-7392113', '1989-08-21', 950000);
insert into doctors values('Dr. Aqsa Shahid', '20193-1872451-0', '0335-1982991', '1980-11-11', 700000);
insert into doctors values('Dr. Kabir Mujtaba', '25754-1021678-5','0317-1020603','1992-8-24',850000);
insert into doctors values('Dr. Ahmed Hussain', '24243-1009440-4', '0311-1001758','1965-9-2', 200000);


--department table
create table departments(dept_id int AUTO_INCREMENT PRIMARY KEY, deptname varchar(30), hod varchar(30));
alter table departments add constraint FK_D_ID foreign key (hod) references doctors(cnic) on update cascade on delete SET NULL;
insert into departments(deptname,hod) values ('Cardiology','32019-8917101-7'); --1
insert into departments(deptname,hod) values ('Neurosurgery','35202-7555101-1'); --2
insert into departments(deptname,hod) values ('Plastic surgery','32910-1927181-7');--3
insert into departments(deptname,hod) values ('ENT','34212-3810353-4');--4
insert into departments(deptname,hod) values ('Eye','32019-8917101-6');--5
insert into departments(deptname,hod) values ('Paediatric', '25754-1021678-5');--6
insert into departments(deptname,hod) values ('Nephrology', '24243-1009440-4');--7
insert into departments(deptname,hod) values ('Gynae', '20193-1872451-0');--8
insert into departments(deptname) values ('Urology');--9
insert into departments(deptname,hod) values ('Surgery','19820-0174516-2');--10
insert into departments(deptname) values ('Psychiatry');--11

--works in
create table worksIn(dept_id int, d_id varchar(30));
alter table worksIn add constraint W_PK PRIMARY KEY(d_id);
alter table worksIn add constraint FK_W_doctor foreign key (d_id) references doctors(cnic) on delete cascade on update cascade;
alter table worksIn add constraint FK_W_dept foreign key (dept_id) references departments(dept_id);
insert into worksIn values (1,'32019-8917101-7');
insert into worksIn values (2,'35202-7555101-1');
insert into worksIn values (3,'32910-1927181-7');
insert into worksIn values (4,'34212-3810353-4');
insert into worksIn values (5,'32019-8917101-6');
insert into worksIn values (6,'25754-1021678-5');
insert into worksIn values (7,'24243-1009440-4');
insert into worksIn values (8,'20193-1872451-0');
insert into worksIn values (10,'19820-0174516-2');

--rooms information
create table rooms(id int, dept_id int,occ int,totalBeds int, perDay float);
alter table rooms add constraint FK_roomdept foreign key (dept_id) references departments(dept_id);
alter table rooms add constraint FK_primaryroom PRIMARY KEY (id, dept_id); 

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,1,0,1,12000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,1,0,6,1000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,1,0,12,800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,1,0,1,12000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,1,0,25,600);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(6,1,0,6,1000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,2,0,1,1800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,2,0,1,1800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,2,0,3,1000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,3,0,12,800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,3,0,1,1800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,3,0,1,1200);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,3,0,6,1000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,3,0,12,800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(6,3,0,12,800);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,4,0,6,2000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,4,0,6,2000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,5,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,5,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,5,0,12,800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,5,0,12,800);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,6,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,6,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,6,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,6,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,6,0,1,20000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,7,0,1,12000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,7,0,6,1000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,7,0,12,800);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,7,0,1,12000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,7,0,25,600);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(6,7,0,6,1000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,8,0,1,20000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(6,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(7,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(8,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(9,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(10,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(11,9,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(12,9,0,1,15000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,10,1,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(6,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(7,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(8,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(9,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(10,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(11,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(12,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(13,10,0,1,18000);


insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(6,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(7,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(8,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(9,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(10,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(11,11,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(12,11,0,1,15000);

--patients that ever visited the hospital
--Not Admit means the idiot came for an appointment
create table patients(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,status varchar(10) CHECK (status = "Discharged" or status = "Admit" or status ="Deceased" or status='Not Admit'),r_id int, dept_id int);
alter table patients add constraint F_r_id foreign key (r_id, dept_id) references rooms (id,dept_id);
insert into patients values('Saifu','24153-2819301-9', '03316372801','1947-08-14','Not Admit', NULL, NULL);
insert into patients values('Samin','35100-1839103-8','03202132231','1948-10-25','Deceased',NULL, NULL);
insert into patients values('Muntaha','35192-2837181-3','03228190326','1997-01-10','Not Admit',NULL, NULL);
insert into patients values('Fareeha','29103-38193010-4','03076782351','1999-11-24','Not Admit',NULL, NULL);
insert into patients values('Adeel','35142-8193038-5','03351627002','1990-06-03','Admit', 2,10);

--hospital staff
create table staff(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,desig varchar(30),salary int);
insert into staff values('Nawaz','30102-10289101-2','03164436563','1995-01-02','Sweeper',25000);
insert into staff values('Amin Dar','20184-6174013-0','03078278103','1998-01-13','Nurse',70000);
insert into staff values('Haider Sarfraz','30102-4801342-2','03078278104','2000-10-25','Receptionist',50000);
insert into staff values('Abdullah Sheikh','30102-2849041-2','03337482910','1990-06-05','Nurse',70000);

--online web app users
create table users(username varchar(30) PRIMARY KEY,password varchar(30),level int,id varchar(30));
insert into users values('admin','341e72004200005c',2, NULL); --admin
insert into users values('shahryar','190ed442e0219ab9',2, NULL); --plutoniumrocks
insert into users values('doc1', 'b8000000b80a2121', 3, '35202-7555101-1'); --doc
insert into users values('recep', 'a24d1600d11e1600', 1, NULL); --pass
insert into users values('doc2', '02b8000a4202b800', 3,'32019-8917101-6'); --doc2
insert into users values('asa','2c00d100160016d1',3,'32019-8917101-7'); --asa

--inventory
create table inventory(id int AUTO_INCREMENT PRIMARY KEY, type varchar(30), no_of_units int, price_per_unit float(24));
insert into inventory (type, no_of_units, price_per_unit) values ('syringe', 10000, 38.0);
insert into inventory (type, no_of_units, price_per_unit) values ('cloth bandage', 50000, 216);

--attendance
--to record attendance of staff and doctors
--normal staff(receptionists,sweepers etc) type=1
--doctors type=2
create table attendance(cnic varchar(30),date date,status char(1),type int);
alter table attendance add constraint at_pk PRIMARY KEY(cnic,date);

insert into attendance VALUES('35202-7555101-1','2023-3-1','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-2','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-3','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-4','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-5','A',2);
insert into attendance VALUES('35202-7555101-1','2023-3-6','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-7','A',2);
insert into attendance VALUES('35202-7555101-1','2023-3-8','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-9','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-10','P',2);
insert into attendance VALUES('35202-7555101-1','2023-3-11','P',2);

insert into attendance VALUES('34212-3810353-4','2023-3-1','P',2);
insert into attendance VALUES('34212-3810353-4','2023-3-2','P',2);
insert into attendance VALUES('34212-3810353-4','2023-3-3','A',2);
insert into attendance VALUES('34212-3810353-4','2023-3-4','P',2);
insert into attendance VALUES('34212-3810353-4','2023-3-5','P',2);
insert into attendance VALUES('34212-3810353-4','2023-3-6','A',2);
insert into attendance VALUES('34212-3810353-4','2023-3-7','A',2);
insert into attendance VALUES('34212-3810353-4','2023-3-8','P',2);
insert into attendance VALUES('34212-3810353-4','2023-3-9','P',2);
insert into attendance VALUES('34212-3810353-4','2023-3-10','P',2);
insert into attendance VALUES('34212-3810353-4','2023-3-11','P',2);

insert into attendance VALUES('32019-8917101-6','2023-3-1','P',2);
insert into attendance VALUES('32019-8917101-6','2023-3-2','P',2);
insert into attendance VALUES('32019-8917101-6','2023-3-3','P',2);
insert into attendance VALUES('32019-8917101-6','2023-3-4','A',2);
insert into attendance VALUES('32019-8917101-6','2023-3-5','P',2);
insert into attendance VALUES('32019-8917101-6','2023-3-6','P',2);
insert into attendance VALUES('32019-8917101-6','2023-3-7','A',2);
insert into attendance VALUES('32019-8917101-6','2023-3-8','P',2);
insert into attendance VALUES('32019-8917101-6','2023-3-9','P',2);
insert into attendance VALUES('32019-8917101-6','2023-3-10','A',2);
insert into attendance VALUES('32019-8917101-6','2023-3-11','A',2);

insert into attendance VALUES('30102-10289101-2','2023-3-1','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-2','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-3','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-4','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-5','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-6','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-7','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-8','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-9','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-10','P',2);
insert into attendance VALUES('30102-10289101-2','2023-3-11','P',2);

insert into attendance VALUES('32019-8917101-7','2023-3-1','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-2','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-3','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-4','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-5','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-6','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-7','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-8','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-9','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-10','P',2);
insert into attendance VALUES('32019-8917101-7','2023-3-11','P',2);

insert into attendance VALUES('19820-0174516-2','2023-3-1','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-2','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-3','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-4','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-5','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-6','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-7','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-8','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-9','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-10','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-11','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-12','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-13','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-14','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-15','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-16','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-17','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-18','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-20','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-21','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-22','P',2);
insert into attendance VALUES('19820-0174516-2','2023-3-23','P',2);

insert into attendance VALUES('20193-1872451-0','2023-3-1','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-2','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-3','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-4','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-5','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-6','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-7','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-8','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-9','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-10','P',2);
insert into attendance VALUES('20193-1872451-0','2023-3-11','P',2);

insert into attendance VALUES('25754-1021678-5','2023-3-1','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-2','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-3','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-4','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-5','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-6','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-7','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-8','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-9','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-10','P',2);
insert into attendance VALUES('25754-1021678-5','2023-3-11','P',2);

insert into attendance VALUES('24243-1009440-4','2023-3-1','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-2','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-3','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-4','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-5','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-6','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-7','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-8','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-9','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-10','P',2);
insert into attendance VALUES('24243-1009440-4','2023-3-11','P',2);

insert into attendance VALUES('32910-1927181-7','2023-3-1','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-2','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-3','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-4','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-5','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-6','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-7','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-8','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-9','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-10','P',1);
insert into attendance VALUES('32910-1927181-7','2023-3-11','P',1);

insert into attendance VALUES('20184-6174013-0','2023-3-1','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-2','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-3','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-4','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-5','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-6','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-7','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-8','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-9','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-10','P',2);
insert into attendance VALUES('20184-6174013-0','2023-3-11','P',2);

insert into attendance VALUES('30102-4801342-2','2023-3-1','P',2);
insert into attendance VALUES('30102-4801342-2','2023-3-2','P',2);
insert into attendance VALUES('30102-4801342-2','2023-3-3','P',2);
insert into attendance VALUES('30102-4801342-2','2023-3-4','A',2);
insert into attendance VALUES('30102-4801342-2','2023-3-5','P',2);
insert into attendance VALUES('30102-4801342-2','2023-3-6','P',2);
insert into attendance VALUES('30102-4801342-2','2023-3-7','A',2);
insert into attendance VALUES('30102-4801342-2','2023-3-8','P',2);
insert into attendance VALUES('30102-4801342-2','2023-3-9','P',2);
insert into attendance VALUES('30102-4801342-2','2023-3-10','A',2);
insert into attendance VALUES('30102-4801342-2','2023-3-11','A',2);

insert into attendance VALUES('30102-2849041-2','2023-3-1','P',2);
insert into attendance VALUES('30102-2849041-2','2023-3-2','P',2);
insert into attendance VALUES('30102-2849041-2','2023-3-3','P',2);
insert into attendance VALUES('30102-2849041-2','2023-3-4','A',2);
insert into attendance VALUES('30102-2849041-2','2023-3-5','P',2);
insert into attendance VALUES('30102-2849041-2','2023-3-6','P',2);
insert into attendance VALUES('30102-2849041-2','2023-3-7','A',2);
insert into attendance VALUES('30102-2849041-2','2023-3-8','P',2);
insert into attendance VALUES('30102-2849041-2','2023-3-9','P',2);
insert into attendance VALUES('30102-2849041-2','2023-3-10','A',2);
insert into attendance VALUES('30102-2849041-2','2023-3-11','A',2);


--patient records 
--type 0 = appointment, type 1 = admission
create table records(type int, cnic varchar(30),admitDate datetime,expiryDate datetime,fee float,d_id varchar(30),r_id int, dept_id int);

alter table records add constraint UNIQUE (d_id, cnic, admitDate);

alter table records add constraint F_rp_id foreign key (cnic) references patients (cnic) on update cascade on delete cascade;--patient lost records lost
alter table records add constraint F_room_id foreign key (r_id, dept_id) references rooms(id, dept_id);

--doctorid + starttime + cnic
--doctor = NULL
--pat cnic //WILL NOT BE SAME
--if starttime = sametime //SAME patient cannot be admitted at same time

insert into records values (0,'24153-2819301-9', '2023-01-01 10:00:00', '2023-01-01 11:00:00', 3000, '32910-1927181-7', NULL,3);
insert into records values (0,'35100-1839103-8', '2023-02-11 13:00:00', '2023-02-11 14:00:00', 3000, '34212-3810353-4', NULL,4);
insert into records values (0,'35142-8193038-5', '2022-12-10 15:00:00', '2022-12-10 16:00:00', 3000, '35202-7555101-1', NULL,2);
insert into records values (0,'35192-2837181-3', '2022-10-10 14:00:00', '2022-10-10 15:00:00', 3000, '34212-3810353-4', NULL,4);
insert into records values (0,'24153-2819301-9', '2022-01-15 09:00:00', '2022-01-15 10:00:00', 3000, '32019-8917101-6', NULL,5);
insert into records values (1,'24153-2819301-9', '2021-10-20 09:00:00', '2021-10-21 22:00:00', 4000, NULL, 2, 4);
insert into records values (1,'35142-8193038-5', '2021-10-20 12:00:00', NULL , NULL, NULL, 2, 10);
insert into records values (0,'24153-2819301-9', '2023-03-23 09:00:00', '2023-03-23 10:00:00', 3000, '35202-7555101-1', NULL,2);
insert into records values (0,'35142-8193038-5', '2023-03-11 10:00:00', '2023-03-11 11:00:00', 3000, '35202-7555101-1', NULL,2);
insert into records values (0,'24153-2819301-9', '2023-03-03 13:00:00', '2023-03-03 14:00:00', 3000, '34212-3810353-4', NULL,4);
insert into records values (0,'35192-2837181-3', '2023-03-06 08:00:00', '2023-03-06 09:00:00', 3000, '34212-3810353-4', NULL,4);
insert into records values (0,'35100-1839103-8', '2023-03-01 09:00:00', '2023-03-01 10:00:00', 3000, '32019-8917101-6', NULL,5);
insert into records values (0,'35142-8193038-5', '2023-01-23 13:00:00', '2023-01-23 14:00:00', 3000, '32019-8917101-7', NULL,1);
insert into records values (0,'35100-1839103-8', '2023-01-01 10:00:00', '2023-01-01 11:00:00', 3000, '32019-8917101-7', NULL,1);
insert into records values (0,'24153-2819301-9', '2022-12-10 15:00:00', '2022-12-10 16:00:00', 3000, '32019-8917101-7', NULL,1);
-- to kill samin
insert into records values(1,'35100-1839103-8','2022-12-10 15:00:00','2023-05-12 4:00:00',NULL,NULL,2,4);

--appointments
create view appointments as (SELECT d_id,TIME(admitDate) as start,TIME(expiryDate) as end,cnic as p_id, DATE(admitDate) as app_date, dept_id FROM records WHERE type = 0);
create view staffView as (SELECT st.name,st.cnic,st.phone,st.dob,st.desig,st.salary,t.perc
     from staff as st join 
     (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc from 
       (SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic)
        as a,(SELECT cnic,COUNT(*) as total from attendance group by cnic) as b where a.cnic=b.cnic)t on
st.cnic = t.cnic);

create view docView as (SELECT st.name,st.cnic,st.phone,st.dob,departments.deptname,st.salary,t.perc
 from doctors as st join 
   (SELECT DISTINCT a.cnic,a.total/b.total*100 as perc from 
          (SELECT cnic,COUNT(*) as total from attendance where status='P' group by cnic) as a
          ,(SELECT cnic,COUNT(*) as total from attendance group by cnic) as b
           where b.cnic = a.cnic)t
   on st.cnic = t.cnic join worksin on st.cnic=worksin.d_id join departments on worksin.dept_id=departments.dept_id);

create view deptView as Select departments.dept_id, departments.deptname, departments.hod, doctors.name
from departments left join doctors on departments.hod = doctors.cnic;
 
create view roomView as select dept.deptname, r.id, r.occ, r.totalBeds, r.perDay from 
  rooms as r join departments as dept on dept.dept_id = r.dept_id;

create view appView as (select doctors.name as DName,patients.name as PName,a.start,a.end,a.app_date,a.d_id,
        a.p_id from appointments as a
         inner join doctors on doctors.cnic = a.d_id inner join 
         patients on patients.cnic=a.p_id);