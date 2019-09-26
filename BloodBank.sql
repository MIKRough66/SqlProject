--=============================================--
-- Project Name : Blood Bank Management System --
-- Student Name : Muhammed Mahfuzul Islam Khan --
-- Student ID   : 1247002					   --
-- Round        : 39						   --
-- Batch   ID   : ESAD-CS/NVIT-A/39/01		   --
--=============================================--



--[Droping Database If Exist]----------------------------------
use master
if DB_ID('My_Blood_Bank') is not null
	drop database My_Blood_Bank
go

--[Ceating And Modifying Database]------------------------------

use master
create database My_Blood_Bank
go

use My_Blood_Bank
go

alter database My_Blood_Bank modify file (name=N'My_Blood_Bank',Size=10MB, MaxSize=unlimited,FileGrowth=1024KB)
go

alter database My_Blood_Bank modify file (name=N'My_Blood_Bank_log',Size=9MB, MaxSize=100MB,FileGrowth=10%)
go

--[Creating Schema]------------------------------------------

use My_Blood_Bank
go

create schema Mahfuz
go

--[Creating Tables]------------------------------------------
use My_Blood_Bank
go

create table Mahfuz.Staff
(
StaffID smallint primary key identity,
Name varchar(40) not null,
Designation varchar(20) not null,
Address nvarchar(50) not null,
Phone varchar(17) check (Phone like '018%' or Phone like '017%') not null,                                --Check option
Email nvarchar(30),
BloodGp varchar(5) not null
)
go


use My_Blood_Bank
go

create table Mahfuz.Donor
(
DonorID smallint primary key identity,
DonorName varchar(35) not null,
Gender char(7) not null,
Age smallint,
DonorPhone varchar(17) not null,
Location varchar(50) not null,
BloodGroup nvarchar(4) not null,
DonatedQty smallint not null,
DonatedDate date default(getdate()) not null,															--use getdate()
StaffID smallint foreign key references Mahfuz.Staff(StaffID)
)
go



use My_Blood_Bank
go
create table Mahfuz.Patient
(
PatientID smallint primary key identity,
PatientName varchar(40) not null,
Gender char(7) not null,
Age smallint not null,
PatientPhone varchar(17) not null,
Location varchar(50) constraint CN_CustomerAddress  default ('Unknown'),                             --using Constraint and Default
RequestedBloodGroup nvarchar(4) not null,
ReceivededBloodQty smallint not null,
ConsultedDoctorName varchar(35),
ReceivedDate varchar(15) default convert(varchar, getdate(),1) not null,                         --Convert American Style
StaffID smallint foreign key references Mahfuz.Staff(StaffID)
)
go



use My_Blood_Bank
go
create table Mahfuz.BloodTest
(
TestEntryID smallint primary key identity,
DonorID smallint foreign key references Mahfuz.Donor(DonorID),
TestedBloodGroup varchar(5) not null,
HIV varchar(10) not null,
HepatitisB varchar(10) not null,
HepatitisC varchar(10) not null,
HTLV varchar(10) not null,
IsSafe bit,
StaffID smallint foreign key references Mahfuz.Staff(StaffID),
Remarks varchar(100) null
)
go

use My_Blood_Bank
go
create table Mahfuz.BloodStorage
(
StoreManagerID smallint foreign key references Mahfuz.Staff(StaffID),
EntryID smallint foreign key references Mahfuz.BloodTest(TestEntryID),
DonorID smallint foreign key references Mahfuz.Donor(DonorID),
BloodGroup nvarchar(4) not null,
BloodBagQty smallint,
StoredDate date not null,
ExpiryDate date not null,
Availability smallint,
Remarks varchar(100) null
)
go


--[Values for tables]-------------------------------------------------------

