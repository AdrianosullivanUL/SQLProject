-- -------------------------------------------------------
-- Create Schema
-- -------------------------------------------------------
 
-- Create a new Schema for the database
CREATE SCHEMA if not exists `engine_management` ;

-- Select the schema
USE engine_management;

-- -------------------------------------------------------
-- Create Tables
-- -------------------------------------------------------

-- Create the Engine Model table
drop table if exists engine_model;
create table engine_model(
engine_model_id int NOT NULL AUTO_INCREMENT,
    model_name varchar(50) NOT NULL,
    active bit(1) not null,
    PRIMARY KEY (engine_model_id),
    unique (model_name)
    );

-- Create the Country table
drop table if exists country;
create table country(
	country_id int NOT NULL AUTO_INCREMENT,
    country_name varchar(150) NOT NULL,
    harsh_environment bit(1) not null,
    harsh_environment_loading decimal(10,2),
    PRIMARY KEY (country_id),
    unique (country_name)
    );    
    
-- Create the Customer Table
drop table if exists customer;
create table customer(
	customer_id int NOT NULL AUTO_INCREMENT,
    company_name varchar(255) NOT NULL,
    address varchar(255) ,
    country_id int NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (country_id) REFERENCES country(country_id),
    unique (company_name)
    );

-- Create the Rate Table
drop table if exists usage_rate;
create table usage_rate(
	usage_rate_id int NOT NULL AUTO_INCREMENT,
    from_cycle int NOT NULL,
    to_cycle int NOT NULL,
    rate decimal (10,2) NOT NULL,
    PRIMARY KEY (usage_rate_id)
    );

-- Create the Engine Table
drop table if exists engine;
create table engine(
	engine_id int NOT NULL AUTO_INCREMENT,
    engine_serial_number varchar(25),
    engine_model_id int NOT NULL,
    enrolement_date date NOT NULL,
    disposal_date date,
    PRIMARY KEY (engine_id),
	FOREIGN KEY (engine_model_id) REFERENCES engine_model(engine_model_id),
    INDEX engine_serial_number_idx (engine_serial_number)
    );

-- Create the Lease Table
drop table if exists lease;
create table lease(
	lease_id int NOT NULL AUTO_INCREMENT,
    lease_reference varchar(25) not null,
    engine_id int not null,
    customer_id int,
    start_date date NOT NULL,
    end_date date,
    PRIMARY KEY (lease_id),
    FOREIGN KEY (engine_id) REFERENCES engine(engine_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    INDEX lease_reference_idx (lease_reference),
    UNIQUE (lease_reference)
    );
    
-- Create the Operation Table
drop table if exists operation;
create table operation(
	operation_id int NOT NULL AUTO_INCREMENT,
    lease_id int not null,
    start_date date NOT NULL,
    end_date date,
    aircraft_serial_number varchar(25),
    PRIMARY KEY (operation_id),
    FOREIGN KEY (lease_id) REFERENCES lease(lease_id)
    );
    
-- Create the Engine Usage Table
drop table if exists engine_usage;
create table engine_usage(
	engine_usage_id int NOT NULL AUTO_INCREMENT,
    operation_id int not null,
    year int NOT NULL,
    month int not null,
    cycles int,
    billing_generated bit(1) default false,
    PRIMARY KEY (engine_usage_id),
    FOREIGN KEY (operation_id) REFERENCES lease(operation_id)
    );

-- Create Maintenace Reserve Billing table
drop table if exists maintenance_reserve_billing;
create table maintenance_reserve_billing(
	maintenance_reserve_billing_id int NOT NULL AUTO_INCREMENT,
    engine_usage_id int not null,
    usage_rate_id int not null,
    rate decimal (10,2),
    harsh_environment bit(1),
    harsh_environment_loading decimal (10,2),
    usage_charge decimal (10,2),
    harsh_environment_charge decimal (10,2),
    billing_processed bit(1) default false,
    PRIMARY KEY (maintenance_reserve_billing_id),
    FOREIGN KEY (engine_usage_id) REFERENCES engine_usage(engine_usage_id),
    FOREIGN KEY (usage_rate_id) REFERENCES usage_rate(usage_rate_id)
    );    

-- View showing the annual cycles and billing charges per customer
drop view if exists Company_annual_Usage_view;
create view Company_annual_Usage_view as
 select c.company_name,
		eu.year,
		sum(eu.cycles) annual_cycles,
		sum(mrb.usage_charge) annual_usage_charge,
		sum(mrb.harsh_environment_charge) annual_harsh_environment_charge
    from maintenance_reserve_billing mrb
    join engine_usage eu on eu.engine_usage_id = mrb.engine_usage_id 
    join operation o on o.operation_id = eu.operation_id
    join lease l on l.lease_id = o.lease_id
    join engine e on e.engine_id = l.engine_id
    join customer c on c.customer_id = l.customer_id
    group by company_name, eu.year;
        
-- View showing the average monthly cycles per engine model/year
drop view if exists engine_model_average_cycles_view;
create view engine_model_average_cycles_view as
 select em.model_name, 
		eu.year,
		avg(eu.cycles) average_cycles
    from engine_usage eu 
    join operation o on o.operation_id = eu.operation_id
    join lease l on l.lease_id = o.lease_id
    join engine e on e.engine_id = l.engine_id
    join engine_model em on em.engine_model_id = e.engine_model_id
    group by em.model_name, eu.year;
    
-- View showing the Current location of each engine on lease    
drop view if exists current_engine_locations_view;
create view current_engine_locations_view as
	select e.engine_serial_number, l.lease_reference, c.company_name, cr.country_name from 
		(select engine_id, engine_serial_number
				from engine e where enrolement_date <= curdate() and disposal_date is null or disposal_date >= curdate()) e
		join (select lease_reference, customer_id, engine_id 
				from lease where start_date <= curdate() and end_date is null or end_date >= curdate()) l on l.engine_id = e.engine_id     
		join customer c on c.customer_id = l.customer_id
		join country cr on cr.country_id = c.country_id;    