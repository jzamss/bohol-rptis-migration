
/* BLDG SMV */


/*=================================================
IMPORTANT !!!  
    PLEASE SET BEFORE EXECUTING:
      @revisionyear
      @municipalcode
=================================================*/

set @revisionyear = 2016;
set @municipalcode = 42;
set @municlass = '1ST';


delete from training_etracs255.rysetting_lgu 
where lguid like concat('%', @municipalcode)
and settingtype = 'bldg';

delete from training_etracs255.bldgadditionalitem;
delete from training_etracs255.bldgassesslevelrange;
delete from training_etracs255.bldgassesslevel;
delete from training_etracs255.bldgkindbucc;
delete from training_etracs255.bldgtype_depreciation;
delete from training_etracs255.bldgtype_storeyadjustment_bldgkind;
delete from training_etracs255.bldgtype_storeyadjustment;
delete from training_etracs255.bldgtype;
delete from training_etracs255.bldgrysetting;



insert ignore into training_etracs255.bldgrysetting(
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
  concat('BR:',@municlass,':', @revisionyear) as objid,
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


insert ignore into training_etracs255.bldgassesslevel(
  objid,
  bldgrysettingid,
  classification_objid,
  code,
  name,
  fixrate,
  rate,
  previd
)
select distinct 
  concat('BRA:',@municlass,':', @revisionyear, ':', a.class_code) as objid,
  concat('BR:',@municlass,':', @revisionyear) as landrysettingid,
  c.class_group as classification_objid,
  c.class_code as code,
  c.class_desc as name,
  0 as fixrate,
  0 as rate,
  null as previd
from rptis.m_assessment_levels a, rptis.m_classification c 
where a.class_code = c.class_code
and a.prop_type_code = 'B'
and municipal_code = @municipalcode
;


update rptis.m_assessment_levels a, rptis.m_classification c set 
  a.xobjid = concat('BRA:',@municlass,':', @revisionyear, ':', a.class_code)
where a.class_code = c.class_code
and a.prop_type_code = 'B'
and municipal_code = @municipalcode
;



insert ignore into training_etracs255.bldgassesslevelrange(
  objid,
  bldgassesslevelid,
  bldgrysettingid,
  mvfrom,
  mvto,
  rate
)
select 
  concat('BRAR:',@municlass,':', @revisionyear, ':', a.class_code, ':', line_no) as objid,
	concat('BRA:',@municlass,':', @revisionyear, ':', a.class_code) as objid,
  concat('BR:',@municlass,':', @revisionyear) as landrysettingid,
  a.value_from as mvfrom,
  a.value_to as mvto,
  a.assessment_level * 100 as rate
from rptis.m_assessment_levels a, rptis.m_classification c 
where a.class_code = c.class_code
and a.prop_type_code = 'B'
and municipal_code = @municipalcode
;



update 
	rptis.m_assessment_levels a, 
	rptis.m_classification c 
set 
  a.xobjid = concat('BRAR:',@municlass,':', @revisionyear, ':', a.class_code, ':', line_no)
where a.class_code = c.class_code
and a.prop_type_code = 'B'
and municipal_code = @municipalcode
;



insert ignore into training_etracs255.bldgtype(
  objid,
  bldgrysettingid,
  code,
  name,
  basevaluetype,
  residualrate,
  previd,
  usecdu,
  storeyadjtype
)
select 
	concat('BT:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', '')) as objid,
  concat('BR:',@municlass,':', @revisionyear) as bldgrysettingid,
  struc_type as code,
  struc_desc as name,
  'gap' as basevaluetype,
  20 as residualrate,
  null as previd,
  0 as usecdu,
  'bykind' as storeyadjtype
from rptis.m_building_structure_type
;
  


alter table rptis.m_building_structure_type
	add xobjid varchar(50)
;


update rptis.m_building_structure_type set 
	xobjid = concat('BT:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', ''))
;




insert ignore into training_etracs255.bldgkindbucc(
  objid,
  bldgrysettingid,
  bldgtypeid,
  bldgkind_objid,
  basevaluetype,
  basevalue,
  minbasevalue,
  maxbasevalue,
  gapvalue,
  minarea,
  maxarea,
  bldgclass,
  previd
)
select 
  concat('BR:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', ''), ':', s.bldg_kind_code ) as objid,
  concat('BR:',@municlass,':', @revisionyear) as bldgrysettingid,
  concat('BT:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', '')) as bldgtypeid,
  s.bldg_kind_code as bldgkind_objid,
  'gap' as basevaluetype,
  0 as basevalue,
  s.min_amt as minbasevalue,
  s.max_amt as maxbasevalue,
  s.gap_amt as gapvalue,
  s.min_area as minarea,
  s.max_area as maxarea,
  null as bldgclass,
  null as previd
