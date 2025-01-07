-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

use flight_management;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a database-wide unique location if
it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	DECLARE existing_count INTEGER;
    DECLARE existing_location VARCHAR(50);
    
    select count(*) into existing_count from airline where airlineID = ip_airlineID;
    if existing_count <> 1 then leave sp_main; end if;
    
    select count(*) into existing_count from airline a join airplane ap on a.airlineID = ap.airlineID
    where ap.airlineID = ip_airlineID and ap.tail_num = ip_tail_num;
    if existing_count = 1 then leave sp_main; end if;
    
    if ip_seat_capacity <= 0 or ip_speed <= 0 then leave sp_main; end if;
    
    if ip_plane_type = 'prop' and ip_skids = null then leave sp_main; end if;
	if ip_plane_type = 'prop' and ip_propellers = null then leave sp_main; end if;
    if ip_plane_type = 'jet' and ip_jet_engines = null then leave sp_main; end if;
    
    select locationID into existing_location from airplane where locationID = ip_locationID;
    if existing_location <> null then leave sp_main; end if;
    
    INSERT INTO airplane (airlineID, tail_num, seat_capacity, speed, locationID, plane_type, skids, propellers, jet_engines)
    VALUES (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);

end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a database-wide unique location if it will be used to support
airplane takeoffs and landings.  An airport may have a longer, more descriptive
name.  An airport must also have a city and state designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state char(2), in ip_locationID varchar(50))
sp_main: begin
	IF (SELECT COUNT(*) FROM airport WHERE airportID = ip_airportID OR
	locationID = ip_locationID) > 0 then leave sp_main; end if;
    
    if ip_city = NULL then leave sp_main; end if;
    if ip_state = NULL then leave sp_main; end if;
    
    INSERT into airport (airportID, airport_name, city, state, locationID)
    VALUES (ip_airportID, ip_airport_name, ip_city, ip_state, ip_locationID);

end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person may have a first and last name as well.

Also, a person can hold a pilot role, a passenger role, or both roles.  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  Also,
a pilot might be assigned to a specific airplane as part of the flight crew.  As a
passenger, a person will have some amount of frequent flyer miles. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_flying_airline varchar(50), in ip_flying_tail varchar(50),
    in ip_miles integer)
sp_main: begin
	if (SELECT COUNT(*) FROM person WHERE personID = ip_personID) > 0 then leave sp_main; end if;
    
    INSERT into person (personID, first_name, last_name, locationID)
    VALUES (ip_personID, ip_first_name, ip_last_name, ip_locationID);
    
    if (ip_experience IS NOT NULL AND ip_taxID IS NOT NULL) then 
    INSERT into pilot (personID, taxID, experience, flying_airline, flying_tail)
    VALUES (ip_personID, ip_taxID, ip_experience, ip_flying_airline, ip_flying_tail); end if;
    
    if (ip_miles IS NOT NULL) then
    INSERT into passenger (personID, miles) 
    VALUES (ip_personID, ip_miles); end if;
end //
delimiter ;

-- [4] grant_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new pilot license.  The license must reference
a valid pilot, and must be a new/unique type of license for that pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_pilot_license;
delimiter //
create procedure grant_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	if (SELECT count(*) from pilot_licenses where personID = ip_personID AND
    license = ip_license) > 0 then leave sp_main; end if;
    
    if (SELECT count(*) from pilot where personID = ip_personID) <> 1 then leave sp_main; end if;
    
    INSERT into pilot_licenses (personID, license)
    VALUES (ip_personID, ip_license);
end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  Once
an airplane has been assigned, we must also track where the airplane is along
the route, whether it is in flight or on the ground, and when the next action -
takeoff or landing - will occur. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_airplane_status varchar(100), in ip_next_time time)
sp_main: begin
	if (SELECT count(*) from route where routeID = ip_routeID) <> 1 then leave sp_main; end if;
    
    if (SELECT count(*) from flight where flightID = ip_flightID) > 0 then leave sp_main; end if;
    
    INSERT into flight (flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time)
    VALUES (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, ip_airplane_status, ip_next_time);
end //
delimiter ;

-- [6] purchase_ticket_and_seat()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ticket.  The cost of the flight is optional
since it might have been a gift, purchased with frequent flyer miles, etc.  Each
flight must be tied to a valid person for a valid flight.  Also, we will make the
(hopefully simplifying) assumption that the departure airport for the ticket will
be the airport at which the traveler is currently located.  The ticket must also
explicitly list the destination airport, which can be an airport before the final
airport on the route.  Finally, the seat must be unoccupied. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ticket_and_seat;
delimiter //
create procedure purchase_ticket_and_seat (in ip_ticketID varchar(50), in ip_cost integer,
	in ip_carrier varchar(50), in ip_customer varchar(50), in ip_deplane_at char(3),
    in ip_seat_number varchar(50))
