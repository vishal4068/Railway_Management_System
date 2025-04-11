/*
################################################################################################################################################
# PROJECT NAME: Railway Management System
# SQUAD 3: Train Techies 
# MEMBERS: Manyam Kushmanth Reddy(52312400), Garje Vishal Anil(52312349), Gopi krishna (52311889), Murali R (52313863)
# NORMALIZATION LEVEL: 3NF
################################################################################################################################################
*/
 

-----------------------------------------DROP----------------------------------------

DROP SEQUENCE SEQ_CANCELLATION;
DROP SEQUENCE SEQ_PASSENGER;
DROP SEQUENCE SEQ_BOOKING;
DROP SEQUENCE SEQ_SEATAVAIL;
DROP SEQUENCE SEQ_COACH;
DROP SEQUENCE SEQ_ROUTE;
DROP SEQUENCE SEQ_TRAIN;
DROP SEQUENCE SEQ_USER; 
DROP SEQUENCE SEQ_STATION;
DROP SEQUENCE SEQ_PNR;

DROP TABLE CANCELLATION;
DROP TABLE ROUTE;
DROP TABLE PASSENGER;
DROP TABLE COACH;
DROP TABLE BOOKING;
DROP TABLE USERS;
DROP TABLE TRAIN;
DROP TABLE STATION;

-- TRUNCATE TABLE CANCELLATION;
-- TRUNCATE TABLE ROUTE;
-- TRUNCATE TABLE PASSENGER;
-- TRUNCATE TABLE COACH;
-- TRUNCATE TABLE BOOKING;
-- TRUNCATE TABLE USERS;
-- TRUNCATE TABLE TRAIN;
-- TRUNCATE TABLE STATION;

---------------------------------------------Tables----------------------------------------

 --Station Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy

CREATE SEQUENCE SEQ_STATION START WITH 10001 INCREMENT BY 1;

CREATE TABLE Station (
    StationID NUMBER,
    StationName VARCHAR2(100) NOT NULL,
    StationCode VARCHAR2(10) NOT NULL,
    Location VARCHAR2(255) NOT NULL,
    CONSTRAINT PK_STATION PRIMARY KEY (StationID),
    CONSTRAINT UQ_STATION_CODE UNIQUE (StationCode)
);

CREATE OR REPLACE TRIGGER trg_station_id
BEFORE INSERT ON Station
FOR EACH ROW
BEGIN
    :NEW.StationID := SEQ_STATION.NEXTVAL;
END;
/


--Train Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy

CREATE SEQUENCE SEQ_TRAIN START WITH 101 INCREMENT BY 1;

CREATE TABLE Train (
    TrainID NUMBER,
    TrainName VARCHAR2(100) NOT NULL,
    TrainNumber VARCHAR2(10) NOT NULL,
    FromStationID NUMBER,
    ToStationID NUMBER,
    StartingTime TIMESTAMP NOT NULL,
    ReachingTime TIMESTAMP NOT NULL,
    TotalDistance NUMBER(6,2),
    CONSTRAINT PK_TRAIN PRIMARY KEY (TrainID),
    CONSTRAINT UQ_TRAIN_NUMBER UNIQUE (TrainNumber),
    CONSTRAINT FK_TRAIN_FROMSTATION FOREIGN KEY (FromStationID) REFERENCES Station(StationID),
    CONSTRAINT FK_TRAIN_TOSTATION FOREIGN KEY (ToStationID) REFERENCES Station(StationID)
);

CREATE INDEX idx_train_fromstation ON Train(FromStationID);
CREATE INDEX idx_train_tostation ON Train(ToStationID);

CREATE OR REPLACE TRIGGER trg_train_id
BEFORE INSERT ON Train
FOR EACH ROW
BEGIN
    :NEW.TrainID := SEQ_TRAIN.NEXTVAL;
END;
/


--Users Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy

CREATE SEQUENCE SEQ_USER START WITH 1 INCREMENT BY 1;

