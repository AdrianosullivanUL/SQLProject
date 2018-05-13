-- -------------------------------------------------------
-- Create triggers for engine_management
-- -------------------------------------------------------
-- Select the schema
USE engine_management;

-- Create before insert for engine trigger
-- -------------------------------------------------------
drop trigger if exists engine_management.before_engine_insert;
delimiter |
create trigger before_engine_insert 
before insert on engine 
	for each row 
	begin
    	declare overlap_count int;
        declare check_engine_model int;
		-- find existing entries for this serial number and make sure no overlaps exist
		-- note: engines can be enrolled, disposed and then re-enrolled         
		set overlap_count = (select count(*) from engine
									where engine_serial_number = new.engine_serial_number
									and ((new.enrolement_date >= enrolement_date and (new.enrolement_date <= disposal_date or isnull(disposal_date))
										  or new.disposal_date >= enrolement_date and (new.disposal_date <= disposal_date or isnull(disposal_date)))
									or (new.enrolement_date < enrolement_date and (new.disposal_date <= disposal_date or isnull(new.disposal_date))))
							);
		if overlap_count > 0 then                   
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "this serial number enrollment/disposal period overlaps with an existing entry for this serial number";
		end if;
        
		-- A new engine cannot be assigned to an engine model that is not active         
		set check_engine_model = (select count(*) from engine_model
										  where engine_model_id = new.engine_model_id and active = true);
		if check_engine_model = 0 then                   
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "The engine model for this entry is does not exist or is not active";
		end if;                              
	end; 
|
delimiter ;
    



-- Create before update for engine trigger
-- -------------------------------------------------------
drop trigger if exists engine_management.before_engine_update;

delimiter |
create trigger before_engine_update
before update on engine 
	for each row 
	begin
    	declare overlap_count int;
        declare check_engine_model int;
		-- find existing entries for this serial number and make sure no overlaps exist
		-- note: engines can be enrolled, disposed and then re-enrolled         
		set overlap_count = (select count(*) from engine
									where engine_serial_number = new.engine_serial_number
									and ((new.enrolement_date >= enrolement_date and (new.enrolement_date <= disposal_date or isnull(disposal_date))
										  or new.disposal_date >= enrolement_date and (new.disposal_date <= disposal_date or isnull(disposal_date)))
									or (new.enrolement_date < enrolement_date and (new.disposal_date <= disposal_date or isnull(new.disposal_date))))
							);
		if overlap_count > 0 then                   
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "this serial number enrollment/disposal period overlaps with an existing entry for this serial number";
		end if;
end
|
delimiter ;