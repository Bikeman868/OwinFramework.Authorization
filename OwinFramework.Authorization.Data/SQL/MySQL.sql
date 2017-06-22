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
  `groupCodeName` VARCHAR(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `groupDisplayName` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `groupDescription` VARCHAR(400) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`groupId`),
  UNIQUE INDEX `ix_code_name` (`groupCodeName`),
  UNIQUE INDEX `ix_display_name` (`groupDisplayName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_roles`
(
  `roleId` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `roleCodeName` VARCHAR(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roleDisplayName` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `roleDescription` VARCHAR(400) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`roleId`),
  UNIQUE INDEX `ix_name` (`roleCodeName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_permissions`
(
  `permissionId` BIGINT(20) NOT NULL AUTO_INCREMENT,
  `permissionCodeName` VARCHAR(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissionResource` VARCHAR(80) COLLATE utf8mb4_unicode_ci NULL,
  `permissionDisplayName` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissionDescription` VARCHAR(400) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`permissionId`),
  UNIQUE INDEX `ix_name` (`permissionCodeName`, `permissionResource`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_user_groups`
(
  `groupId` BIGINT(20) NOT NULL,
  `userId` VARCHAR(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`groupId`, `userId`),
  KEY `ix_group` (`groupId`),
  UNIQUE INDEX `ix_user` (`userId`)
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
		g.`groupCodeName`,
		g.`groupDisplayName`,
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
		g.`groupCodeName`,
		g.`groupDisplayName`,
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
	IN `groupCodeName` VARCHAR(30),
	IN `groupDisplayName` VARCHAR(50),
	IN `groupDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	DECLARE groupId BIGINT UNSIGNED;

	INSERT INTO 
		`tbl_groups`
	(
		`groupCodeName`,
		`groupDisplayName`,
		`groupDescription`
	) VALUES (
		`groupCodeName`,
		`groupDisplayName`,
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
	IN `groupCodeName` VARCHAR(30),
	IN `groupDisplayName` VARCHAR(50),
	IN `groupDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	UPDATE
		`tbl_groups` g
	SET
		`groupCodeName` = `groupCodeName`,
		`groupDisplayName` = `groupDisplayName`,
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

DELIMITER //
CREATE PROCEDURE `sp_AddGroupRole`
(
	IN `groupId` BIGINT UNSIGNED,
	IN `roleId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	INSERT IGNORE INTO 
		`tbl_group_roles`
	(
		`groupId`,
		`roleId`
	) VALUES (
		`groupId`,
		`roleId`
	);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_DeleteGroupRole`
(
	IN `groupId` BIGINT UNSIGNED,
	IN `roleId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	DELETE 
		gr
	FROM
		`tbl_group_roles` gr
	WHERE
		gr.`groupId` = `groupId`
			AND
		gr.`roleId` = `roleId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_ChangeUserGroup`
(
	IN `userId` VARCHAR(80),
	IN `groupId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	REPLACE INTO 
		`tbl_user_groups`
	(
		`groupId`,
		`userId`
	) VALUES (
		`groupId`,
		`userId`
	);
	
	CALL sp_GetGroup(`groupId`);	
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetRoles`() DETERMINISTIC
BEGIN
	SELECT
		r.`roleId`,
		r.`roleCodeName`,
		r.`roleDisplayName`,
		r.`roleDescription`
	FROM
		`tbl_roles` r;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetRole`
(
	IN `roleId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	SELECT
		r.`roleId`,
		r.`roleCodeName`,
		r.`roleDisplayName`,
		r.`roleDescription`
	FROM
		`tbl_roles` r
	WHERE
		r.`roleId` = `roleId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_AddRole`
(
	IN `roleCodeName` VARCHAR(30),
	IN `roleDisplayName` VARCHAR(50),
	IN `roleDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	DECLARE roleId BIGINT UNSIGNED;

	INSERT INTO 
		`tbl_roles`
	(
		`roleCodeName`,
		`roleDisplayName`,
		`roleDescription`
	) VALUES (
		`roleCodeName`,
		`roleDisplayName`,
		`roleDescription`
	);
		
	SELECT LAST_INSERT_ID() INTO `roleId`;

	CALL sp_GetRole(roleId);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_UpdateRole`
(
	IN `roleId` BIGINT UNSIGNED,
	IN `roleCodeName` VARCHAR(30),
	IN `roleDisplayName` VARCHAR(50),
	IN `roleDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	UPDATE
		`tbl_roles` r
	SET
		`roleCodeName` = `roleCodeName`,
		`roleDisplayName` = `roleDisplayName`,
		`roleDescription` = `roleDescription`
	WHERE
		r.`roleId` = `roleId`;

	CALL sp_GetRole(roleId);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_DeleteRole`
(
	IN `roleId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	DELETE 
		rp
	FROM
		`tbl_role_permissions` rp
	WHERE
		rp.`roleId` = `roleId`;

	DELETE 
		gr
	FROM
		`tbl_group_roles` gr
	WHERE
		gr.`roleId` = `roleId`;

	DELETE 
		r
	FROM
		`tbl_roles` r
	WHERE
		r.`roleId` = `roleId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_AddRolePermission`
(
	IN `roleId` BIGINT UNSIGNED,
	IN `permissionId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	INSERT IGNORE INTO 
		`tbl_role_permissions`
	(
		`roleId`,
		`permissionId`
	) VALUES (
		`roleId`,
		`permissionId`
	);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_DeleteRolePermission`
(
	IN `roleId` BIGINT UNSIGNED,
	IN `permissionId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	DELETE 
		gr
	FROM
		`tbl_role_permissions` gr
	WHERE
		gr.`permissionId` = `permissionId`
			AND
		gr.`roleId` = `roleId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetPermissions`() DETERMINISTIC
BEGIN
	SELECT
		p.`permissionId`,
		p.`permissionCodeName`,
		p.`permissionResource`,
		p.`permissionDisplayName`,
		p.`permissionDescription`
	FROM
		`tbl_permissions` p;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetPermission`
(
	IN `permissionId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	SELECT
		p.`permissionId`,
		p.`permissionCodeName`,
		p.`permissionResource`,
		p.`permissionDisplayName`,
		p.`permissionDescription`
	FROM
		`tbl_permissions` p
	WHERE
		p.`permissionId` = `permissionId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_AddPermission`
(
	IN `permissionCodeName` VARCHAR(30),
	IN `permissionResource` VARCHAR(80),
	IN `permissionDisplayName` VARCHAR(50),
	IN `permissionDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	DECLARE permissionId BIGINT UNSIGNED;

	INSERT INTO 
		`tbl_permissions`
	(
		`permissionCodeName`,
		`permissionResource`,
		`permissionDisplayName`,
		`permissionDescription`
	) VALUES (
		`permissionCodeName`,
		`permissionResource`,
		`permissionDisplayName`,
		`permissionDescription`
	);
		
	SELECT LAST_INSERT_ID() INTO `permissionId`;

	CALL sp_GetPermission(permissionId);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_UpdatePermission`
(
	IN `permissionId` BIGINT UNSIGNED,
	IN `permissionCodeName` VARCHAR(30),
	IN `permissionResource` VARCHAR(80),
	IN `permissionDisplayName` VARCHAR(50),
	IN `permissionDescription` VARCHAR(400)
)
DETERMINISTIC
BEGIN
	UPDATE
		`tbl_permissions` p
	SET
		`permissionCodeName` = `permissionCodeName`,
		`permissionResource` = `permissionResource`,
		`permissionDisplayName` = `permissionDisplayName`,
		`permissionDescription` = `permissionDescription`
	WHERE
		p.`permissionId` = `permissionId`;

	CALL sp_GetPermission(permissionId);
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_DeletePermission`
(
	IN `permissionId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	DELETE 
		rp
	FROM
		`tbl_role_permissions` rp
	WHERE
		rp.`permissionId` = `permissionId`;

	DELETE 
		p
	FROM
		`tbl_permissions` p
	WHERE
		p.`permissionId` = `permissionId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetRolePermissions`
(
	IN `roleId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	SELECT
		p.`permissionId`,
		p.`permissionCodeName`,
		p.`permissionDisplayName`,
		p.`permissionDescription`
	FROM
		`tbl_role_permissions` rp
			JOIN
		`tbl_permissions` p ON rp.`permissionId` = p.`permissionId`
	WHERE
		rp.`roleId` = `roleId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetRolesWithPermission`
(
	IN `permissionId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	SELECT
		r.`roleId`,
		r.`roleCodeName`,
		r.`roleDisplayName`,
		r.`roleDescription`
	FROM
		`tbl_role_permissions` rp
			JOIN
		`tbl_roles` r ON rp.`roleId` = r.`roleId`
	WHERE
		rp.`permissionId` = `permissionId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetGroupPermissions`
(
	IN `groupId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	SELECT DISTINCT
		p.`permissionId`,
		p.`permissionCodeName`,
		p.`permissionResource`,
		p.`permissionDisplayName`,
		p.`permissionDescription`
	FROM
		`tbl_group_roles` gr
			JOIN
		`tbl_role_permissions` rp ON gr.`roleId` = rp.`roleId`
			JOIN
		`tbl_permissions` p ON rp.`permissionId` = p.`permissionId`
	WHERE
		gr.`groupId` = `groupId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetGroupRoles`
(
	IN `groupId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	SELECT DISTINCT
		r.`roleId`,
		r.`roleCodeName`,
		r.`roleDisplayName`,
		r.`roleDescription`
	FROM
		`tbl_group_roles` gr
			JOIN
		`tbl_roles` r ON gr.`roleId` = r.`roleId`
	WHERE
		gr.`groupId` = `groupId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetUserPermissions`
(
	IN `userId` VARCHAR(80)
)
DETERMINISTIC
BEGIN
	SELECT DISTINCT
		p.`permissionId`,
		p.`permissionCodeName`,
		p.`permissionResource`,
		p.`permissionDisplayName`,
		p.`permissionDescription`
	FROM
		`tbl_user_groups` ug
			JOIN 
		`tbl_group_roles` gr ON ug.`groupId` = gr.`groupId`
			JOIN
		`tbl_role_permissions` rp ON gr.`roleId` = rp.`roleId`
			JOIN
		`tbl_permissions` p ON rp.`permissionId` = p.`permissionId`
	WHERE
		ug.`userId` = `userId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetUserRoles`
(
	IN `userId` VARCHAR(80)
)
DETERMINISTIC
BEGIN
	SELECT DISTINCT
		r.`roleId`,
		r.`roleCodeName`,
		r.`roleDisplayName`,
		r.`roleDescription`
	FROM
		`tbl_user_groups` ug
			JOIN 
		`tbl_group_roles` gr ON ug.`groupId` = gr.`groupId`
			JOIN
		`tbl_roles` r ON gr.`roleId` = r.`roleId`
	WHERE
		ug.`userId` = `userId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetUserGroupId`
(
	IN `userId` VARCHAR(80)
)
DETERMINISTIC
BEGIN
	SELECT DISTINCT
		ug.`groupId`
	FROM
		`tbl_user_groups` ug
	WHERE
		ug.`userId` = `userId`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetUser`
(
	IN `userId` VARCHAR(80)
)
DETERMINISTIC
BEGIN
	DECLARE groupId BIGINT UNSIGNED;

	SELECT
		ug.`groupId`
	INTO
		`groupId`
	FROM
		`tbl_user_groups` ug
	WHERE
		ug.`userId` = `userId`;

	SELECT
		g.`groupId`,
		g.`groupCodeName`,
		g.`groupDisplayName`
	FROM
		`tbl_groups` g
	WHERE
		g.`groupId` = `groupId`;

	SELECT DISTINCT
		r.`roleId`,
		r.`roleCodeName`
	FROM
		`tbl_group_roles` gr
			JOIN
		`tbl_roles` r ON gr.`roleId` = r.`roleId`
	WHERE
		gr.`groupId` = `groupId`;

	SELECT DISTINCT
		p.`permissionId`,
		p.`permissionCodeName`,
		p.`permissionResource`
	FROM
		`tbl_group_roles` gr
			JOIN
		`tbl_role_permissions` rp ON gr.`roleId` = rp.`roleId`
			JOIN
		`tbl_permissions` p ON rp.`permissionId` = p.`permissionId`
	WHERE
		gr.`groupId` = `groupId`;
END//
DELIMITER ;

/********************************************************************/

CALL sp_AddRole('user',  'User of the system', 'Public user of the system');
CALL sp_AddRole('admin', 'Administrator of the system', 'Administrator of the system');

CALL sp_AddGroup('users',  'Users', 'Default group for all new users');
CALL sp_AddGroup('admins', 'Administrators', 'Users who have full control over everything in the system. These users can give anyone access to anything.');

CALL sp_AddGroupRole(1, 1);
CALL sp_AddGroupRole(2, 2);
