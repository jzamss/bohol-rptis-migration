# Organization

## Goals

- Generate a unified organization structure based **objid** (primary key)

## Tables

- sys_orgclass
- sys_org
- province
- municipality
- barangay

## ERD

![alt Organization ERD][logo]

## Scripts (INITIAL DATABASE)

### Clear Organization Data

```
set foreign_key_checks=0;

delete from sys_org;
delete from barangay;
delete from municipality;
delete from province;

set foreign_key_checks=1;

```

### 1. sys_orgclass

** province **
``
/_ province data _/
insert into sys_org (
objid,
name,
orgclass,
parent_objid,
parent_orgclass,
code,
root,
txncode
)
select
'047' as objid,
'BOHOL' as name,
'PROVINCE' as orgclass,
null as parent_objid,
null as parent_orgclass,
'047' as code,
0 as root,
'047' as txncode
;

```

**municipality**

```

insert into sys_org (
objid,
name,
orgclass,
parent_objid,
parent_orgclass,
code,
root,
txncode
)
select
'04742' as objid,
'TALIBON' as name,
'MUNICIPALITY' as orgclass,
'047' as parent_objid,
'PROVINCE' as parent_orgclass,
'047-42' as code,
0 as root,
'04742' as txncode
;

```

*barangay*
```

select
concat('047',municipal_code, brgy_code) as objid,
brgy_desc as name,
'BARANGAY' as orgclass,
municipal_code as parent_objid,
'MUNICIPALITY' as parent_orgclass,
concat('047-',municipal_code,'-', repeat('0',4 - LENGTH(brgy_code)), brgy_code) as code,
0 as root,
concat('047-',municipal_code,'-', brgy_code) as txncode
from rptis_talibon.m_barangay  
;

```

### 2. sys_org

### 3. province

### 4. municipality

### 5. barangay

[logo]: images/erd-organization.png "Organization ERD"

```

```

```