insert into Mahfuz.Staff values ('Asif','Receptionist','Halishahar,Ctg','01811547895','asif@gmail.com','A+'),
								('Arif','Manager','Dewanhat,Ctg','01784578498','Arif@yahoo.com','AB-'),
								('Akash','Doctor','Potenga,Ctg','01711458795','Akash@outlook.com','O+'),
								('Amir','Tecnical Supervisor','Khulshi,Ctg','01854784589',' ','B+'),
								('Fahmida','Nurse','Khulshi,Ctg','01745876582',' ','B+')
go

insert into Mahfuz.Donor values('Akib','Male',24,'01512457812','Ctg','B+',1,getdate(),1),
							   ('Foysal','Male',27,'01715784853','Ctg','O+',2,getdate(),1),
							   ('Belal','Male',27,'01614578458','Ctg','B+',3,getdate(),1),
							   ('Zahed','Male',26,'01924578495','Ctg','B+',1,getdate(),1)
go

insert into Mahfuz.Patient values('Tushar','Male',25,'01567845895','Ctg','O+',1,'-',getdate(),1),
								 ('Nazmun','Female',27,'01961245867','Ctg','O+',3,'-',getdate(),1),
								 ('Sakhawat','Male',27,'01536458752','Ctg','O+',2,'-',getdate(),1),
								 ('Sohel','Male',28,'01754685264','Ctg','B+',1,'-',getdate(),1)
go



--[Trigger For Staff Table]------------------------------------------------

use My_Blood_Bank
go
create table Mahfuz.Staff_Audit
(
 StaffID smallint,
 Name varchar(40),
 Designation varchar(20),
 Address nvarchar(50),
 Phone varchar(17),
 Email nvarchar(30),
 BloodGp varchar(5),
 Audit_Action varchar(100),
 Audit_Timestamp datetime
)
GO

create trigger Mahfuz.trgAfterInsert on [Mahfuz].[Staff]
for insert
as 
declare @staffid smallint, 
	    @name varchar(40), 
		@designation varchar(20),
		@address nvarchar(50),
		@phone varchar(17),
		@email nvarchar(30),
		@bloodGp varchar(5),
		@audit_action varchar(100);
select @staffid = i.StaffID from inserted i;
select @name = i.Name from inserted i;
select @designation = i.Designation from inserted i;
select @address = i.Address from inserted i;
select @phone = i.Phone from inserted i;
select @email = i.Email from inserted i;
select @bloodGp = i.BloodGp from inserted i;
set @audit_action='Inserted Record -- After Insert Trigger.';
		insert into Mahfuz.Staff_Audit(StaffID,Name,Designation,Address,Phone,Email,BloodGp,Audit_Action,Audit_Timestamp)
		values (@staffid,@name,@designation,@address,@phone,@email,@bloodGp,@audit_action,getdate());
		PRINT 'AFTER INSERT trigger fired.'
GO

--trying to insert data in Employee table

insert into Mahfuz.Staff_Audit(StaffID,Name,Designation,Address,Phone,Email,BloodGp) values (5,'Jerin','Nurse','Ctg','01846758215','_','A-')

--selecting data from both the tables to see trigger action

select * from Mahfuz.Staff
select * from Mahfuz.Staff_Audit
GO

--drop table Mahfuz.Staff_Audit
--drop trigger Mahfuz.trgAfterInsert


--[Creating Function Scalar]------------------------------------------------

use My_Blood_Bank
go
Create Function Mahfuz.fn_BloodDonate
(
@donationqty int,
@currentqty int
)
Returns int
As
Begin
	declare @totalqty int
	Set @totalqty = (@donationqty + @currentqty)
	Return @totalqty
End
Go

--drop function Mahfuz.fn_BloodDonate

--[Creating Function Tabular]-------------------------------------------------

use My_Blood_Bank
go
create function Mahfuz.fn_Donor
(
@a int =0
)
returns table
return
(
select d.Location,d.BloodGroup          
from Mahfuz.Donor d
join Mahfuz.BloodTest b
on d.DonorID=b.DonorID
where d.DonatedQty>@a
);
go

