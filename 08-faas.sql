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

/* build realproperty info */
alter table rptis.h_property_info 
	add xrpid varchar(50)
;


update rptis.h_property_info  set 
	xrpid = trans_stamp
where prop_type_code = 'L'
;

alter table training_etracs255.realproperty modify column surveyno varchar(500)
;

insert ignore into training_etracs255.realproperty (
  objid,
  state,
  autonumber,
  pintype,
  pin,
  ry,
  claimno,
  section,
  parcel,
  cadastrallotno,
  blockno,
  surveyno,
  street,
  purok,
  north,
  south,
  east,
  west,
  barangayid,
  lgutype,
  lguid
 )
select 
  p.xrpid as  objid,
  case when p.pin_status = 'C' then 'CURRENT' else 'CANCELLED' end as state,
  0 as autonumber,
  'new' as pintype,
  p.pin_no as pin,
  @revisionyear as ry,
  null as claimno,
  concat(repeat('0', 3 - LENGTH(p.section)), p.section) as section,
  concat(repeat('0', 2 - LENGTH(p.lot_no)), p.lot_no) as parcel,
  p.blk_no as cadastrallotno,
  null as blockno,
  p.survey_no as surveyno,
  null as street,
  null as purok,
  p.prop_bound_north as north,
  p.prop_bound_south as south,
  p.prop_bound_east as east,
  p.prop_bound_west as west,
  b.brgyid as barangayid,
  'municipality' as lgutype,
  b.lguid as lguid
from rptis.h_property_info p, rptis.m_barangay b 
where p.prop_type_code = 'L'
and p.municipal_code = b.municipal_code
and p.brgy_code = b.brgy_code
;


insert ignore into training_etracs255.rpumaster (
  objid
)
select pin_no from rptis.h_property_info
;



/* create rpu info summary */
drop  table if exists zztmp_rpu_info
;

create table zztmp_rpu_info 
as 
select 
  a.trans_stamp as xrpuid,
	a.kind as rputype, 
	a.pin_no as fullpin, 
  sum(case 
		when a.kind = 'L' then a.area * 10000
		else a.area 
	end) as totalareasqm,
  sum(case 
		when a.kind = 'L' then a.area
		else a.area / 10000
	end) as totalareaha,
  sum(market_value) as totalmv,
  sum(assessed_value) as totalav
from rptis.p_ar a 
group by a.trans_stamp, a.kind, a.pin_no
;

create index ix_rpuid on zztmp_rpu_info(xrpuid)
;


/* UPDATE IMPROVEMENT xrpid */
create index ix_pinno on rptis.h_property_info(pin_no)
;
create index ix_rpid on rptis.h_property_info(xrpid)
;
create index ix_ref_land_pin_no on rptis.h_property_info(ref_land_pin_no)
;


update rptis.h_property_info i, rptis.h_property_info l set 
	i.xrpid = l.xrpid
where i.ref_land_pin_no = l.pin_no
and i.prop_type_code <> 'L'
and l.xrpid is not null 
;


alter table training_etracs255.rpu modify column fullpin varchar(25)
;

/* GENERATE SUFFIX */
alter table rptis.h_property_info  
	add suffix int
;

update rptis.h_property_info  set 
	suffix = right(replace(replace(trim(pin_no),'(', ''), ')', ''), 4)
where prop_type_code <> 'L'
;





insert ignore into training_etracs255.rpu (
  objid,
  state,
  realpropertyid,
  rputype,
  ry,
  fullpin,
  suffix,
  subsuffix,
  classification_objid,
  exemptiontype_objid,
  taxable,
  totalareaha,
  totalareasqm,
  totalbmv,
  totalmv,
  totalav,
  hasswornamount,
  swornamount,
  useswornamount,
  previd,
  rpumasterid,
  reclassed,
  isonline
)
select 
  p.trans_stamp as objid,
  case when p.pin_status = 'C' then 'CURRENT' else 'CANCELLED' end as state,
  p.xrpid as realpropertyid,
  case 
		when p.prop_type_code = 'L' then 'land' 
		when p.prop_type_code = 'B' then 'bldg' 
		when p.prop_type_code = 'M' then 'mach' 
		else 'planttree'
	end as rputype,
  @revisionyear as ry,
  trim(p.pin_no) as fullpin,
  p.suffix as suffix,
  null as subsuffix,
  'R' as classification_objid,
  null as exemptiontype_objid,
  1 as taxable,
  sum(case 
		when a.kind = 'L' then a.area
		else a.area / 10000
	end) as totalareaha,
  sum(case 
		when a.kind = 'L' then a.area * 10000
		else a.area 
	end) as totalareasqm,
  sum(a.market_value) as totalbmv,
  sum(a.market_value) as totalmv,
  sum(a.assessed_value) as totalav,
  0 as hasswornamount,
  0 as swornamount,
  0 as useswornamount,
  null as previd,
  p.pin_no as  rpumasterid,
  0 as reclassed,
  0 as isonline
