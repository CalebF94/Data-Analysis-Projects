CREATE database PGA;

USE PGA;

########################################
# Creating and Reading DrivingDistance #
########################################
CREATE TABLE DrivingDistance (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    DrivingDistance DECIMAL(4,2),
    DDAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);


SELECT * from drivingdistance;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\SQL Server 8.0\\Uploads\\DrivingDistance.csv' 
INTO TABLE DrivingDistance
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;

#####################################
# Creating and Reading ApexDistance #
#####################################
CREATE TABLE ApexDistance (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    ApexDistance DOUBLE,
    ADAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ApexDistance.csv' 
INTO TABLE ApexHeight
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;



###################################
# Creating and Reading ApexHeight #
###################################
CREATE TABLE ApexHeight (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    ApexHeight DOUBLE,
    AHAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ApexHeight.csv' 
INTO TABLE ApexHeight
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;


###################################
# Creating and Reading BallSpeed  #
###################################
CREATE TABLE BallSpeed(
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    BallSpeed DOUBLE,
    BSAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\BallSpeed.csv' 
INTO TABLE BallSpeed
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;


######################################
# Creating and Reading CarryDistance #
######################################
CREATE TABLE CarryDistance (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    CarryDistance DOUBLE,
    CDAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CarryDistance.csv' 
INTO TABLE CarryDistance
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;


######################################
# Creating and Reading ClubheadSpeed #
######################################
CREATE TABLE ClubheadSpeed (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    ClubheadSpeed DOUBLE,
    CSAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ClubheadSpeed.csv' 
INTO TABLE ClubheadSpeed
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;


###################################
# Creating and Reading HangTime   #
###################################
CREATE TABLE HangTime (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    HangTime DOUBLE,
    HTAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\HangTime.csv' 
INTO TABLE HangTime
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;


####################################
# Creating and Reading LaunchAngle #
####################################
CREATE TABLE LaunchAngle (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(25),
    Rounds INTEGER,
    LaunchAngle DOUBLE,
    LAAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\LaunchAngle.csv' 
INTO TABLE LaunchAngle
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;


###################################
# Creating and Reading SpinRate   #
###################################
CREATE TABLE SpinRate (
	PlayerYear VARCHAR(35),
	Year VARCHAR(4),
    Player VARCHAR(30),
    Rounds INTEGER,
    SpinRate DECIMAL(6,2),
    SRAttempts INTEGER,
    CONSTRAINT pk_playeryear PRIMARY KEY (PlayerYear)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\SpinRate.csv' 
INTO TABLE SpinRate
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
IGNORE 1 ROWS;


SELECT dd.PlayerYear, ah.Year, ah.Player, dd.Rounds, DrivingDistance, dd.Attempts, 
	   ApexHeight, AhAttempts, ApexDistance, ADAttempts, BallSpeed, BSAttempts,CarryDistance, CDAttempts, ClubheadSpeed, CSAttempts, 
       HangTime, HTAttempts, LaunchAngle, LAAttempts, SpinRate, SRAttempts
	FROM DrivingDistance dd LEFT JOIN ApexHeight ah
		ON dd.PlayerYear = ah.PlayerYear
	LEFT JOIN ApexDistance ad
		ON dd.PlayerYear = ad.PlayerYear
    LEFT JOIN BallSpeed bs
		ON dd.PlayerYear = bs.PlayerYear
	LEFT JOIN CarryDistance cd
		ON dd.PlayerYear = cd.PlayerYear
	LEFT JOIN ClubheadSpeed cs
		ON dd.PlayerYear = cs.PlayerYear
	LEFT JOIN HangTime ht
		ON dd.PlayerYear = ht.PlayerYear
	LEFT JOIN LaunchAngle la
		ON dd.PlayerYear = la.PlayerYear
	LEFT JOIN SpinRate sr
		ON dd.PlayerYear = sr.PlayerYear;
    