--drop function Mahfuz.fn_Donor


--[View]-----------------------------------------------------

use My_Blood_Bank
go
create view Mahfuz.vw_BloodGroupByLocation																	
as
select d.Location,d.BloodGroup,count(d.DonatedQty) as [Total Quantity]						--use of select,from,where,group by,having,
from Mahfuz.Donor d
join Mahfuz.BloodTest b
on d.DonorID=b.DonorID
where d.DonatedQty>0
group by d.BloodGroup,d.Location
having  d.BloodGroup in(select BloodGroup from Mahfuz.Donor)
go

alter view Mahfuz.vw_BloodGroupByLocation										            --Alter View
with encryption																				--With Encryption
as
select d.Location,d.BloodGroup,count(d.DonatedQty) as [Total Quantity]
from Mahfuz.Donor d
join Mahfuz.BloodTest b
on d.DonorID=b.DonorID
where d.DonatedQty>0
group by d.BloodGroup,d.Location
having  d.BloodGroup in(select BloodGroup from Mahfuz.Donor)
go

select * from Mahfuz.vw_BloodGroupByLocation
go

select *
from sys.sql_modules
where object_id=OBJECT_ID('Mahfuz.vw_BloodGroupByLocation')									--using sys.sql_modules
go
--exec sp_helptext vw_BloodGroupByLocation
--go
--drop view Mahfuz.vw_BloodGroupByLocation
--go

--[All Joins]--------------------------------------------------------------

select s.Name,s.Designation,p.PatientName,p.PatientID
from Mahfuz.Staff s
join Mahfuz.Patient p																								--inner Join
on s.StaffID=p.StaffID
order by s.Name asc
go


select t.DonorID,t.IsSafe,t.StaffID,b.BloodGroup,b.BloodBagQty,b.Availability,b.StoredDate,b.ExpiryDate,b.StoreManagerID
from Mahfuz.BloodTest t
full join Mahfuz.BloodStorage b																						--Full Join
on t.TestEntryID=b.EntryID
where b.BloodGroup=b.BloodGroup
go


select d.DonorID,d.BloodGroup,d.DonatedQty,p.PatientID,p.RequestedBloodGroup,p.ReceivededBloodQty
from Mahfuz.Donor d
cross join Mahfuz.Patient p																							--Cross Join
go

select a.PatientName,b.Age
from Mahfuz.Patient a, Mahfuz.Patient b																				--Self Join
where a.PatientID<>b.PatientID
go

select IsSafe
from Mahfuz.BloodTest
Union All																											--Union All Operator
select BloodBagQty
from Mahfuz.BloodStorage
order by IsSafe
go

select t.DonorID,t.IsSafe,t.TestedBloodGroup,b.Availability,b.ExpiryDate
from Mahfuz.BloodTest t
left outer join Mahfuz.BloodStorage b																				--left outer join
on t.TestEntryID=b.EntryID
where b.Availability > 0
go

select s.Name,s.Designation,p.PatientName,p.ReceivededBloodQty
from Mahfuz.Staff s
right outer join Mahfuz.Patient p																					--right outer join
on s.StaffID=p.StaffID
go

--[Store Procedure For Blood Storage with Select,Insert,Update,Delete,Try..Catch,Transaction,Rollback,Print]---------------------------------------

