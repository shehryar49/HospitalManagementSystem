
use hospital;
--drop view appointments;
--drop table attendance;
--drop table records;
--drop table rooms;
--drop table patients;
--drop table doctors;
--drop table inventory;
--drop table staff;
--drop table users;

--doctors that currently work at hospital
create table doctors(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,start time,end time,salary int);
insert into doctors values('Dr. Zabago','32910-1927181-7','03253416969','1987-09-09','9:00','17:00',690000);
insert into doctors values('Dr. Nasir Ahmad', '35202-7555101-1','0321-6241789', '1995-01-08', '9:00', '17:00', 900000);
insert into doctors values('Dr. Asiya Bhatti','34212-3810353-4','0302-1829104', '1992-11-21','16:00', '21:00', 1000000);
insert into doctors values('Dr. Saad Asif', '32019-8917101-6','0332-6364156', '1990-12-10', '13:00', '19:00', 850000);
insert into doctors values("Dr. Asa",'32019-8917101-7','0332-6765193','1995-12-10','9:00','5:00',231220);

--department table
create table departments(dept_id int AUTO_INCREMENT PRIMARY KEY, deptname varchar(30), hod varchar(30));
alter table departments add constraint FK_D_ID foreign key (hod) references doctors(cnic) on update cascade on delete SET NULL;
insert into departments(deptname,hod) values ('Cardiology','32019-8917101-7');
insert into departments(deptname,hod) values ('Neurosurgery','35202-7555101-1');
insert into departments(deptname,hod) values ('Plastic surgery','32910-1927181-7');
insert into departments(deptname,hod) values ('ENT','34212-3810353-4');
insert into departments(deptname,hod) values ('Eye','32019-8917101-6');
insert into departments(deptname) values ('Paediatric');
insert into departments(deptname) values ('Nephrology');
insert into departments(deptname) values ('Gynae');
insert into departments(deptname) values ('Urology');
insert into departments(deptname) values ('Surgery');
insert into departments(deptname) values ('Psychiatry');

--works in
create table worksIn(dept_id int, d_id varchar(30));
alter table worksIn add constraint FK_W_doctor foreign key (d_id) references doctors(cnic) on delete cascade on update cascade;
alter table worksIn add constraint FK_W_dept foreign key (dept_id) references departments(dept_id);
insert into worksIn values (1,'32019-8917101-7');
insert into worksIn values (2,'35202-7555101-1');
insert into worksIn values (3,'32910-1927181-7');
insert into worksIn values (4,'34212-3810353-4');
insert into worksIn values (5,'32019-8917101-6');

--rooms information
create table rooms(id int, dept_id int,occ int,totalBeds int, perDay float);
alter table rooms add constraint FK_roomdept foreign key (dept_id) references departments(dept_id);
alter table rooms add constraint FK_primaryroom PRIMARY KEY (id, dept_id); 

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,3,0,12,800);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,4,0,6,2000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,4,1,6,2000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,5,0,2,5000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(3,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(4,8,0,2,5000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(5,8,0,1,20000);

insert into rooms(id, dept_id, occ, totalBeds, perDay) values(1,10,0,1,18000);
insert into rooms(id, dept_id, occ, totalBeds, perDay) values(2,10,0,1,18000);
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
create table patients(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,status varchar(10),r_id int, dept_id int);
alter table patients add constraint F_r_id foreign key (r_id, dept_id) references rooms (id,dept_id);
insert into patients values('Saifu','24153-2819301-9', '03316372801','1947-08-14','Not Admit', NULL, NULL);
insert into patients values('Samin','35100-1839103-8','03202132231','1948-10-25','Not Admit',NULL, NULL);
insert into patients values('Muntaha','35192-2837181-3','03228190326','1997-01-10','Not Admit',NULL, NULL);
insert into patients values('Fareeha','29103-38193010-4','03076782351','1999-11-24','Not Admit',NULL, NULL);
insert into patients values('Adeel','35142-8193038-5','03351627002','1990-06-03','Admit', 2,4);

--hospital staff
create table staff(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,desig varchar(30),start time,end time
,salary int);
insert into staff values('Nawaz','30102-10289101-2','03164436563','1995-01-02','Sweeper','9:00','17:00',25000);
insert into staff values('Amin Dar','20184-6174013-0','03078278103','1998-01-13','Nurse','9:00','17:00',70000);
insert into staff values('Haider Sarfraz','30102-4801342-2','03326173892','2000-10-25','Receptionist','9:00','17:00',50000);
insert into staff values('Abdullah Sheikh','30102-2849041-2','03337482910','1990-06-05','Nurse','9:00','17:00',70000);

--online web app users
create table users(username varchar(30) PRIMARY KEY,password varchar(30),level int,id varchar(30));
insert into users values('admin','341e72004200005c',2, NULL);
insert into users values('shahryar','190ed442e0219ab9',2, NULL);
insert into users values('doc1', 'b8000000b80a2121', 3, '35202-7555101-1');
insert into users values('recep', 'a24d1600d11e1600', 1, NULL);
insert into users values('doc2', '02b8000a4202b800', 3,'32019-8917101-6');
insert into users values('asa','2c00d100160016d1',3,'32019-8917101-7');

--inventory
create table inventory(id int AUTO_INCREMENT PRIMARY KEY, type varchar(30), no_of_units int, price_per_unit float(24));
insert into inventory (type, no_of_units, price_per_unit) values ('syringe', 10000, 38.0);
insert into inventory (type, no_of_units, price_per_unit) values ('cloth bandage', 50000, 216);

--attendance
--to record attendance of staff and doctors
--normal staff(receptionists,sweepers etc) type=1
--doctors type=2
create table attendance(cnic varchar(30),date date,status char(1),type int);
alter table attendance add constraint at_pk PRIMARY KEY(cnic,date,type);

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

--patient records 
--type 0 = appointment, type 1 = admission
create table records(type int, cnic varchar(30),admitDate datetime,expiryDate datetime,fee float,d_id varchar(30),r_id int, dept_id int);

alter table records add constraint UNIQUE (d_id, cnic, admitDate);

alter table records add constraint F_rp_id foreign key (cnic) references patients (cnic) on update cascade on delete cascade;
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


--appointments
create view appointments as (SELECT d_id,TIME(admitDate) as start,TIME(expiryDate) as end,cnic as p_id, DATE(admitDate) as app_date, dept_id FROM records WHERE type = 0);

--procedure for deletion
--DELIMETER $$
--CREATE PROCEDURE deleteDoctor(nic varchar(30))
--BEGIN
--	IF EXISTS (SELECT *  FROM records WHERE d_id = nic and admitDate >= CURDATE()) THEN
--        SELECT 'Doctor has Appointments!';
--    ELSE
--        DELETE FROM doctors WHERE cnic = nic;
--    END IF;
--END $$
