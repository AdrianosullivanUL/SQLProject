-- -------------------------------------------------------
-- Create Stored Procedures
-- -------------------------------------------------------

-- Select the schema
USE engine_management;
-- Report Maintenace Reserve Billing issues for period
-- ----------------------------------------------------
DROP PROCEDURE if exists `engine_management`.`check_maintenance_reserve_billing` ;
 
DELIMITER //
 create procedure  check_maintenance_reserve_billing(prm_year int, prm_month int )
BEGIN

SELECT 	c1.company_name,
		co1.country_name,
		l1.lease_reference,
        e1.engine_serial_number,
		eu1.year,
		eu1.month,
		eu1.cycles,
		0 as usage_charge,
		0 as harsh_environment_charge,
		co1.harsh_environment,
        co1.harsh_environment_loading,
        'Billing not Generated' as message
FROM engine_management.engine_usage eu1
   join operation o1 on o1.operation_id = eu1.operation_id
    join lease l1 on l1.lease_id = o1.lease_id
    join engine e1 on e1.engine_id = l1.engine_id
    join engine_management.customer c1 on c1.customer_id = l1.customer_id
    join country co1 on co1.country_id = c1.country_id
  where eu1.billing_generated = false
    -- and eu1.year = prm_year and eu1.month = prm_month
    and eu1.year = 2018 and eu1.month = 4
 and eu1.engine_usage_id not in (select distinct engine_usage_id from maintenance_reserve_billing)
 union
 select c.company_name,
		co.country_name,
		l.lease_reference,
        e.engine_serial_number,
			eu.year,
			eu.month,
			eu.cycles,
			mrb.usage_charge,
			mrb.harsh_environment_charge,
		mrb.harsh_environment,
        co.harsh_environment_loading,
        'Billing not processed' as message
    from maintenance_reserve_billing mrb
    join engine_usage eu on eu.engine_usage_id = mrb.engine_usage_id 
    join operation o on o.operation_id = eu.operation_id
    join lease l on l.lease_id = o.lease_id
    join engine e on e.engine_id = l.engine_id
    join customer c on c.customer_id = l.customer_id
    join country co on co.country_id = c.country_id
    where eu.billing_generated = false 
    and year = prm_year and month = prm_month
    and mrb.billing_processed = false;

end; //
delimiter ;





-- Generate Maintenace Reserve Billing entries for period
-- -------------------------------------------------------
DROP PROCEDURE if exists `engine_management`.`generate_maintenance_reserve_billing` ;
 
DELIMITER //
 create procedure  generate_maintenance_reserve_billing(prm_year int, prm_month int )
BEGIN
	DECLARE loc_invalidParam CONDITION FOR SQLSTATE '48000';
    DECLARE errno INT;
    declare msg varchar(250);
    declare loc_message varchar(250);
    declare loc_engine_usage_id int;
	declare loc_year int;
	declare loc_month int;
	declare loc_cycles int;
	declare loc_usage_rate_id int;
	declare loc_rate decimal;
	declare loc_harsh_environment bit(1);
    declare loc_harsh_environment_loading decimal;
    declare loc_usage_charge decimal;    
    declare loc_harsh_environment_charge decimal;
    declare done bit(1);

-- Create a cursor to get all un-processed engine usage entries for period 
	DECLARE cur1 CURSOR FOR  
    select engine_usage_id,
			eu.year,
			eu.month,
			eu.cycles,
			null as usage_rate_id,
			null as rate,
			co.harsh_environment,
			co.harsh_environment_loading
    from engine_usage eu
    join operation o on o.operation_id = eu.operation_id
    join lease l on l.lease_id = o.lease_id
    join engine e on e.engine_id = l.engine_id
    join customer c on c.customer_id = l.customer_id
    join country co on co.country_id = c.country_id
    where eu.billing_generated = false 
    and eu.year = prm_year and eu.month = prm_month;
    
-- Declare the continue handler     
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;  
-- Declare the exception handler and roll back if issues found
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		GET DIAGNOSTICS CONDITION 1
        errno = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
		-- GET CURRENT DIAGNOSTICS CONDITION 1 errno = MYSQL_ERRNO;
        -- Note: see https://bugs.mysql.com/bug.php?id=79975 regarding issue with GET
		-- SELECT errno AS MYSQL_ERROR;
        select errno, msg;
		ROLLBACK;
    END;    
select 'Hello world' ;
	-- disable auto commit and begin transaction control
	START TRANSACTION;

-- Open the cursor and read each row into local variables for processing
  OPEN cur1;
  read_loop: LOOP
    FETCH cur1 INTO loc_engine_usage_id,
					loc_year,
					loc_month,
					loc_cycles,
					loc_usage_rate_id,
					loc_rate,
					loc_harsh_environment,
					loc_harsh_environment_loading;
                    
-- All rows processed to exist loop
    IF done THEN
      LEAVE read_loop;
    END IF;
 
		-- get the matching rate id and rate for this engine usage entry
		select usage_rate_id, rate into loc_usage_rate_id, loc_rate 
				from usage_rate 
				where loc_cycles >= from_cycle and loc_cycles <= to_cycle;
        
	if (loc_usage_rate_id <= 0) then 
		-- rate not found so report it as an error and continue processing
		set loc_usage_rate_id = 0;
			set loc_message = 'WARNING: No rate found for engine usage entry id: '
							  + loc_engine_usage_id 
                              + ', please add a rate for this entry and re-run this procedure for this year/month'; 
		  SIGNAL SQLSTATE '48000'
          SET MESSAGE_TEXT = loc_message;
    else
		select loc_usage_rate_id;
		-- Do the calculations for charges
		set loc_usage_charge = loc_rate * loc_cycles;
        if (loc_harsh_environment) then
			set loc_harsh_environment_charge = loc_usage_charge * loc_harsh_environment_loading;
            
        else
			set loc_harsh_environment_charge = 0;
        end if;
        
        -- Mark the engine usage entry as processed
		update engine_usage set billing_generated = true where engine_usage_id = loc_engine_usage_id;
        
        -- Create a new billing entry
        insert into maintenance_reserve_billing (engine_usage_id, usage_rate_id, rate, 
											     harsh_environment, harsh_environment_loading, usage_charge, 
                                                 harsh_environment_charge)
					values (loc_engine_usage_id, loc_usage_rate_id, loc_rate, 
							loc_harsh_environment, loc_harsh_environment_loading, loc_usage_charge, 
                            loc_harsh_environment_charge);
    end if;
   
  END LOOP;

  CLOSE cur1;

-- commit all database changes
commit;     
end; //
delimiter ;
