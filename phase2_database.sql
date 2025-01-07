
DROP DATABASE IF EXISTS airline_management;
CREATE DATABASE IF NOT EXISTS airline_management;
USE airline_management;

drop table if exists Location;
create table Location (
	locID char(50) not null,
	primary key (locID)
) ENGINE=InnoDB;

drop table if exists Person;
create table Person (
	personID char(50) not null,
    f_name char(100) not null,
    l_name char(100),
    location char(50) not null,
	primary key(personID)
) ENGINE = InnoDB;

drop table if exists Airline;
create TABLE Airline (
	airlineID char(50) not null,
	revenue decimal(11, 2) not null,
	primary key (airlineID)
) ENGINE=InnoDB;

drop table if exists Airplane;
create TABLE Airplane (
	airlineID char(50) not null,
	tail_num char(6) not null,
	seat_cap decimal(11, 0) not null,
	speed decimal(11, 2) not null,
    locID char(50),
    plane_type char(50),
    skids decimal(11, 0),
    props_or_jets decimal(11, 0),
	primary key (airlineID, tail_num)
) ENGINE=InnoDB;

drop table if exists Pilot;
create table Pilot (
	personID char(50) not null,
	taxID char(11) not null,
	experience decimal(11, 0) not null,
	airlineID char(50),
	tail_num char(6),
	primary key(personID),
    unique key(taxID)
) ENGINE = InnoDB;

drop table if exists License;
create table License (
	personID char(50) not null,
	license char(50),
	primary key(personID, license)
) ENGINE = InnoDB;

drop table if exists Passenger;
create table Passenger (
	personID char(50) not null,
	miles decimal(11, 2),
	primary key(personID)
) ENGINE = InnoDB;

drop table if exists Airport;
create table Airport (
	airportID char(3) not null,
	name char(100) not null,
	city char(100) not null,
	state char(2) not null,
	locID char(50),
	primary key(airportID)
) ENGINE = InnoDB;

drop table if exists Flight;
create TABLE Flight (
	flightID char(50) not null,
	routeID char(50) not null,
	airlineID char(50),
    tail_num char(6),
	primary key (flightID)
) ENGINE=InnoDB;

drop table if exists Route;
create table Route (
	routeID char(50) not null,
	primary key (routeID)
) ENGINE=InnoDB;

drop table if exists Leg;
create table Leg (
	legID char(50) not null,
	distance decimal(11, 2) not null, 
	departure char(3) not null,
	arrival char(3) not null,
	primary key (legID)
) ENGINE=InnoDB;

drop table if exists Ticket;
create table Ticket (
	ticketID char(50) not null, 
	cost decimal(11, 2) not null,
    flightID char(50) not null,
	personID char(50) not null, 
	airportID char(3) not null, 
	primary key (ticketID)
) ENGINE=InnoDB;

drop table if exists Seat;
create table Seat (
	ticketID char(50) not null, 
	seat char(50) not null,
    primary key (ticketID, seat)
) ENGINE=InnoDB;

drop table if exists Contains;
CREATE TABLE Contains (
	routeID char(50) NOT NULL,
	legID char(50) NOT NULL,
	primary key(routeID, legID)
) ENGINE=InnoDB;

drop table if exists Supports;
CREATE TABLE Supports (
	flightID char(50) not null,
	airlineID char(50) not null,
	tail_num char(6) not null,
  	progress decimal(11, 0),
    status char(50),
 	next_time char(100),
   	PRIMARY KEY (airlineID, tail_num),
	unique key(flightID)
) ENGINE=InnoDB;