CREATE TABLE Users (
    UserID NUMBER,
    UserName VARCHAR2(100) NOT NULL,
    UserPhone VARCHAR2(10) NOT NULL,
    UserEmail VARCHAR2(100) NOT NULL,
    UserPassword VARCHAR2(100) NOT NULL,
    UserAddress VARCHAR2(255),
    UserDOB DATE NOT NULL,
    UserGender CHAR(1),
    CONSTRAINT PK_USER PRIMARY KEY (UserID),
    CONSTRAINT UQ_USER_PHONE UNIQUE (UserPhone),
    CONSTRAINT UQ_USER_EMAIL UNIQUE (UserEmail),
    CONSTRAINT chk_USER_EMAIL_FORMAT CHECK(UserEmail LIKE '%@%.%'),
    CONSTRAINT chk_UserGender CHECK (UserGender IN ('M', 'F', 'O')),
    CONSTRAINT chk_UserPhone CHECK (LENGTH(UserPhone) = 10),
    --CONSTRAINT chk_UserDOB CHECK (UserDOB < SYSDATE),
    CONSTRAINT chk_UserPassword CHECK (LENGTH(UserPassword) >= 8)
);

CREATE OR REPLACE TRIGGER trg_check_UserDOB
BEFORE INSERT OR UPDATE ON Users
FOR EACH ROW
BEGIN
    IF :NEW.UserDOB >= SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'UserDOB must be less than the current date.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_user_id
BEFORE INSERT ON Users
FOR EACH ROW
BEGIN
    :NEW.UserID := SEQ_USER.NEXTVAL;
END;
/


--Booking Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy

CREATE SEQUENCE SEQ_BOOKING START WITH 4001 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PNR START WITH 1000000001 INCREMENT BY 1;


CREATE TABLE Booking (
    BookingID NUMBER,
    UserID NUMBER,
    TrainID NUMBER,
    FromStationID NUMBER NOT NULL,
    ToStationID NUMBER NOT NULL,
    PNR NUMBER,
    TravelDate DATE NOT NULL,
    TravelDistance NUMBER(6,2),
    TotalAmount NUMBER(10,2),
    NoOfPassenger NUMBER(3),
    BookingDate DATE DEFAULT SYSDATE,
    CONSTRAINT PK_BOOKING PRIMARY KEY (BookingID),
    CONSTRAINT UQ_PNR UNIQUE (PNR),
    CONSTRAINT FK_BOOKING_USER FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_BOOKING_TRAIN FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    CONSTRAINT chk_TravelDistance CHECK (TravelDistance >= 0),
    CONSTRAINT chk_TotalAmount CHECK (TotalAmount >= 0),
    CONSTRAINT chk_NoOfPassenger CHECK (NoOfPassenger > 0 AND NoOfPassenger <= 6)
    --CONSTRAINT chk_TravelDate CHECK (TravelDate >= SYSDATE)
);

CREATE INDEX idx_booking_user ON Booking(UserID);
CREATE INDEX idx_booking_train ON Booking(TrainID);

CREATE OR REPLACE TRIGGER trg_check_TravelDate
BEFORE INSERT OR UPDATE ON Booking
FOR EACH ROW
BEGIN
    IF :NEW.TravelDate <= SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'TravelDate must be greater than the current date.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_booking_id
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
    :NEW.BookingID := SEQ_BOOKING.NEXTVAL;
    :NEW.PNR := SEQ_PNR.NEXTVAL;
END;
/


--Coach Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy and Murli R

CREATE SEQUENCE SEQ_COACH START WITH 2001 INCREMENT BY 1;

CREATE TABLE Coach (
    CoachID NUMBER,
    TrainID NUMBER,
    ClassType VARCHAR2(3) NOT NULL,
    FareAmount NUMBER(10,2) NOT NULL,
    TotalSeats NUMBER(5),
    TotalAvailableSeats NUMBER(5),
    CONSTRAINT PK_COACH PRIMARY KEY (CoachID),
    CONSTRAINT FK_COACH_TRAIN FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    CONSTRAINT chk_FareAmount CHECK (FareAmount > 0),
    CONSTRAINT chk_TotalSeats CHECK (TotalSeats > 0 AND TotalSeats <= 50),
    CONSTRAINT chk_TotalAvailableSeats CHECK (TotalAvailableSeats >= 0 AND TotalAvailableSeats <= 50),
    CONSTRAINT chk_ClassType CHECK (ClassType IN ('AC', 'SL', 'GEN'))
);
ALTER TABLE COACH DROP CONSTRAINT chk_TotalAvailableSeats
ALTER TABLE COACH ADD CONSTRAINT chk_TotalAvailableSeats CHECK (TotalAvailableSeats <= 50)