from rptis.h_property_info p, rptis.p_ar a 
where p.trans_stamp = a.trans_stamp
group by p.trans_stamp 
;


/* MAPPING TXN TYPE */
alter table rptis.p_ar 
	add xtxntype varchar(5)
;

update rptis.p_ar  set 
	xtxntype = 
	case 
		when trans_code = 'R' then 'RE'
		when trans_code = 'RC' then 'CC'
		else trans_code
	end 
;



alter table training_etracs255.faas modify fullpin varchar(50)
;
alter table training_etracs255.faas_list modify pin varchar(50)
;
alter table training_etracs255.faas_list modify displaypin varchar(50)
;


insert ignore into training_etracs255.faas (
  objid,
  state,
  rpuid,
  datacapture,
  autonumber,
  utdno,
  tdno,
  txntype_objid,
  effectivityyear,
  effectivityqtr,
  titletype,
  titleno,
  titledate,
  taxpayer_objid,
  owner_name,
  owner_address,
  administrator_objid,
  administrator_name,
  administrator_address,
  memoranda,
  backtaxyrs,
  prevtdno,
  prevpin,
  prevowner,
  prevav,
  prevmv,
  cancelreason,
  canceldate,
  cancelledbytdnos,
  lguid,
  txntimestamp,
  cancelledtimestamp,
  name,
  dtapproved,
  realpropertyid,
  lgutype,
  ryordinanceno,
  ryordinancedate,
  prevareaha,
  prevareasqm,
  fullpin,
  preveffectivity,
  year,
  qtr,
  month,
  day,
  cancelledyear,
  cancelledqtr,
  cancelledmonth,
  cancelledday,
  originlguid
)
select distinct
  a.trans_stamp as objid,
  case when p.pin_status = 'C' then 'CURRENT' else 'CANCELLED' end as state,
  a.trans_stamp as rpuid,
  1 as datacapture,
  0 as autonumber,
  concat(a.arp_year, '-', a.municipal_code, '-', repeat('0', 4 - length(a.brgy_code)), a.brgy_code, '-', repeat('0', 5 - length(a.arp_count)), a.arp_count) as utdno,
  concat(a.arp_year, '-', a.municipal_code, '-', repeat('0', 4 - length(a.brgy_code)), a.brgy_code, '-', repeat('0', 5 - length(a.arp_count)), a.arp_count) as tdno,
  a.xtxntype as txntype_objid,
  year(s.effectivity) as effectivityyear,
  1 as effectivityqtr,
  null as titletype,
  p.title_reference as titleno,
  null as titledate,
  mo.xobjid as taxpayer_objid,
  a.owner_name,
  mo.owner_adderss,
  null as administrator_objid,
	concat(
		case when p.admtr_lname is null then '' else concat(p.admtr_lname, ', ') end,
		case when p.admtr_fname is null then '' else concat(p.admtr_fname, ' ') end,
		case when p.admtr_mi is null then '' else p.admtr_mi end
	) as  administrator_name,
	concat(
		case when p.admtr_house_no is null then '' else concat(p.admtr_house_no, ', ') end,
		case when p.admtr_street is null then '' else concat(p.admtr_street, ', ') end,
		case when p.admtr_barangay is null then '' else concat(p.admtr_barangay, ', ') end,
		case when p.admtr_municipality is null then '' else concat(p.admtr_municipality, ', ') end,
		case when p.admtr_province is null then '' else concat(p.admtr_province, ', ') end
	) as administrator_address,
  s.memoranda,
  0 as backtaxyrs,
  s.prev_td_no as prevtdno,
  s.prev_pin as prevpin,
  s.prev_owner as prevowner,
  s.prev_assessed_value as prevav,
  0 as prevmv,
  null as cancelreason,
  null as canceldate,
  null as cancelledbytdnos,
  b.lguid,
  null as txntimestamp,
  null as cancelledtimestamp,
  substring(a.owner_name,1, 10) as name,
  s.approved_date as dtapproved,
  p.xrpid as realpropertyid,
  'municipality' as lgutype,
  '' as ryordinanceno,
  null as ryordinancedate,
  0 as prevareaha,
  0 as prevareasqm,
  a.pin_no as fullpin,
  null as preveffectivity,
  year(s.approved_date) as year,
  quarter(s.approved_date) as qtr,
  month(s.approved_date) as month,
  day(s.approved_date) as day,
  null as cancelledyear,
  null as cancelledqtr,
  null as cancelledmonth,
  null as cancelledday,
  b.lguid as originlguid
from 
	rptis.p_ar a, 
	rptis.h_property_info p,
	rptis.d_owner o,
	rptis.m_owner mo,
	rptis.c_faas_summary s,
	rptis.m_barangay b 
