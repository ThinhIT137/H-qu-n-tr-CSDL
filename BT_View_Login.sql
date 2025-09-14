-- fuc---------------------------
CREATE FUNCTION TinhTuoi --của bài 1
(
    @date date
)
RETURNS INT
AS
BEGIN
	DECLARE @tuoi int;
    set @tuoi = DATEDIFF(Year, @date, GETDATE()) - case
		when MONTH(@date) > MONTH(GETDATE()) 
		or (MONTH(@date) = MONTH(GETDATE()) and DAY(@date) > Day(GETDATE()))
		then 1 else 0
	end
    RETURN @tuoi;
END

CREATE FUNCTION dtb -- của bài 2
(
    @T float,
	@V float,
	@L float,
	@H float
)
RETURNS float
AS
BEGIN
    RETURN ((@T + @V)*2 + @L + @H)/6
END
-------------------------------------

--Bài 1
--1.1
CREATE OR ALTER VIEW dbo.DanhSachSV
AS
    Select MaSV, HoSV, TenSV, HocBong from dbo.DSSinhVien
select * from dbo.DanhSachSV

--1.2
CREATE OR ALTER VIEW dbo.HocBong150k
AS
    Select MaSV, HoSV, TenSV, HocBong from dbo.DSSinhVien
	where HocBong>=150000

select * from dbo.HocBong150k

--1.3
CREATE OR ALTER VIEW dbo.Khoa
AS
    Select sv.MaSV, sv.HoSV , sv.TenSV, khoa.TenKhoa, sv.Phai 
	from dbo.DSSinhVien sv inner join DMKhoa khoa on sv.MaKhoa = khoa.MaKhoa
	where sv.Phai = 'Nam' and (sv.MaKhoa = 'AV' or sv.MaKhoa = 'TH')

select * from dbo.Khoa

--1.4
CREATE OR ALTER VIEW dbo.SVTuoi
AS
    Select sv.HoSV, sv.TenSV, dbo.TinhTuoi(sv.NgaySinh) as Tuoi,khoa.TenKhoa
	from dbo.DSSinhVien sv inner join DMKhoa khoa on sv.MaKhoa = khoa.MaKhoa
	where dbo.TinhTuoi(sv.NgaySinh)>=20 and dbo.TinhTuoi(sv.NgaySinh)<=25

select * from dbo.SVTuoi

--1.5
CREATE OR ALTER VIEW dbo.MucHocBong
AS
    Select 
		sv.MaSV,
		sv.Phai,
		sv.MaKhoa,
		(case 
			when sv.HocBong >= 500000 then N'Học bổng cao'
			else N'Mức trung bình'
		end) as MucHocBong
	from dbo.DSSinhVien sv

select * from dbo.MucHocBong 

--1.6
CREATE OR ALTER VIEW dbo.SVHocBong
AS
    Select * from dbo.DSSinhVien sv
	where sv.HocBong > (
		select Max(sv2.HocBong) from dbo.DSSinhVien sv2
		where sv2.MaKhoa = 'AV')

select * from dbo.SVHocBong

--1.7
CREATE OR ALTER VIEW dbo.SV_Max_Diem
AS
    Select sv.MaSV, sv.HoSV, sv.TenSV, mh.MaMH, mh.TenMH, kq.Diem
	from dbo.DSSinhVien sv inner join KetQua kq on sv.MaSV = kq.MaSV
		inner join dbo.DMMonHoc mh on kq.MaMH = mh.MaMH
	where kq.Diem = (
		select max(kq2.Diem)
		from KetQua kq2
		where kq2.MaMH = kq.MaMH)

select * from dbo.SV_Max_Diem

--1.8
select * from DMMonHoc

CREATE or alter VIEW dbo.SV_Chua_Thi
AS
    Select sv.MaSV, sv.HoSV, sv.TenSV from dbo.DSSinhVien sv
	where sv.MaSV not in (
		select kq2.MaSV 
		from KetQua kq2
		where kq2.MaMH='01'
	)

select * from dbo.SV_Chua_Thi

--1.9
CREATE or alter VIEW dbo.SV_Khong_Truot
AS
    Select sv.MaSV, sv.HoSV, sv.TenSV from dbo.DSSinhVien sv
	where not exists (
		select 1
		from KetQua kq2
		where kq2.MaSV=sv.MaSV and kq2.Diem < 5
	)

select * from SV_Khong_Truot

