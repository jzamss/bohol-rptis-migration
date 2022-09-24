/*======================================================= 
* FOR EXISTING INSTALLATION
=======================================================*/
-- RPTIS DATABASE

/* add etracs target reference fields */
alter table rptis.m_barangay 
	add lguid varchar(50),
	add brgyid varchar(50)
;

update rptis.m_barangay set 
	lguid = concat('047-', repeat('0', 2 - LENGTH(municipal_code)), municipal_code ),
	brgyid = concat('047-',repeat('0', 2 - LENGTH(municipal_code)), municipal_code,'-', repeat('0',4 - LENGTH(brgy_code)), brgy_code)
;







