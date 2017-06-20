USE authorization;

CALL sp_AddPermission('order.delete', 'Delete order', 'Delete orders from the database');
CALL sp_AddPermission('order.discount', 'Discount order', 'Apply discounts to orders to compensate customers');
CALL sp_AddPermission('user.suspend', 'Suspend user', 'Suspend a user''s access to the system');
CALL sp_AddPermission('user.resume', 'Resume user', 'Restore a user''s access to the system');
CALL sp_AddPermission('auth.assign.csmanager', 'Assign user to CS Manager group', 'Add users to the CS managers group');
CALL sp_AddPermission('auth.assign.cs', 'Assign user to CS group', 'Add users to the CS team group');
CALL sp_AddPermission('use', 'Use the system', 'Make use of the parts of the system restricted to logged in users');

CALL sp_AddRole('cs.manager', 'Customer service manager', 'Manages the customer service function');
CALL sp_AddRole('cs.operator', 'Customer service operator', 'Helps customers with their issues');
CALL sp_AddRole('user', 'User of the system', 'Public user of the system');
CALL sp_AddRole('admin', 'Administrator of the system', 'Administrator of the system');

CALL sp_AddGroup('Customer service manager', 'Manages the customer service team', NULL);
CALL sp_AddGroup('Customer service', 'Take customer comlaints and deal with them', 6);
CALL sp_AddGroup('Users', 'Default group for all new users', NULL);
CALL sp_AddGroup('Administrators', 'Manage the authentication system', NULL);

CALL sp_AddRolePermission(1, 1);
CALL sp_AddRolePermission(1, 2);
CALL sp_AddRolePermission(1, 6);

CALL sp_AddRolePermission(2, 3);
CALL sp_AddRolePermission(2, 4);

CALL sp_AddRolePermission(3, 7);

CALL sp_AddRolePermission(4, 5);

CALL sp_AddGroupRole(1, 1);
CALL sp_AddGroupRole(1, 2);
CALL sp_AddGroupRole(1, 3);
CALL sp_AddGroupRole(2, 2);
CALL sp_AddGroupRole(2, 3);
CALL sp_AddGroupRole(3, 3);
CALL sp_AddGroupRole(4, 4);

CALL sp_ChangeUserGroup('manager@domain', 1);
CALL sp_ChangeUserGroup('cs1@domain', 2);
CALL sp_ChangeUserGroup('cs2@domain', 2);
CALL sp_ChangeUserGroup('cs3@domain', 2);
CALL sp_ChangeUserGroup('admin@domain', 4);

-- =================================================

CALL sp_GetGroups();
CALL sp_GetRoles();
CALL sp_GetPermissions();

CALL sp_GetGroupPermissions(1);
CALL sp_GetGroupPermissions(2);
CALL sp_GetGroupPermissions(3);

CALL sp_GetRolesWithPermission(1);
CALL sp_GetRolesWithPermission(2);
CALL sp_GetRolesWithPermission(3);
CALL sp_GetRolesWithPermission(4);
CALL sp_GetRolesWithPermission(5);
CALL sp_GetRolesWithPermission(6);
CALL sp_GetRolesWithPermission(7);

CALL sp_GetUserPermissions('manager@domain');
CALL sp_GetUserPermissions('cs1@domain');
CALL sp_GetUserPermissions('cs2@domain');
CALL sp_GetUserPermissions('cs3@domain');

CALL sp_GetUserRoles('manager@domain');
CALL sp_GetUserRoles('cs1@domain');
CALL sp_GetUserRoles('cs2@domain');
CALL sp_GetUserRoles('cs3@domain');

CALL sp_GetUser('manager@domain');
CALL sp_GetUser('cs1@domain');
CALL sp_GetUser('cs2@domain');
CALL sp_GetUser('cs3@domain');
CALL sp_GetUser('annonymous@domain');
CALL sp_GetUser('admin@domain');

-- =================================================

/*

CALL sp_DeletePermission(2);

*/