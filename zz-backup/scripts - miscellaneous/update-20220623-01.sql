update 
	training_etracs255.faas f, rptis_talibon.h_property_info p
set
	f.titleno = p.title_reference 
where f.objid = p.trans_stamp
;

update training_etracs255.faas_list f, rptis_talibon.h_property_info p
set
	f.titleno = p.title_reference 
where f.objid = p.trans_stamp
;

