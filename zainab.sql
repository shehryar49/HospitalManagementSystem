
use hospital;

--rooms information
create table rooms(id int AUTO_INCREMENT PRIMARY KEY,type varchar(30),occ int,totalBeds int, perDay float);
insert into rooms(type, occ, totalBeds, perDay) values('public ward',0, 12, 800);
insert into rooms(type, occ, totalBeds, perDay) values('private ward',1, 6, 2000);
insert into rooms(type, occ, totalBeds, perDay) values('semi private room',0, 2, 5000);
insert into rooms(type, occ, totalBeds, perDay) values('private room',0, 1, 15000);
insert into rooms(type, occ, totalBeds, perDay) values('private plus room',0, 1, 18000);
insert into rooms(type, occ, totalBeds, perDay) values('Executive room',0, 1, 20000);


--patients that ever visited the hospital
create table patients(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,status varchar(10),r_id int);
alter table patients add constraint F_r_id foreign key (r_id) references rooms (id);
insert into patients values('Saifu','24153-2819301-9', '03316372801','1947-08-14','not admit', NULL);
insert into patients values('Samin','35100-1839103-8','03202132231','1948-10-25','not admit',NULL);
insert into patients values('Muntaha','35192-2837181-3','03228190326','1997-01-10','not admit',NULL);
insert into patients values('Fareeha','29103-38193010-4','03076782351','1999-11-24','not admit',NULL);
insert into patients values('Adeel','35142-8193038-5','03351627002','1990-06-03','admit', 2);


--doctors that currently work at hospital
create table doctors(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,spec varchar(30),start time,end time
,salary int);
insert into doctors values('Dr.Zabago','32910-1927181-7','03253416969','1987-09-09','Radiology','9:00','17:00',690000);
insert into doctors values('Dr. Nasir Ahmad', '35202-7555101-1','0321-6241789', '1995-01-08', 'Surgery', '9:00', '17:00', 900000);
insert into doctors values('Dr. Asiya Bhatti','34212-3810353-4','0302-1829104', '1992-11-21', 'ENT', '16:00', '21:00', 1000000);
insert into doctors values('Dr. Saad Asif', '32019-8917101-6','0332-6364156', '1990-12-10', 'Eye Specialist', '13:00', '19:00', 850000);
insert into doctors values("Dr. Asa",'32019-8917101-7','0332-6765193','1995-12-10','Heart Specialist','9:00','5:00',231220);
--hospital staff
create table staff(name varchar(30),cnic varchar(30) PRIMARY KEY,phone char(12),dob date,desig varchar(30),start time,end time
,salary int);
insert into staff values('Nawaz','30102-10289101-2','03164436563','1995-01-02','Sweeper','9:00','17:00',25000);
insert into staff values('Amin Dar','20184-6174013-0','03078278103','1998-01-13','Nurse','9:00','17:00',70000);
insert into staff values('Haider Sarfraz','30102-4801342-2','03326173892','2000-10-25','Receptionist','9:00','17:00',50000);
insert into staff values('Abdullah Sheikh','30102-2849041-2','03337482910','1990-06-05','Nurse','9:00','17:00',70000);

--online web app users
create table users(username varchar(30) PRIMARY KEY,password varchar(30),level int,id varchar(30));
insert into users values('admin','admin',2, NULL);
insert into users values('shahryar','plutoniumrocks',2, NULL);
insert into users values('doc1', 'doc', 3, '35202-7555101-1');
insert into users values('recep', 'pass', 1, NULL);
insert into users values('doc2', 'doc2', 3,'32019-8917101-6');
insert into users values('asa','asa',3,'32019-8917101-7');

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
create table records(type int, cnic varchar(30),admitDate datetime,expiryDate datetime,fee float,d_id varchar(30),r_id int);
alter table records add constraint F_rp_id foreign key (cnic) references patients (cnic) on delete no action on update cascade;
alter table records add constraint F_rd_id foreign key (d_id) references doctors (cnic) on delete no action on update cascade;

insert into records values (0,'24153-2819301-9', '2023-01-01 10:00:00', '2023-01-01 11:00:00', 3000, '32910-1927181-7', NULL);
insert into records values (0,'35100-1839103-8', '2023-02-11 13:00:00', '2023-02-11 14:00:00', 3000, '34212-3810353-4', NULL);
insert into records values (0,'35142-8193038-5', '2022-12-10 15:00:00', '2022-12-10 16:00:00', 3000, '35202-7555101-1', NULL);
insert into records values (0,'35192-2837181-3', '2022-10-10 14:00:00', '2022-10-10 15:00:00', 3000, '34212-3810353-4', NULL);
insert into records values (0,'24153-2819301-9', '2022-01-15 09:00:00', '2022-01-15 10:00:00', 3000, '32019-8917101-6', NULL);
insert into records values (1,'24153-2819301-9', '2021-10-20 09:00:00', '2021-10-21 22:00:00', 4000, '32019-8917101-6', 2);
insert into records values (1,'35142-8193038-5', '2021-10-20 12:00:00', NULL , NULL, '32019-8917101-6', 2);
insert into records values (0,'24153-2819301-9', '2023-03-23 09:00:00', '2023-03-23 10:00:00', 3000, '35202-7555101-1', NULL);
insert into records values (0,'35142-8193038-5', '2023-03-11 10:00:00', '2023-03-11 11:00:00', 3000, '35202-7555101-1', NULL);
insert into records values (0,'24153-2819301-9', '2023-03-03 13:00:00', '2023-03-03 14:00:00', 3000, '34212-3810353-4', NULL);
insert into records values (0,'35192-2837181-3', '2023-03-06 08:00:00', '2023-03-06 09:00:00', 3000, '34212-3810353-4', NULL);
insert into records values (0,'35100-1839103-8', '2023-03-01 09:00:00', '2023-03-01 10:00:00', 3000, '32019-8917101-6', NULL);


insert into records values (0,'35142-8193038-5', '2023-01-23 13:00:00', '2023-01-23 14:00:00', 3000, '32019-8917101-7', NULL);
insert into records values (0,'35100-1839103-8', '2023-01-01 10:00:00', '2023-01-01 11:00:00', 3000, '32019-8917101-7', NULL);
insert into records values (0,'24153-2819301-9', '2022-12-10 15:00:00', '2022-12-10 16:00:00', 3000, '32019-8917101-7', NULL);

--appointments
create view appointments as (SELECT d_id,TIME(admitDate) as start,TIME(expiryDate) as end,cnic as p_id, DATE(admitDate) as app_date FROM records WHERE type = 0);