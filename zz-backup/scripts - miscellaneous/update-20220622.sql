/* LAND DETAIL SPECIFIC CLASS */

update training_etracs255.landdetail ld, rptis_talibon.m_classification mc set 
	ld.landspecificclass_objid = mc.class_code
where ld.landspecificclass_objid = mc.xobjid
;