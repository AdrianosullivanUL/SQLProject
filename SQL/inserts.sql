-- -------------------------------------------------------
-- Insert entries into tables
-- -------------------------------------------------------

-- Select the schema
USE engine_management;

-- Engine Model Table
insert into engine_model (model_name, active) values ('CFM56-5A', true);
insert into engine_model (model_name, active) values ('CFM56-5B', true);
insert into engine_model (model_name, active) values ('CFM56-5C', true);
insert into engine_model (model_name, active) values ('CFM56-7B', true);
insert into engine_model (model_name, active) values ('LEAP-1A', true);
insert into engine_model (model_name, active) values ('LEAP-1B', true);

insert into country(country_name, harsh_environment) values ('Ireland', false);
insert into country(country_name, harsh_environment) values ('United Kingdom', false);
insert into country(country_name, harsh_environment) values ('France', false);
insert into country(country_name, harsh_environment, harsh_environment_loading) values ('India', true, 0.150);
insert into country(country_name, harsh_environment, harsh_environment_loading) values ('Egypt', true, 0.100);



insert into customer (company_name, address, country_id) values ('Aer Lingus', 'Dublin Airport, Dublin', (select country_id from country where country_name = 'Ireland'));
insert into customer (company_name, address, country_id) values ('Ryanair', 'Dublin Airport, Dublin', (select country_id from country where country_name = 'Ireland'));
insert into customer (company_name, address, country_id) values ('BA', 'Heathrow Airport, London', (select country_id from country where country_name = 'United Kingdom'));
insert into customer (company_name, address, country_id) values ('Air France', 'Charles De Gaul Airport, Paris', (select country_id from country where country_name = 'France'));
insert into customer (company_name, address, country_id) values ('Jet Airways', 'Mumbai', (select country_id from country where country_name = 'India'));

insert into usage_rate (from_cycle, to_cycle, rate) values (1,10,250);
insert into usage_rate (from_cycle, to_cycle, rate) values (11,15,255);
insert into usage_rate (from_cycle, to_cycle, rate) values (16,20,260);
insert into usage_rate (from_cycle, to_cycle, rate) values (21,15,265);
insert into usage_rate (from_cycle, to_cycle, rate) values (26,30,270);
insert into usage_rate (from_cycle, to_cycle, rate) values (31,999,275);


insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) 
values ('123456', (select engine_model_id from engine_model where model_name = 'CFM56-5A'), STR_TO_DATE('01/01/2013', '%d/%m/%Y'), null);

insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) values ('789103', (select engine_model_id from engine_model where model_name = 'CFM56-5B'), STR_TO_DATE('01/01/2003', '%d/%m/%Y'),STR_TO_DATE('01/02/2017', '%d/%m/%Y'));
insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) values ('606060', (select engine_model_id from engine_model where model_name = 'CFM56-5C'), STR_TO_DATE('31/01/2013', '%d/%m/%Y'), null);
insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) values ('101010', (select engine_model_id from engine_model where model_name = 'CFM56-7B'), STR_TO_DATE('01/02/2010', '%d/%m/%Y'), null);
insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) values ('AF5092', (select engine_model_id from engine_model where model_name = 'LEAP-1A'), STR_TO_DATE('01/01/2018', '%d/%m/%Y'), null);
insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) values ('AZ5092', (select engine_model_id from engine_model where model_name = 'LEAP-1B'), STR_TO_DATE('01/02/2018', '%d/%m/%Y'), null);
insert into engine (engine_serial_number, engine_model_id, enrolement_date, disposal_date) values ('729101', (select engine_model_id from engine_model where model_name = 'CFM56-5B'), STR_TO_DATE('01/01/2018', '%d/%m/%Y'), null);

insert into lease (lease_reference, engine_id, customer_id, start_date , end_date ) values ('L10001',
	(select engine_id from engine where engine_serial_number = '789103'),
    (select customer_id from customer where company_name = 'Aer Lingus'),STR_TO_DATE('01/01/2017', '%d/%m/%Y'),null);

