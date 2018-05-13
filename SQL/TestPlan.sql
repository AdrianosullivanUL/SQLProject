-- -------------------------------------------------------
-- est plan for engine_management
-- -------------------------------------------------------

-- ***Following should produce error***
-- this serial number enrollment/disposal period overlaps with an existing entry for this serial number
start transaction;
insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) 
values ('123456', (select engine_model_id from engine_model where model_name = 'CFM56-5A'), STR_TO_DATE('01/02/2013', '%d/%m/%Y'), null);
rollback;

-- ***Following should produce error:****
-- Error Code: 1644. The engine model for this entry is does not exist or is not active
SET SQL_SAFE_UPDATES = 0;
start transaction;
update engine_model a
	join engine_model b on a.engine_model_id = b.engine_model_id
	set a.active = 0
	where b.model_name = 'CFM56-5A'; 
insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) 
	values ('123456A', (select engine_model_id from engine_model where model_name = 'CFM56-5A'), STR_TO_DATE('01/02/2013', '%d/%m/%Y'), null);
rollback;
SET SQL_SAFE_UPDATES = 1;

-- Execute stored procedure to generate billing entries
-- ***Following will produce error "No rate found for engine usage entry id" for engine usage id 5
CALL `engine_management`.`generate_maintenance_reserve_billing`(2018, 04);

-- Execute stored procedure to validate billing
CALL `engine_management`.`check_maintenance_reserve_billing`(2018, 03);
CALL `engine_management`.`check_maintenance_reserve_billing`(2018, 04);


-- Show the annual useage per company and billing charges
select * from Company_annual_Usage_view ;
        
-- Showing the average monthly cycles per engine model/year
select * from engine_model_average_cycles_view;
    
-- Show the Current location of each engine on lease    
select * from current_engine_locations_view;
