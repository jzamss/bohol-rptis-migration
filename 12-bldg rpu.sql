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


insert into training_etracs255.bldgrpu (
  objid,
  landrpuid,
  permitno,
  permitdate,
  basevalue,
  dtcompleted,
  dtoccupied,
  floorcount,
  depreciation,
  depreciationvalue,
  totaladjustment,
  bldgage,
  percentcompleted,
  assesslevel,
  bldgclass,
  effectiveage,
  dtconstructed,
  occpermitno,
	condominium
)
select 
  b.trans_stamp as objid,
  null as landrpuid,
  b.bldg_permit as permitno,
  null as permitdate,
  0 as basevalue,
  case 
    when b.date_completed <= year(now()) and b.date_completed >= 1800
      then concat(b.date_completed, '-01-01') 
      else null
    end  as dtcompleted,
  case 
    when b.date_occupied <= year(now()) and b.date_occupied >= 1800
      then concat(b.date_occupied, '-01-01') 
      else null
    end as dtoccupied,
  ifnull(b.no_of_storeys,1) as floorcount,
  0 as depreciation,
  0 as depreciationvalue,
  0 as totaladjustment,
  ifnull(b.bldg_age,0) as bldgage,
  100 as percentcompleted,
  0 as assesslevel,
  null as bldgclass,
  ifnull(b.bldg_age,0) as effectiveage,
  case 
    when b.date_constructed <= year(now()) and b.date_constructed >= 1800
      then concat(b.date_constructed, '-01-01') 
      else null
    end as dtconstructed,
  null as occpermitno,
	0 as condominium
from 
	rptis.h_property_info p,
	rptis.h_bldg_gen_info b
where p.trans_stamp = b.trans_stamp 
and p.prop_type_code = 'B'
and exists(select * from rptis.p_ar where trans_stamp = p.trans_stamp)
;