-- Bài 2
-- 2.1
CREATE OR ALTER VIEW dbo.DSHS10A1
AS
    Select 
		hs.MAHS, hs.HO, hs.TEN,
		(case
			when hs.NU = 1 then N'Nữ'
			else N'Nam'
			end
		) as GioiTinh,
		d.TOAN, d.LY, d.HOA
	from dbo.DSHS hs inner join dbo.DIEM d on hs.MAHS = d.MAHS
	where MALOP = '10A1'

select * from dbo.DSHS10A1

--2.2
exec sp_addlogin TranThanhPhong, 123
exec sp_adduser TranThanhPhong, TranThanhPhong
grant select on Object::dbo.DSHS10A1 to TranThanhPhong
--Login TranThanhPhong
select * from dbo.DSHS10A1
----------------------
CREATE OR ALTER VIEW dbo.DSHS10A2
AS
    Select 
		hs.MAHS, hs.HO, hs.TEN,
		(case
			when hs.NU = 1 then N'Nữ'
			else N'Nam'
			end
		) as GioiTinh,
		d.TOAN, d.LY, d.HOA
	from dbo.DSHS hs inner join dbo.DIEM d on hs.MAHS = d.MAHS
	where MALOP = '10A2'

select * from dbo.DSHS10A2

exec sp_addlogin PhamVanNam, 123
exec sp_adduser PhamVanNam, PhamVanNam
grant select on object::dbo.DSHS10A2 to PhamVanNam
--Login PhamVanNam
select * from dbo.DSHS10A2
----------------------

--2.3
CREATE or alter VIEW dbo.KTNH
AS
    Select 
		hs.MAHS,
		hs.HO,
		hs.TEN,
		(case
			when hs.NU = 1 then N'Nữ'
			else N'Nam'
		end) as GioiTinh,
		cast( dbo.dtb(d.TOAN, d.VAN, d.LY, d.HOA) as decimal(4,2)) as DTB,
		(case 
			when dbo.dtb(d.TOAN, d.VAN, d.LY, d.HOA) > 5 and LEAST(d.TOAN, d.VAN, d.LY, d.HOA) > 4
				then N'Lên lớp'
			else N'Lưu ban'
		end) as XepLoai
	from dbo.DSHS hs inner join dbo.DIEM d on hs.MAHS = d.MAHS
	order by XepLoai

select * from dbo.KTNH

--2.4
CREATE or alter VIEW dbo.HSXS
AS
    Select 
		hs.MALOP,
		hs.MAHS, 
		hs.HO,
		hs.TEN,
		YEAR(hs.NGAYSINH) as NamSinh,
		hs.NU,
		d.TOAN,
		d.LY,
		d.HOA,
		d.VAN,
		cast(dbo.dtb(d.TOAN, d.LY, d.HOA, d.VAN) as decimal(4,2)) as DTB,
		LEAST(d.TOAN, d.LY, d.HOA, d.VAN) as DTN
	from dbo.DSHS hs inner join dbo.DIEM d on hs.MAHS = d.MAHS
	where dbo.dtb(d.TOAN, d.LY, d.HOA, d.VAN)>=8.5 
		and LEAST(d.TOAN, d.LY, d.HOA, d.VAN)>=8

select * from dbo.HSXS

--2.5 
CREATE or alter VIEW dbo.HSDATTHUKHOA
AS
    Select 
		hs.MALOP,
		hs.MAHS, 
		hs.HO,
		hs.TEN,
		YEAR(hs.NGAYSINH) as NamSinh,
		hs.NU,
		d.TOAN,
		d.LY,
		d.HOA,
		d.VAN,
		cast((dbo.dtb(d.TOAN, d.LY, d.HOA, d.VAN)) as decimal(4,2)) as DTB
	from dbo.DSHS hs inner join dbo.DIEM d on hs.MAHS = d.MAHS
	where dbo.dtb(d.TOAN, d.LY, d.HOA, d.VAN)>=8.5 
		and LEAST(d.TOAN, d.LY, d.HOA, d.VAN)>=8
		and dbo.dtb(d.TOAN, d.LY, d.HOA, d.VAN)=(select MAX(dbo.dtb(d2.TOAN, d2.LY, d2.HOA, d2.VAN))
			from DIEM d2)

select * from dbo.HSDATTHUKHOA

--Bài 3
--3.1
exec sp_addlogin Login1, 123
exec sp_adduser Login1, User1

--3.2
grant select on DSSinhVien to User1

--3.3
select * from DSSinhVien

--3.4
exec sp_addlogin Login2, 123
exec sp_adduser Login2, User2

--3.5
grant update on DSSinhVien to User2 with grant option

--3.6
grant update on DSSinhVien to User1

--3.7
update DSSinhVien 
set HocBong = 10000
where MaSV = 'B01'
select * from DSSinhVien where MaSV = 'B01'

