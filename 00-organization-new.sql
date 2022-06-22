/*=====================================================================
* FOR NEW INSTALLATION 
*  - BUILD ORG FROM M_BARANGAY
*
* STEPS:
*    1. CHANGE "training_etracs255" with the actual ETRACS db name
*    2. CHANGE @municipalcode to INDEX NUMBER of your municipality
*    3. REPLACE ALL instances of "rptis." with the actual RPTIS Database
*       Name such as "rptis_talibon."
*    4. Execute ALL script by pressing CTRL + R
======================================================================*/


use training_etracs255
;


set @municipalcode = '42'
;

-- Clear Organization Data

set foreign_key_checks=0;

delete from sys_org;
delete from barangay;
delete from municipality;
delete from province;

set foreign_key_checks=1;


/* province */

insert into sys_org (
objid,
name,
orgclass,
parent_objid,
parent_orgclass,
code,
root,
txncode
)
select
'047' as objid,
'BOHOL' as name,
'PROVINCE' as orgclass,
null as parent_objid,
null as parent_orgclass,
'047' as code,
0 as root,
'047' as txncode
;

/* municipality */
insert into sys_org (
objid,
name,
orgclass,
parent_objid,
parent_orgclass,
code,
root,
txncode
)
select
  concat('047-', repeat('0', 2 - LENGTH(b.municipal_code)), b.municipal_code ) as objid,
  municipal_desc as name,
  'MUNICIPALITY' as orgclass,
  '047' as parent_objid,
  'PROVINCE' as parent_orgclass,
  concat('047-',repeat('0', 2 - LENGTH(b.municipal_code)), b.municipal_code)  as code,
  1 as root,
  concat('047', repeat('0', 2 - LENGTH(b.municipal_code)), b.municipal_code ) as txncode
from rptis.m_municipality m,  rptis.m_barangay b 
where m.municipal_code = b.municipal_code
and m.municipal_code = @municipalcode
limit 1;
;


/* barangay data */
insert into sys_org (
  objid,
  name,
  orgclass,
  parent_objid,
  parent_orgclass,
  code,
  root,
  txncode
)
select
  concat('047-',municipal_code,'-',repeat('0',4 - LENGTH(brgy_code)), brgy_code) as objid,
  brgy_desc as name,
  'BARANGAY' as orgclass,
  concat('047-',municipal_code) as parent_objid,
  'MUNICIPALITY' as parent_orgclass,
  concat('047-',municipal_code,'-', repeat('0',4 - LENGTH(brgy_code)), brgy_code) as code,
  0 as root,
  concat('047',municipal_code,repeat('0',4 - LENGTH(brgy_code)), brgy_code) as txncode
from rptis.m_barangay  
where municipal_code = @municipalcode
;

insert into province (
  objid,
  state,
  indexno,
  pin,
  name,
  parentid
)
select 
  objid,
  'DRAFT' as state,
  objid as indexno,
  objid as pin,
  name,
  parent_objid as parentid
from sys_org
where orgclass = 'province'
;

insert into municipality (
  objid,
  state,
  indexno,
  pin,
  name,
  parentid
)
select
  concat('047-', repeat('0', 2 - LENGTH(b.municipal_code)), b.municipal_code ) as objid,
  'DRAFT' as state,
  concat(repeat('0', 2 - LENGTH(b.municipal_code)), b.municipal_code ) as indexno,
  concat('047-',repeat('0', 2 - LENGTH(b.municipal_code)), b.municipal_code) as pin,
  municipal_desc as name,
  '047' as parentid
from rptis.m_municipality m,  rptis.m_barangay b 
where m.municipal_code = b.municipal_code
and m.municipal_code = @municipalcode
limit 1;
;

insert into barangay (
  objid,
  state,
  indexno,
  pin,
  name,
  parentid
)
select 
  concat('047-',municipal_code,'-', repeat('0',4 - LENGTH(brgy_code)), brgy_code),
  'DRAFT' as state,
  concat(repeat('0',4 - LENGTH(brgy_code)), brgy_code) as indexno,
  concat('047-',municipal_code,'-', repeat('0',4 - LENGTH(brgy_code)), brgy_code) as pin,
  brgy_desc,
  concat('047-',municipal_code) as parentid
from rptis.m_barangay
where municipal_code = @municipalcode
;


alter table rptis.m_barangay 
	add lguid varchar(50),
	add brgyid varchar(50)
;

update rptis.m_barangay set 
	lguid = concat('047-', repeat('0', 2 - LENGTH(municipal_code)), municipal_code ),
	brgyid = concat('047-',municipal_code,'-', repeat('0',4 - LENGTH(brgy_code)), brgy_code)
;



