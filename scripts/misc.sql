/* check invalid suffix */
select * from h_property_info 
where prop_type_code <> 'L' 
and pin_no not regexp '.*[0-9][0-9][0-9][0-9]$'

set @pin_no:='047-46-0002-010-30-(1001)                       ';

select right(replace(replace(trim(@pin_no),'(', ''), ')', ''), 4);



/* check invalid section */
select section from h_property_info order by section desc limit 5;

/* INVALID BLDG DATE */
select  date_completed 
from h_bldg_gen_info 
where date_completed > year(now())
and date_completed < 1902

