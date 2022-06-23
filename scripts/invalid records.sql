

/* check invalid section */
select section from rptis.h_property_info order by section desc limit 5;

/* INVALID BLDG DATE */
select  date_completed 
from rptis.h_bldg_gen_info 
where date_completed > year(now())
and date_completed < 1902

/* INVALID SUBCLASS OR SPECIFIC CLASS */
select * from training_etracs255.landdetail 
where subclass_objid is null 
or specificclass_objid is null 
;