use My_Blood_Bank
go
create proc sp_CrudOperation
(
	@donorid smallint,
	@donorname varchar(35),
	@gender char(7),
	@age smallint,
	@donorphone varchar(17),
	@location varchar(50),
	@bloodgroup nvarchar(4),
	@donatedqty smallint,
	@staffid smallint,

	@operation varchar(20),
	@tablename varchar(20)
)
as
begin
set nocount on																							--set nocount on/off
	 begin try
		begin transaction
			if(@tablename='Mahfuz.Donor')
				begin
					if(@operation='select')
						begin
							select * from Mahfuz.Donor where DonorID=@donorid
						end
					else if(@operation='Insert')
						begin
							insert into Mahfuz.Donor (DonorName,Gender,Age,DonorPhone,Location,BloodGroup,DonatedQty,StaffID) 
							values(@donorname,@gender,@age,@donorphone,@location,@bloodgroup,@donatedqty,@staffid)
							Print 'Data Inserted Successfully'
						end
					else if(@operation='Update')
						begin
							update Mahfuz.Donor
							set DonorName=@donorname,Gender=@gender,Age=@age,DonorPhone=@donorphone,Location=@location,BloodGroup=@bloodgroup,DonatedQty=@donatedqty,StaffID=@staffid
							where DonorID=@donorid
							Print 'Data Updated Successfully'
						end
					else if(@operation='Delete')
						begin
							delete from Mahfuz.Donor
							where DonorID=@donorid
							Print 'Data Deleted Successfully'
						end
				end
		commit transaction
	 end try

	 begin catch
		rollback transaction
		Print 'Something Went Wrong'
	 end catch
end
go

exec sp_CrudOperation 0,'Rasel','Male',25,01154784586,Ctg,'AB+',2,1,'Insert','Mahfuz.Donor'
go

--drop proc sp_CrudOperation
--go

--======================================================================================

use My_Blood_Bank
go
create proc sp_TestStore
(
@testentryid smallint,
@donorid smallint,
@testedbloodgroup varchar(5),
@hiv varchar(10),
@hepatitisb varchar(10),
@hepatitisc varchar(10),
@htlv varchar(10),
@issafe bit,
@staffid smallint,
@remarks varchar(100),

@storemanagerid smallint,
@bloodbagqty smallint,
@storeddate date,
@expirydate date,
@availability smallint,

@operation varchar(20)
)
as
begin
Set nocount on
	begin try
			declare @donateamount int
			Select @donateamount = (select BloodBagQty from Mahfuz.BloodStorage where DonorID = @donorid)
				if(@operation='Insert')
					begin
						insert into Mahfuz.BloodTest(DonorID,TestedBloodGroup,HIV,HepatitisB,HepatitisC,HTLV,IsSafe,StaffID,Remarks)
						values (@donorid,@testedbloodgroup,@hiv,@hepatitisb,@hepatitisc,@htlv,@issafe,@staffid,@remarks)
						Print 'Data Inserted Successfully' 
							if(@issafe=1)
								begin
									insert into Mahfuz.BloodStorage(DonorID,EntryID,BloodGroup,StoreManagerID,BloodBagQty,StoredDate,ExpiryDate,Availability,Remarks)
									values (@@identity,@@identity,@@identity,@storemanagerid,@bloodbagqty,@storeddate,@expirydate,@availability,@remarks)
									Print 'Data Inserted Successfully'
								end
					end
				if(@operation = 'Update')
					begin
						Update Mahfuz.BloodStorage Set BloodBagQty=Mahfuz.fn_BloodDonate(@bloodbagqty, @donateamount) Where DonorID = @donorid
						Print 'Data Updated Successfully'
					end
	end try

	begin catch
		Print 'Blood Is Not Safe'
	end catch
end
go

--inserting values by Procedure

exec sp_TestStore 0,1,'AB-','No','No','No','No',1,3,'_',2,1,'05/06/2018','06/10/2018',5,'Insert'
go



--drop proc sp_TestStore
--go

--[Create Sequence]------------------------------------------------------------------

use My_Blood_Bank
go 
create sequence sq_MySequence
as bigint
start with 1
increment by 1
minvalue 1
maxvalue 100
no cycle
cache 10
go

select *
from sys.sequences
where name='q_MySequence'
go

--[CTE]------------------------------------------------------------------------

use My_Blood_Bank
go

with StaffCTE
as
(
select StaffID, Name, Phone from Mahfuz.Staff
)