alter table Person add constraint fk1 foreign key (location) references location (locID);
alter table Pilot add constraint fk2 foreign key (personID) references Person(personID);
alter table Pilot add constraint fk3 foreign key (airlineID, tail_num) references Airplane(airlineID, tail_num);
alter table License add constraint fk4 foreign key(personID) references Pilot(personID);
alter table Passenger add constraint fk5 foreign key(personID) references Person(personID);
alter table Airplane add constraint fk6 foreign key (airlineID) references airline (airlineID);
alter table Flight add constraint fk9 foreign key (routeID) references route (routeID);
alter table Flight add constraint fk10 foreign key (airlineID, tail_num) references airplane (airlineID, tail_num);
alter table Leg add constraint fk11 foreign key (departure) references Airport (airportID);
alter table Leg add constraint fk12 foreign key (arrival) references Airport (airportID);
alter table Ticket add constraint fk13 foreign key (personID) references Person (personID);
alter table Ticket add constraint fk14 foreign key (airportID) references Airport (airportID);
alter table Ticket add constraint fk15 foreign key (flightID) references Flight (flightID);
alter table Seat add constraint fk16 foreign key (ticketID) references Ticket(ticketID);
alter table Contains add constraint fk17 FOREIGN KEY (routeID) REFERENCES Route (routeID);
alter table Contains add constraint fk18 FOREIGN KEY (legID) REFERENCES Leg (legID);
alter table Supports add constraint fk19 FOREIGN KEY (flightID) REFERENCES Flight (flightID);
alter table Supports add constraint fk20 FOREIGN KEY (airlineID, tail_num) REFERENCES Airplane (airlineID, tail_num);
alter table Airport add constraint fk21 FOREIGN KEY(locID) references Location(locID);
alter table Airplane add constraint fk22 FOREIGN KEY(locID) references Location(locID);

INSERT INTO Airline VALUES
('Air_France', 25),
('American', 45),
('Delta', 46),
('JetBlue', 8),
('Lufthansa', 31),
('Southwest', 22),
('Spirit', 4),
('United', 40);

INSERT INTO location VALUES 
('plane_1'),
('plane_11'),
('plane_15'),
('plane_2'),
('plane_4'),
('plane_7'),
('plane_8'),
('plane_9'),
('port_1'),
('port_10'),
('port_11'),
('port_13'),
('port_14'),
('port_15'),
('port_17'),
('port_18'),
('port_2'),
('port_3'),
('port_4'),
('port_5'),
('port_7'),
('port_9');

INSERT INTO airplane VALUES 
('American', 'n330ss', 4, 200, 'plane_4', 'jet', null, 2),
('American', 'n380sd', 5, 400, null, 'jet', null, 2),
('Delta', 'n106js', 4, 200, 'plane_1', 'jet', null, 2),
('Delta', 'n110jn', 5, 600, 'plane_2', 'jet', null, 4),
('Delta', 'n127js', 4, 800, null, null, null, null),
('Delta', 'n156sq', 8, 100, null, null, null, null),
('JetBlue', 'n161fk', 4, 200, null, 'jet', null, 2),
('JetBlue', 'n337as', 5, 400, null, 'jet', null, 2),
('Southwest', 'n118fm', 4, 100, 'plane_11', 'prop', 1, 1),
('Southwest', 'n401fj', 4, 200, 'plane_9', 'jet', null, 2),
('Southwest', 'n653fk', 6, 400, null, 'jet', null, 2),
('Southwest', 'n815pw', 3, 200, null, 'prop', 0, 2),
('Spirit', 'n256ap', 4, 400, 'plane_15', 'jet', null, 2),
('United', 'n45lfi', 5, 400, null, 'jet', null, 4),
('United', 'n517ly', 4, 400, 'plane_7', 'jet', null, 2),
('United', 'n616lt', 7, 400, null, 'jet', null, 4),
('United', 'n620la', 4, 200, 'plane_8', 'prop', 0, 2);

INSERT INTO route VALUES
('circle_east_coast'),
('circle_west_coast'),
('eastbound_north_milk_run'),
('eastbound_north_nonstop'),
('eastbound_south_milk_run'),
('hub_xchg_southeast'),
('hub_xchg_southwest'),
('local_texas'),
('northbound_east_coast'),
('northbound_west_coast'),
('southbound_midwest'),
('westbound_north_milk_run'),
('westbound_north_nonstop'),
('westbound_south_nonstop');