insert into lease (lease_reference,engine_id, customer_id, start_date , end_date ) values ('L10002',
	(select engine_id from engine where engine_serial_number = '606060'),
    (select customer_id from customer where company_name = 'Ryanair'),STR_TO_DATE('01/01/2016', '%d/%m/%Y'), STR_TO_DATE('31/12/2016', '%d/%m/%Y'));

insert into lease (lease_reference,engine_id, customer_id, start_date , end_date ) values ('L10003',
	(select engine_id from engine where engine_serial_number = '101010'),
    (select customer_id from customer where company_name = 'BA'),STR_TO_DATE('01/01/2017', '%d/%m/%Y'), STR_TO_DATE('01/01/2018', '%d/%m/%Y'));

insert into lease (lease_reference,engine_id, customer_id, start_date , end_date ) values ('L10004',
	(select engine_id from engine where engine_serial_number = 'AF5092'),
    (select customer_id from customer where company_name = 'Air France'),STR_TO_DATE('01/02/2018', '%d/%m/%Y'),null);

insert into lease (lease_reference,engine_id, customer_id, start_date , end_date ) values ('L10005',
	(select engine_id from engine where engine_serial_number = '729101'),
    (select customer_id from customer where company_name = 'Jet Airways'),STR_TO_DATE('01/01/2018', '%d/%m/%Y'),null);


-- TODO Need to clean up dates and references here
delete from operation where operation_id > 0;
insert into operation (lease_id, start_date, end_date, aircraft_serial_number) values (
		(select lease_id from lease where lease_reference = 'L10001'), STR_TO_DATE('01/01/2016', '%d/%m/%Y'),STR_TO_DATE('01/01/2016', '%d/%m/%Y'),'N904EE');
        
insert into operation (lease_id, start_date, end_date, aircraft_serial_number) values (
		(select lease_id from lease where lease_reference = 'L10002'), STR_TO_DATE('01/01/2016', '%d/%m/%Y'),STR_TO_DATE('01/01/2016', '%d/%m/%Y'),'N904XF');

insert into operation (lease_id, start_date, end_date, aircraft_serial_number) values (
		(select lease_id from lease where lease_reference = 'L10003'), STR_TO_DATE('01/01/2016', '%d/%m/%Y'),STR_TO_DATE('01/01/2016', '%d/%m/%Y'),'N904ZG');

insert into operation (lease_id, start_date, end_date, aircraft_serial_number) values (
		(select lease_id from lease where lease_reference = 'L10004'), STR_TO_DATE('01/01/2016', '%d/%m/%Y'),STR_TO_DATE('01/01/2016', '%d/%m/%Y'),'N904AH');

insert into operation (lease_id, start_date, end_date, aircraft_serial_number) values (
		(select lease_id from lease where lease_reference = 'L10005'), STR_TO_DATE('01/01/2016', '%d/%m/%Y'),STR_TO_DATE('01/01/2016', '%d/%m/%Y'),'N904KI');


INSERT INTO engine_usage (operation_id,year,month,cycles) VALUES ((select operation_id from operation where aircraft_serial_number = 'N904EE'),2018,4,10);
INSERT INTO engine_usage (operation_id,year,month,cycles) VALUES ((select operation_id from operation where aircraft_serial_number = 'N904XF'),2018,4,15);
INSERT INTO engine_usage (operation_id,year,month,cycles) VALUES ((select operation_id from operation where aircraft_serial_number = 'N904ZG'),2018,4,20);
INSERT INTO engine_usage (operation_id,year,month,cycles) VALUES ((select operation_id from operation where aircraft_serial_number = 'N904AH'),2018,4,25);
INSERT INTO engine_usage (operation_id,year,month,cycles) VALUES ((select operation_id from operation where aircraft_serial_number = 'N904KI'),2018,4,30);





        
        
    
    