select * from StaffCTE
go


select * from Mahfuz.Staff																			--Between
Where StaffID between 1 and 5
go



--[Temporary Table]-----------------------------------------------------------

if object_id('tempdb..#MytempTable') is not null
	drop table #MytempTable
go

select 'A+' [BloodGroup], 1 [DonatedQty], 25 [Age],'Ctg' [Address],1 [ID], 48.7 [Weight], 'Sahid' DonorName
into #MytempTable
union
select 'A+', 5, 27 , null [Address],2 [ID], 52.5 [Weight],'Raton'
union
select 'B+', 3, 32 , null [Address],3 [ID], 50.3 [Weight],'Noha'
union
select 'B+', 4, 25 ,'Ctg' [Address],4 [ID], 49.9 [Weight],'Azim'
go

create clustered index TmpClustered on #MytempTable(ID)												--Clustered Index
go

--drop index TmpClustered on #MytempTable
--go

create nonclustered index TmpnonClustered on #MytempTable (BloodGroup)								--nonclustered Index
GO

select BloodGroup, DonatedQty,Age,Address,ID,Weight,DonorName 
from #MytempTable
go

--use of Rollup

select BloodGroup,Age,sum(DonatedQty) as [Total Donation]
from #MytempTable
group by BloodGroup,Age with rollup
go

--use of Cube

select BloodGroup,Age,sum(DonatedQty) as [Total Donation]
from #MytempTable
group by BloodGroup,Age with cube
go

--use of grouping sets

select BloodGroup,Age,sum(DonatedQty) as [Total Donation]
from #MytempTable
group by grouping sets(
(BloodGroup,Age),BloodGroup
)
go

--use of Max

select BloodGroup, max(DonatedQty) as [Max Quantity]
from #MytempTable
group by BloodGroup
order by BloodGroup
go

--use of Min

select BloodGroup, min(DonatedQty) as [Min Quantity]
from #MytempTable
group by BloodGroup
order by BloodGroup
go

--use of Average

select BloodGroup, avg(DonatedQty) as Average
from #MytempTable
group by BloodGroup
go

--use of Distinct

select distinct BloodGroup
from #MytempTable
go

--use of Is Null

select DonorName,Address
from #MytempTable
where Address is null
go

--use of Except

select Age
from #MytempTable
except
select DonatedQty
from #MytempTable
go

--use of exist

select DonorName
from #MytempTable
where exists(select DonatedQty from #MytempTable where DonatedQty>1)
go

--use of Any

select DonorName,BloodGroup
from #MytempTable
where ID=any(select ID from #MytempTable where ID=2)
go

--use of Round

select round(Weight,0) as [Rounded Weight] 
from #MytempTable

--use of Flore

select floor(Weight) as [Floored Weight] 
from #MytempTable

--use of Ceiling

select ceiling(Weight) as [Rounded Weight] 
from #MytempTable

--use of Choose

select 
choose (5,27,2,52.2,'Raton') as [Set]
go

--Alter,Drop Table,Trancate Table, Delete Table

alter table #MytempTable
drop column [Age]
go


--truncate table #tempTable
--go

--delete #tempTable
--go






--[Selecting]---------------------------------------------------------------------

select * from Mahfuz.Staff
select * from Mahfuz.Donor
select * from Mahfuz.Patient
select * from Mahfuz.BloodTest
select * from Mahfuz.BloodStorage
go

--sp_addmessage
--@msgnum=65000,
--@severity=10,
--@msgtext='IDB-BISEW Error'

--exec sp_helpdb My_Blood_Bank
--go
--exec sp_help Staff
--go
--[BackUp Database]---------------------------------------------------------------

--use My_Blood_Bank
--go
--backup database Database_name to disk = 'Location_in_Disk\Database_name.bak';
--backup database Database_name to disk = 'Location_In_Disk\Database_name.trn';
--go