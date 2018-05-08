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
    PRIMARY KEY (engine_model_id)
    );

-- Create the Country table
drop table if exists country;
create table country(
	country_id int NOT NULL AUTO_INCREMENT,
    country_name varchar(150) NOT NULL,
    harsh_environment bit(1) not null,
    harsh_environment_loading decimal,
    PRIMARY KEY (country_id)
    );    
    
-- Create the Customer Table
drop table if exists customer;
create table customer(
customer_id int NOT NULL AUTO_INCREMENT,
    company_name varchar(255) NOT NULL,
    address varchar(255) ,
    country_id int NOT NULL,
    PRIMARY KEY (customer_id),
    FOREIGN KEY (country_id) REFERENCES country(country_id)
    
    -- create index for company name
    );

-- Create the Rate Table
drop table if exists usage_rate;
create table usage_rate(
	usage_rate_id int NOT NULL AUTO_INCREMENT,
    from_cycle int NOT NULL,
    to_cycle int NOT NULL,
    rate decimal NOT NULL,
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
	FOREIGN KEY (engine_model_id) REFERENCES engine_model(engine_model_id)
  -- create index for Engine Serial Number
    );

-- Create the Lease Table
drop table if exists lease;
create table lease(
	lease_id int NOT NULL AUTO_INCREMENT,
    lease_reference varchar(25) not null unique,
    engine_id int not null,
    customer_id int,
    start_date date NOT NULL,
    end_date date,
    PRIMARY KEY (lease_id),
    FOREIGN KEY (engine_id) REFERENCES engine(engine_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    
    -- create index for lease reference
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
    rate decimal,
    harsh_environment bit(1),
    harsh_environment_loading decimal,
    usage_charge decimal,
    harsh_environment_charge decimal,
    billing_processed bit(1) default false,
    PRIMARY KEY (maintenance_reserve_billing_id),
    FOREIGN KEY (engine_usage_id) REFERENCES engine_usage(engine_usage_id),
    FOREIGN KEY (usage_rate_id) REFERENCES usage_rate(usage_rate_id)
    );    
--     


    

