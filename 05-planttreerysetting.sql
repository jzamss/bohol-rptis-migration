/* PLANT/TREE SMV */


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
and settingtype = 'planttree';

delete from training_etracs255.planttreeunitvalue;
delete from training_etracs255.planttreeassesslevel;
delete from training_etracs255.planttreerysetting;



insert ignore into training_etracs255.planttreerysetting(
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
  concat('PR:',@municlass,':', @revisionyear) as objid,
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




insert ignore into training_etracs255.planttreeassesslevel(
  objid,
  planttreerysettingid,
  classification_objid,
  code,
  name,
  fixrate,
  rate,
  previd
)
select distinct 
  concat('PA:',@municlass,':', @revisionyear, ':', a.class_code) as objid,
  concat('PR:',@municlass,':', @revisionyear) as planttreerysettingid,
  c.class_group as classification_objid,
  c.class_code as code,
  c.class_desc as name,
  1 as fixrate,
  assessment_level * 100 as rate,
  null as previd
from rptis.m_assessment_levels a, rptis.m_classification c 
where a.class_code = c.class_code
and a.prop_type_code = 'P'
and municipal_code = @municipalcode
;


update rptis.m_assessment_levels a, rptis.m_classification c set 
  a.xobjid = concat('PA:',@municlass,':', @revisionyear, ':', a.class_code)
where a.class_code = c.class_code
and a.prop_type_code = 'P'
and municipal_code = @municipalcode
;



insert ignore into training_etracs255.planttreeunitvalue(
  objid,
  planttreerysettingid,
  planttree_objid,
  code,
  name,
  unitvalue,
  previd
)
select  
  concat('PR:',@municlass,':', @revisionyear, ':', replace(t.plant_desc, ' ', ''), ':', tu.class_level_code) as objid,
  concat('PR:',@municlass,':', @revisionyear) as planttreerysettingid,
  t.plant_desc as planttree_objid,
  concat(tu.plant_code, '-', substr(tu.class_level_code, 1,1)) as code,
  concat(tu.class_level_code, ' CLASS') as name,
  tu.value_for_every_unit as unitvalue,
  null as previd
from rptis.m_plants_trees tu, rptis.m_plants_trees_entry t
where tu.plant_code = t.plant_code 
;


alter table rptis.m_plants_trees 
	add xobjid varchar(50)
;

update rptis.m_plants_trees tu, rptis.m_plants_trees_entry t set 
  tu.xobjid = concat('PR:',@municlass,':', @revisionyear, ':', replace(t.plant_desc, ' ', ''), ':', tu.class_level_code) 
where tu.plant_code = t.plant_code 
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
  'planttree' as settingtype,
  null as barangayid,
  (select name from training_etracs255.municipality) as lguname
from training_etracs255.planttreerysetting
;



