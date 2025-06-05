-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE 1 (Airline Performance Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE airline_performance_report(
    IN reportYear INT
)
BEGIN
    -- Calculating total ticket sales and revenue per airline
    WITH AirlinePerformance AS (
        SELECT
            a.airline_id,
            a.name AS Airline,
            COUNT(t.ticket_id) AS Total_Tickets_Sold,
            IFNULL(SUM(t.price), 0) AS Total_Revenue,
            RANK() OVER (ORDER BY SUM(t.price) DESC) AS Revenue_Rank
        FROM ticket t
        JOIN flight f ON t.flight_id = f.flight_id
        JOIN airline a ON f.airline_id = a.airline_id
        WHERE YEAR(t.booking_date) = reportYear
        GROUP BY a.airline_id, a.name
    ),
    -- Calculating the total market-wide statistics for ticket sales and revenue
    TotalMarket AS (
        SELECT
            SUM(Total_Tickets_Sold) AS Market_Total_Tickets,
            SUM(Total_Revenue) AS Market_Total_Revenue
        FROM AirlinePerformance
    )
    -- Generating the final airline performance report
    SELECT
        ap.Revenue_Rank,
        ap.Airline,
        ap.Total_Tickets_Sold,
        ap.Total_Revenue,
        ROUND((ap.Total_Tickets_Sold / NULLIF(tm.Market_Total_Tickets, 0)) * 100, 2) AS Ticket_Share_Percentage,
        ROUND((ap.Total_Revenue / NULLIF(tm.Market_Total_Revenue, 0)) * 100, 2) AS Revenue_Share_Percentage
    FROM AirlinePerformance ap
    CROSS JOIN TotalMarket tm
    ORDER BY ap.Revenue_Rank
    LIMIT 5;
END $$
DELIMITER ;

CALL airline_performance_report(2023);
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE 2 (Flight Performance Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE flight_performance_report(IN flightNumber VARCHAR(10))
BEGIN
    -- Retrieving flight details and total seats for the given flight number
    WITH FlightInfo AS (
        SELECT
            f.flight_id,
            f.flight_number,
            a.total_seats
        FROM flight f
        JOIN aircraft a ON f.aircraft_id = a.aircraft_id
        WHERE f.flight_number = flightNumber
    ),
    -- Calculating total tickets sold and revenue generated for the given flight number
    TicketStats AS (
        SELECT
            t.flight_id,
            COUNT(*) AS tickets_sold,
            IFNULL(SUM(t.price), 0) AS total_revenue
        FROM ticket t
        JOIN flight f ON t.flight_id = f.flight_id
        WHERE f.flight_number = flightNumber
        GROUP BY t.flight_id
    )
    -- Combining flight details with ticket statistics
    SELECT
        fi.flight_number AS Flight_Number,
        fi.total_seats AS Total_Seats,
        ts.tickets_sold AS Tickets_Sold,
        ROUND((ts.tickets_sold / NULLIF(fi.total_seats, 0)) * 100, 2) AS Seat_Utilization_Percentage,
        ts.total_revenue AS Total_Revenue
    FROM FlightInfo fi
    LEFT JOIN TicketStats ts ON fi.flight_id = ts.flight_id;

END $$
DELIMITER ;

CALL flight_performance_report('AZ306');
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE 3 (Flight Type Comparison Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE flight_type_comparison_report(
    IN reportYear INT,
    IN airlineName VARCHAR(255)
)
BEGIN
    -- Categorizing flights as either Domestic or International based on departure and arrival country
    WITH FlightCategory AS (
        SELECT
            f.flight_id,
            a.name AS Airline,
            IF(da.country = aa.country, 'Domestic', 'International') AS Flight_Type
        FROM flight f
        JOIN airline a ON f.airline_id = a.airline_id
        JOIN airport da ON f.departure_airport_id = da.airport_id
        JOIN airport aa ON f.arrival_airport_id = aa.airport_id
        WHERE YEAR(f.departure_time) = reportYear
          AND a.name = airlineName
    ),
    -- Summarizing the total number of flights for each flight type (Domestic/International)
    CategorySummary AS (
        SELECT
            Flight_Type,
            COUNT(f.flight_id) AS Total_Flights
        FROM FlightCategory f
        GROUP BY Flight_Type
    ),
    -- Calculating the grand total of all flights for percentage calculation
    TotalFlights AS (
        SELECT SUM(Total_Flights) AS Grand_Total FROM CategorySummary
    )
    -- Retrieving the number of flights per category along with their percentage share
    SELECT
        cs.Flight_Type,
        cs.Total_Flights,
        ROUND((cs.Total_Flights / NULLIF(tf.Grand_Total, 0)) * 100, 2) AS Flight_Percentage
    FROM CategorySummary cs
    CROSS JOIN TotalFlights tf
    ORDER BY cs.Total_Flights DESC;
END $$
DELIMITER ;

CALL flight_type_comparison_report(2020, 'American Airlines');
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------