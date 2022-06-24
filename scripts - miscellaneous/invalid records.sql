

/* check invalid section */
select section from rptis.h_property_info order by section desc limit 5;

/* INVALID BLDG DATES */
select  date_completed 
from rptis.h_bldg_gen_info 
where date_completed > year(now())
and date_completed < 1800
;

select  date_occupied 
from rptis.h_bldg_gen_info 
where date_occupied > year(now())
and date_occupied < 1800
;

select  date_constructed 
from rptis.h_bldg_gen_info 
where date_constructed > year(now())
and date_constructed < 1800
;



/* INVALID SUBCLASS OR SPECIFIC CLASS */
select * from training_etracs255.landdetail 
where subclass_objid is null 
or specificclass_objid is null 
;


/* BLDG INDVALID FLOORS */
select * from rptis_talibon.d_bldg_floor
where floor_no not REGEXP '[0-9]+'
;