CREATE INDEX idx_coach_train ON Coach(TrainID);

CREATE OR REPLACE TRIGGER trg_coach_id
BEFORE INSERT ON Coach
FOR EACH ROW
BEGIN
    :NEW.CoachID := SEQ_COACH.NEXTVAL;
END;
/


--Passenger Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy and Murli R

CREATE SEQUENCE SEQ_PASSENGER START WITH 5001 INCREMENT BY 1;

CREATE TABLE Passenger (
    PassengerID NUMBER,
    BookingID NUMBER,
    CoachID NUMBER,
    PassengerName VARCHAR2(100) NOT NULL,
    PassengerAge NUMBER(3),
    PassengerGender CHAR(1),
    SeatNumber NUMBER(5),
    Status VARCHAR2(20),
    WaitingListNumber NUMBER(5),
    CONSTRAINT PK_PASSENGER PRIMARY KEY (PassengerID),
    CONSTRAINT FK_PASSENGER_BOOKING FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    CONSTRAINT FK_PASSENGER_COACH FOREIGN KEY (CoachID) REFERENCES Coach(CoachID),
    CONSTRAINT chk_PassengerAge CHECK (PassengerAge > 0),
    CONSTRAINT chk_PassengerGender CHECK (PassengerGender IN ('M', 'F', 'O')),
    CONSTRAINT chk_SeatNumber CHECK(SeatNumber > 0 AND SeatNumber < 4),
    CONSTRAINT chk_WaitingListNumber CHECK (WaitingListNumber > 0),
    CONSTRAINT chk_PassengerName CHECK (PassengerName IS NOT NULL AND PassengerName <> ''),
    CONSTRAINT chk_Status CHECK (STATUS IN ('Confirmed','Waiting','Cancelled'))
);

CREATE INDEX idx_passenger_booking ON Passenger(BookingID);
CREATE INDEX idx_passenger_coach ON Passenger(CoachID);

CREATE OR REPLACE TRIGGER trg_passenger_id
BEFORE INSERT ON Passenger
FOR EACH ROW
BEGIN
    :NEW.PassengerID := SEQ_PASSENGER.NEXTVAL;
END;
/


--Route Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy and Murli R

CREATE SEQUENCE SEQ_ROUTE START WITH 1001 INCREMENT BY 1;

CREATE TABLE Route (
    RouteID NUMBER,
    TrainID NUMBER,
    SourceStationID NUMBER,
    DestinationStationID NUMBER,
    ArrivalTime TIMESTAMP NOT NULL,
    DepartureTime TIMESTAMP NOT NULL,
    StationCount NUMBER, 
    Distance NUMBER(6,2),
    CONSTRAINT PK_ROUTE PRIMARY KEY (RouteID),
    CONSTRAINT FK_ROUTE_TRAIN FOREIGN KEY (TrainID) REFERENCES Train(TrainID),
    CONSTRAINT FK_ROUTE_SRCSTATION FOREIGN KEY (SourceStationID) REFERENCES Station(StationID),
    CONSTRAINT FK_ROUTE_DESTSTATION FOREIGN KEY (DestinationStationID) REFERENCES Station(StationID),
    CONSTRAINT chk_Distance CHECK (Distance > 0), 
    CONSTRAINT chk_StationCount CHECK (StationCount >= 0), 
    CONSTRAINT chk_ArrivalDeparture CHECK (ArrivalTime > DepartureTime) 
);

CREATE INDEX idx_route_train ON Route(TrainID);
CREATE INDEX idx_route_srcstation ON Route(SourceStationID);
CREATE INDEX idx_route_deststation ON Route(DestinationStationID);

CREATE OR REPLACE TRIGGER trg_route_id
BEFORE INSERT ON Route
FOR EACH ROW
BEGIN
    :NEW.RouteID := SEQ_ROUTE.NEXTVAL;
END;
/
 

--Cancellation Table Created by Garje Vishal Anil and Manyam Kushmanth Reddy and Murli R

CREATE SEQUENCE SEQ_CANCELLATION START WITH 6001 INCREMENT BY 1;

