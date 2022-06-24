/* BLDG DEPRECIATION */
/*======================================================
NOTE:
  * objid - primary key
  * bldgrpuid - links to trans_stamp
  * basemarketvalue - basis for depreciation
  * deprate - deprecation rate
  * depreciation - computed depreciation
======================================================*/

create view etracs_bldgfloor_depreciation
as
select
  '' as objid,
  '' as bldgrpuid,
  0 as year,
  0 as basemarketvalue,
  0 as deprate,
  0 as depreciation
from 