INSERT INTO flight VALUES 
('AM_1523', 'circle_west_coast', 'American', 'n330ss'),
('DL_1174', 'northbound_east_coast', 'Delta', 'n106js'),
('DL_1243', 'westbound_north_nonstop', 'Delta', 'n110jn'),
('DL_3410', 'circle_east_coast', NULL, NULL),
('SP_1880', 'circle_east_coast', 'Spirit', 'n256ap'),
('SW_1776', 'hub_xchg_southwest', 'Southwest', 'n401fj'),
('SW_610', 'local_texas', 'Southwest', 'n118fm'),
('UN_1899', 'eastbound_north_milk_run', 'United', 'n517ly'),
('UN_523', 'hub_xchg_southeast', 'United', 'n620la'),
('UN_717', 'circle_west_coast', NULL, NULL);

INSERT INTO supports VALUES 
('AM_1523', 'American', 'n330ss', 2, 'on_ground', '14:30:00'),
('DL_1174', 'Delta', 'n106js', 0, 'on_ground', '08:00:00'),
('DL_1243', 'Delta', 'n110jn', 0, 'on_ground', '09:30:00'),
('SP_1880', 'Spirit', 'n256ap', 2, 'in_flight', '15:00:00'),
('SW_1776', 'Southwest', 'n401fj', 2, 'in_flight', '14:00:00'),
('SW_610', 'Southwest', 'n118fm', 2, 'in_flight', '11:30:00'),
('UN_1899', 'United', 'n517ly', 0, 'on_ground', '09:30:00'),
('UN_523', 'United', 'n620la', 1, 'in_flight', '11:00:00');

