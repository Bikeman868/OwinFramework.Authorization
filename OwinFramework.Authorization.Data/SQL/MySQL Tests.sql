use authorization;

CALL sp_AddPermission('order.delete', 'Delete order', 'Delete orders from the database');
CALL sp_AddPermission('order.discount', 'Discount order', 'Apply discounts to orders to compensate customers');
CALL sp_AddPermission('user.suspend', 'Suspend user', 'Delete orders from the database');
CALL sp_AddPermission('user.resume', 'Resume user', 'Delete orders from the database');

CALL sp_AddRole('cs.manager', 'Customer service manager', 'Manages the customer service function');
CALL sp_AddRole('cs.operator', 'Customer service operator', 'Helps customers with their issues');

CALL sp_AddGroup('Customer service manager', 'Manages the customer service team');
CALL sp_AddGroup('Customer service', 'Take customer comlaints and deal with them');

CALL sp_AddRolePermission(1, 1);
CALL sp_AddRolePermission(1, 2);
CALL sp_AddRolePermission(1, 3);
CALL sp_AddRolePermission(1, 4);

CALL sp_AddRolePermission(2, 3);
CALL sp_AddRolePermission(2, 4);

CALL sp_AddGroupRole(1, 1);
CALL sp_AddGroupRole(2, 2);

CALL sp_ChangeUserGroup('manager@domain', 1);
CALL sp_ChangeUserGroup('cs1@domain', 2);
CALL sp_ChangeUserGroup('cs2@domain', 2);
CALL sp_ChangeUserGroup('cs3@domain', 2);

---------------------------------------------------

CALL sp_GetGroupPermissions(1);
CALL sp_GetGroupPermissions(2);

CALL sp_GetRolesWithPermission(1);
CALL sp_GetRolesWithPermission(2);
CALL sp_GetRolesWithPermission(3);
CALL sp_GetRolesWithPermission(4);

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

---------------------------------------------------

CALL sp_DeletePermission(2);
