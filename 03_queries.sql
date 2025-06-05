-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERY 1 (Seasonal Flight Revenue Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH SeasonalRevenue AS (
    -- Categorizing flights based on departure month into seasonal groups
    SELECT
        CASE
            WHEN MONTH(f.departure_time) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(f.departure_time) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(f.departure_time) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Fall'
        END AS Season,
        COUNT(DISTINCT f.flight_id) AS Total_Flights,
        IFNULL(SUM(t.price), 0) AS Total_Revenue
    FROM flight f
    JOIN aircraft a ON f.aircraft_id = a.aircraft_id
    LEFT JOIN ticket t ON f.flight_id = t.flight_id
    WHERE YEAR(f.departure_time) = 2024
    GROUP BY Season
)
-- Retrieving the seasonal revenue summary
SELECT
    Season,
    Total_Flights,
    Total_Revenue
FROM SeasonalRevenue
ORDER BY Total_Revenue DESC;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERY 2 (High-Spending Passengers Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH PassengerSpending AS (
    -- Summarizing passenger spending and flight details
    SELECT
        p.passenger_id,
        p.first_name,
        p.last_name,
        SUM(t.price) AS Total_Spending,
        COUNT(t.ticket_id) AS Flights_Taken,
        ROUND(SUM(t.price) / NULLIF(COUNT(t.ticket_id), 0), 2) AS Avg_Spending_Per_Flight,
        -- Identifying the passenger’s most frequently used airline
        (SELECT a.name
         FROM ticket t2
         JOIN flight f2 ON t2.flight_id = f2.flight_id
         JOIN airline a ON f2.airline_id = a.airline_id
         WHERE t2.passenger_id = p.passenger_id
         GROUP BY a.name
         ORDER BY COUNT(t2.ticket_id) DESC
         LIMIT 1) AS Preferred_Airline
    FROM passenger p
    JOIN ticket t ON p.passenger_id = t.passenger_id
    WHERE YEAR(t.booking_date) = 2024
    GROUP BY p.passenger_id, p.first_name, p.last_name
)
-- Retrieving the top 5 highest-spending passengers
SELECT
    passenger_id AS Passenger_ID,
    first_name AS First_Name,
    last_name AS Last_Name,
    Flights_Taken,
    Avg_Spending_Per_Flight,
    Total_Spending,
    Preferred_Airline
FROM PassengerSpending
ORDER BY Total_Spending DESC
LIMIT 5;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERY 3 (High-Revenue Flight Routes Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH RouteRevenue AS (
    -- Calculating revenue and ticket sales for each flight route
    SELECT
        f.departure_airport_id,
        f.arrival_airport_id,
        COUNT(t.ticket_id) AS Total_Tickets_Sold,
        IFNULL(SUM(t.price), 0) AS Total_Revenue,
        ROUND(IFNULL(SUM(t.price), 0) / NULLIF(COUNT(DISTINCT f.flight_id), 0), 2) AS Avg_Revenue_Per_Flight
    FROM flight f
    JOIN ticket t ON f.flight_id = t.flight_id
    WHERE YEAR(t.booking_date) = 2023
    GROUP BY f.departure_airport_id, f.arrival_airport_id
)
-- Retrieving the top 3 highest-revenue flight routes
SELECT
    da.name AS Departure_Airport,
    da.city AS Departure_City,
    aa.name AS Arrival_Airport,
    aa.city AS Arrival_City,
    rr.Total_Tickets_Sold,
    rr.Total_Revenue
FROM RouteRevenue rr
JOIN airport da ON rr.departure_airport_id = da.airport_id
JOIN airport aa ON rr.arrival_airport_id = aa.airport_id
ORDER BY rr.Total_Revenue DESC
LIMIT 3;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERY 4 (Busiest Airports Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH AirportTraffic AS (
    -- Calculating airport traffic based on departures and arrivals
    SELECT
        a.airport_id,
        a.name AS Airport,
        a.city AS City,
        a.country AS Country,
        SUM(IF(f.departure_airport_id = a.airport_id, 1, 0)) AS Departures,
        SUM(IF(f.arrival_airport_id = a.airport_id, 1, 0)) AS Arrivals
    FROM airport a
    JOIN flight f ON a.airport_id IN (f.departure_airport_id, f.arrival_airport_id)
    WHERE YEAR(f.departure_time) = 2024
    GROUP BY a.airport_id, a.name, a.city, a.country
)
-- Retrieving the top 5 busiest airports based on total traffic (departures + arrivals)
SELECT
    Airport,
    City,
    Country,
    Departures,
    Arrivals,
    (Departures + Arrivals) AS Total_Traffic
FROM AirportTraffic
ORDER BY Total_Traffic DESC
LIMIT 5;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERY 5 (Airline Operational Performance Report)
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH AirlineOperations AS (
    -- Calculating delays and cancellations per flight
    SELECT
        f.flight_id,
        a.name AS Airline,
        COUNT(d.delay_id) AS Total_Delays,
        COUNT(c.cancellation_id) AS Total_Cancellations
    FROM flight f
    JOIN airline a ON f.airline_id = a.airline_id
    LEFT JOIN delay d ON f.flight_id = d.flight_id
    LEFT JOIN cancellation c ON f.flight_id = c.flight_id
    LEFT JOIN ticket t ON f.flight_id = t.flight_id
    WHERE YEAR(f.departure_time) = 2017
    GROUP BY f.flight_id, a.name
    HAVING COUNT(d.delay_id) > 0 OR COUNT(c.cancellation_id) > 0
)
-- Summarizing operational performance for each airline
SELECT
    Airline,
    COUNT(f.flight_id) AS Total_Flights,
    SUM(Total_Delays) AS Total_Delays,
    SUM(Total_Cancellations) AS Total_Cancellations,
    ROUND((SUM(Total_Delays) / NULLIF(COUNT(f.flight_id), 0)) * 100, 2) AS Delay_Percentage,
    ROUND((SUM(Total_Cancellations) / NULLIF(COUNT(f.flight_id), 0)) * 100, 2) AS Cancellation_Percentage
FROM AirlineOperations f
GROUP BY Airline
ORDER BY Total_Flights DESC;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------