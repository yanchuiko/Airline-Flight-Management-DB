-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGER 1 (Prevent Overbooking)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER prevent_overbooking
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
    DECLARE max_seats INT;
    DECLARE current_bookings INT;

    -- Retrieving the total number of seats for the aircraft assigned to the specific flight
    SELECT a.total_seats INTO max_seats
    FROM flight f
    JOIN aircraft a ON f.aircraft_id = a.aircraft_id
    WHERE f.flight_id = NEW.flight_id;

    -- Counting the number of tickets already booked for this flight
    SELECT COUNT(*) INTO current_bookings
    FROM ticket
    WHERE flight_id = NEW.flight_id;

    -- Preventing booking if the number of tickets reaches or exceeds the aircraft's seat capacity
    IF current_bookings >= max_seats THEN
        SIGNAL SQLSTATE '45000'-- MySQL Custom Error
        SET MESSAGE_TEXT = 'This flight is fully booked. No more tickets can be issued.';
    END IF;
END;
$$
DELIMITER ;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRIGGER 2 (Logging)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER flight_update
AFTER UPDATE ON flight
FOR EACH ROW
BEGIN
    DECLARE old_values TEXT DEFAULT '';
    DECLARE new_values TEXT DEFAULT '';
    DECLARE change_detected BOOLEAN DEFAULT FALSE;

    -- Checking if the flight number, departure time, or arrival time has been updated
    IF OLD.flight_number <> NEW.flight_number THEN
        SET old_values = CONCAT(old_values, 'flight_number: ', OLD.flight_number, '; ');
        SET new_values = CONCAT(new_values, 'flight_number: ', NEW.flight_number, '; ');
        SET change_detected = TRUE;
    END IF;

    IF OLD.departure_time <> NEW.departure_time THEN
        SET old_values = CONCAT(old_values, 'departure_time: ', OLD.departure_time, '; ');
        SET new_values = CONCAT(new_values, 'departure_time: ', NEW.departure_time, '; ');
        SET change_detected = TRUE;
    END IF;

    IF OLD.arrival_time <> NEW.arrival_time THEN
        SET old_values = CONCAT(old_values, 'arrival_time: ', OLD.arrival_time, '; ');
        SET new_values = CONCAT(new_values, 'arrival_time: ', NEW.arrival_time, '; ');
        SET change_detected = TRUE;
    END IF;

    -- If any of the above fields have changed, log the old and new values
    IF change_detected THEN
        SET old_values = TRIM(TRAILING '; ' FROM old_values);
        SET new_values = TRIM(TRAILING '; ' FROM new_values);

        INSERT INTO log (table_name, record_id, changed_by, change_timestamp, old_values, new_values)
        VALUES ('FLIGHT', OLD.flight_id, CURRENT_USER(), NOW(), old_values, new_values);
    END IF;
END$$

CREATE TRIGGER ticket_update
AFTER UPDATE ON ticket
FOR EACH ROW
BEGIN
    DECLARE old_values TEXT DEFAULT '';
    DECLARE new_values TEXT DEFAULT '';
    DECLARE change_detected BOOLEAN DEFAULT FALSE;

    -- Checking if the seat number, class, or price has been updated
    IF OLD.seat_number <> NEW.seat_number THEN
        SET old_values = CONCAT(old_values, 'seat_number: ', OLD.seat_number, '; ');
        SET new_values = CONCAT(new_values, 'seat_number: ', NEW.seat_number, '; ');
        SET change_detected = TRUE;
    END IF;

    IF OLD.class <> NEW.class THEN
        SET old_values = CONCAT(old_values, 'class: ', OLD.class, '; ');
        SET new_values = CONCAT(new_values, 'class: ', NEW.class, '; ');
        SET change_detected = TRUE;
    END IF;

    IF OLD.price <> NEW.price THEN
        SET old_values = CONCAT(old_values, 'price: ', OLD.price, '; ');
        SET new_values = CONCAT(new_values, 'price: ', NEW.price, '; ');
        SET change_detected = TRUE;
    END IF;

    -- If any of the above fields have changed, log the old and new values
    IF change_detected THEN
        SET old_values = TRIM(TRAILING '; ' FROM old_values);
        SET new_values = TRIM(TRAILING '; ' FROM new_values);

        INSERT INTO log (table_name, record_id, changed_by, change_timestamp, old_values, new_values)
        VALUES ('TICKET', OLD.ticket_id, CURRENT_USER(), NOW(), old_values, new_values);
    END IF;
END$$
DELIMITER ;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------