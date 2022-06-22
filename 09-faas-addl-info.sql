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

insert into training_etracs255.landdetail (
  objid,
  appraiser_name ,
  appraiser_title,
  appraiser_dtsigned ,
  recommender_name ,
  recommender_title,
  recommender_dtsigned ,
  approver_name,
  approver_title ,
  approver_dtsigned
)
select 
  p.trans_stamp as objid,
  s.appraised_by as appraiser_name ,
  '' as appraiser_title,
  s.appraised_date as appraiser_dtsigned ,
  s.recommending_approv as recommender_name ,
  '' as recommender_title,
  s.recommending_date as recommender_dtsigned ,
  s.approved_by as approver_name,
  '' as approver_title ,
  s.approved_date as approver_dtsigned
from 
	rptis_talibon.h_property_info p,
	rptis_talibon.c_faas_summary s
where p.trans_stamp = s.trans_stamp
and p.trans_stamp = @transid
;


/* PREVIOUS INFORMATION */
insert into training_etracs255.faas_previous (
  objid,
  faasid,
  prevfaasid,
  prevrpuid,
  prevtdno,
  prevpin,
  prevowner,
  prevadministrator,
  prevav,
  prevmv,
  prevareasqm,
  prevareaha,
  preveffectivity,
  prevtaxability
)
select 
  p.trans_stamp as objid,
  p.trans_stamp as faasid,
  null as prevfaasid,
  null as prevrpuid,
  s.prev_td_no as prevtdno,
  s.prev_pin as  prevpin,
  s.prev_owner as prevowner,
  null as prevadministrator,
  s.prev_assessed_value as prevav,
  null as prevmv,
  null as prevareasqm,
  null as prevareaha,
  null as preveffectivity,
  null as prevtaxability
from 
	rptis_talibon.h_property_info p,
	rptis_talibon.c_faas_summary s
where p.trans_stamp = s.trans_stamp
;



