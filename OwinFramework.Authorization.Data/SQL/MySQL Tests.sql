USE authorization;

CALL sp_AddRole('cs.manager', 'Customer service manager', 'Manages the customer service function');
CALL sp_AddRole('cs', 'Customer service operator', 'Helps customers with their issues');

CALL sp_AddPermission('sys:use',             NULL,               'Use the system', 'Make use of the parts of the system restricted to logged in users');

CALL sp_AddPermission('cart:order.delete',   NULL,               'Delete order', 'Delete orders from the shopping cart system');
CALL sp_AddPermission('cart:order.discount', NULL,               'Discount order', 'Apply discounts to orders');
CALL sp_AddPermission('cart:order.cancel',   'user:{self}',      'Cancel my orders', 'Cancel orders that I placed in the system');
CALL sp_AddPermission('cart:order.cancel',   NULL,               'Cancel any order', 'Cancel any order in the shopping cart system');
															     
CALL sp_AddPermission('users:user.suspend',  NULL,               'Suspend any user', 'Suspend any user''s access to the system');
CALL sp_AddPermission('users:user.resume',   NULL,               'Resume any user', 'Restore any user''s access to the system');
															     
CALL sp_AddPermission('auth:role.assign',    'role:csmanager',   'Assign the CS Manager role', 'Assign the CS managers role to any group of users');
CALL sp_AddPermission('auth:role.assign',    'role:cs',          'Assign CS role', 'Assign the CS role to any group of users');
CALL sp_AddPermission('auth:group.assign',   'group:cs.manager', 'Assign user to cs.manager group', 'Add users to the CS Managers group');
CALL sp_AddPermission('auth:group.assign',   'group:cs',         'Assign user to cs group', 'Add users to the CS group');

CALL sp_AddRolePermission(1, 1);
CALL sp_AddRolePermission(1, 4);

CALL sp_AddRolePermission(3, 2);
CALL sp_AddRolePermission(3, 5);
CALL sp_AddRolePermission(3, 11);

CALL sp_AddRolePermission(4, 3);
CALL sp_AddRolePermission(4, 6);
CALL sp_AddRolePermission(4, 7);

CALL sp_AddGroup('cs.manager', 'Customer service manager', 'Manages the customer service team');
CALL sp_AddGroup('cs', 'Customer service', 'Users who listen to customer comlaints and resolve them');

CALL sp_AddGroupRole(3, 1);
CALL sp_AddGroupRole(3, 3);
CALL sp_AddGroupRole(3, 4);

CALL sp_AddGroupRole(4, 1);
CALL sp_AddGroupRole(4, 4);

CALL sp_ChangeIdentityGroup('manager@domain', 3);
CALL sp_ChangeIdentityGroup('cs1@domain', 4);
CALL sp_ChangeIdentityGroup('cs2@domain', 4);
CALL sp_ChangeIdentityGroup('cs3@domain', 4);
CALL sp_ChangeIdentityGroup('admin@domain', 2);

/************************************************************/

CALL sp_GetGroups();
CALL sp_GetRoles();
CALL sp_GetPermissions();

CALL sp_GetGroupPermissions(1);
CALL sp_GetGroupPermissions(2);
CALL sp_GetGroupPermissions(3);
CALL sp_GetGroupPermissions(4);

CALL sp_GetRolesWithPermission(1);
CALL sp_GetRolesWithPermission(2);
CALL sp_GetRolesWithPermission(3);
CALL sp_GetRolesWithPermission(4);
CALL sp_GetRolesWithPermission(5);
CALL sp_GetRolesWithPermission(6);
CALL sp_GetRolesWithPermission(7);

CALL sp_GetIdentityPermissions('manager@domain');
CALL sp_GetIdentityPermissions('cs1@domain');
CALL sp_GetIdentityPermissions('cs2@domain');
CALL sp_GetIdentityPermissions('cs3@domain');

CALL sp_GetIdentityRoles('manager@domain');
CALL sp_GetIdentityRoles('cs1@domain');
CALL sp_GetIdentityRoles('cs2@domain');
CALL sp_GetIdentityRoles('cs3@domain');

CALL sp_GetIdentity('manager@domain');
CALL sp_GetIdentity('cs1@domain');
CALL sp_GetIdentity('cs2@domain');
CALL sp_GetIdentity('cs3@domain');
CALL sp_GetIdentity('annonymous@domain');
CALL sp_GetIdentity('admin@domain');

/************************************************************/

/*

CALL sp_DeletePermission(2);

*/