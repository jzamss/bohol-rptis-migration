/*=====================================================================
* MASTER FILES 
*
* STEPS:
*    1. REPLACE ALL instances of "training_etracs255" with 
*       the actual ETRACS db name
*    2. REPLACE ALL instances of "rptis." with the actual RPTIS Database
*       Name such as "rptis_talibon."
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


insert into training_etracs255.propertyclassification(
  objid,
  state,
  code,
  name,
  special,
  orderno
)
select 
  prop_class_code as objid,
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
  prop_class_code as objid,
  'APPROVED' as state,
  prop_class_code  as code,
  prop_class_desc as name,
  ifnull(class_order,100) as orderno
from rptis.m_prop_classification
where taxability ='E'
;  

insert into training_etracs255.landspecificclass(
  objid,
  state,
  code,
  name
)
select 
  class_code as objid,
  'APPROVED' as state,
  class_code as code,
  class_desc as name
from rptis.m_classification
;  

insert into training_etracs255.bldgkind(
  objid,
  state,
  code,
  name
)
select 
  bldg_kind_code as objid,
  'APPROVED' as state,
  bldg_kind_code as code,
  bldg_kind_desc as name
from rptis.m_building_kinds
;  

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


insert ignore into training_etracs255.structure(
  objid,
  state,
  code,
  name
)
select
  bldg_components_desc as objid,
  'APPROVED' as state,
  bldg_components_code code,
  bldg_components_desc as name
from rptis.m_building_components
;  


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

