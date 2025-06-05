# Airline Flight Management Database

## Overview

The **Airline Flight Management Database** is a comprehensive relational database system designed to manage and analyze airline operations, including flights, passengers, bookings, crew, baggage, payments, delays, and cancellations. It supports advanced reporting, integrity enforcement, and audit logging through SQL queries, stored procedures, and triggers.

## Features

- **Schema Design:** Normalized tables for airports, airlines, aircraft, flights, passengers, tickets, baggage, payments, crew, delays, cancellations, and logs.
- **Data Integrity:** Triggers to prevent overbooking and to log critical updates.
- **Advanced Reporting:** Predefined queries and stored procedures for performance, revenue, and operational analytics.
- **Sample Data:** Realistic sample data for all entities to support testing and demonstration.

## File Structure

- [`01_schema.sql`](01_schema.sql): Database schema definitions (tables, constraints).
- [`02_data.sql`](02_data.sql): Sample data inserts for all tables.
- [`03_queries.sql`](03_queries.sql): Analytical queries for reporting.
- [`04_procedures.sql`](04_procedures.sql): Stored procedures for advanced reports.
- [`05_triggers.sql`](05_triggers.sql): Triggers for business rules and logging.

## Setup Instructions

1. **Create the Database:**
   - Run the statements in [`01_schema.sql`](01_schema.sql) to create the schema.

2. **Insert Sample Data:**
   - Execute [`02_data.sql`](02_data.sql) to populate the tables.

3. **Add Queries, Procedures, and Triggers:**
   - Run [`03_queries.sql`](03_queries.sql) for analytical queries.
   - Run [`04_procedures.sql`](04_procedures.sql) to create stored procedures.
   - Run [`05_triggers.sql`](05_triggers.sql) to enable triggers.

4. **Usage:**
   - Use the provided queries and procedures to generate reports and analyze airline operations.
   - The triggers will automatically enforce overbooking prevention and log important changes.

## Requirements

- MySQL 8.0+ (or compatible RDBMS supporting standard SQL, CTEs, triggers, and window functions).

## Key Concepts

- **Overbooking Prevention:** Ensures no flight is booked beyond its seat capacity.
- **Change Logging:** Tracks updates to critical fields in `flight` and `ticket` tables.
- **Reporting:** Includes seasonal revenue, high-spending passengers, busiest airports, and more.
