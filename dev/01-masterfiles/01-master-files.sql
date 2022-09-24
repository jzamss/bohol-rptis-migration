/*=====================================================================
* MASTER FILES 
*
* STEPS:
*    1. REPLACE ALL instances of "training_etracs255" with 
*       the actual ETRACS db name
*    2. REPLACE ALL instances of "rptis." with the actual RPTIS Database
*       Name such as "rptis."
*    3. Execute ALL script by pressing CTRL + R
======================================================================*/



/* MASTER DATA */
delete from training_etracs255.rysetting_lgu;

delete from training_etracs255.landadjustmenttype_classification;
delete from training_etracs255.landadjustmenttype;
delete from training_etracs255.landassesslevelrange;
delete from training_etracs255.landassesslevel;
delete from training_etracs255.lcuvstripping;
delete from training_etracs255.lcuvsubclass;
delete from training_etracs255.lcuvspecificclass;
delete from training_etracs255.landrysetting;

delete from training_etracs255.bldgadditionalitem;
delete from training_etracs255.bldgassesslevelrange;
delete from training_etracs255.bldgassesslevel;
delete from training_etracs255.bldgkindbucc;
delete from training_etracs255.bldgtype_depreciation;
delete from training_etracs255.bldgtype_storeyadjustment_bldgkind;
delete from training_etracs255.bldgtype_storeyadjustment;
delete from training_etracs255.bldgtype;
delete from training_etracs255.bldgrysetting;

delete from training_etracs255.machforex;
delete from training_etracs255.machassesslevelrange;
delete from training_etracs255.machassesslevel;
delete from training_etracs255.machrysetting;

delete from training_etracs255.planttreeunitvalue;
delete from training_etracs255.planttreeassesslevel;
delete from training_etracs255.planttreerysetting;


delete from training_etracs255.miscitemvalue;
delete from training_etracs255.miscassesslevelrange;
delete from training_etracs255.miscassesslevel;
delete from training_etracs255.miscrysetting;


delete from training_etracs255.propertyclassification;
delete from training_etracs255.exemptiontype;
delete from training_etracs255.canceltdreason;
delete from training_etracs255.machine;
delete from training_etracs255.bldgkind;
delete from training_etracs255.landspecificclass;
delete from training_etracs255.structurematerial;
delete from training_etracs255.structure;
delete from training_etracs255.material;
delete from training_etracs255.planttree;
delete from training_etracs255.miscitem;
delete from training_etracs255.rptparameter;


/* ADD objid as etracs reference field */
alter table rptis.m_prop_classification add objid varchar(50);
update rptis.m_prop_classification set objid = prop_class_desc;

insert into training_etracs255.propertyclassification(
  objid,
  state,
  code,
  name,
  special,
  orderno
)
select 
  objid,
  'APPROVED' as state,
  prop_class_code  as code,
  prop_class_desc as name,
  case when prop_class_code like 'S%' then 1 else 0 end as special,
  class_order as orderno
from rptis.m_prop_classification
where taxability ='T'
;


insert into training_etracs255.exemptiontype(
  objid,
  state,
  code,
  name,
  orderno
)
select 
  objid,
  'APPROVED' as state,
  prop_class_code  as code,
  prop_class_desc as name,
  ifnull(class_order,100) as orderno
from rptis.m_prop_classification
where taxability ='E'
;  


/* ADD objid as etracs reference field */
alter table rptis.m_classification add objid varchar(50);
update rptis.m_classification set objid = class_desc;

insert into training_etracs255.landspecificclass(
  objid,
  state,
  code,
  name
)
select 
  objid,
  'APPROVED' as state,
  class_code as code,
  class_desc as name
from rptis.m_classification
;  

/* ADD objid as etracs reference field */
alter table rptis.m_building_kinds add objid varchar(50);
update rptis.m_building_kinds set objid = concat('SBK-',MD5(bldg_kind_desc));

insert into training_etracs255.bldgkind(
  objid,
  state,
  code,
  name
)
select 
  objid,
  'APPROVED' as state,
  bldg_kind_code as code,
  bldg_kind_desc as name
from rptis.m_building_kinds
;  

/* ADD objid as etracs reference field */
alter table rptis.m_building_materials add objid varchar(50);
update rptis.m_building_materials set objid = concat('SL-',MD5(bldg_matls_desc));

insert ignore into training_etracs255.material(
  objid,
  state,
  code,
  name
)
select 
  bldg_matls_desc as objid,
  'APPROVED' as state,
  bldg_matls_code as code,
  bldg_matls_desc as name
from rptis.m_building_materials 
where bldg_matls_desc in(
	select DISTINCT bldg_matls_desc from rptis.m_building_materials 
)
;  


/* ADD objid as etracs reference field */
alter table rptis.m_building_components add objid varchar(50);
update rptis.m_building_components set objid = bldg_components_desc;

insert into training_etracs255.structure (
  objid,
  state,
  code,
  name,
  indexno,
  showinfaas
)
select 
  xobjid as objid,
  'APPROVED' as state,
  substring(bldg_components_desc, 1, 8) as code,
  bldg_components_desc as name,
  ifnull(order_no,100) as indexno,
  case 
		when bldg_components_desc = 'ROOF' then 1 
		when bldg_components_desc = 'FLOORING' then 1 
		when bldg_components_desc = 'WALL' then 1 
		else 0
	end as showinfaas
from rptis.m_building_components 
;


/* ADD objid as etracs reference field */
alter table rptis.m_machine_type add objid varchar(50);
update rptis.m_machine_type set objid = mach_type_desc;

insert ignore into training_etracs255.machine(
  objid,
  state,
  code,
  name
)
select
  mach_type_desc as objid,
  'APPROVED' as state,
  mach_type_code as code,
  mach_type_desc as name
from rptis.m_machine_type
;


/* ADD objid as etracs reference field */

alter table rptis.m_plants_trees_entry add objid varchar(50);
update rptis.m_plants_trees_entry set objid = plant_desc;

insert ignore into training_etracs255.planttree(
  objid,
  state,
  code,
  name
)
select
  plant_desc as objid,
  'APPROVED' as state,
  plant_code as code,
  plant_desc as name
from rptis.m_plants_trees_entry
;

