/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

DROP DATABASE IF EXISTS `authorization`;
CREATE DATABASE IF NOT EXISTS `authorization` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE `authorization`;

CREATE TABLE IF NOT EXISTS `tbl_groups`
(
  `groupId` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `groupName` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `groupDescription` VARCHAR(400) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`groupId`),
  KEY `ix_name` (`groupName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_roles`
(
  `roleId` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `roleCodeName` VARCHAR(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roleDisplayName` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roleDescription` VARCHAR(400) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`roleId`),
  KEY `ix_name` (`roleCodeName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_permissions`
(
  `permissionId` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `permissionCodeName` VARCHAR(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissionDisplayName` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissionDescription` VARCHAR(400) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`permissionId`),
  KEY `ix_name` (`permissionCodeName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_user_groups`
(
  `groupId` BIGINT(20) NOT NULL,
  `userId` VARCHAR(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`groupId`, `userId`),
  KEY `ix_group` (`groupId`),
  KEY `ix_user` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_group_roles`
(
  `groupId` BIGINT(20) NOT NULL,
  `roleId` BIGINT(20) NOT NULL,
  PRIMARY KEY (`groupId`, `roleId`),
  KEY `ix_group` (`groupId`),
  KEY `ix_role` (`roleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_role_permissions`
(
  `roleId` BIGINT(20) NOT NULL,
  `permissionId` BIGINT(20) NOT NULL,
  PRIMARY KEY (`roleId`, `permissionId`),
  KEY `ix_role` (`roleId`),
  KEY `ix_permission` (`permissionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetGroups`() DETERMINISTIC
BEGIN
	SELECT
		g.`groupId`,
		g.`groupName`,
		g.`groupDescription`
	FROM
		`tbl_groups` g;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetGroup`
(
	IN `groupId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	SELECT
		g.`groupId`,
		g.`groupName`,
		g.`groupDescription`
	FROM
		`tbl_groups` g
	WHERE
		g.`groupId` = `groupId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_AddGroup`
(
	IN `groupName` VARCHAR(50),
	IN `groupDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	DECLARE groupId BIGINT UNSIGNED;

	INSERT INTO 
		`tbl_groups`
	(
		`groupName`,
		`groupDescription`
	) VALUES (
		`groupName`,
		`groupDescription`
	);
		
	SELECT LAST_INSERT_ID() INTO `groupId`;

	CALL sp_GetGroup(groupId);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_UpdateGroup`
(
	IN `groupId` BIGINT UNSIGNED,
	IN `groupName` VARCHAR(50),
	IN `groupDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	UPDATE
		`tbl_groups` g
	SET
		`groupName` = `groupName`,
		`groupDescription` = `groupDescription`
	WHERE
		g.`groupId` = `groupId`;

	CALL sp_GetGroup(groupId);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_DeleteGroup`
(
	IN `groupId` BIGINT UNSIGNED,
	IN `replacementGroupId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	UPDATE
		`tbl_user_groups` g
	SET
		g.`groupId` = `replacementGroupId`
	WHERE
		g.`groupId` = `groupId`;

	DELETE 
		g
	FROM
		`tbl_group_roles` g
	WHERE
		g.`groupId` = `groupId`;

	DELETE 
		g
	FROM
		`tbl_groups` g
	WHERE
		g.`groupId` = `groupId`;
END//
DELIMITER ;

/********************************************************************/