CREATE TABLE Cancellation (
    CancelID NUMBER,
    PassengerID NUMBER,
    CancellationDate DATE NOT NULL,
    Amount NUMBER(10,2) NOT NULL,
    PaymentStatus VARCHAR(10),
    CONSTRAINT PK_CANCELLATION PRIMARY KEY (CancelID),
    CONSTRAINT FK_CANCELLATION_PASSENGER FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),
    CONSTRAINT chk_Amount CHECK (Amount > 0),
    --CONSTRAINT chk_CancellationDate CHECK (CancellationDate <= SYSDATE),
    CONSTRAINT chk_PaymentStatus CHECK (PaymentStatus IN ('Refunded', 'Pending'))
);

CREATE INDEX idx_cancellation_passenger ON Cancellation(PassengerID);

CREATE OR REPLACE TRIGGER trg_check_CancellationDate
BEFORE INSERT OR UPDATE ON Cancellation
FOR EACH ROW
BEGIN
    IF :NEW.CancellationDate > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20001, 'CancellationDate must be less than the current date.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_cancellation_id
BEFORE INSERT ON Cancellation
FOR EACH ROW
BEGIN
    :NEW.CancelID := SEQ_CANCELLATION.NEXTVAL;
END;
/

------------------------------------------------Clear Sequence cache----------------------------------
ALTER SEQUENCE SEQ_CANCELLATION NOCACHE;
ALTER SEQUENCE SEQ_PASSENGER NOCACHE;
ALTER SEQUENCE SEQ_BOOKING NOCACHE;
ALTER SEQUENCE SEQ_SEATAVAIL NOCACHE;
ALTER SEQUENCE SEQ_COACH NOCACHE;
ALTER SEQUENCE SEQ_ROUTE NOCACHE;
ALTER SEQUENCE SEQ_TRAIN NOCACHE;
ALTER SEQUENCE SEQ_USER NOCACHE;
ALTER SEQUENCE SEQ_STATION NOCACHE;
ALTER SEQUENCE SEQ_PNR NOCACHE;



----------------------------------Inserting Data-----------------------------------------

-- Insert sample data into Station table
INSERT INTO Station (StationName, StationCode, Location) VALUES
('Hyderabad', 'HYD', 'Telangana'),
('Mumbai', 'MUM', 'Maharashtra'),
('Delhi', 'DEL', 'Delhi'),
('Chennai', 'CHE', 'Tamil Nadu');

SELECT * FROM Station;
COMMIT;

-- Insert sample data into Train table(Create trigger for fromstationid and tostationid)
INSERT INTO Train (TrainName, TrainNumber, FromStationID, ToStationID, StartingTime, ReachingTime, TotalDistance) VALUES
('Deccan Express', 'DEC1', 10001, 10004, TIMESTAMP '2025-04-23 08:00:00', TIMESTAMP '2025-04-23 20:00:00', 700.00);

SELECT * FROM Train;
COMMIT;

-- Insert sample data into Route table
INSERT INTO Route (TrainID, SourceStationID, DestinationStationID, ArrivalTime, DepartureTime, StationCount, Distance) VALUES
(101, 10001, 10002, TIMESTAMP '2025-04-23 12:00:00', TIMESTAMP '2025-04-23 08:00:00', 1, 300.00),
(101, 10002, 10003, TIMESTAMP '2025-04-23 16:00:00', TIMESTAMP '2025-04-23 12:30:00', 2, 200.00),
(101, 10003, 10004, TIMESTAMP '2025-04-23 20:00:00', TIMESTAMP '2025-04-12 16:30:00', 3, 200.00);


SELECT * FROM Route;
COMMIT;

-- Insert sample data into Users table
INSERT INTO Users (UserName, UserPhone, UserEmail, UserPassword, UserAddress, UserDOB, UserGender) VALUES
('Vishal Garje', '7066747899', 'vishal.garje@gmail.com', 'Vishal123', 'Pune', DATE '2001-07-12', 'M'),
('Kushmanth', '8765432109', 'kushmanth@gmail.com', 'Kushmanth456', 'Chennai', DATE '2001-02-02', 'M'),
('Priya Singh', '9145999472', 'priya.singh@gmail.com', 'Priya789', 'Mumbai', DATE '1992-02-02', 'F');

