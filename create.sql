CREATE TABLE `requires` (
  `job_id` int NOT NULL,
  `subject_title` varchar(36) NOT NULL,
  PRIMARY KEY (`job_id`,`subject_title`),
  KEY `SUBREQ` (`subject_title`),
  CONSTRAINT `JOBREQ` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `SUBREQ` FOREIGN KEY (`subject_title`) REFERENCES `subject` (`title`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `app_log` (
  `cand_usrname` varchar(30) NOT NULL,
  `job_id` int NOT NULL,
  `eval1` varchar(30) DEFAULT NULL,
  `eval2` varchar(30) DEFAULT NULL,
  `grade` int DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`cand_usrname`,`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `db_admin` (
  `username` varchar(30) DEFAULT NULL,
  `id` varchar(30) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  KEY `UDBA` (`username`),
  CONSTRAINT `UDBA` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `applies` (
  `cand_usrname` varchar(30) NOT NULL,
  `job_id` int NOT NULL,
  `status` enum('ACTIVE','COMPLETE','CANCELED') DEFAULT NULL,
  `grade1` int DEFAULT NULL,
  `grade2` int DEFAULT NULL,
  `regdate` date DEFAULT NULL,
  PRIMARY KEY (`cand_usrname`,`job_id`),
  KEY `JOBAPP` (`job_id`),
  CONSTRAINT `CANDAPP` FOREIGN KEY (`cand_usrname`) REFERENCES `employee` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `JOBAPP` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `degree` (
  `titlos` varchar(150) NOT NULL,
  `idryma` varchar(150) NOT NULL,
  `bathmida` enum('BSc','MSc','PhD') NOT NULL,
  PRIMARY KEY (`titlos`,`idryma`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `etairia` (
  `AFM` char(9) NOT NULL,
  `DOY` varchar(30) NOT NULL,
  `name` varchar(35) NOT NULL,
  `tel` varchar(10) DEFAULT NULL,
  `street` varchar(15) DEFAULT NULL,
  `num` int DEFAULT NULL,
  `city` varchar(45) DEFAULT NULL,
  `country` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`AFM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `employee` (
  `username` varchar(30) NOT NULL,
  `bio` text,
  `sistatikes` varchar(35) DEFAULT NULL,
  `certificates` varchar(35) DEFAULT NULL,
  PRIMARY KEY (`username`),
  CONSTRAINT `UEMP` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `evaluator` (
  `username` varchar(30) NOT NULL,
  `exp_years` tinyint DEFAULT NULL,
  `firm` char(9) NOT NULL,
  PRIMARY KEY (`username`),
  KEY `COMP` (`firm`),
  CONSTRAINT `COMP` FOREIGN KEY (`firm`) REFERENCES `etairia` (`AFM`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `UEVL` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `has_degree` (
  `degr_title` varchar(150) NOT NULL,
  `degr_idryma` varchar(150) NOT NULL,
  `cand_username` varchar(30) NOT NULL,
  `etos` year DEFAULT NULL,
  `grade` float DEFAULT NULL,
  PRIMARY KEY (`degr_title`,`degr_idryma`,`cand_username`),
  KEY `EDGR` (`cand_username`),
  CONSTRAINT `EDGR` FOREIGN KEY (`cand_username`) REFERENCES `employee` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `TDGREE` FOREIGN KEY (`degr_title`, `degr_idryma`) REFERENCES `degree` (`titlos`, `idryma`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `log` (
  `admin` varchar(30) DEFAULT NULL,
  `action_date` datetime DEFAULT NULL,
  `dbaction` varchar(30) DEFAULT NULL,
  `actable` varchar(30) DEFAULT NULL,
  KEY `DBA` (`admin`),
  CONSTRAINT `DBA` FOREIGN KEY (`admin`) REFERENCES `db_admin` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `project` (
  `candid` varchar(30) NOT NULL,
  `num` tinyint NOT NULL AUTO_INCREMENT,
  `descr` text,
  `url` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`num`,`candid`),
  KEY `PRJT` (`candid`),
  CONSTRAINT `PRJT` FOREIGN KEY (`candid`) REFERENCES `employee` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `languages` (
  `candid` varchar(30) NOT NULL,
  `lang` set('EN','FR','SP','GE','CH','GR') NOT NULL,
  PRIMARY KEY (`candid`,`lang`),
  CONSTRAINT `LNGS` FOREIGN KEY (`candid`) REFERENCES `employee` (`username`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `job` (
  `id` int NOT NULL AUTO_INCREMENT,
  `startdate` date DEFAULT NULL,
  `salary` float DEFAULT NULL,
  `position` varchar(60) DEFAULT NULL,
  `edra` varchar(60) DEFAULT NULL,
  `evaluator` varchar(30) NOT NULL,
  `announce_date` datetime DEFAULT NULL,
  `submission_date` date DEFAULT NULL,
  `evaluator2` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `EVAL` (`evaluator`),
  KEY `EVAL2_idx` (`evaluator2`),
  CONSTRAINT `EVAL` FOREIGN KEY (`evaluator`) REFERENCES `evaluator` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `EVAL2` FOREIGN KEY (`evaluator2`) REFERENCES `evaluator` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `subject` (
  `title` varchar(36) NOT NULL,
  `descr` tinytext,
  `belongs_to` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`title`),
  KEY `PARENT` (`belongs_to`),
  CONSTRAINT `PARENT` FOREIGN KEY (`belongs_to`) REFERENCES `subject` (`title`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user` (
  `username` varchar(30) NOT NULL,
  `password` varchar(30) NOT NULL DEFAULT '12345',
  `name` varchar(25) NOT NULL DEFAULT 'unknown',
  `lastname` varchar(25) NOT NULL DEFAULT 'unknown',
  `regdate` datetime DEFAULT NULL,
  `email` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


