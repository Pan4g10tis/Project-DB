DELIMITER $
CREATE TRIGGER jobin AFTER INSERT ON job FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'INSERT', 'job');
END$

CREATE TRIGGER jobdel AFTER DELETE ON job FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'DELETE', 'job');
END$

CREATE TRIGGER jobup AFTER UPDATE ON job FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'UPDATE', 'job');
END$

CREATE TRIGGER userin AFTER INSERT ON user FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'INSERT', 'user');
END$

CREATE TRIGGER userdel AFTER DELETE ON user FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'DELETE', 'user');
END$

CREATE TRIGGER userup AFTER UPDATE ON user FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'UPDATE', 'user');
END$

CREATE TRIGGER degreein AFTER INSERT ON degree FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'INSERT', 'degree');
END$

CREATE TRIGGER degreedel AFTER DELETE ON degree FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'DELETE', 'degree');
END$

CREATE TRIGGER degreeup AFTER UPDATE ON degree FOR EACH ROW
BEGIN 
DECLARE dba VARCHAR(30);
SELECT username INTO dba FROM db_admin WHERE id =  USER();
INSERT INTO log VALUES(dba, CURRENT_TIMESTAMP, 'UPDATE', 'degree');
END$

CREATE TRIGGER insert_app BEFORE INSERT ON applies FOR EACH ROW
BEGIN
DECLARE startd DATE;
DECLARE appnum INT;
SELECT startdate INTO startd FROM job WHERE id = NEW.job_id;
SELECT count(*) INTO appnum FROM applies WHERE cand_usrname = NEW.cand_usrname;
IF DATEDIFF(startd, NEW.regdate)<15 THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Invalid registration date! Must be at least 15 days before start date.';
ELSEIF appnum > 2 THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Invalid! More than 3 applications.';
END IF;
END$

CREATE TRIGGER update_app BEFORE UPDATE ON applies FOR EACH ROW
BEGIN
DECLARE startd DATE;
DECLARE appnum INT;
SELECT startdate INTO startd FROM job WHERE id = NEW.job_id;
SELECT count(*) INTO appnum FROM applies WHERE cand_usrname = NEW.cand_usrname;
IF NEW.status = 'CANCELED' THEN
IF DATEDIFF(startd, CURDATE())<10 THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Invalid cancelation date! Must be at least 10 days before start date.';
END IF;
ELSEIF NEW.status = 'ACTIVE' THEN
IF DATEDIFF(startd, CURDATE())<15 THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Invalid reactivation date! Must be at least 15 days before start date.';
ELSEIF appnum > 2 THEN
SIGNAL SQLSTATE VALUE '45000'
SET MESSAGE_TEXT = 'Invalid! More than 3 applications.';
END IF;
END IF; 
END$

DELIMITER ;

CREATE INDEX grade_ind ON app_log (grade);
CREATE INDEX eval_ind ON app_log (eval1, eval2);