SELECT * FROM Users;
COMMIT;


INSERT INTO Coach (CoachID, TrainID, ClassType, FareAmount, TotalSeats, TotalAvailableSeats) VALUES
(2001, 101, 'AC', 1.5, 3, 3),
(2002, 101, 'SL', 1.2, 3, 3),
(2003, 101, 'GEN', 1, 3, 3);

SELECT * FROM Coach;
COMMIT;


--Validate Passenger count(If user booked for 6 passenger then user should able to enter only 6 passenger details)
CREATE OR REPLACE TRIGGER trg_validate_passenger_count
BEFORE INSERT ON Passenger
FOR EACH ROW
DECLARE
    v_no_of_passenger NUMBER;
    v_passenger_count NUMBER;
BEGIN
    -- Get the number of passengers booked for the booking
    SELECT NoOfPassenger
    INTO v_no_of_passenger
    FROM Booking
    WHERE BookingID = :NEW.BookingID;

    -- Get the current count of passengers for the booking
    SELECT COUNT(*)
    INTO v_passenger_count
    FROM Passenger
    WHERE BookingID = :NEW.BookingID;

    -- Validate the number of passengers(Passenger count w. r. t. bookingid and NoOfPassenger in Booking table)
    IF v_passenger_count >= v_no_of_passenger THEN
        RAISE_APPLICATION_ERROR(-20001, 'Number of passengers exceeds the number of seats booked.');
    END IF;
END;
/


-------------------------------------------------Package--------------------------------------------------

CREATE OR REPLACE PACKAGE RMS_Package AS
    -- Procedure to book a ticket
    PROCEDURE book_ticket (
        p_user_id NUMBER,
        p_train_id NUMBER,
        p_from_station_id NUMBER,
        p_to_station_id NUMBER,
        p_travel_date DATE,
        p_no_of_passenger NUMBER,
        p_class_type VARCHAR2
    );

    -- Procedure to insert passenger details
    PROCEDURE Passenger_Details (
        p_booking_id NUMBER,
        p_classtype VARCHAR2,
        p_passenger_name VARCHAR2,
        p_passenger_age NUMBER,
        p_passenger_gender CHAR
    );

    -- Procedure to cancel a passenger
    PROCEDURE cancel_passenger(p_passenger_id NUMBER);
END RMS_Package;
/


CREATE OR REPLACE PACKAGE BODY RMS_Package AS
    PROCEDURE book_ticket (
        p_user_id NUMBER,
        p_train_id NUMBER,
        p_from_station_id NUMBER,
        p_to_station_id NUMBER,
        p_travel_date DATE,
        p_no_of_passenger NUMBER,
        p_class_type VARCHAR2
    ) IS
        v_booking_id NUMBER;
        v_pnr NUMBER;
        v_travel_distance NUMBER;
        v_total_amount NUMBER;
        v_fare_multiplier NUMBER;
    BEGIN
        -- Calculate the total distance between the source and destination stations
        SELECT SUM(r.Distance)
        INTO v_travel_distance
        FROM Route r
        WHERE r.TrainID = p_train_id
          AND r.SourceStationID >= p_from_station_id
          AND r.DestinationStationID <= p_to_station_id;

        -- Determine the fare multiplier based on the class type
        IF p_class_type = 'AC' THEN
            v_fare_multiplier := 1.5;
        ELSIF p_class_type = 'SL' THEN
            v_fare_multiplier := 1.2;
        ELSE
            v_fare_multiplier := 1.0;
        END IF;

        -- Calculate the total amount based on the distance, fare multiplier, and number of passengers
        v_total_amount := v_travel_distance * v_fare_multiplier * p_no_of_passenger;

        -- Insert the booking
        INSERT INTO Booking (UserID, TrainID, FromStationID, ToStationID, TravelDate, NoOfPassenger, BookingDate, TravelDistance, TotalAmount)
        VALUES (p_user_id, p_train_id, p_from_station_id, p_to_station_id, p_travel_date, p_no_of_passenger, SYSDATE, v_travel_distance, v_total_amount)
        RETURNING BookingID INTO v_booking_id;

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No route found for the given stations.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ROLLBACK;
    END book_ticket;

    PROCEDURE Passenger_Details (
    p_booking_id NUMBER,
    p_classtype VARCHAR2,
    p_passenger_name VARCHAR2,
    p_passenger_age NUMBER,
    p_passenger_gender CHAR
) IS
    v_seat_number NUMBER;
    v_status VARCHAR2(20);
    v_waiting_list_number NUMBER := NULL;
    v_total_available_seats NUMBER;
    v_coach_id NUMBER;