INSERT INTO Airport VALUES
('ABQ', 'Albuquerque International Support', 'Albuquerque', 'NM', NULL),
('ANC', 'Ted Stevens Anchorage International Airport', 'Anchorage', 'AK', NULL),
('ATL', 'Hartsfield-Jackson Atlanta International Airport', 'Atlanta', 'GA', 'port_1'),
('BDL', 'Bradley International Airport', 'Hartford', 'CT', NULL),
('BFI', 'King County International Airport', 'Seattle', 'WA', 'port_10'),
('BHM', 'Birmingham-Shuttlesworth International Airport', 'Birmingham', 'AL', NULL),
('BNA', 'Nashville International Airport', 'Nashville', 'TN', NULL),
('BOI', 'Boise Airport', 'Boise', 'ID', NULL),
('BOS', 'General Edward Lawrence Logan International Airport', 'Boston', 'MA', NULL),
('BTV', 'Burlington International Airport', 'Burlington', 'VT', NULL),
('BWI', 'Baltimore_Washington International Airport', 'Burlington', 'VT', NULL),
('BZN', 'Bozeman Yellowstone International Airport', 'Bozeman', 'MT', NULL),
('CHS', 'Charleston International Airport', 'Charleston', 'SC', NULL),
('CLE', 'Cleveland Hopkins International Airport', 'Cleveland', 'OH', NULL),
('CLT', 'Charlotte Douglas International Airport', 'Charlotte', 'NC', NULL),
('CRW', 'Yeager Airport', 'Charleston', 'WV', NULL),
('DAL', 'Dallas Love Field', 'Dallas', 'TX', 'port_7'),
('DCA', 'Ronald Reagan Washington National Airport', 'Washington', 'DC', 'port_9'),
('DEN', 'Denver International Airport', 'Denver', 'CO', 'port_3'),
('DFW', 'Dallas-Fort Worth International Airport', 'Dallas', 'TX', 'port_2'),
('DSM', 'Des Moines International Airport', 'Des Moines', 'IA', NULL),
('DTW', 'Detroit Metro Wayne County Airport', 'Detroit', 'MI', NULL),
('EWR', 'Newark Liberty International Airport', 'Newark', 'NJ', NULL),
('FAR', 'Hector International Airport', 'Fargo', 'ND', NULL),
('FSD', 'Joe Foss Field', 'Sioux Falls', 'SD', NULL),
('GSN', 'Saipan International Airport', 'Obyan Saipan Island', 'MP', NULL),
('GUM', 'Antonio B_Won Pat International Airport', 'Agana Tamuning', 'GU', NULL),
('HNL', 'Daniel K. Inouye International Airport', 'Honolulu Oahu', 'HI', NULL),
('HOU', 'William P_Hobby Airport', 'Houston', 'TX', 'port_18'),
('IAD', 'Washington Dulles International Airport', 'Washington', 'DC', 'port_11'),
('IAH', 'George Bush Intercontinental Houston Airport', 'Houston', 'TX', 'port_13'),
('ICT', 'Wichita Dwight D_Eisenhower National Airport', 'Wichita', 'KS', NULL),
('ILG', 'Wilmington Airport', 'Wilmington', 'DE', NULL),
('IND', 'Indianapolis International Airport', 'Indianapolis', 'IN', NULL),
('ISP', 'Long Island MacArthur Airport', 'New York Islip', 'NY', 'port_14'),
('JAC', 'Jackson Hole Airport', 'Jackson', 'WY', NULL),
('JAN', 'Jackson_Medgar Wiley Evers International Airport', 'Jackson', 'MS', NULL),
('JFK', 'John F_Kennedy International Airport', 'New York', 'NY', 'port_15'),
('LAS', 'Harry Reid International Airport', 'New York', 'NY', NULL),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'CA', 'port_5'),
('LGA', 'LaGuardia Airport', 'New York', 'NY', NULL),
('LIT', 'Bill and Hillary Clinton National Airport', 'Little Rock', 'AR', NULL),
('MCO', 'Orlando International Airport', 'Orlando', 'FL', NULL),
('MDW', 'Chicago Midway International Airport', 'Chicago', 'IL', NULL),
('MHT', 'Manchester_Boston Regional Airport', 'Manchester', 'NH', NULL),
('MKE', 'Milwaukee Mitchell International Airport', 'Milwaukee', 'WI', NULL),
('MRI', 'Merrill Field', 'Anchorage', 'AK', NULL),
('MSP', 'Minneapolis_St_Paul International Wold_Chamberlain Airport', 'Minneapolis Saint Paul', 'MN', NULL),
('MSY', 'Louis Armstrong New Orleans International Airport', 'New Orleans', 'LA', NULL),
('OKC', 'Will Rogers World Airport', 'Oklahoma City', 'OK', NULL),
('OMA', 'Eppley Airfield', 'Omaha', 'NE', NULL),
('ORD', 'O_Hare International Airport', 'Chicago', 'IL', 'port_4'),
('PDX', 'Portland International Airport', 'Portland', 'OR', NULL),
('PHL', 'Philadelphia International Airport', 'Philadelphia', 'PA', NULL),
('PHX', 'Phoenix Sky Harbor International Airport', 'Phoenix', 'AZ', NULL),
('PVD', 'Rhode Island T_F_Green International Airport', 'Providence', 'RI', NULL),
('PWM', 'Portland International Jetport', 'Portland', 'ME', NULL),
('SDF', 'Louisville International Airport', 'Louisville', 'KY', NULL),
('SEA', 'Seattle-Tacoma International Airport', 'Seattle Tacoma', 'WA', 'port_17'),
('SJU', 'Luis Munoz Marin International Airport', 'San Juan Carolina', 'PR', NULL),
('SLC', 'Salt Lake City International Airport', 'Salt Lake City', 'UT', NULL),
('STL', 'St_Louis Lambert International Airport', 'Saint Louis', 'MO', NULL),
('STT', 'Cyril E_King Airport', 'Charlotte Amalie Saint Thomas', 'VI', NULL);