sp_main: begin
	declare this_seat int default 0;
    
    select count(*) into this_seat from ticket_seats where seat_number = ip_seat_number;
    
    if this_seat > 0 then 
		leave sp_main;
	end if;
    
    insert into ticket (ticketID, cost, carrier, customer, deplane_at)
    values (ip_ticketID, ip_cost, ip_carrier, ip_customer, ip_deplane_at);
    insert into ticket_seats (ticketID, seat_number) values (ip_ticketID, ip_seat_number);
end //
delimiter ;

-- [7] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new leg as specified.  However, if a leg from
the departure airport to the arrival airport already exists, then don't create a
new leg - instead, update the existence of the current leg while keeping the existing
identifier.  Also, all legs must be symmetric.  If a leg in the opposite direction
exists, then update the distance to ensure that it is equivalent.   */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (in ip_legID varchar(50), in ip_distance integer,
    in ip_departure char(3), in ip_arrival char(3))
sp_main: begin
	declare already_exist_legID varchar(50);
    declare already_exist_distance int;
    
    select legID, distance into already_exist_legID, already_exist_distance from leg
    where (departure = ip_departure and arrival = ip_arrival) or (departure = ip_arrival and arrival = ip_departure);
    if already_exist_legID is not null then
		if already_exist_distance <> ip_distance then
			update leg
            set distance = ip_distance
            where legID = already_exist_legID;
		end if;
	else
		insert into leg (legID, distance, departure, arrival)
        values (ip_legID, ip_distance, ip_departure, ip_arrival);
	end if;
end //
delimiter ;

-- [8] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route.  Routes in our
system must be created in the sequential order of the legs.  The first leg of
the route can be any valid leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
	insert into route(routeID) values (ip_routeID);
	insert into route_path (routeID, legID, sequence) values (ip_routeID, ip_legID, 1);
end //
delimiter ;

-- [9] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route.  Routes
in our system must be created in the sequential order of the legs, and the route
must be contiguous: the departure airport of this leg must be the same as the
arrival airport of the previous leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
	declare last_leg varchar(50);
    declare last_leg_sequence int;
    declare last_arrival char(3);
    declare new_departure char(3);
    
    select max(sequence) into last_leg_sequence from route_path where routeID = ip_routeID;
    if last_leg_sequence is null then
		leave sp_main;
    end if;
    
    select legID into last_leg from route_path where routeID = ip_routeID and sequence = last_leg_sequence;
    select arrival into last_arrival from leg where legID = last_leg;
    select departure into new_departure from leg where legID = ip_legID;
    
    if last_arrival <> new_departure then 
		leave sp_main;
	end if;
    insert into route_path (routeID, legID, sequence) values (ip_routeID, ip_legID, last_leg_sequence + 1);
end //
delimiter ;

-- [10] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
    declare current_tail varchar(50);
    declare current_legID varchar(50);
	declare current_distance int;
    
    update flight 
    set airplane_status = 'on_ground'
	where flightID = ip_flightID;
    
	update flight
    set next_time = next_time + interval 1 hour
    where flightID = ip_flightID;
    
    select support_tail into current_tail from flight where flightID = ip_flightID;
    
    update pilot
    set experience = experience + 1
    where flying_tail = current_tail;
    
    select legID into current_legID from route_path 
    where routeID = (select routeID from flight where flightID = ip_flightID limit 1) limit 1;
    select distance into current_distance from leg where legID = current_legID;
    
    update passenger 
    set miles = miles + current_distance
    where personID in (select customer from ticket where carrier = ip_flightID);
end //
delimiter ;

-- [11] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
	declare airplane_type varchar(100);
    declare pilot_count int;
    declare current_legID varchar(50);
    declare leg_distance int;
    declare airplane_speed int;
    declare time_to_next int;
        
    select plane_type, speed into airplane_type, airplane_speed from airplane where tail_num = (select support_tail from flight where flightID = ip_flightID);
    select count(*) into pilot_count from pilot where flying_tail = (select support_tail from flight where flightID = ip_flightID);
    
	select legID into current_legID from route_path 
    where routeID = (select routeID from flight where flightID = ip_flightID) and sequence = 1;
    select distance into leg_distance from leg where legID = current_legID;
    
	set time_to_next = leg_distance / airplane_speed;
    
    if airplane_type = 'prop' then
		if pilot_count < 1 then
			update flight
			set next_time = next_time + interval 0.5 hour
			where flightID = ip_flightID;
            leave sp_main;
		end if;
	else if airplane_type = 'jet' then
		if pilot_count < 2 then
			update flight
			set next_time = next_time + interval 0.5 hour
			where flightID = ip_flightID;
            leave sp_main;
		end if;
	end if;
    end if;
    update flight
    set progress = progress + 1
    where flightID = ip_flightID;
	update flight 
	set airplane_status = 'in_flight'
	where flightID = ip_flightID;
	update flight
	set next_time = next_time + interval time_to_next hour
	where flightID = ip_flightID;