BEGIN
    -- Find the CoachID based on the class type
    SELECT CoachID INTO v_coach_id
    FROM Coach
    WHERE ClassType = p_classtype;
 
    -- Check the total available seats in the coach
    SELECT TotalAvailableSeats INTO v_total_available_seats
    FROM Coach
    WHERE CoachID = v_coach_id;
 
    IF v_total_available_seats > 0 THEN
        -- Find the lowest available seat number
        SELECT MIN(seat_no)
        INTO v_seat_number
        FROM (
            SELECT LEVEL AS seat_no
            FROM dual
            CONNECT BY LEVEL <= (SELECT TotalSeats FROM Coach WHERE CoachID = v_coach_id)
            MINUS
            SELECT SeatNumber
            FROM Passenger
            WHERE CoachID = v_coach_id AND Status = 'Confirmed'
        );
 
        v_status := 'Confirmed';
 
        -- Update available seats in the coach
        UPDATE Coach
        SET TotalAvailableSeats = TotalAvailableSeats - 1
        WHERE CoachID = v_coach_id;
 
    ELSE
        -- Allocate waiting list number
        SELECT NVL(MAX(WaitingListNumber), 0) + 1
        INTO v_waiting_list_number
        FROM Passenger
        WHERE CoachID = v_coach_id;
 
        v_status := 'Waiting';
        v_seat_number := NULL;
    END IF;
 
    -- Insert passenger details
    INSERT INTO Passenger (
        BookingID, CoachID, PassengerName, PassengerAge, PassengerGender,
        SeatNumber, Status, WaitingListNumber
    ) VALUES (
        p_booking_id, v_coach_id, p_passenger_name, p_passenger_age, p_passenger_gender,
        v_seat_number, v_status, v_waiting_list_number
    );
 
    COMMIT;
 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No available seats or waiting list numbers found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END Passenger_Details;
 
PROCEDURE cancel_passenger(p_passenger_id NUMBER) IS
    v_booking_id NUMBER;
    v_coach_id NUMBER;
    v_seat_number NUMBER;
    v_total_amount NUMBER;
    v_no_of_passenger NUMBER;
    v_refund NUMBER;
    v_charged NUMBER;
    v_waiting_passenger NUMBER;
    v_travel_date DATE;
    v_status VARCHAR2(20);
    v_waiting_list_number NUMBER;