INSERT INTO Leg VALUES
('leg_11', 600, 'IAD', 'ORD'),
('leg_13', 1400, 'IAH', 'LAX'),
('leg_14', 2400, 'ISP', 'BFI'),
('leg_15', 800, 'JFK', 'ATL'),
('leg_2', 600, 'ATL', 'IAH'),
('leg_5', 1000, 'BFI', 'LAX'),
('leg_18', 1200, 'LAX', 'DFW'),
('leg_24', 1800, 'SEA', 'ORD'),
('leg_23', 2400, 'SEA', 'JFK'),
('leg_25', 600, 'ORD', 'ATL'),
('leg_12', 200, 'IAH', 'DAL'),
('leg_3', 800, 'ATL', 'JFK'),
('leg_19', 1000, 'LAX', 'SEA'),
('leg_21', 800, 'ORD', 'DFW'),
('leg_16', 800, 'JFK', 'ORD'),
('leg_17', 2400, 'JFK', 'SEA'),
('leg_27', 1600, 'ATL', 'LAX'),
('leg_10', 800, 'DFW', 'ORD'),
('leg_20', 600, 'ORD', 'DCA'),
('leg_9', 800, 'DFW', 'ATL'),
('leg_4', 600, 'ATL', 'ORD'),
('leg_26', 800, 'LAX', 'ORD'),
('leg_6', 200, 'DAL', 'HOU'),
('leg_7', 600, 'DCA', 'ATL'),
('leg_22', 800, 'ORD', 'LAX'),
('leg_8', 200, 'DCA', 'JFK'),
('leg_1', 600, 'ATL', 'IAD');

INSERT INTO person VALUES  
('p1', 'Jeanne', 'Nelson', 'plane_1'), 
('p10', 'Lawrence', 'Morgan', 'plane_9'),
('p11', 'Sandra', 'Cruz', 'plane_9'),
('p12', 'Dan', 'Ball', 'plane_11'),
('p13', 'Bryant', 'Figueroa', 'plane_2'),
('p14', 'Dana', 'Perry', 'plane_2'),
('p15', 'Matt', 'Hunt', 'plane_2'),
('p16', 'Edna', 'Brown', 'plane_15'),
('p17', 'Ruby', 'Burgess', 'plane_15'),
('p18', 'Esther', 'Pittman', 'port_2'),
('p19', 'Doug', 'Fowler', 'port_4'),
('p2', 'Roxanne', 'Byrd', 'plane_1'),
('p20', 'Thomas', 'Olson', 'port_3'),
('p21', 'Mona', 'Harrison', 'port_4'),
('p22', 'Arlene', 'Massey', 'port_2'),
('p23', 'Judith', 'Patrick', 'port_3'),
('p24', 'Reginald', 'Rhodes', 'plane_1'),
('p25', 'Vincent', 'Garcia', 'plane_1'),
('p26', 'Cheryl', 'Moore', 'plane_4'),
('p27', 'Michael', 'Rivera', 'plane_7'),
('p28', 'Luther', 'Matthews', 'plane_8'),
('p29', 'Moses', 'Parks', 'plane_8'),
('p3', 'Tanya', 'Nguyen', 'plane_4'),
('p30', 'Ora', 'Steele', 'plane_9'),
('p31', 'Antonio', 'Flores', 'plane_9'), 
('p32', 'Glenn', 'Ross', 'plane_11'),
('p33', 'Irma', 'Thomas', 'plane_11'),
('p34', 'Ann', 'Maldonado', 'plane_2'),
('p35', 'Jeffrey', 'Cruz', 'plane_2'),
('p36', 'Sonya', 'Price', 'plane_15'),
('p37', 'Tracy', 'Hale', 'plane_15'),
('p38', 'Albert', 'Simmons', 'port_1'),
('p39', 'Karen', 'Terry', 'port_9'), 
('p4', 'Kendra', 'Jacobs', 'plane_4'),
('p40', 'Glen', 'Kelley', 'plane_4'),
('p41', 'Brooke', 'Little', 'port_4'), 
('p42', 'Daryl', 'Nguyen', 'port_3'),
('p43', 'Judy', 'Willis', 'port_1'), 
('p44', 'Marco', 'Klein', 'port_2'), 
('p45', 'Angelica', 'Hampton', 'port_5'),
('p5', 'Jeff', 'Burton', 'plane_4'),
('p6', 'Randal', 'Parks', 'plane_7'),
('p7', 'Sonya', 'Owens', 'plane_7'),
('p8', 'Bennie', 'Palmer', 'plane_8'),
('p9', 'Marlene', 'Warner', 'plane_8');
 
