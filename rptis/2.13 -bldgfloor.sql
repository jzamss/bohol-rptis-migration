/* BLDG FLOOR INFORMATION */

/*======================================================
NOTE:
  * objid - primary key
  * bldguseid - links to bldguse.objd, set to ''
  * bldgrpuid - links to trans_stamp
  * storeyrate - storey adjustment rate
======================================================*/

create view etracs_bldgfloor 
as
select
  '' as objid,
  '' as bldguseid,
  '' as bldgrpuid,
  1 as floorno,
  0 as area,
  0 as storeyrate,
  0 as basevalue,
  0 as unitvalue,
  0 as basemarketvalue,
  0 as adjustment,
  0 as marketvalue
from 