BEGIN
    -- Get passenger details
    SELECT BookingID, CoachID, SeatNumber, Status, WaitingListNumber
    INTO v_booking_id, v_coach_id, v_seat_number, v_status, v_waiting_list_number
    FROM Passenger
    WHERE PassengerID = p_passenger_id;
 
    -- Check travel date
    SELECT TravelDate INTO v_travel_date
    FROM Booking
    WHERE BookingID = v_booking_id;
 
    IF TRUNC(v_travel_date) = TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cancellation is not allowed on the day of the journey.');
    END IF;
 
    -- Refund calculation
    SELECT TotalAmount, NoOfPassenger
    INTO v_total_amount, v_no_of_passenger
    FROM Booking
    WHERE BookingID = v_booking_id;
 
    v_refund := v_total_amount / v_no_of_passenger;
    v_charged := v_refund - 50; -- Charged Rs. 50
 
    -- Insert into Cancellation table
    INSERT INTO Cancellation (
        PassengerID, CancellationDate, Amount, PaymentStatus
    ) VALUES (
        p_passenger_id, SYSDATE, v_charged, 'Pending'
    );
 
    -- Update booking
    UPDATE Booking
    SET TotalAmount = TotalAmount - v_refund,
        NoOfPassenger = NoOfPassenger - 1
    WHERE BookingID = v_booking_id;
 
    -- Update passenger status
    UPDATE Passenger
    SET Status = 'Cancelled', SeatNumber = NULL, WaitingListNumber = NULL
    WHERE PassengerID = p_passenger_id;
 
    IF v_status = 'Confirmed' THEN
        -- Make seat available again
        UPDATE Coach
        SET TotalAvailableSeats = TotalAvailableSeats + 1
        WHERE CoachID = v_coach_id;
 
        -- Assign seat to next waiting passenger
        SELECT MIN(PassengerID)
        INTO v_waiting_passenger
        FROM Passenger
        WHERE CoachID = v_coach_id AND Status = 'Waiting';
 
        IF v_waiting_passenger IS NOT NULL THEN
            UPDATE Passenger
            SET Status = 'Confirmed', SeatNumber = v_seat_number, WaitingListNumber = NULL
            WHERE PassengerID = v_waiting_passenger;
 
            -- Reduce seat count again after reassignment
            UPDATE Coach
            SET TotalAvailableSeats = TotalAvailableSeats - 1
            WHERE CoachID = v_coach_id;
 
            -- Update other waiting list numbers
            UPDATE Passenger
            SET WaitingListNumber = WaitingListNumber - 1
            WHERE CoachID = v_coach_id AND Status = 'Waiting';
        END IF;
    ELSE
        -- Only reduce waiting numbers
        UPDATE Passenger
        SET WaitingListNumber = WaitingListNumber - 1
        WHERE CoachID = v_coach_id AND Status = 'Waiting' AND WaitingListNumber > v_waiting_list_number;
    END IF;
 
    COMMIT;
 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Passenger not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END cancel_passenger;
 
END RMS_Package;
/

---------Booking Ticket-----------

BEGIN
    RMS_Package.book_ticket(
        p_user_id => 1,
        p_train_id => 101,
        p_from_station_id => 10001,
        p_to_station_id => 10004,
        p_travel_date => DATE '2025-04-23',
        p_no_of_passenger => 6,
        p_class_type => 'GEN'
    );
END;
/

--------------Inserting Passenger------------------

DECLARE
    TYPE PassengerArray IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    TYPE AgeArray IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE GenderArray IS TABLE OF CHAR INDEX BY PLS_INTEGER;

    passenger_names PassengerArray;
    passenger_ages AgeArray;
    passenger_genders GenderArray;
    i PLS_INTEGER;
BEGIN
    -- Initialize the arrays with passenger details
    passenger_names(1) := 'Mangesh';
    passenger_ages(1) := 34;
    passenger_genders(1) := 'M';

    passenger_names(2) := 'Sagar';
    passenger_ages(2) := 28;
    passenger_genders(2) := 'M';

    passenger_names(3) := 'Aditya';
    passenger_ages(3) := 34;
    passenger_genders(3) := 'M';

    passenger_names(4) := 'Sohel';
    passenger_ages(4) := 28;
    passenger_genders(4) := 'M';

    passenger_names(5) := 'Kush';
    passenger_ages(5) := 34;
    passenger_genders(5) := 'M';

    passenger_names(6) := 'Rutik';
    passenger_ages(6) := 34;
    passenger_genders(6) := 'M';

    -- Loop through the arrays and call the procedure for each passenger
    FOR i IN 1 .. passenger_names.COUNT LOOP
        RMS_Package.Passenger_Details(
            p_booking_id => 4001, -- Replace with your actual booking ID
            p_classtype => 'GEN', -- Replace with the actual class type
            p_passenger_name => passenger_names(i),
            p_passenger_age => passenger_ages(i),
            p_passenger_gender => passenger_genders(i)
        );
    END LOOP;

    COMMIT;
END;
/

SELECT * FROM Booking;
SELECT p.passengerid, p.passengername, c.classtype, p.seatnumber, p.status, p.waitinglistnumber FROM Passenger p
JOIN Coach c ON p.coachid=c.coachid;
SELECT * FROM Coach;
SELECT * FROM Cancellation;

--------------Cancellation------------------
BEGIN
    RMS_Package.cancel_passenger(p_passenger_id => 5006);
END;
/


----------------------------------------------------Views-----------------------------------------------
-- Passenger Details

