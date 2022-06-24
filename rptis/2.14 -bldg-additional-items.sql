/* BLDG FLOOR ADDITIONAL/EXTRAS */

/*======================================================
NOTE:
  * objid - primary key
  * bldgfloorid - links to bldgfloor table
  * bldgrpuid - links to trans_stamp
  * additionalitem_objid - links to bldg extra master
  * expr - set to ''
  * issystem - set to 0
======================================================*/


create view etracs_bldgfloor_additional
as
select
  '' as objid,
  '' as bldgfloorid,
  '' as bldgrpuid,
  '' as additionalitem_objid,
  0 as amount,
  '' as expr,
  0 as depreciate,
  0 as issystem
from 