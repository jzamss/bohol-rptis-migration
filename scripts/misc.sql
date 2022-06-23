/* check invalid suffix */
select * from rptis.h_property_info 
where prop_type_code <> 'L' 
and pin_no not regexp '.*[0-9][0-9][0-9][0-9]$'

set @pin_no:='047-46-0002-010-30-(1001)                       ';

select right(replace(replace(trim(@pin_no),'(', ''), ')', ''), 4);