end //
delimiter ;

-- [12] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the airport and hold a valid ticket
for the flight. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	update person
    set locationID = (select locationID from airplane join flight 
    on airlineID = support_airline and tail_num = support_tail where flightID = ip_flightID)
    where locationID in (select locationID from airport)
    and personID in (select customer from ticket where carrier = ip_flightID);
end //
delimiter ;

-- [13] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS passengers_disembark;
DELIMITER //
CREATE PROCEDURE passengers_disembark (IN ip_flightID VARCHAR(50))
sp_main: BEGIN
    update person
    set locationID = (select locationID from airport   join leg on arrival = airportID 	   join route_path on route_path.legID = leg.legID   join flight on progress = sequence and route_path.routeID = flight.routeID   where flightID = ip_flightID)  -- set person be at the airport plane is at
    where locationID = (select locationID from flight join airplane on support_airline=airlineID and support_tail=tail_num where flightID = ip_flightID)
    and (select locationID from airport join leg on arrival = airportID 	join route_path on route_path.legID = leg.legID   join flight on progress = sequence and route_path.routeID = flight.routeID  where flightID = ip_flightID)   -- set person be at the airport plane is at
     = (select locationID from airport join ticket on deplane_at = airportID where carrier = ip_flightID and customer = personID);
END //
DELIMITER ;

-- [14] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
airplane.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS assign_pilot;
DELIMITER //
CREATE PROCEDURE assign_pilot (IN ip_flightID VARCHAR(50), IN ip_personID VARCHAR(50))
sp_main: BEGIN
    if (select plane_type from flight join airplane on support_airline=airlineID and support_tail=tail_num where flightID = ip_flightID)
	in (select license from pilot_licenses where personID = ip_personID)	
	and (select airport.locationID from airport   
    join leg on arrival = airportID 		
	join route_path on route_path.legID = leg.legID 
    join flight on progress = sequence and route_path.routeID = flight.routeID   
    where flightID = ip_flightID) 
	= (select locationID from person where personID = ip_personID)  	
    and (select flying_airline from pilot where personID = ip_personID) is null
    and (select flying_tail from pilot where personID = ip_personID) is null
	then
		update pilot join person join flight
        set flying_airline = support_airline,
        flying_tail = support_tail,
        person.locationID = (select locationID from flight join airplane on support_airline=airlineID and support_tail=tail_num where flightID = ip_flightID)
        where pilot.personID = ip_personID and person.personID = ip_personID and flightID = ip_flightID;
	end if;
END //

DELIMITER ;

-- [15] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin
	
end //
delimiter ;

-- [16] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
	if (select airplane_status from flight where flightID = ip_flightID) = 'on_ground' 
	and ((select progress from flight where flightID = ip_flightID) = 0 				
	or (select progress from flight where flightID = ip_flightID) >= 				
	all(select sequence from route_path join flight on route_path.routeID= flight.routeID where flightID = ip_flightID)) then
	delete from flight where flightID = ip_flightID;
	end if;
end //
delimiter ;

-- [17] remove_passenger_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the passenger role from person.  The passenger
must be on the ground at the time; and, if they are on a flight, then they must
disembark the flight at the current airport.  If the person had both a pilot role
and a passenger role, then the person and pilot role data should not be affected.
If the person only had a passenger role, then all associated person data must be
removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_passenger_role;
delimiter //
create procedure remove_passenger_role (in ip_personID varchar(50))
sp_main: begin
	IF (ip_personID in (select personID from person where locationID like 'port_%'))
    THEN delete from passenger where personID = ip_personID;
    IF (ip_personID not in (select personID from pilot))
    THEN delete from person where personID = ip_personID;
    END IF;
    END IF;
end //
delimiter ;