INSERT INTO pilot VALUES
('p1', '330-12-6907', 31, 'Delta', 'n106js'),
('p10', '769-60-1266', 15, 'Southwest', 'n401fj'),
('p11', '369-22-9505', 22, 'Southwest', 'n401fj'),
('p12', '680-92-5329', 24, 'Southwest', 'n118fm'),
('p13', '513-40-4168', 24, 'Delta', 'n110jn'),
('p14', '454-71-7847', 13, 'Delta', 'n110jn'),
('p15', '153-47-8101', 30, 'Delta', 'n110jn'),
('p16', '598-47-5172', 28, 'Spirit', 'n256ap'),
('p17', '865-71-6800', 36, 'Spirit', 'n256ap'),
('p18', '250-86-2784', 23, null, null),
('p19', '386-39-7881', 2, null, null),
('p2', '842-88-1257', 9, 'Delta', 'n106js'),
('p20', '522-44-3098', 28, null, null),
('p21', '621-34-5755', 2, null, null),
('p22', '177-47-9877', 3, null, null),
('p23', '528-64-7912', 12, null, null),
('p24', '803-30-1789', 34, null, null),
('p25', '986-76-1587', 13, null, null),
('p26', '584-77-5105', 20, null, null),
('p3', '750-24-7616', 11, 'American', 'n330ss'),
('p4', '776-21-8098', 24, 'American', 'n330ss'),
('p5', '933-93-2165', 27, 'American', 'n330ss'),
('p6', '707-84-4555', 38, 'United', 'n517ly'),
('p7', '450-25-5617', 13, 'United', 'n517ly'),
('p8', '701-38-2179', 12, 'United', 'n620la'),
('p9', '936-44-6941', 13, 'United', 'n620la');

INSERT INTO PASSENGER VALUES 
('p21', 771),
('p22', 374),
('p23', 414),
('p24', 292),
('p25', 390),
('p26', 302),
('p27', 470),
('p28', 208),
('p29', 292),
('p30', 686),
('p31', 547),
('p32', 257),
('p33', 564),
('p34', 211),
('p35', 233),
('p36', 293),
('p37', 552),
('p38', 812),
('p39', 541),
('p40', 441),
('p41', 875),
('p42', 691),
('p43', 572),
('p44', 572),
('p45', 663);

INSERT INTO ticket VALUES 
('tkt_dl_1', 450, 'DL_1174', 'p24', 'JFK'),
('tkt_dl_2', 225, 'DL_1174', 'p25', 'JFK'),
('tkt_am_3', 250, 'AM_1523', 'p26', 'LAX'),
('tkt_un_4', 175, 'UN_1899', 'p27', 'DCA'),
('tkt_un_5', 225, 'UN_523', 'p28', 'ATL'),
('tkt_un_6', 100, 'UN_523', 'p29', 'ORD'),
('tkt_sw_7', 400, 'SW_1776', 'p30', 'ORD'),
('tkt_sw_8', 175, 'SW_1776', 'p31', 'ORD'),
('tkt_sw_9', 125, 'SW_610', 'p32', 'HOU'),
('tkt_sw_10', 425, 'SW_610', 'p33', 'HOU'),
('tkt_dl_11', 500, 'DL_1243', 'p34', 'LAX'),
('tkt_dl_12', 250, 'DL_1243', 'p35', 'LAX'),
('tkt_sp_13', 225, 'SP_1880', 'p36', 'ATL'),
('tkt_sp_14', 150, 'SP_1880', 'p37', 'DCA'),
('tkt_un_15', 150, 'UN_523', 'p38', 'ORD'),
('tkt_sp_16', 475, 'SP_1880', 'p39', 'ATL'),
('tkt_am_17', 375, 'AM_1523', 'p40', 'ORD'),
('tkt_am_18', 275, 'AM_1523', 'p41', 'LAX');

