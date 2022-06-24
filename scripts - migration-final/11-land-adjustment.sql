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


delete from training_etracs255.landadjustment
;

drop table if exists rptis.zztmp_landadjustment
;

create table rptis.zztmp_landadjustment
as
select
	p.trans_stamp as rpuid,
	a.xoid as landdetailid,
	adj.xobjid as adjtypeid,
	a.line_no,
	sum(va.market_value) as bmv,
	sum(value_adjustment) as adjustment,
	sum(va.adjusted_market_value) as mv
from 
	rptis.h_property_info p, 
	rptis.d_land_appraisal a,
	rptis.c_value_adjustment va,
	rptis.m_adjustment_factor adj,
 	rptis.m_adjustment_type t
where p.trans_stamp = a.trans_stamp
and p.trans_stamp = va.trans_stamp
and a.actual_use = va.class_code
and a.line_no = va.line_no
and va.adj_type_code = adj.adj_type_code
and va.adjustment_code = adj.adjustment_code
and adj.adj_type_code = t.adj_type_code
group by 
	p.trans_stamp,
	a.xoid,
	adj.xobjid, 
	a.line_no
;


create index ix_rpuid on rptis.zztmp_landadjustment(rpuid);
create index ix_landdetailid on rptis.zztmp_landadjustment(landdetailid);
create index ix_line_no on rptis.zztmp_landadjustment(line_no);
	
alter table rptis.zztmp_landadjustment 
	add objid varchar(50)
;

create index ix_objid on rptis.zztmp_landadjustment(objid);

update rptis.zztmp_landadjustment  set objid = md5(concat(rand(),line_no))
;


insert ignore into training_etracs255.landadjustment (
  objid,
  landrpuid,
  landdetailid,
  adjustmenttype_objid,
  expr,
  adjustment,
  type,
  basemarketvalue,
  marketvalue
)
select 
  objid,
  rpuid as landrpuid,
  landdetailid,
  adjtypeid as adjustmenttype_objid,
  '' as expr,
  adjustment,
  'LV' as type,
  bmv as basemarketvalue,
  mv as marketvalue
from rptis.zztmp_landadjustment   
;