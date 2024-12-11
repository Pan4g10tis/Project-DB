DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `apply_actions`(IN employee VARCHAR(30),IN jobid INT, IN action_char CHAR(1))
BEGIN
DECLARE eval1 VARCHAR(30);
DECLARE eval2 VARCHAR(30);
DECLARE exist INT;
DECLARE app_status VARCHAR(20);
CASE action_char
WHEN 'i' THEN
SELECT evaluator, evaluator2 INTO eval1, eval2 FROM job WHERE id = jobid;
INSERT INTO applies(cand_usrname, job_id, status, regdate) VALUES
(employee, jobid, 'ACTIVE', CURRENT_TIMESTAMP());
WHEN 'c' THEN
SELECT count(*) INTO exist FROM applies WHERE cand_usrname = employee AND job_id = jobid GROUP BY cand_usrname;
IF exist IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No Application Exists.';
ELSE
SELECT status INTO app_status FROM applies WHERE cand_usrname = employee AND job_id = jobid;
IF app_status like '%CANC%' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Application Already Canceled.';
ELSEIF app_status like '%ACTI%' THEN
UPDATE applies SET status = 'CANCELED' WHERE cand_usrname = employee AND job_id = jobid;
END IF;
END IF;
WHEN 'a' THEN
SELECT count(*) INTO exist FROM applies WHERE cand_usrname = employee AND job_id = jobid GROUP BY cand_usrname;
IF exist IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No Application Exists.';
ELSE
SELECT status INTO app_status FROM applies WHERE cand_usrname = employee AND job_id = jobid;
IF app_status like '%ACTI%' THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Application Already Activated.';
ELSEIF app_status like '%CANC%' THEN
UPDATE applies SET status = 'ACTIVE' WHERE cand_usrname = employee AND job_id = jobid;
END IF;
END IF;
END CASE;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `apps_eval_by`(IN eval VARCHAR(30))
BEGIN
SELECT cand_usrname, job_id FROM app_log WHERE eval1 = eval OR eval2 = eval; 
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `apps_in_range`(IN mingrade INT, IN maxgrade INT)
BEGIN
SELECT cand_usrname, job_id FROM app_log WHERE grade >= mingrade AND grade<= maxgrade; 
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_grade`(IN eval VARCHAR(30), IN employee VARCHAR(30),IN jobid INT,OUT grade INT)
BEGIN
DECLARE eval1 VARCHAR(30);
DECLARE eval2 VARCHAR(30);
DECLARE BSc_deg INT;
DECLARE MSc_deg INT;
DECLARE PhD_deg INT;
DECLARE lang INT;
DECLARE project INT;
SELECT evaluator, evaluator2 INTO eval1, eval2 FROM job WHERE id = jobid;
IF eval NOT IN (eval1, eval2) THEN
SET grade = 0;
ELSE
IF eval = eval1 THEN
SELECT grade1 INTO grade FROM applies WHERE cand_usrname = employee AND job_id = jobid;
ELSEIF eval = eval2 THEN
SELECT grade2 INTO grade FROM applies WHERE cand_usrname = employee AND job_id = jobid;
END IF;
IF grade IS NULL THEN
SELECT count(*) INTO lang FROM languages WHERE candid = employee GROUP BY candid;
IF(lang>1) THEN
SET lang = 1;
END IF;
SELECT count(*) INTO project FROM project WHERE candid = employee GROUP BY candid;
SELECT count(*) INTO BSc_deg FROM has_degree INNER JOIN degree ON degr_title = titlos AND degr_idryma = idryma WHERE cand_username = employee AND bathmida = 'BSc' GROUP BY cand_username;
SELECT count(*) INTO MSc_deg FROM has_degree INNER JOIN degree ON degr_title = titlos AND degr_idryma = idryma WHERE cand_username = employee AND bathmida = 'MSc' GROUP BY cand_username;
SELECT count(*) INTO PhD_deg FROM has_degree INNER JOIN degree ON degr_title = titlos AND degr_idryma = idryma WHERE cand_username = employee AND bathmida = 'PhD' GROUP BY cand_username;
SET lang = COALESCE(lang, 0);
SET project = COALESCE(project, 0);
SET BSc_deg = COALESCE(BSc_deg, 0);
SET MSc_deg = COALESCE(MSc_deg, 0);
SET PhD_deg = COALESCE(PhD_deg, 0);
SET grade = BSc_deg + MSc_deg*2 + PhD_deg*3 + lang + project;
END IF;
END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertApps`()
BEGIN
DECLARE counter INT;
SET counter = 0; 
WHILE counter < 60000 DO
INSERT INTO app_log VALUES
(SUBSTRING(UUID(), 1, 20),
FLOOR(RAND() * 1000) + 1,
SUBSTRING(UUID(), 1, 20),
SUBSTRING(UUID(), 1, 20),
FLOOR(RAND() * 20) + 1,
'COMPLETE');
SET counter = counter + 1; 
END WHILE;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `select_cand`(IN jobid INT)
BEGIN
DECLARE eval1 VARCHAR(30);
DECLARE eval2 VARCHAR(30);
DECLARE cur_cand VARCHAR(30);
DECLARE cur_date DATETIME;
DECLARE cur_grade1 INT;
DECLARE cur_grade2 INT;
DECLARE cur_gradeavg INT;
DECLARE max_cand VARCHAR(30);
DECLARE max_gradeavg INT;
DECLARE max_date DATETIME;
DECLARE finishedFlag INT;
DECLARE candCursor CURSOR FOR
SELECT cand_usrname, regdate FROM applies WHERE job_id=jobid;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finishedFlag=1;
OPEN candCursor;
SET finishedFlag=0;
SET max_gradeavg = 0;
SET max_date = 18000101;
SELECT evaluator, evaluator2 INTO eval1, eval2 FROM job WHERE id = jobid;
REPEAT
FETCH candCursor INTO cur_cand, cur_date;
IF finishedFlag=0 THEN
CALL find_grade(eval1, cur_cand, jobid, cur_grade1);
CALL find_grade(eval2, cur_cand, jobid, cur_grade2);
SET cur_gradeavg = (cur_grade1 + cur_grade2)/2;
IF cur_gradeavg > max_gradeavg OR (cur_gradeavg = max_gradeavg AND cur_date<max_date) THEN
SET max_gradeavg = cur_gradeavg;
SET max_cand = cur_cand;
SET max_date = cur_date;
END IF;
END IF;
UNTIL finishedFlag=1
END REPEAT;
SELECT max_cand AS 'Best Candidate'; 
END$$
DELIMITER ;
