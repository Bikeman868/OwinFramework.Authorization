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
  `permissionResource` VARCHAR(120) COLLATE utf8mb4_unicode_ci NULL,
  `permissionDisplayName` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permissionDescription` VARCHAR(400) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`permissionId`),
  UNIQUE INDEX `ix_name` (`permissionCodeName`, `permissionResource`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tbl_identity_groups`
(
  `groupId` BIGINT(20) NOT NULL,
  `identity` VARCHAR(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`groupId`, `identity`),
  KEY `ix_group` (`groupId`),
  UNIQUE INDEX `ix_identity` (`identity`)
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
CREATE PROCEDURE `sp_GetGroupByCodeName`
(
	IN `codeName` VARCHAR(80)
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
		g.`groupCodeName` = `codeName`;
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
		`tbl_identity_groups` g
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
CREATE PROCEDURE `sp_ChangeIdentityGroup`
(
	IN `identity` VARCHAR(80),
	IN `groupId` BIGINT UNSIGNED
)
DETERMINISTIC
BEGIN
	REPLACE INTO 
		`tbl_identity_groups`
	(
		`groupId`,
		`identity`
	) VALUES (
		`groupId`,
		`identity`
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
CREATE PROCEDURE `sp_GetRoleByCodeName`
(
	IN `codeName` VARCHAR(80)
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
		r.`roleCodeName` = `codeName`;
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
CREATE PROCEDURE `sp_GetPermissions`
(
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
CREATE PROCEDURE `sp_GetPermissionByCodeName`
(
	IN `codeName` VARCHAR(80)
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
		p.`permissionCodeName` = `codeName`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_AddPermission`
(
	IN `permissionCodeName` VARCHAR(30),
	IN `permissionResource` VARCHAR(120),
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
	IN `permissionResource` VARCHAR(120),
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
		p.`permissionResource`,
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
CREATE PROCEDURE `sp_GetIdentityPermissions`
(
	IN `identity` VARCHAR(80)
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
		`tbl_identity_groups` ug
			JOIN 
		`tbl_group_roles` gr ON ug.`groupId` = gr.`groupId`
			JOIN
		`tbl_role_permissions` rp ON gr.`roleId` = rp.`roleId`
			JOIN
		`tbl_permissions` p ON rp.`permissionId` = p.`permissionId`
	WHERE
		ug.`identity` = `identity`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetIdentityRoles`
(
	IN `identity` VARCHAR(80)
)
DETERMINISTIC
BEGIN
	SELECT DISTINCT
		r.`roleId`,
		r.`roleCodeName`,
		r.`roleDisplayName`,
		r.`roleDescription`
	FROM
		`tbl_identity_groups` ug
			JOIN 
		`tbl_group_roles` gr ON ug.`groupId` = gr.`groupId`
			JOIN
		`tbl_roles` r ON gr.`roleId` = r.`roleId`
	WHERE
		ug.`identity` = `identity`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetIdentityGroupId`
(
	IN `identity` VARCHAR(80)
)
DETERMINISTIC
BEGIN
	SELECT DISTINCT
		ug.`groupId`
	FROM
		`tbl_identity_groups` ug
	WHERE
		ug.`identity` = `identity`;
END//
DELIMITER ;

/********************************************************************/

DELIMITER //
CREATE PROCEDURE `sp_GetIdentity`
(
	IN `identity` VARCHAR(80)
)
DETERMINISTIC
BEGIN
	DECLARE groupId BIGINT UNSIGNED;

	SELECT
		ug.`groupId`
	INTO
		`groupId`
	FROM
		`tbl_identity_groups` ug
	WHERE
		ug.`identity` = `identity`;

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

-- Permissions with no resource restrictions
CALL sp_AddPermission('auth:api', NULL, 'Authorization API', 'Allows users to call the authorization API, required to use the UI');
CALL sp_AddPermission('auth:permission.edit', NULL, 'Edit any permission', 'Allows users to save changes to permission records');
CALL sp_AddPermission('auth:role.edit', NULL, 'Edit any role', 'Allows users to save changes to role records');
CALL sp_AddPermission('auth:group.edit', NULL, 'Edit any group', 'Allows users to save changes to group records');
CALL sp_AddPermission('auth:permission.assign', NULL, 'Assign any permission', 'Allows users to assign any permission to any role');
CALL sp_AddPermission('auth:role.assign', NULL, 'Assign any role', 'Allows users to assign any role to any group');
CALL sp_AddPermission('auth:group.assign', NULL, 'Assign any group', 'Allows users to assign any group to any user');

-- Permissions restricted to specific resources
CALL sp_AddPermission('auth:group.assign', 'group:{my.group}', 'Assign user to my group', 'Allows users to add other users into their group');

-- Roles
CALL sp_AddRole('sys.user', 'User of the system', 'Allows users to use the system');
CALL sp_AddRole('auth.admin', 'Administrator of the authentication system', 'Allows users to manage groups, roles and permissions');
CALL sp_AddRole('auth.super', 'Supervisor of the authentication system', 'Allows users to view the authentication system UI and give other users to this role');

CALL sp_AddRolePermission(2, 1);
CALL sp_AddRolePermission(2, 2);
CALL sp_AddRolePermission(2, 3);
CALL sp_AddRolePermission(2, 4);
CALL sp_AddRolePermission(2, 5);
CALL sp_AddRolePermission(2, 6);
CALL sp_AddRolePermission(2, 7);

CALL sp_AddRolePermission(3, 1);
CALL sp_AddRolePermission(3, 8);

-- User groups
CALL sp_AddGroup('sys.admins', 'Administrators', 'Users who have full control over everything in the system. These users can give anyone access to anything.');
CALL sp_AddGroup('sys.users',  'Users', 'Default group for all new users');
CALL sp_AddGroup('auth.admins',  'Auth users', 'Users who manage the authentication system');
CALL sp_AddGroup('auth.super',  'Auth supervisors', 'Users who can perform basic authentication system tasks');

-- Note that sys admins don't need roles assigned, they automatically have all permissions
CALL sp_AddGroupRole(2, 1);
CALL sp_AddGroupRole(3, 2);
CALL sp_AddGroupRole(4, 3);

-- Note that you need to assign at least one sys admin to be able to configure permissions for other users
CALL sp_ChangeIdentityGroup('administrator@mycompany.com', 1);
