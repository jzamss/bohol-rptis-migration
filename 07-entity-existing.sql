/*=====================================================================
* STEPS:
*    1. REPLACE ALL instances of "training_etracs255" with 
*       the actual ETRACS db name
*    2. REPLACE ALL instances of "rptis." with the actual RPTIS Database
*       Name such as "rptis_talibon."
*    3. Copy to Navicat and Execute ALL script by pressing CTRL + R

IMPORTANT !!!  
    PLEASE SET BEFORE EXECUTING:
      @revisionyear
      @municipalcode
      @municlass

======================================================================*/

set @revisionyear = 2016;
set @municipalcode = 42;
set @municlass = '1ST';


alter table rptis.m_owner add xobjid varchar(50)
;

update rptis.m_owner set 
	xobjid = concat('047', @municipalcode, owner_code)
;

set @revisionyear = 2016;
set @municipalcode = 42;
set @municlass = '1ST';

insert into training_etracs255.entity (
  objid,
  entityno,
  name,
  address_text,
  type,
  entityname,
  address_objid,
  mobileno,
  phoneno,
  email,
  state
)
select 
  xobjid as objid,
  xobjid as entityno,
  owner_desc as name,
  ifnull(owner_adderss, '-') as address_text,
  case 
		when owner_type = 'I' then 'INDIVIDUAL' 
		when owner_type = 'C' then 'JURIDICAL' 
		else 'MULTIPLE'
	end as type,
  substring(owner_desc, 1, 255) as entityname,
  null as address_objid,
  null as mobileno,
  phone_no as phoneno,
  null as email,
  'ACTIVE' as state
from rptis.m_owner 
where owner_desc is not null
;

insert into training_etracs255.entity_address (
  objid,
  parentid,
  type,
  addresstype,
  barangay_objid,
  barangay_name,
  city,
  province,
  municipality,
  bldgno,
  bldgname,
  unitno,
  street,
  subdivision,
  pin,
  text
)
select 
  xobjid as objid,
  xobjid as parentid,
  'local' as type,
  null as addresstype,
  null as barangay_objid,
  null as barangay_name,
  null as city,
  null as province,
  null as municipality,
  null as bldgno,
  null as bldgname,
  null as unitno,
  null as street,
  null as subdivision,
  null as pin,
  owner_adderss as text
from rptis.m_owner 
where owner_desc is not null 
;


update training_etracs255.entity set address_objid = objid
;

insert into training_etracs255.entityindividual (
  objid,
  lastname,
  firstname,
  middlename,
  gender
)
select 
  xobjid,
  '' as lastname,
  '' as firstname,
  '' as middlename,
  null as gender
from rptis.m_owner 
where owner_desc is not null 
and owner_type = 'I'
;


alter table training_etracs255.entityindividual  
	modify column lastname varchar(380)
;

alter table training_etracs255.entityindividual  
	modify column firstname varchar(1600)
;

insert into training_etracs255.entityindividual (
  objid,
  lastname,
  firstname,
  middlename,
  gender
)
select 
  xobjid,
  case 
		when owner_desc like '%,%' then substring(owner_desc, 1, position(',' in owner_desc) - 1)
		else owner_desc
	end as lastname,
  case 
		when owner_desc like '%,%' then substring(owner_desc, position(',' in owner_desc) + 1)
		else ''
	end as firstname,
  '' as middlename,
  null as gender
from rptis.m_owner 
where owner_desc is not null 
and owner_type = 'I'
;

insert into training_etracs255.entityjuridical (
  objid
)
select 
  xobjid
from rptis.m_owner 
where owner_desc is not null 
and owner_type = 'C'
;

insert into training_etracs255.entitymultiple(
  objid,
  fullname
)
select 
  xobjid,
  owner_desc as fullname
from rptis.m_owner 
where owner_desc is not null 
and owner_type = 'M'
;


