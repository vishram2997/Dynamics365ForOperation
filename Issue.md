#Error : Object Server Database Synchronizer: 
The internal system table version number stored in the database is higher than the version supported by the kernel (145/144). Use a newer Microsoft Dynamics 365 for Finance and Operations kernel, or start Microsoft Dynamics 365 for Finance and Operations using the -REPAIR command line parameter to enforce synchronization.

Solution : open SSMS and check sqlsytemvariables table parm 'SysTabVersion'. set it to required version

UPDATE SQLSYSTEMVARIABLES 
SET 
value =144
where PARM='SYSTABVERSION'
