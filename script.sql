USE [yourdatabasename]
GO
/****** Object:  UserDefinedTableType [dbo].[cartid]    Script Date: 16-04-2021 21:01:21 ******/
CREATE TYPE [dbo].[cartid] AS TABLE(
	[Id] [int] NOT NULL DEFAULT ((0))
)
GO
/****** Object:  UserDefinedTableType [dbo].[orderdetail]    Script Date: 16-04-2021 21:01:22 ******/
CREATE TYPE [dbo].[orderdetail] AS TABLE(
	[orderid] [int] NOT NULL DEFAULT ((0)),
	[productid] [int] NOT NULL DEFAULT ((0)),
	[productname] [nvarchar](255) NULL,
	[productimg] [nvarchar](255) NULL,
	[price] [numeric](16, 2) NULL,
	[discount] [numeric](16, 2) NULL DEFAULT ((0)),
	[quantity] [int] NULL DEFAULT ((0)),
	[subtotal] [numeric](16, 2) NULL,
	[offerid] [int] NULL DEFAULT ((0))
)
GO
/****** Object:  StoredProcedure [dbo].[Loginuser]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Loginuser]
@type nvarchar(10) ='',
@action int =0,
@userid int = 0,
@name nvarchar (50) ='',
@mobileno nvarchar(30) = '',
@emailid nvarchar(30) ='',
@Password nvarchar(10) ='',
@profileimg nvarchar(255) ='',
@sessionid nvarchar(max) ='',
@usercode nvarchar(max) = '',
@refercode nvarchar(max) ='',
@checkcode int =0,
@today datetime = '',
@dob datetime = '',
@pincode nvarchar(10) = '',
@address nvarchar(255) = '',
@landmark nvarchar(255) = '',
@cityid int = 0,
@stateid int = 0,
@email nvarchar(100) = '',
@Id int = 0
as
begin
select @today = [dbo].[gettodaydate](1)
set @userid = [dbo].[getuserid](@emailid)
if(@action = 1)
begin
set @userid = [dbo].[getuserid](@emailid)
if(@userid > 0)
begin
declare @status int = 0
Select @status = status from userprofile where Lower(emailid) = Lower(@emailid) and [Password] = @password
if(@status = 1)
begin
if((Select COUNT(*) from userprofile where Lower(emailid) = Lower(@emailid) and [Password] = @password and status = 1) = 1)
begin
Select 1 as result, 'user' as Type, Id, emailid from userprofile where Lower(emailid) = Lower(@emailid) and [Password] = @password
end
end
else if(@status = 0)
begin
select 2 as result
end
end
end
else if(@action = 2)
begin
if((select COUNT(*) from userprofile where LOWER(emailid) = LOWER(@emailid)) = 0)
begin
insert into userprofile (username, dob, mobileno, emailid, regdate, [password], profileimg, status)
values (@name, @dob, @mobileno, @emailid, @today, @Password, @profileimg, 1)
set @userid = [dbo].[getuserid](@emailid)
update tblcartitem set custid = @userid where sessionid = @sessionid
select 1 as result, @@IDENTITY as Id
end
else
begin
select 2 as result
end
end
if(@action = 3)
begin
Select [dbo].[getuserid](@emailid) as userid
end
if(@action = 4)
begin
update userprofile set username = @name, profileimg = case when @profileimg = '' or @profileimg = null or @profileimg is null then profileimg else @profileimg end where emailid  = @emailid
select 1 as result
end
if(@action = 5)
begin
select * from userprofile where status <> 0 order by Id desc
end
if(@action = 6)
begin
if((select count(*) from useraddress where custid = @userid and pincode = @pincode and address = @address and landmark = @landmark and cityid = @cityid and stateid = @stateid and status = 1) = 0)
begin
if(@userid > 0)
begin
insert into useraddress(custid,address,landmark,pincode,cityid,stateid,status,Name,email, mobileno)values(@userid,@address,@landmark,@pincode,@cityid,@stateid,1,@Name,@email, @mobileno)
select 1 as result
end
else
begin
select 3 as result
end
end
else
begin
select 2 as result
end
end
if(@action = 7)
begin
if(@userid > 0)
begin
select 1 as result, sm.State_Name, cm.City_Name, ua.* from useraddress ua left outer join State_Master sm on sm.Id = ua.stateid left outer join City_Master cm on cm.Id = ua.cityid where custid = @userid and ua.status = 1
end
else
begin
select 2 as result
end
end
if(@action = 8)
begin
if(@userid > 0)
begin
update useraddress set status = 0 where Id = @Id
select 1 as result
end
else
begin
select 2 as result
end
end
end


GO
/****** Object:  StoredProcedure [dbo].[manage_productimage]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[manage_productimage]
@Id int = 0,
@productid int = 0,
@imagename nvarchar(100) = '',
@product_image nvarchar(255) = '',
@action int = 1
as
begin
if(@action = 1)
begin
select 1 as result,* from productimages where productid = @productid and status = 1 order by id desc
select * from productimages where Id = @Id
end
else if(@action = 2)
begin
if(@Id = 0)
begin
if((select count(*) from productimages where lower(imagename) = lower(@imagename) and productid = @productid)=0)
begin
insert into productimages (productid, product_image, imagename) values (@productid, @product_image, @imagename)
select 1 as result, @@IDENTITY as Id
end
else
begin
select 2 as result
end
end
else
begin
if((select count(*) from productimages where lower(imagename) = lower(@imagename) and productid = @productid and Id <> @Id)=0)
begin
update productimages set imagename = @imagename, productid = @productid, product_image = case when @product_image = '' or @product_image = null or @product_image is null then product_image else @product_image end where Id = @Id
select 1 as result, @Id as Id
end
else
begin
select 2 as result
end
end
end
else if(@action = 3)
begin
delete from productimages where Id = @Id
select 1 as result
end
end
GO
/****** Object:  StoredProcedure [dbo].[managemeproductqty]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[managemeproductqty]
@baseprice numeric(16,2) = 0,
@Id int = 0,
@catid int = 0,
@subcatid int = 0,
@productid int = 0,
@measurement decimal(16,2) = 0,
@stock int = 0,
@price decimal(16,2) = 0,
@discount numeric(16,2) = 0,
@discountprice numeric(16,2) = 0,
@tax numeric (16, 2) = 0,
@taxamount numeric (16, 2) = 0,
@profit numeric (16, 2) = 0,
@profitpercent numeric(16,2) = 0,
@action int = 1,
@pprice numeric (16, 2) = 0,
@weight decimal(18,2) = 0,
@sku nvarchar(max) = ''
as
begin
if(@action = 1)
begin
Select * from (select tpm.image1, tpm.productname, tpm.isdelete, tps.*, tpmc.catName, tpc.catName as subcatname from tblproductstock tps left outer join tblProductMaster tpm on tpm.productId = tps.productid  left outer join tblproductmastercategory tpmc on tpmc.mstcatid = tps.catid left outer join tblProductCategory tpc on tpc.catId = tps.subcatid where tps.status = 1 and tpm.isdelete = 0) as tbl where tbl.isdelete = 0 order by tbl.id desc
Select * from (select tpm.image1, tpm.productname, tpm.isdelete, tps.*, tpmc.catName, tpc.catName as subcatname from tblproductstock tps left outer join tblProductMaster tpm on tpm.productId = tps.productid  left outer join tblproductmastercategory tpmc on tpmc.mstcatid = tps.catid left outer join tblProductCategory tpc on tpc.catId = tps.subcatid where tps.status = 1 and tpm.isdelete = 0 and tps.Id = @Id) as tbl where tbl.isdelete = 0 order by tbl.id desc
select * from tblProductMasterCategory where isDelete = 0
end
else if(@action = 2)
begin
select @catid = CatId, @subcatid = subCatId from tblProductMaster where productId = @productid
if(@Id = 0)
begin
if((select count(*) from tblproductstock where productid = @productid and sku = @sku and status = 1) = 0)
begin
set @profit = @baseprice * 0.01 * @profitpercent
set @pprice = @baseprice + @profit
set @discountprice = @pprice * 0.01 * @discount
set @price = (@pprice + (@pprice * 0.01 * @tax)) - @discountprice
insert into tblproductstock (catid,subcatid, productid, price, measurement, stock, baseprice, status, pprice, tax, profit, taxamount, profitpercent,[weight], sku, discount, discountprice) values
(@catid, @subcatid, @productid, @price, @measurement, @stock, @baseprice, 1, @pprice, @tax, @profit, (@pprice * 0.01 * @tax), @profitpercent, @weight, @sku,@discount, @discountprice)
select 1 as result
end
else
begin
select 2 as result
end
end
else
begin
if((select count(*) from tblproductstock where productid = @productid and sku = @sku and status = 1 and Id <> @Id) = 0)
begin
set @profit = @baseprice * 0.01 * @profitpercent
set @pprice = @baseprice + @profit
set @discountprice = @pprice * 0.01 * @discount
set @price = (@pprice + (@pprice * 0.01 * @tax)) - @discountprice
update tblproductstock set catid = @catid, subcatid = @subcatid, productid = @productid, measurement = @measurement, taxamount = (@pprice * 0.01 * @tax), stock = @stock,baseprice=@baseprice, price = @price, pprice = @pprice, tax = @tax, profit= @profit, profitpercent = @profitpercent, [weight] = @weight, sku = @sku,discount = @discount, discountprice = @discountprice where Id = @Id
select 1 as result
end
else
begin
select 2 as result
end
end
end
else if(@action = 3)
begin
update tblproductstock set status = 0 where Id = @Id
select 1 as result
end
end
GO
/****** Object:  StoredProcedure [dbo].[manageorder]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[manageorder]
@Id int = 0,
@paymenttype nvarchar(15) = '',
@custid int = 0,
@action int = 1,
@sessionid nvarchar(max) = '',
@tprice numeric(16,2) = 0,
@tdiscount numeric(16,2) = 0,
@tquantity int = 0,
@tsubtotal numeric(16,2) = 0,
@couponcode nvarchar(100) = '',
@address nvarchar(255) ='',
@landmark nvarchar(255) ='',
@cityid int = 0,
@stateid int = 0,
@pincode nvarchar(10) ='',
@productid int = 0,
@productname nvarchar(255) ='',
@productimg nvarchar(255) ='',
@orderid int = 0,
@price numeric(16,2) = 0,
@contactno nvarchar(30) ='',
@discount numeric(16,2) = 0,
@quantity int = 0,
@subtotal numeric(16,2) = 0,
@offerid int = 0,
@orderdate datetime = '',
@createacnt int = 0,
@username nvarchar(100) = '',
@mobileno nvarchar(15) = '',
@emailid nvarchar(100) = '',
@catid int = 0,
@subcatid int = 0,
@secondcatid int = 0,
@invoiceno nvarchar(max) ='',
@mobile nvarchar(30) ='',
@email nvarchar(100) ='',
@tax numeric(16,2) = 0,
@taxamount numeric(16,2) = 0,
@restqty int = 0,
@invcount int = 0,
@min int =0,
@max int = 0,
@measureid int = 0,
@cartid cartid READONLY
as
begin
set @orderdate = DATEADD(MINUTE, 330, GETUTCDATE())
select ROW_NUMBER() over(order by cartid)as rn, * into #temp from tblcartitem where cartid in(Select Id from @cartid)
if(@action = 1)
begin
select @custid = Id from [dbo].[userprofile] where emailid = @emailid
select 1 as result, up.Username, sm.State_Name, cm.City_Name, tor.* from tblorder tor left outer join State_Master sm on sm.Id = tor.stateid left outer join City_Master cm on cm.Id = tor.cityid left outer join userprofile up on up.Id = tor.custid where tor.custid = @custid order by tor.orderdate desc
end
else if(@action = 2)
begin
select @custid = Id from [dbo].[userprofile] where emailid = @emailid
set @invoiceno = Convert(nvarchar(max),LEFT(CAST(RAND()*1000000000 AS INT),9))
select @invcount = count(*) from tblorder where invoiceno = @invoiceno
if(@invcount <> 0)
begin
while(@invcount <> 0)
begin
set @invoiceno = Convert(nvarchar(max),LEFT(CAST(RAND()*1000000000 AS INT),9))
select @invcount = count(*) from tblorder where invoiceno = @invoiceno
end
end
insert into [dbo].[tblorder](custid, sessionid, price, discount, quantity, subtotal, orderdate, couponcode, [address], landmark, cityid, stateid, pincode, [status], paymenttype, invoiceno, mobile, email, name, tax, taxamount) values (@custid, @sessionid, @tprice, @tdiscount, @tquantity, @tsubtotal, @orderdate, @couponcode, @address, @landmark, @cityid, @stateid, @pincode, 0, @paymenttype, @invoiceno, @mobile, @email, @username, @tax, @taxamount)
select @orderid = @@IDENTITY
insert into [dbo].[orderdetail] select @orderid, tci.productid, tpm.productName,tci.productimg,tci.price,tci.discount,tci.quantity,tci.subtotal, tci.measurement, tci.unit,tpm.CatId, tpm.subCatId, tci.measureid from tblcartitem tci left outer join tblproductmaster tpm on tpm.productid = tci.productid where tci.isdelete = 0 and tci.custid = case when @custid > 0 then @custid else tci.custid end and tci.sessionid = case when @sessionid = '' or @sessionid is null or @sessionid = null then tci.sessionid else @sessionid end and tci.cartid in(Select Id from @cartid)
select @tax = SUM(tax), @taxamount = sum(taxamount) from tblcartitem where cartid in(Select Id from @cartid)
update tblorder set tax = @tax, taxamount = @taxamount where id = @orderid
insert into orderstatus	(orderid, remark, statusdate) values(@orderid, 'Order Placed', @orderdate)
if((Select COUNT(*) from [dbo].[useraddress] where	custid = @custid and [address] = @address and landmark = @landmark and pincode = @pincode and cityid =@cityid and stateid = @stateid and mobileno = @contactno and status = 1) = 0)
begin
insert into [dbo].[useraddress] (custid, [address], landmark, pincode, cityid, stateid, mobileno) values (@custid,@address,@landmark, @pincode, @cityid, @stateid, @mobileno)
end
select @min = min(rn), @max = max(rn) from #temp
while(@min<= @max)
begin
select @measureid = measureid from #temp where rn = @min
select @quantity = quantity from #temp where rn = @min
update tblproductstock set stock = stock - @quantity where Id =@measureid
set @min = @min + 1
end
delete from tblcartitem where cartid in(Select Id from @cartid)
select 1 as result, @invoiceno as invoiceno, @orderid as orderid, subtotal as price from tblorder where Id = @orderid
end
else if(@action = 3)
begin
Select (Select count(*) from tblorder where custid = @custid) as totalorder, tpm.image1, tci.quantity, tps.sku, tci.price, tpm.productName from  tblcartitem tci left outer join tblproductmaster tpm on tpm.productid = tci.productid left outer join tblproductstock tps on tps.Id = tci.measureid where tci.cartid in (select Id from @cartid)
Select * from city_master where id = @cityid
Select * from state_master where id = @stateid
end
else if(@action = 4)
begin
select @custid = Id from [dbo].[userprofile] where emailid = @emailid
set @invoiceno = Convert(nvarchar(max),LEFT(CAST(RAND()*1000000000 AS INT),9))
select @invcount = count(*) from tblorder where invoiceno = @invoiceno
if(@invcount <> 0)
begin
while(@invcount <> 0)
begin
set @invoiceno = Convert(nvarchar(max),LEFT(CAST(RAND()*1000000000 AS INT),9))
select @invcount = count(*) from tblorder where invoiceno = @invoiceno
end
end
insert into [dbo].[tblorder](custid, sessionid, price, discount, quantity, subtotal, orderdate, couponcode, [address], landmark, cityid, stateid, pincode, [status], paymenttype, invoiceno, mobile, email, name, tax, taxamount) values (@custid, @sessionid, @tprice, @tdiscount, 1, @tsubtotal, @orderdate, @couponcode, @address, @landmark, @cityid, @stateid, @pincode, 0, @paymenttype, @invoiceno, @mobile, @email, @username, @tax, @taxamount)
select @orderid = @@IDENTITY
insert into [dbo].[orderdetail] select @orderid, tci.productid, tpm.productName,tci.productimg,tci.price,tci.discount,1,tci.price, tci.measurement, tci.unit,tpm.CatId, tpm.subCatId, tci.measureid from tblcartitem tci left outer join tblproductmaster tpm on tpm.productid = tci.productid where tci.isdelete = 0 and tci.custid = case when @custid > 0 then @custid else tci.custid end and tci.sessionid = case when @sessionid = '' or @sessionid is null or @sessionid = null then tci.sessionid else @sessionid end and tci.cartid in(Select Id from @cartid)
select @tax = SUM(tax), @taxamount = sum(taxamount) from tblcartitem where cartid in(Select Id from @cartid)
update tblorder set tax = @tax, taxamount = @taxamount where id = @orderid
insert into orderstatus	(orderid, remark, statusdate) values(@orderid, 'Order Placed', @orderdate)
if((Select COUNT(*) from [dbo].[useraddress] where	custid = @custid and [address] = @address and landmark = @landmark and pincode = @pincode and cityid =@cityid and stateid = @stateid and mobileno = @contactno and status = 1) = 0)
begin
insert into [dbo].[useraddress] (custid, [address], landmark, pincode, cityid, stateid, mobileno) values (@custid,@address,@landmark, @pincode, @cityid, @stateid, @contactno)
end
select @min = min(rn), @max = max(rn) from #temp
while(@min<= @max)
begin
select @measureid = measureid from #temp where rn = @min
select @quantity = quantity from #temp where rn = @min
update tblproductstock set stock = stock - @quantity where Id =@measureid
set @min = @min + 1
end
Select @restqty = quantity from tblcartitem where cartid in(Select Id from @cartid)
if(@restqty = 1)
begin
delete from tblcartitem where cartid in(Select Id from @cartid)
end
else
begin
update tblcartitem set quantity = quantity - 1 where cartid in(Select Id from @cartid)
end
select 1 as result, @invoiceno as invoiceno, @orderid as orderid, subtotal as price from tblorder where Id = @orderid
end
else if (@action = 5)
begin
select 1 as result, * from orderdetail where orderid = @orderid
select * from orderstatus where orderid = @orderid
end
else if (@action = 6)
begin
select 1 as result, * from orderstatus where orderid = @orderid
end
end
GO
/****** Object:  StoredProcedure [dbo].[sp_managebrand]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_managebrand]
@Id int = 0,
@Brandname nvarchar(100) = '',
@brandimg nvarchar(255) ='',
@action int = 1
as
begin
if(@action = 1)
begin
select 1 as result, * from tblbrandmaster where status = 1 order by Id desc
select * from tblbrandmaster where Id = @Id
end
if(@action = 2)
begin
if(@Id = 0)
begin
if((Select COUNT(*) from [dbo].[tblbrandmaster] where LOWER(Brandname) = LOWER(@Brandname)) = 0)
begin
insert into [dbo].[tblbrandmaster](Brandname, brandimg) values(@Brandname, @brandimg)
select 1 as result, @@IDENTITY as Id
end
else 
begin
select 2 as result
end
end
else
begin
if((Select COUNT(*) from [dbo].[tblbrandmaster] where LOWER(Brandname) = LOWER(@Brandname) and Id <> @Id) = 0)
begin
update [dbo].[tblbrandmaster] set Brandname = @Brandname, brandimg = case when @brandimg is null or @brandimg = null or @brandimg = '' then brandimg else @brandimg end where Id = @Id
select 1 as result, @Id as Id
end
else 
begin
select 2 as result
end
end
end
else if(@action = 3)
begin
update [dbo].[tblbrandmaster] set [status]= 0 where Id = @Id
select 1 as result
end
end



GO
/****** Object:  StoredProcedure [dbo].[sp_managecart]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_managecart]
@cartid int = 0,
@custid int = -1,
@emailid nvarchar(max) ='',
@sessionid nvarchar(100) = '',
@productid int = 0,
@productimg nvarchar(255) = '',
@price numeric(16,2) = 0,
@quantity int = 0,
@subtotal numeric(16, 2) =0,
@addtime datetime = '',
@sku nvarchar(max) = '',
@carttype nvarchar(20) = '',
@discount numeric(16, 2) = 0,
@isdelete tinyint = 0,
@measureid int = 0,
@measurement numeric (16,2) = 0,
@action int = 1,
@stock int = 0,
@unit nvarchar(30) = '',
@tax numeric(16,2) = 0,
@taxamount numeric(16,2) = 0,
@pprice numeric (16, 2) = 0,
@profit numeric (16, 2) = 0,
@vendorid int = 0
as
begin
Select @custid = [dbo].[getuserid](@emailid)
if(@action = 1)
begin
select 1 as result, [dbo].[urlcreater](tpm.productName) as url, tci.*, tpm.productName from tblcartitem tci left outer join tblproductmaster tpm on tpm.productid = tci.productid where tci.isdelete = 0 and tci.custid = case when @custid > 0 then @custid else tci.custid end and tci.sessionid = case when @sessionid = '' or @sessionid is null or @sessionid = null then tci.sessionid else @sessionid end
end
else if(@action = 2)
begin
if(@cartid = 0)
begin
if(@custid > 0)
begin
select @discount = discount, @price = price, @tax= tax, @measurement = measurement, @stock = stock, @pprice = pprice, @profit=profit, @sku = sku from tblproductstock where Id = @measureid
select @productimg = image1, @unit = unitid from tblProductMaster where productId = @productId
select @unit = unitName from tblUnitMaster where unitId = @unit
if((Select COUNT(*) from tblcartitem where productid = @productid and measurement = @measurement and isdelete = 0 and custid = @custid and sku = @sku) = 0)
begin
insert into tblcartitem(custid,sessionid,productid,productimg,price,quantity,subtotal,addtime,discount,exptime,carttype,isdelete, measurement, unit, measureid, tax, taxamount, pprice, profit, sku) values (@custid,@sessionid,@productid,@productimg,@price,@quantity,(@price * @quantity),DATEADD(MINUTE, 330, GETUTCDATE()),@discount,DATEADD(YEAR, 1, DATEADD(MINUTE, 330, GETUTCDATE())), @carttype,@isdelete, @measurement, @unit, @measureid, @tax, ((@pprice * @quantity) * 0.01 * @tax), @pprice, (@profit*@quantity), @sku)
select 1 as result, COUNT(*) as totalitem from tblcartitem where custid = @custid
end
else
begin
update tblcartitem set quantity = quantity + @quantity, subtotal = ((quantity + @quantity) * price), taxamount = ((quantity + @quantity) * taxamount), profit = (@profit*(quantity + @quantity)) where custid = @custid and productid = @productid and measurement = @measurement and isdelete = 0
select 1 as result, COUNT(*) as totalitem from tblcartitem where custid = @custid
end
end
else if(@sessionid <> '' OR @sessionid <> NULL or @sessionid is not null)
begin
select @discount = discount, @price = price, @measurement = measurement, @tax= tax, @taxamount = (pprice * 0.01 * @tax), @stock = stock, @pprice = pprice, @profit=profit, @sku = sku from tblproductstock where Id = @measureid
select @productimg = image1, @unit = unitid from tblProductMaster where productId = @productId
select @unit = unitName from tblUnitMaster where unitId = @unit
if((Select COUNT(*) from tblcartitem where productid = @productid and measurement = @measurement and isdelete = 0 and sessionid = @sessionid and sku = @sku) = 0)
begin
insert into tblcartitem(custid,sessionid,productid,productimg,price,quantity,subtotal,addtime,discount,exptime,carttype,isdelete, measurement, unit, measureid, tax, taxamount, pprice, profit, sku) values (@custid,@sessionid,@productid,@productimg,@price,@quantity,(@price * @quantity),DATEADD(MINUTE, 330, GETUTCDATE()),@discount,DATEADD(YEAR, 1, DATEADD(MINUTE, 330, GETUTCDATE())), @carttype,@isdelete, @measurement, @unit, @measureid, @tax, ((@pprice * @quantity) * 0.01 * @tax), @pprice, (@profit*@quantity),@sku)
select 1 as result, COUNT(*) as totalitem from tblcartitem where sessionid = @sessionid
end
else
begin
update tblcartitem set quantity = quantity + @quantity, subtotal = ((quantity + @quantity) * price), taxamount = ((quantity + @quantity) * taxamount), profit = (@profit*(quantity + @quantity)) where sessionid = @sessionid and productid = @productid and measurement = @measurement and isdelete = 0
select 1 as result, COUNT(*) as totalitem from tblcartitem where sessionid = @sessionid
end
end
end
else
begin
select @stock = stock, @price = price, @pprice = pprice, @profit = profit, @tax = tax from tblproductstock where id in (select measureid from tblcartitem where cartid = @cartid)
update tblcartitem set quantity = @quantity,pprice = (pprice * @quantity), subtotal = (@price * @quantity), taxamount = (taxamount * @quantity), profit = (profit* @quantity) where cartid = @cartid
if(@quantity = 0)
begin
update tblcartitem set isdelete = 1 where cartid = @cartid
end
select 1 as result
end
end
else if(@action = 3)
begin
delete from tblcartitem  where cartid = @cartid
select 1 as result
end
end
GO
/****** Object:  StoredProcedure [dbo].[spManageChildcategory]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spManageChildcategory]
@catId int = 0,
@mstCatId int = 0,
@catName nvarchar(max) ='',
@catimg nvarchar(255) = '',
@isDelete int = 0,
@isfeatured int = 0,
@tax numeric(16,2) = 0,
@action int = 1
as
begin
if(@action = 1)
begin
select 1 as result, tc.*, tpc.catname as mastercategoryname from [dbo].[tblProductCategory] tc left outer join tblProductMasterCategory tpc on tc.mstcatid = tpc.mstcatid where tc.isdelete =0 and tpc.isdelete=0 order by catId desc
select tc.*, tpc.catname as mastercategoryname from [dbo].[tblProductCategory] tc left outer join tblProductMasterCategory tpc on tc.mstcatid = tpc.mstcatid where tc.catId = @catId and tc.isdelete =0 order by catId desc
end
if(@action = 2)
begin
if(@catId = 0)
begin
if((Select COUNT(*) from [dbo].[tblProductCategory] where LOWER(catName) = LOWER(@catName) and mstCatId= @mstCatId and isDelete = 0) = 0)
begin
insert into [dbo].[tblProductCategory](mstCatId, catName, isDelete, catimg) values(@mstCatId, @catName, @isDelete, @catimg)
select 1 as result, @@IDENTITY as Id
end
else 
begin
select 2 as result
end
end
else
begin
if((Select COUNT(*) from [dbo].[tblProductCategory] where LOWER(catName) = LOWER(@catName) and mstCatId = @mstCatId and isDelete = 0 and catId <> @catId) = 0)
begin
update [dbo].[tblProductCategory] set catName = @catName, catimg = case when @catimg = '' or @catimg = null or @catimg is null then catimg else @catimg end, mstCatId = @mstCatId where catId = @catId
select 1 as result, @catId as Id
end
else 
begin
select 2 as result
end
end
end
else if(@action = 3)
begin
update [dbo].[tblProductCategory] set isDelete = 1 where catId = @catId
select 1 as result
end
end
GO
/****** Object:  StoredProcedure [dbo].[spMasterCategory]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spMasterCategory]
@mstCatId int = 0,
@catName nvarchar(max) ='',
@catimg nvarchar(255) = '',
@isDelete int = 0,
@action int = 1
as
begin
if(@action = 1)
begin
select 1 as result, * from [dbo].[tblProductMasterCategory] where isdelete = 0 order by mstCatId desc
select * from [dbo].[tblProductMasterCategory] where mstCatId = @mstCatId
end
if(@action = 2)
begin
if(@mstCatId = 0)
begin
if((Select COUNT(*) from [dbo].[tblProductMasterCategory] where LOWER(catName) = LOWER(@catName) and isDelete = 0) = 0)
begin
insert into [dbo].[tblProductMasterCategory](catName, isDelete, catimg) values(@catName, @isDelete, @catimg)
select 1 as result, @@IDENTITY as id
end
else 
begin
select 2 as result
end
end
else
begin
if((Select COUNT(*) from [dbo].[tblProductMasterCategory] where LOWER(catName) = LOWER(@catName) and mstCatId <>  @mstCatId and isdelete = 0) = 0)
begin
update [dbo].[tblProductMasterCategory] set catName = @catName, catimg = case when @catimg = '' or @catimg = null or @catimg is null then catimg else @catimg end where mstCatId = @mstCatId
select 1 as result, @mstCatId as Id
end
else 
begin
select 2 as result
end

end
end
else if(@action = 3)
begin
update [dbo].[tblProductMasterCategory] set isDelete = 1 where mstCatId = @mstCatId
select 1 as result
end
end




GO
/****** Object:  StoredProcedure [dbo].[spProductMaster]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spProductMaster]
(
@productId int=0,
@productName nvarchar(250) ='',
@CatId int =0,
@subCatId int =0,
@description nvarchar(250) ='',
@isDelete int =0 ,
@image1 nvarchar(max) ='',
@shortDesc1 nvarchar(255) ='',
@modalNo nvarchar(100) ='',
@unitId int =0,
@skucode nvarchar(100)='',
@brandid int = 0,
@action int=1
)
as
begin

if(@action=1)
begin
select 1 as result, p.*, u.unitName,mstc.catname,cat.catname as childcategory, tbm.brandname from tblProductMaster as p
left outer join tblUnitMaster as u on u.unitId=p.unitId
left outer join tblProductMasterCategory as mstc on mstc.mstcatid=p.CatId
left outer join tblProductCategory as cat on cat.catid=p.subCatId
left outer join tblbrandmaster tbm on tbm.Id = p.brandid
where p.isDelete=0 and mstc.isDelete=0 and cat.isDelete=0 and p.productId= case when @productId>0 then @productId else p.productId end
select * from tblProductMasterCategory where isdelete=0
select * from tblUnitMaster  where isdelete=0
select * from tblbrandmaster where [status] = 1
end
else if(@action=2)
begin
if(@productId>0)
begin
if((Select count(*) from tblProductMaster where CatId = @CatId and subCatId = @subCatId and LOWER(productName) = LOWER(@productName) and isDelete = 0 and productId<>@productId) = 0)
begin
update tblProductMaster set brandid = @brandid,shortDesc1=@shortDesc1,modalNo=@modalNo,unitId=@unitId,skucode=@skucode,
image1=case when @image1!='' then @image1 else image1 end
,productName=case when @productName!='' then @productName else productName end
,CatId=case when @CatId>0 then @CatId else CatId end
,subCatId=case when @subCatId>0 then @subCatId else subCatId end
where productId=@productId
select 1 as result, @productId as productId
end
else
begin
select 2 as result
end
end
else 
begin
if((Select count(*) from tblProductMaster where CatId = @CatId and subCatId = @subCatId and LOWER(productName) = LOWER(@productName) and isDelete = 0) = 0)
begin
insert into tblProductMaster (productName,CatId,subCatId,[description],isDelete,image1, shortDesc1, brandid,modalNo,unitId,skucode) 
values (@productName,@CatId,@subCatId, @description,0,@image1, @shortDesc1, @brandid, @modalNo,@unitId,@skucode)
select 1 as result, @@IDENTITY as productId
end
else
begin
select 2 as result
end
end
end
if(@action=3)
begin
update tblProductMaster set isDelete=1 where productId=@productId
select 1 as result
end
end
GO
/****** Object:  StoredProcedure [dbo].[spUnitMaster]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spUnitMaster]
(
@unitId int=0,
@unitName nvarchar(250) ='',
@action int=1
)
as
begin

if(@action=1)
begin
select 1 as result, * from tblUnitMaster where isDelete=0 order by unitid desc
select * from tblUnitMaster where unitId = @unitId
end


if(@action=2)
begin
if(@unitId>0)
begin
if((Select COUNT(*) from tblUnitMaster where LOWER(unitName)=LOWER(@unitName) and unitId<>@unitId)=0)
begin
update tblUnitMaster set unitName=@unitName where  unitId=@unitId
select 1 as result
end
else
begin
select 2 as result
end
end
else 
begin
if((Select COUNT(*) from tblUnitMaster where LOWER(unitName)=LOWER(@unitName))=0)
begin
insert into tblUnitMaster (unitName) values (@unitName)
select 1 as result
end
else
begin
select 2 as result
end
end
end
if(@action=3)
begin
update tblUnitMaster set isDelete= 1 where unitId=@unitId
select 1 as result
end
end
GO
/****** Object:  UserDefinedFunction [dbo].[gettodaydate]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[gettodaydate](@a int)
RETURNS datetime
as
begin
declare @today datetime = ''
select @today = DATEADD(MINUTE, 330, GETUTCDATE())
return @today
end



GO
/****** Object:  UserDefinedFunction [dbo].[getuserid]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[getuserid](@emailid nvarchar(100))
RETURNS int
as
begin
declare @userid int = 0
if(@emailid <> null or @emailid <> '' or @emailid is not null)
begin
Select @userid = ISNULL(Id, 0) from userprofile where emailid = @emailid
end
return @userid
end



GO
/****** Object:  UserDefinedFunction [dbo].[urlcreater]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[urlcreater](@url nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
set @url= LOWER(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(@url, ' ', '-'),'~', '-'), '`','-'), '!', '-'),'@','-'), '#', '-'),'$','-'), '%','-'), '^', '-'),'&','-'), '*','-'), '(','-'), ')','-'),'+','-'),'=','-'),'<','-'),'>','-'),'/','-'),',','-'),'.','-'),'?','-'), ':', '-'), '--', '-'), '---','-'),'----','-'),';','-'),'''','-'),'"','-'), '_', '-'))
RETURN @url
END



GO
/****** Object:  Table [dbo].[City_Master]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City_Master](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[City_Name] [nvarchar](100) NULL,
	[State_Id] [int] NOT NULL,
	[Country_Id] [int] NOT NULL,
	[status] [int] NULL,
 CONSTRAINT [PK_City_Master] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[error_log]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[error_log](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[errormsg] [nvarchar](max) NULL,
	[pagename] [nvarchar](max) NULL,
	[controllername] [nvarchar](max) NULL,
	[error_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[logintab]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[logintab](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Userid] [nvarchar](50) NULL,
	[password] [nvarchar](30) NULL,
	[type] [nvarchar](20) NULL,
	[Status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[orderdetail]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orderdetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[orderid] [int] NOT NULL,
	[productid] [int] NOT NULL,
	[productname] [nvarchar](255) NULL,
	[productimg] [nvarchar](255) NULL,
	[price] [numeric](16, 2) NOT NULL,
	[discount] [numeric](16, 2) NOT NULL,
	[quantity] [int] NOT NULL,
	[subtotal] [numeric](16, 2) NOT NULL,
	[measurement] [numeric](16, 2) NOT NULL,
	[unit] [nvarchar](30) NULL,
	[catid] [int] NOT NULL,
	[subcatid] [int] NOT NULL,
	[measureid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[orderstatus]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orderstatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[orderid] [int] NULL,
	[remark] [nvarchar](max) NULL,
	[statusdate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[productimages]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[productimages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[productid] [int] NULL,
	[product_image] [nvarchar](255) NULL,
	[imagename] [nvarchar](100) NULL,
	[status] [int] NULL,
 CONSTRAINT [PK__producti__3214EC078612D5C3] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[State_Master]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[State_Master](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[State_Name] [nvarchar](100) NULL,
	[Country_Id] [int] NOT NULL,
	[status] [int] NULL,
 CONSTRAINT [PK_State_Master] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblbrandmaster]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblbrandmaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Brandname] [nvarchar](100) NULL,
	[brandimg] [nvarchar](255) NULL,
	[status] [int] NULL,
 CONSTRAINT [PK__tblbrand__3214EC271A4B275D] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblcartitem]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblcartitem](
	[cartid] [int] IDENTITY(1,1) NOT NULL,
	[custid] [int] NOT NULL,
	[sessionid] [nvarchar](100) NULL,
	[productid] [int] NOT NULL,
	[productimg] [nvarchar](255) NULL,
	[price] [numeric](16, 2) NULL,
	[quantity] [int] NOT NULL,
	[subtotal] [numeric](16, 2) NULL,
	[addtime] [datetime] NULL,
	[carttype] [nvarchar](20) NULL,
	[isdelete] [int] NOT NULL,
	[discount] [numeric](16, 2) NULL,
	[exptime] [datetime] NULL,
	[offerid] [int] NOT NULL,
	[measurement] [numeric](16, 2) NOT NULL,
	[unit] [nvarchar](30) NULL,
	[measureid] [int] NOT NULL,
	[tax] [numeric](16, 2) NOT NULL,
	[taxamount] [numeric](16, 2) NOT NULL,
	[pprice] [numeric](16, 2) NOT NULL,
	[profit] [numeric](16, 2) NOT NULL,
	[sku] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[cartid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblorder]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblorder](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[custid] [int] NOT NULL,
	[sessionid] [nvarchar](100) NULL,
	[price] [numeric](16, 2) NULL,
	[discount] [numeric](16, 2) NOT NULL,
	[quantity] [int] NOT NULL,
	[subtotal] [numeric](16, 2) NOT NULL,
	[orderdate] [datetime] NULL,
	[couponcode] [nvarchar](100) NULL,
	[address] [nvarchar](255) NULL,
	[landmark] [nvarchar](255) NULL,
	[cityid] [int] NOT NULL,
	[stateid] [int] NOT NULL,
	[pincode] [nvarchar](10) NULL,
	[status] [tinyint] NOT NULL,
	[paymenttype] [nvarchar](15) NULL,
	[invoiceno] [nvarchar](30) NULL,
	[measurement] [numeric](16, 2) NOT NULL,
	[unit] [nvarchar](30) NULL,
	[measureid] [int] NOT NULL,
	[tax] [numeric](16, 2) NOT NULL,
	[taxamount] [numeric](16, 2) NOT NULL,
	[mobile] [nvarchar](30) NULL,
	[email] [nvarchar](100) NULL,
	[name] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductCategory]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductCategory](
	[catId] [int] IDENTITY(1,1) NOT NULL,
	[mstCatId] [int] NULL,
	[catName] [nvarchar](100) NULL,
	[isDelete] [tinyint] NULL,
	[catimg] [nvarchar](255) NULL,
 CONSTRAINT [PK_tblProductCategory] PRIMARY KEY CLUSTERED 
(
	[catId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductMaster]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductMaster](
	[productName] [nvarchar](250) NULL,
	[CatId] [int] NULL,
	[subCatId] [int] NULL,
	[description] [nvarchar](250) NULL,
	[isDelete] [int] NULL,
	[image1] [nvarchar](max) NULL,
	[shortDesc1] [nvarchar](255) NULL,
	[modalNo] [nvarchar](100) NULL,
	[unitId] [int] NULL,
	[skucode] [nvarchar](100) NULL,
	[productId] [int] IDENTITY(1,1) NOT NULL,
	[brandid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[productId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblProductMasterCategory]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductMasterCategory](
	[mstCatId] [int] IDENTITY(1,1) NOT NULL,
	[catName] [nvarchar](100) NULL,
	[isDelete] [tinyint] NULL,
	[catimg] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[mstCatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblproductstock]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblproductstock](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[catid] [int] NOT NULL,
	[subcatid] [int] NOT NULL,
	[productid] [int] NOT NULL,
	[measurement] [decimal](16, 2) NOT NULL,
	[stock] [int] NOT NULL,
	[price] [decimal](16, 2) NOT NULL,
	[status] [int] NOT NULL,
	[discount] [numeric](16, 2) NOT NULL,
	[discountprice] [numeric](16, 2) NOT NULL,
	[tax] [numeric](16, 2) NOT NULL,
	[taxamount] [numeric](16, 2) NOT NULL,
	[profitpercent] [numeric](16, 2) NOT NULL,
	[profit] [numeric](16, 2) NOT NULL,
	[pprice] [numeric](16, 2) NOT NULL,
	[weight] [decimal](18, 2) NOT NULL,
	[sku] [nvarchar](max) NULL,
	[baseprice] [numeric](16, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblUnitMaster]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUnitMaster](
	[unitId] [int] IDENTITY(1,1) NOT NULL,
	[unitName] [nvarchar](50) NULL,
	[isDelete] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[unitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[useraddress]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[useraddress](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[custid] [int] NULL,
	[address] [nvarchar](255) NULL,
	[landmark] [nvarchar](255) NULL,
	[pincode] [nvarchar](10) NULL,
	[cityid] [int] NULL,
	[stateid] [int] NULL,
	[status] [int] NULL,
	[Name] [nvarchar](100) NULL,
	[email] [nvarchar](100) NULL,
	[mobileno] [nvarchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[userprofile]    Script Date: 16-04-2021 21:01:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[userprofile](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](100) NULL,
	[dob] [datetime] NULL,
	[mobileno] [nvarchar](15) NULL,
	[emailid] [nvarchar](100) NULL,
	[regdate] [datetime] NULL,
	[password] [nvarchar](10) NULL,
	[profileimg] [nvarchar](255) NULL,
	[status] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[City_Master] ADD  CONSTRAINT [DF_City_Master_State_Id]  DEFAULT ((0)) FOR [State_Id]
GO
ALTER TABLE [dbo].[City_Master] ADD  CONSTRAINT [DF_City_Master_Country_Id]  DEFAULT ((0)) FOR [Country_Id]
GO
ALTER TABLE [dbo].[City_Master] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[logintab] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [dbo].[orderdetail] ADD  DEFAULT ((0)) FOR [orderid]
GO
ALTER TABLE [dbo].[orderdetail] ADD  DEFAULT ((0)) FOR [productid]
GO
ALTER TABLE [dbo].[orderdetail] ADD  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[orderdetail] ADD  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[orderdetail] ADD  DEFAULT ((0)) FOR [quantity]
GO
ALTER TABLE [dbo].[orderdetail] ADD  DEFAULT ((0)) FOR [subtotal]
GO
ALTER TABLE [dbo].[orderdetail] ADD  DEFAULT ((0)) FOR [measurement]
GO
ALTER TABLE [dbo].[orderdetail] ADD  CONSTRAINT [DF_orderdetail_catid]  DEFAULT ((0)) FOR [catid]
GO
ALTER TABLE [dbo].[orderdetail] ADD  CONSTRAINT [DF_orderdetail_subcatid]  DEFAULT ((0)) FOR [subcatid]
GO
ALTER TABLE [dbo].[orderdetail] ADD  CONSTRAINT [DF_orderdetail_measureid]  DEFAULT ((0)) FOR [measureid]
GO
ALTER TABLE [dbo].[orderstatus] ADD  DEFAULT ((0)) FOR [orderid]
GO
ALTER TABLE [dbo].[productimages] ADD  CONSTRAINT [DF__productim__produ__3587F3E0]  DEFAULT ((0)) FOR [productid]
GO
ALTER TABLE [dbo].[productimages] ADD  CONSTRAINT [DF__productim__statu__367C1819]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[State_Master] ADD  CONSTRAINT [DF_State_Master_Country_id]  DEFAULT ((0)) FOR [Country_Id]
GO
ALTER TABLE [dbo].[State_Master] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tblbrandmaster] ADD  CONSTRAINT [DF__tblbrandm__statu__2B0A656D]  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  DEFAULT ((0)) FOR [custid]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  DEFAULT ((0)) FOR [productid]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  DEFAULT ((0)) FOR [quantity]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  DEFAULT ((0)) FOR [isdelete]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  DEFAULT ((0)) FOR [offerid]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  DEFAULT ((0)) FOR [measurement]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  CONSTRAINT [DF_tblcartitem_measureid]  DEFAULT ((0)) FOR [measureid]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  CONSTRAINT [DF_tblcartitem_tax]  DEFAULT ((0)) FOR [tax]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  CONSTRAINT [DF_tblcartitem_taxamount]  DEFAULT ((0)) FOR [taxamount]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  CONSTRAINT [DF_tblcartitem_pprice]  DEFAULT ((0)) FOR [pprice]
GO
ALTER TABLE [dbo].[tblcartitem] ADD  CONSTRAINT [DF_tblcartitem_profit]  DEFAULT ((0)) FOR [profit]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [custid]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [quantity]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [subtotal]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [cityid]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [stateid]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [measurement]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [measureid]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [tax]
GO
ALTER TABLE [dbo].[tblorder] ADD  DEFAULT ((0)) FOR [taxamount]
GO
ALTER TABLE [dbo].[tblProductMaster] ADD  DEFAULT ((0)) FOR [isDelete]
GO
ALTER TABLE [dbo].[tblProductMaster] ADD  DEFAULT ((0)) FOR [brandid]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [catid]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [subcatid]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [productid]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [measurement]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [stock]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [discountprice]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [tax]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [taxamount]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [profitpercent]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [profit]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [pprice]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  DEFAULT ((0)) FOR [weight]
GO
ALTER TABLE [dbo].[tblproductstock] ADD  CONSTRAINT [DF_tblproductstock_baseprice]  DEFAULT ((0)) FOR [baseprice]
GO
ALTER TABLE [dbo].[tblUnitMaster] ADD  DEFAULT ((0)) FOR [isDelete]
GO
ALTER TABLE [dbo].[useraddress] ADD  DEFAULT ((0)) FOR [custid]
GO
ALTER TABLE [dbo].[useraddress] ADD  DEFAULT ((0)) FOR [cityid]
GO
ALTER TABLE [dbo].[useraddress] ADD  DEFAULT ((0)) FOR [stateid]
GO
ALTER TABLE [dbo].[useraddress] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[userprofile] ADD  DEFAULT ((0)) FOR [status]
GO