-- [18] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the pilot role from person.  The pilot must not
be assigned to a flight; or, if they are assigned to a flight, then that flight
must either be at the start or end of its route.  If the person had both a pilot
role and a passenger role, then the person and passenger role data should not be
affected.  If the person only had a pilot role, then all associated person data
must be removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_personID varchar(50))
sp_main: begin
	declare pilot_count int default 0;
    declare passenger_count int default 0;
    declare flight_count int default 0;
	declare pilot_routeID varchar(50);
	declare current_sequence int;
    declare end_leg_sequence int;
    
    select count(*) into pilot_count from pilot where personID = ip_personID;
    if pilot_count = 0 then
        leave sp_main;
    end if;
    
    select count(*) into passenger_count from passenger where personID = ip_personID;
    
    select count(*) into flight_count from pilot
    where flying_tail in (select support_tail from flight);
    
    select routeID into pilot_routeID from flight where support_tail = 
    (select flying_tail from pilot where personID = ip_personID);
    
    if flight_count > 0 then
		select progress into current_sequence from flight where routeID = pilot_routeID;
		select sequence into end_leg_sequence from route_path where routeID = pilot_routeID;
        if current_sequence <> 1 or current_sequence <> end_leg_sequence then
			leave sp_main;
		end if;
    end if;
    
	delete from pilot_licenses where personID = ip_personID;
	delete from pilot where personID = ip_personID;

	if passenger_count <= 0 then
		delete from person where personID = ip_personID;
	end if;
end //
delimiter ;

-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
    select departure, arrival, 1, flightID, next_time, next_time, locationID
    from flight f join route_path r on f.routeID = r.routeID join leg l on
    r.legID = l.legID join airplane a on f.support_tail = a.tail_num AND f.support_airline = a.airlineID
    where f.airplane_status = 'in_flight' and f.progress = r.sequence;

-- [20] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
    select departure, 1, flightID, next_time, next_time, locationID
    from flight f join route_path r on f.routeID = r.routeID join leg l
    on r.legID = l.legID join airplane a on f.support_tail = a.tail_num AND f.support_airline = a.airlineID
    where f.airplane_status = 'on_ground' and f.progress + 1 = r.sequence;

-- [21] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
    airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
    num_passengers, joint_pilots_passengers, person_list) as
    select departure, 
    arrival, 
    1, 
    a.locationID, flightID, next_time, next_time, 
    count(CASE WHEN person.personID in (select pilot.personID from pilot) and person.locationID = a.locationID THEN 1 END),
    count(CASE WHEN person.personID in (select passenger.personID from passenger) and person.locationID = a.locationID THEN 1 END),
    count(*),
    GROUP_CONCAT(person.personID SEPARATOR ',')
    from flight f 
    join route_path r on f.routeID = r.routeID 
    join leg l on r.legID = l.legID 
    join airplane a on f.support_tail = a.tail_num AND f.support_airline = a.airlineID
    join person on person.locationID = a.locationID
    where f.airplane_status = 'in_flight' and f.progress = r.sequence
    group by l.departure, l.arrival, a.locationID, next_time, next_time, flightID;

-- [22] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
    city, state, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select airportID as departing_from,
person.locationID as airport,
airport_name,
city,
state,
count(CASE WHEN person.personID in (select pilot.personID from pilot) THEN 1 END),
count(CASE WHEN person.personID in (select passenger.personID from passenger) THEN 1 END),
count(*),
GROUP_CONCAT(person.personID SEPARATOR ',')
from person, airport as ap
where person.locationID = ap.locationID
group by departing_from;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select route_path.routeID, 
count(*) as num_legs, 
GROUP_CONCAT(route_path.legID Order by sequence SEPARATOR ',') as leg_sequence,
SUM(leg.distance),
COALESCE(F.num_flights, 0),
F.flight_list, 
GROUP_CONCAT(
        CONCAT_WS('->', leg.departure, leg.arrival) ORDER BY sequence SEPARATOR ',')
from route_path
JOIN leg ON FIND_IN_SET(leg.legID, route_path.legID)
LEFT JOIN (
    SELECT flight.routeID, COUNT(*) as num_flights, GROUP_CONCAT(flightID SEPARATOR ',') AS flight_list
    FROM flight
    GROUP BY flight.routeID
) F ON route_path.routeID = F.routeID
group by route_path.routeID;
#select null, 0, null, 0, 0, null, null;

-- [24] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, num_airports,
    airport_code_list, airport_name_list) as
select city, state, 
count(*) as num_airports,
GROUP_CONCAT(airportID order by airportID SEPARATOR ',') as airport_code_list, 
GROUP_CONCAT(airport_name order by airportID SEPARATOR ',') as airport_name_list from airport 
group by city, state
having num_airports >= 2;

-- [25] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

end //
delimiter ;
