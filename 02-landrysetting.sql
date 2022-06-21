/*=====================================================================
* STEPS:
*    1. REPLACE ALL instances of "training_etracs255" with 
*       the actual ETRACS db name
*    2. REPLACE ALL instances of "rptis." with the actual RPTIS Database
*       Name such as "rptis_talibon."
*    3. Execute ALL script by pressing CTRL + R

IMPORTANT !!!  
    PLEASE SET BEFORE EXECUTING:
      @revisionyear
      @municipalcode
      @municlass

======================================================================*/


set @revisionyear = 2016;
set @municipalcode = 42;
set @municlass = '1ST';



delete from training_etracs255.rysetting_lgu 
where lguid like concat('%', @municipalcode)
and settingtype = 'land';

delete from training_etracs255.landadjustmenttype_classification;
delete from training_etracs255.landadjustmenttype;
delete from training_etracs255.landassesslevelrange;
delete from training_etracs255.landassesslevel;
delete from training_etracs255.lcuvstripping;
delete from training_etracs255.lcuvsubclass;
delete from training_etracs255.lcuvspecificclass;
delete from training_etracs255.landrysetting;

insert ignore into training_etracs255.landrysetting(
  objid,
  state,
  ry,
  appliedto,
  previd,
  remarks,
  ordinanceno,
  ordinancedate
)
select
  concat('LR:',@municlass,':', @revisionyear) as objid,
  'APPROVED' as state,
  @revisionyear as ry,
  m.municipal_desc as appliedto,
  null as previd,
  null as remarks,
  '' as ordinanceno,
  null as ordinancedate
from rptis.m_municipality m
where m.municipal_code = @municipalcode
;



update rptis.m_assessment_levels set municipal_code = @municipalcode
;



insert ignore into training_etracs255.landassesslevel(
  objid,
  landrysettingid,
  classification_objid,
  code,
  name,
  fixrate,
  rate,
  previd
)
select
  concat('LRA:',@municlass,':', @revisionyear, '-',c.class_code) as objid,
  concat('LR:',@municlass,':', @revisionyear) as landrysettingid,
  (select objid from training_etracs255.propertyclassification where objid = c.class_group) as classification_objid,
  c.class_code as code,
  c.class_desc as name,
  case when a.value_from is null then 1 else 0 end as fixrate,
  a.assessment_level * 100 as rate,
  null as previd
from rptis_talibon.m_assessment_levels a
left join rptis_talibon.m_classification c on a.class_code = c.class_code
where a.prop_type_code = 'L'
and municipal_code = @municipalcode
;



alter table rptis.m_assessment_levels 
	add xobjid varchar(50)
;

update 
	rptis.m_assessment_levels a, 
	rptis.m_classification c
set 
  a.xobjid = concat('LRA:',@municlass,':', @revisionyear, '-',c.class_code)
where a.class_code = c.class_code
and a.prop_type_code = 'L'
and municipal_code = @municipalcode
;


insert ignore into training_etracs255.lcuvspecificclass(
  objid,
  landrysettingid,
  classification_objid,
  areatype,
  previd,
  landspecificclass_objid
)
select
  concat('LRSPC:',@municlass,':', @revisionyear, ':', class_code) as objid,
  concat('LR:',@municlass,':', @revisionyear) as landrysettingid,
  class_group as classification_objid,
  case when class_group = 'A' then 'HA' else 'SQM' end  areatype,
  null as previd,
  class_code as  landspecificclass_objid
from rptis.m_classification
;



alter table rptis.m_classification 
	add xobjid varchar(50)
;

update rptis.m_classification set 
  xobjid = concat('LRSPC:',@municlass,':', @revisionyear, ':', class_code)
;


insert ignore into training_etracs255.lcuvsubclass(
  objid,
  specificclass_objid,
  landrysettingid,
  code,
  name,
  unitvalue,
  previd
)
select
  concat('LRSUB:',@municlass,':', @revisionyear, ':', c.sub_class_code, ':', v.class_level_code) as objid,
	concat('LRSPC:',@municlass,':', @revisionyear, ':', c.class_code) as specificclass_objid,
  concat('LR:',@municlass,':', @revisionyear) as landrysettingid,
  concat(c.sub_class_code, substring(v.class_level_code, 1,1)) as code,
  concat(v.class_level_code, ' CLASS') as name,
  v.class_level_amt as unitvalue,
  null as previd
from rptis.m_classification c
inner join rptis.m_unit_value v on c.class_code = v.class_code
;

alter table rptis.m_unit_value 
	add xobjid varchar(50),
	add xspcid varchar(50)
;

update 
	rptis.m_classification c,
	rptis.m_unit_value v 
set 
  v.xobjid = concat('LRSUB:',@municlass,':', @revisionyear, ':', c.sub_class_code, ':', v.class_level_code),
	v.xspcid = concat('LRSPC:',@municlass,':', @revisionyear, ':', c.class_code)
where c.class_code = v.class_code
;




insert ignore into training_etracs255.landadjustmenttype(
  objid,
  landrysettingid,
  code,
  name,
  expr,
  appliedto,
  previd,
  idx
)
select  distinct 
  concat('LRAT:',@municlass,':', @revisionyear, ':', replace(f.adjustment_desc,' ', '')) as objid,
  concat('LR:',@municlass,':', @revisionyear) as landrysettingid,
  substr(f.adjustment_desc, 1, 5) as code,
  f.adjustment_desc as name,
	case 
		when f.value_adj is null then 0 
		else concat('SYS_BASE_MARKET_VALUE * ', f.value_adj) 
	end as expr,
  null as appliedto,
  null as previd,
  0 as idx
from rptis.m_adjustment_factor f, 
	rptis.m_adjustment_type a,
	rptis.m_classification c, 
	rptis.m_prop_classification p
where f.adj_type_code = a.adj_type_code
and f.class_code = c.class_code
and c.class_group = p.prop_class_code
and f.adj_type_code <> 55
;

alter table rptis.m_adjustment_factor 
	add xobjid varchar(50)
;


update rptis.m_adjustment_factor f, 
	rptis.m_adjustment_type a,
	rptis.m_classification c, 
	rptis.m_prop_classification p
set 
  f.xobjid = concat('LRAT:',@municlass,':', @revisionyear, ':', replace(f.adjustment_desc,' ', ''))
where f.adj_type_code = a.adj_type_code
and f.class_code = c.class_code
and c.class_group = p.prop_class_code
and f.adj_type_code <> 55
;





insert ignore into training_etracs255.rysetting_lgu(
  objid,
  rysettingid,
  lguid,
  settingtype,
  barangayid,
  lguname
)
select  
  objid,
  objid as rysettingid,
  (select objid from training_etracs255.municipality) as lguid,
  'land' as settingtype,
  null as barangayid,
  (select name from training_etracs255.municipality) as lguname
from training_etracs255.landrysetting
;




