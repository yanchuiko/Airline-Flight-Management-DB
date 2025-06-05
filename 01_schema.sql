-- ==========================================================================================================================================================================================
-- DATABASE: Airline Flight Management Database
-- ==========================================================================================================================================================================================
CREATE DATABASE airline_db;
DROP DATABASE airline_db;
USE airline_db;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AIRPORT
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE airport (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    iata_code CHAR(3) UNIQUE NOT NULL,
    icao_code CHAR(4) UNIQUE NOT NULL,
    time_zone VARCHAR(50) NOT NULL
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AIRLINE
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE airline (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    iata_code CHAR(3) UNIQUE NOT NULL,
    icao_code CHAR(4) UNIQUE NOT NULL
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AIRCRAFT
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE aircraft (
    aircraft_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT NOT NULL,
    model VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(100) NOT NULL,
    year YEAR NOT NULL,
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    total_seats INT CHECK (total_seats > 0),
    flight_range INT CHECK (flight_range > 0),
    FOREIGN KEY (airline_id) REFERENCES airline(airline_id) ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FLIGHT
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE flight (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    departure_airport_id INT NOT NULL,
    arrival_airport_id INT NOT NULL,
    flight_number VARCHAR(10) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    distance INT CHECK (distance > 0),
    FOREIGN KEY (airline_id) REFERENCES airline(airline_id) ON DELETE CASCADE,
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id) ON DELETE CASCADE,
    FOREIGN KEY (departure_airport_id) REFERENCES airport(airport_id) ON DELETE CASCADE,
    FOREIGN KEY (arrival_airport_id) REFERENCES airport(airport_id) ON DELETE CASCADE,
    UNIQUE (airline_id, flight_number)
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PASSENGER
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE passenger (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    passport_number VARCHAR(64) UNIQUE NOT NULL
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TICKET
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE ticket (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    booking_reference VARCHAR(20) UNIQUE NOT NULL,
    booking_date DATE NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    class ENUM('economy', 'business', 'first') NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    FOREIGN KEY (flight_id) REFERENCES flight(flight_id) ON DELETE CASCADE,
    FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id) ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BAGGAGE
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE baggage (
    baggage_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    weight DECIMAL(5,2) CHECK (weight > 0),
    type ENUM('carry_on', 'checked') NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENT
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    amount DECIMAL(10,2) CHECK (amount > 0),
    method ENUM('credit_card', 'debit_card', 'cash', 'bank_transfer') NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id) ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREW
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE crew (
    crew_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('pilot', 'co_pilot', 'engineer', 'purser', 'flight_attendant') NOT NULL,
    experience_years INT CHECK (experience_years >= 0)
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FLIGHT CREW
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE flight_crew (
    flight_crew_id INT PRIMARY KEY AUTO_INCREMENT,
    crew_id INT NOT NULL,
    flight_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    shift_start TIME NOT NULL,
    shift_end TIME NOT NULL,
    FOREIGN KEY (crew_id) REFERENCES crew(crew_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES flight(flight_id) ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELAY
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE delay (
    delay_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    duration INT CHECK (duration > 0),
    reason TEXT NOT NULL,
    reported_time DATETIME NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flight(flight_id) ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CANCELLATION
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE cancellation (
    cancellation_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    reason TEXT NOT NULL,
    cancellation_date DATETIME NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flight(flight_id) ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LOG
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_values TEXT,
    new_values TEXT
);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------