where p.trans_stamp = a.trans_stamp
and p.trans_stamp = o.trans_stamp
and o.owner_code = mo.owner_code
and p.trans_stamp = s.trans_stamp
and b.brgy_code = p.brgy_code
and b.municipal_code = p.municipal_code
;


insert ignore into training_etracs255.faas_list(
	objid,
	state,
	datacapture,
	rpuid,
	realpropertyid,
	ry,
	txntype_objid,
	tdno,
	utdno,
	prevtdno,
	displaypin,
	pin,
	taxpayer_objid,
	owner_name,
	owner_address,
	administrator_name,
	administrator_address,
	rputype,
	barangayid,
	barangay,
	classification_objid,
	classcode,
	cadastrallotno,
	blockno,
	surveyno,
	titleno,
	totalareaha,
	totalareasqm,
	totalmv,
	totalav,
	effectivityyear,
	effectivityqtr,
	cancelreason,
	cancelledbytdnos,
	lguid,
	originlguid,
	yearissued,
	taskid,
	taskstate,
	assignee_objid,
	trackingno,
	publicland 
)
select 
	f.objid,
	f.state,
	f.datacapture, 
	f.rpuid,
	f.realpropertyid,
	r.ry,
	f.txntype_objid,
	f.tdno,
	f.utdno,
	f.prevtdno,
	f.fullpin as displaypin,
	case when r.rputype = 'land' then rp.pin else concat(rp.pin, '-', r.suffix) end as pin,
	f.taxpayer_objid,
	f.owner_name,
	f.owner_address,
	f.administrator_name,
	f.administrator_address,
	r.rputype,
	rp.barangayid,
	(select name from training_etracs255.barangay where objid = rp.barangayid) as barangay,
	r.classification_objid,
	pc.code as classcode,
	rp.cadastrallotno,
	rp.blockno,
	rp.surveyno,
	f.titleno,
	r.totalareaha,
	r.totalareasqm,
	r.totalmv,
	r.totalav,
	f.effectivityyear,
	f.effectivityqtr,
	f.cancelreason,
	f.cancelledbytdnos,
	f.lguid,
	f.originlguid,
	f.year as yearissued,
	null as taskid,
	null as taskstate,
	null as assignee_objid,
	null as trackingno,
	0 as publicland
from training_etracs255.faas f 
	inner join training_etracs255.rpu r on f.rpuid = r.objid 
	inner join training_etracs255.realproperty rp on f.realpropertyid = rp.objid 
	inner join training_etracs255.propertyclassification pc on r.classification_objid = pc.objid 
;

update training_etracs255.faas set fullpin = trim(fullpin)
;
update training_etracs255.faas_list set pin = trim(pin)
;
update training_etracs255.faas_list set displaypin= trim(displaypin)
;


update training_etracs255.landrysetting set 
	ordinanceno = '2012-070',
	ordinancedate = '2012-12-21'
;

update training_etracs255.bldgrysetting set 
	ordinanceno = '2012-070',
	ordinancedate = '2012-12-21'
;

update training_etracs255.machrysetting set 
	ordinanceno = '2012-070',
	ordinancedate = '2012-12-21'
;

update training_etracs255.planttreerysetting set 
	ordinanceno = '2012-070',
	ordinancedate = '2012-12-21'
;


/* RPU ASSESSMENT*/

alter table rptis.p_ar 
	add xoid varchar(50)
;

create unique index ux_oid on rptis.p_ar (xoid)
;

update rptis.p_ar set xoid = md5(concat(rand(),line_no))
;


delete from training_etracs255.rpu_assessment
;

insert ignore into training_etracs255.rpu_assessment (
  objid,
  rpuid,
  classification_objid,
  actualuse_objid,
  areasqm,
  areaha,
  marketvalue,
  assesslevel,
  assessedvalue,
  rputype,
  taxable
)
select 
	a.xoid as objid,
  a.trans_stamp as rpuid,
  a.class_group as classification_objid,
  al.xobjid as actualuse_objid,
  case 
		when a.kind = 'L' then a.area * 10000
		else a.area 
	end as areasqm,
  case 
		when a.kind = 'L' then a.area
		else a.area / 10000
	end as areaha,
  a.market_value as marketvalue,
  a.assmt_level * 100 as assesslevel,
  a.assessed_value as assessedvalue,
  case 
		when p.prop_type_code = 'L' then 'land' 
		when p.prop_type_code = 'B' then 'bldg' 
		when p.prop_type_code = 'M' then 'mach' 
		else 'planttree'
	end as rputype,
  case when a.taxability = 'T' then 1 else 0 end as taxable
from 
	rptis.p_ar a, 
	rptis.h_property_info p,
	rptis.m_assessment_levels al 
where p.trans_stamp = a.trans_stamp
and a.actual_use = al.class_code
and p.prop_type_code = al.prop_type_code
;