CREATE OR REPLACE VIEW PassengerDetails AS
SELECT 
    p.PassengerID,
    p.PassengerName,
    p.PassengerAge,
    p.PassengerGender,
    p.SeatNumber,
    p.Status,
    p.WaitingListNumber,
    c.ClassType,
    t.TrainNumber,
    t.TrainName,
    b.TravelDate,
    fs.StationName AS FromStationName,
    ts.StationName AS ToStationName
FROM 
    Passenger p
JOIN 
    Coach c ON p.CoachID = c.CoachID
JOIN 
    Booking b ON p.BookingID = b.BookingID
JOIN 
    Train t ON b.TrainID = t.TrainID
JOIN 
    Station fs ON b.FromStationID = fs.StationID
JOIN 
    Station ts ON b.ToStationID = ts.StationID
ORDER BY p.PassengerID;

SELECT * FROM PassengerDetails;


-- Booking Details

CREATE OR REPLACE VIEW BookingDetails AS
SELECT 
    b.BookingID,
    b.UserID,
    u.UserName,
    b.TrainID,
    t.TrainName,
    b.FromStationID,
    s1.StationName AS FromStationName,
    b.ToStationID,
    s2.StationName AS ToStationName,
    b.PNR,
    b.TravelDate,
    b.TravelDistance,
    b.TotalAmount,
    COUNT(p.PassengerID) AS PassengerCount
FROM 
    Booking b
JOIN 
    Users u ON b.UserID = u.UserID
JOIN 
    Train t ON b.TrainID = t.TrainID
JOIN 
    Station s1 ON b.FromStationID = s1.StationID
JOIN 
    Station s2 ON b.ToStationID = s2.StationID
LEFT JOIN 
    Passenger p ON b.BookingID = p.BookingID
WHERE p.Status = 'Confirmed'
GROUP BY 
    b.BookingID, b.UserID, u.UserName, b.TrainID, t.TrainName, b.FromStationID, s1.StationName, b.ToStationID, s2.StationName, b.PNR, b.TravelDate, b.TravelDistance, b.TotalAmount, b.NoOfPassenger
ORDER BY 
    b.BookingID;

SELECT * FROM BookingDetails;


-- Train Schedule 

CREATE OR REPLACE VIEW TrainSchedule AS
SELECT 
    t.TrainID,
    t.TrainName,
    t.TrainNumber,
    r.SourceStationID,
    s1.StationName AS SourceStationName,
    r.DestinationStationID,
    s2.StationName AS DestinationStationName,
    r.DepartureTime,
    r.ArrivalTime,
    r.Distance
FROM 
    Train t
JOIN 
    Route r ON t.TrainID = r.TrainID
JOIN 
    Station s1 ON r.SourceStationID = s1.StationID
JOIN 
    Station s2 ON r.DestinationStationID = s2.StationID
ORDER BY 
    t.TrainID, r.DepartureTime;

SELECT * FROM TrainSchedule;
 

-- Seat Availability 

CREATE VIEW SeatAvailability AS
SELECT 
    sa.AvailID, 
    t.TrainName, 
    c.CoachName, 
    sa.AvailableDate, 
    sa.AvailableSeats, 
    sa.NoOfWaitings
FROM SeatAvailability sa
JOIN TRAIN t ON sa.TrainID = t.TrainID
JOIN Coach c ON sa.CoachID = c.CoachID;

SELECT * FROM SeatAvailability;


--Revenue Report (Internal Purpose)

CREATE OR REPLACE VIEW RevenueReport AS
SELECT 
    t.TrainID,
    t.TrainName, 
    SUM(b.TotalAmount) AS TotalRevenue
FROM Booking b
JOIN TRAIN t ON b.TrainID = t.TrainID
GROUP BY t.TrainID, t.TrainName;

SELECT * FROM RevenueReport;


-- Cancellation Details 

CREATE OR REPLACE VIEW CancellationDetails AS
SELECT 
    c.CancelID, 
    b.PNR, 
    p.PASSENGERID,
    p.PassengerName, 
    c.CancellationDate, 
    c.Amount AS RefundAmount
FROM Cancellation c
JOIN Passenger p ON c.PassengerID = p.PassengerID
JOIN Booking b ON p.BookingID = b.BookingID;

SELECT * FROM CancellationDetails;