from rptis.m_building_structure_type st,
	rptis.m_sched_bldg_cost s
where st.struc_code = s.struc_code
and year_from = @revisionyear
;


alter table rptis.m_sched_bldg_cost
  add xobjid varchar(50)
;

update rptis.m_building_structure_type st,
	rptis.m_sched_bldg_cost s
set 
  s.xobjid = concat('BR:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', ''), ':', s.bldg_kind_code )
where st.struc_code = s.struc_code
and year_from = @revisionyear
;


insert ignore into training_etracs255.bldgtype_depreciation(
  objid,
  bldgtypeid,
  bldgrysettingid,
  agefrom,
  ageto,
  rate
)
select 
  concat('BTD:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', ''), ':', d.unique_code ) as objid,
  concat('BT:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', '')) as bldgtypeid,
  concat('BR:',@municlass,':', @revisionyear) as bldgrysettingid,
  d.stage_from as agefrom,
  d.stage_to as ageto,
  d.percent_depreciation as rate
from rptis.m_building_structure_type st,
	rptis.m_bldg_depreciation d
where st.struc_code = d.struc_code
;



insert ignore into training_etracs255.bldgtype_storeyadjustment(
  objid,
  bldgrysettingid,
  bldgtypeid,
  floorno,
  rate,
  previd
)
select 
  concat('BTSA:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', ''), ':', bldg_kind_code) as objid,
  concat('BR:',@municlass,':', @revisionyear) as bldgrysettingid,
  concat('BT:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', '')) as bldgtypeid,
  2 as floorno,
  a.percent_value as rate,
  null as previd
from rptis.m_building_structure_type st,
	rptis.m_addtnl_every_floor_bldg a
where st.struc_code = a.struc_code
;





alter table rptis.m_addtnl_every_floor_bldg
	add xobjid varchar(50)
;

update 
	rptis.m_building_structure_type st,
	rptis.m_addtnl_every_floor_bldg a
set 
  a.xobjid = concat('BTSA:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', ''), ':', bldg_kind_code)
where st.struc_code = a.struc_code
;




insert ignore into training_etracs255.bldgtype_storeyadjustment_bldgkind(
  objid,
  bldgrysettingid,
  parentid,
  bldgtypeid,
  floorno,
  bldgkindid
)
select 
  concat('BTSAB:',@municlass,':', @revisionyear, ':',  replace(struc_type, ' ', ''), ':', a.bldg_kind_code, ':', bldg_class_code) as objid,
  concat('BR:',@municlass,':', @revisionyear) as bldgrysettingid,
  concat('BTSA:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', ''), ':', bldg_kind_code) as parentid,
  concat('BT:',@municlass,':', @revisionyear, ':', replace(struc_type, ' ', '')) as bldgtypeid,
  2 as floorno,
  a.bldg_kind_code as bldgkindid
from rptis.m_building_structure_type st,
	rptis.m_addtnl_every_floor_bldg a
where st.struc_code = a.struc_code
;



alter table rptis.m_addtnl_every_floor_bldg
	add xstoreyadjkindid varchar(50)
;

update 
	rptis.m_building_structure_type st,
	rptis.m_addtnl_every_floor_bldg a
set 
  a.xstoreyadjkindid = concat('BTSAB:',@municlass,':', @revisionyear, ':', struc_type, ':', a.bldg_kind_code, ':', bldg_class_code)
where st.struc_code = a.struc_code
;



insert ignore into training_etracs255.bldgadditionalitem(
  objid,
  bldgrysettingid,
  code,
  name,
  unit,
  expr,
  previd,
  type,
  addareatobldgtotalarea,
  idx
)
select 
  concat('BR:',@municlass,':', @revisionyear,':', replace(i.extra_desc, ' ', '')) as objid,
  concat('BR:',@municlass,':', @revisionyear) as bldgrysettingid,
  i.extra_code as code,
  i.extra_desc as name,
  '' as unit,
  case 
		when i.buv_per_sqr_meter = 'B' then concat('SYS_BASE_VALUE * ', i.percent_amt_per_m2, ' * AREA_SQM')
		else concat('AREA SQM * ', i.percent_amt_per_m2)
	end as expr,
  null as previd,
  'additionalitem' as type,
  0 as addareatobldgtotalarea,
  1 as idx
from rptis.m_building_extra_items i
where i.year_from = @revisionyear
;


alter table rptis.m_building_extra_items 
	add xobjid varchar(100)
;

update rptis.m_building_extra_items i set 
	i.xobjid = concat('BR:',@municlass,':', @revisionyear,':', replace(i.extra_desc, ' ', '')) 
where i.year_from = @revisionyear
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
  'bldg' as settingtype,
  null as barangayid,
  (select name from training_etracs255.municipality) as lguname
from training_etracs255.bldgrysetting
;

