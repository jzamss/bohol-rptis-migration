/* BLDG FLOOR ADDITIONAL/EXTRAS */
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