INSERT INTO seat VALUES
('tkt_dl_1', '1C'), 
('tkt_dl_2', '2D'), 
('tkt_am_3', '3B'), 
('tkt_un_4', '2B'), 
('tkt_un_5', '1A'), 
('tkt_un_6', '3B'), 
('tkt_sw_7', '3C'), 
('tkt_sw_8', '3E'), 
('tkt_sw_9', '1C'), 
('tkt_sw_10', '1D'), 
('tkt_dl_11', '1E'), 
('tkt_dl_12', '2A'), 
('tkt_sp_13', '1A'), 
('tkt_sp_14', '2B'), 
('tkt_un_15', '1B'), 
('tkt_sp_16', '2C'), 
('tkt_am_17', '2B'), 
('tkt_am_18', '2A'), 
('tkt_dl_1', '2F'), 
('tkt_dl_11', '1B'), 
('tkt_dl_11', '2F'), 
('tkt_sp_16', '2E');

INSERT INTO contains VALUES
('circle_east_coast', 'leg_4'),
('circle_east_coast', 'leg_20'),
('circle_east_coast', 'leg_7'),
('circle_west_coast', 'leg_18'),
('circle_west_coast', 'leg_10'),
('circle_west_coast', 'leg_8'),
('eastbound_north_milk_run', 'leg_24'),
('eastbound_north_milk_run', 'leg_20'),
('eastbound_north_milk_run', 'leg_8'),
('eastbound_north_nonstop', 'leg_23'),
('eastbound_south_milk_run', 'leg_18'),
('eastbound_south_milk_run', 'leg_9'),
('eastbound_south_milk_run', 'leg_1'),
('hub_xchg_southeast', 'leg_25'),
('hub_xchg_southeast', 'leg_4'),
('hub_xchg_southwest', 'leg_22'),
('hub_xchg_southwest', 'leg_26'),
('local_texas', 'leg_12'),
('local_texas', 'leg_6'),
('northbound_east_coast', 'leg_3'),
('northbound_west_coast', 'leg_19'),
('southbound_midwest', 'leg_21'),
('westbound_north_milk_run', 'leg_16'),
('westbound_north_milk_run', 'leg_22'),
('westbound_north_milk_run', 'leg_19'),
('westbound_north_nonstop', 'leg_17'),
('westbound_south_nonstop', 'leg_27');

INSERT INTO license VALUES 
('p1', 'jet'),
('p10', 'jet'),
('p11', 'jet, prop'),
('p12', 'prop'),
('p13', 'jet'),
('p14', 'jet'),
('p15', 'jet, prop, testing'),
('p16', 'jet'),
('p17', 'jet, prop'),
('p18', 'jet'),
('p19', 'jet'),
('p2', 'jet, prop'),
('p20', 'jet'),
('p21', 'jet, prop'),
('p22', 'jet'),
('p23', 'jet'),
('p24', 'jet, prop, testing'),
('p25', 'jet'),
('p26', 'jet'),
('p3', 'jet'),
('p4', 'jet, prop'),
('p5', 'jet'),
('p6', 'jet, prop'),
('p7', 'jet'),
('p8', 'prop'),
('p9', 'jet, prop, testing');

