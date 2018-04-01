USE authorization;

SELECT p.permissionId INTO @permission_assign_mygroup FROM tbl_permissions p WHERE p.permissionCodeName='auth:group.assign' AND p.permissionResource='group:{my.group}';

SELECT r.roleId INTO @role_user FROM tbl_roles r WHERE r.roleCodeName='sys.user';
SELECT r.roleId INTO @role_admin FROM tbl_roles r WHERE r.roleCodeName='auth.admin';
SELECT r.roleId INTO @role_super FROM tbl_roles r WHERE r.roleCodeName='auth.super';

SELECT g.groupId INTO @group_sys_admins FROM tbl_groups g WHERE g.groupCodeName='sys.admins';
SELECT g.groupId INTO @group_sys_users FROM tbl_groups g WHERE g.groupCodeName='sys.users';
SELECT g.groupId INTO @group_auth_admins FROM tbl_groups g WHERE g.groupCodeName='auth.admins';
SELECT g.groupId INTO @group_auth_super FROM tbl_groups g WHERE g.groupCodeName='auth.super';

CALL sp_AddPermission('sys:use', NULL,  'Use the system', 'Make use of the parts of the system restricted to logged in users');
SELECT p.permissionId INTO @permission_sys_user FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('cart:order.delete', NULL, 'Delete order', 'Delete orders from the shopping cart system');
SELECT p.permissionId INTO @permission_cart_order_delete FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('cart:order.discount', NULL, 'Discount order', 'Apply discounts to orders');
SELECT p.permissionId INTO @permission_cart_order_discount FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('cart:order.cancel', 'user:{my.id}', 'Cancel my orders', 'Cancel orders that I placed in the system');
SELECT p.permissionId INTO @permission_cart_myorder_cancel FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('cart:order.cancel', NULL, 'Cancel any order', 'Cancel any order in the shopping cart system');
SELECT p.permissionId INTO @permission_cart_order_cancel FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;
															     
CALL sp_AddPermission('users:user.suspend', NULL, 'Suspend any user', 'Suspend any user''s access to the system');
SELECT p.permissionId INTO @permission_user_suspend FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('users:user.resume', NULL, 'Resume any user', 'Restore any user''s access to the system');
SELECT p.permissionId INTO @permission_user_resume FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;
															     
CALL sp_AddPermission('auth:role.assign', 'role:csmanager', 'Assign the CS Manager role', 'Assign the CS managers role to any group of users');
SELECT p.permissionId INTO @permission_assign_role_csmanager FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('auth:role.assign', 'role:cs', 'Assign CS role', 'Assign the CS role to any group of users');
SELECT p.permissionId INTO @permission_assign_role_cs FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('auth:group.assign', 'group:cs.manager', 'Assign user to cs.manager group', 'Add users to the CS Managers group');
SELECT p.permissionId INTO @permission_assign_group_csmanager FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddPermission('auth:group.assign', 'group:cs', 'Assign user to cs group', 'Add users to the CS group');
SELECT p.permissionId INTO @permission_assign_group_cs FROM tbl_permissions p ORDER BY p.permissionId DESC LIMIT 1;

CALL sp_AddRole('cs.manager', 'Customer service manager', 'Manages the customer service function');
CALL sp_AddRole('cs', 'Customer service operator', 'Helps customers with their issues');

SELECT r.roleId INTO @role_cs_manager FROM tbl_roles r WHERE r.roleCodeName='cs.manager';
SELECT r.roleId INTO @role_cs FROM tbl_roles r WHERE r.roleCodeName='cs';

CALL sp_AddRolePermission(@role_user, @permission_sys_user); -- Users can use the system
CALL sp_AddRolePermission(@role_user, @permission_cart_myorder_cancel);  -- Users can cancel their own orders

CALL sp_AddRolePermission(@role_cs_manager, @permission_cart_order_delete);  -- CS managers can delete orders
CALL sp_AddRolePermission(@role_cs_manager, @permission_cart_order_cancel);  -- CS managers can cancel any order
CALL sp_AddRolePermission(@role_cs_manager, @permission_assign_group_cs); -- CS managers can add users to the 'cs' group

CALL sp_AddRolePermission(@role_cs, @permission_cart_order_discount);  -- CS can discount any order
CALL sp_AddRolePermission(@role_cs, @permission_user_suspend);  -- CS can suspend user accounts
CALL sp_AddRolePermission(@role_cs, @permission_user_resume);  -- CS can resume user accounts

CALL sp_AddGroup('cs.manager', 'Customer service manager', 'Manages the customer service team');
CALL sp_AddGroup('cs', 'Customer service', 'Users who listen to customer comlaints and resolve them');

SELECT g.groupId INTO @group_cs_manager FROM tbl_groups g WHERE g.groupCodeName='cs.manager';
SELECT g.groupId INTO @group_cs FROM tbl_groups g WHERE g.groupCodeName='cs';

CALL sp_AddGroupRole(@group_cs_manager, @role_user); -- CS manager has the 'user' role
CALL sp_AddGroupRole(@group_cs_manager, @role_cs_manager); -- CS manager has the 'cs.manager' role
CALL sp_AddGroupRole(@group_cs_manager, @role_cs); -- CS manager has the 'cs' role

CALL sp_AddGroupRole(@group_cs, @role_user); -- CS has the 'user' role
CALL sp_AddGroupRole(@group_cs, @role_cs); -- CS manager has the 'cs' role

CALL sp_ChangeIdentityGroup('urn:identity:baltmzbu1uypqajj1n9dv87m6v', @group_cs_manager);
CALL sp_ChangeIdentityGroup('urn:identity:bb7m2ss1hi858bwgc111h3zk1o', @group_cs);
CALL sp_ChangeIdentityGroup('urn:identity:bcw1qpn09prjmdnvnwdht1hcge', @group_cs);
CALL sp_ChangeIdentityGroup('urn:identity:bcxc0ermlshfxa3tmstwyyzvbh', 1);

/************************************************************/

CALL sp_GetGroups();
CALL sp_GetRoles();
CALL sp_GetPermissions();

CALL sp_GetGroupPermissions(@group_sys_admins);
CALL sp_GetGroupPermissions(@group_sys_users);
CALL sp_GetGroupPermissions(@group_auth_admins);
CALL sp_GetGroupPermissions(@group_auth_super);
CALL sp_GetGroupPermissions(@group_cs_manager);
CALL sp_GetGroupPermissions(@group_cs);

CALL sp_GetRolePermissions(@role_user);
CALL sp_GetRolePermissions(@role_admin);
CALL sp_GetRolePermissions(@role_super);
CALL sp_GetRolePermissions(@role_cs_manager);
CALL sp_GetRolePermissions(@role_cs);

CALL sp_GetRolesWithPermission(@permission_assign_mygroup);
CALL sp_GetRolesWithPermission(@permission_sys_user);
CALL sp_GetRolesWithPermission(@permission_assign_role_cs);
CALL sp_GetRolesWithPermission(@permission_assign_group_cs);
CALL sp_GetRolesWithPermission(@permission_cart_myorder_cancel);

CALL sp_GetIdentityPermissions('urn:identity:baltmzbu1uypqajj1n9dv87m6v');
CALL sp_GetIdentityPermissions('urn:identity:bb7m2ss1hi858bwgc111h3zk1o');
CALL sp_GetIdentityPermissions('urn:identity:bcw1qpn09prjmdnvnwdht1hcge');
CALL sp_GetIdentityPermissions('urn:identity:bcxc0ermlshfxa3tmstwyyzvbh');

CALL sp_GetIdentityRoles('urn:identity:baltmzbu1uypqajj1n9dv87m6v');
CALL sp_GetIdentityRoles('urn:identity:bb7m2ss1hi858bwgc111h3zk1o');
CALL sp_GetIdentityRoles('urn:identity:bcw1qpn09prjmdnvnwdht1hcge');
CALL sp_GetIdentityRoles('urn:identity:bcxc0ermlshfxa3tmstwyyzvbh');

CALL sp_GetIdentity('urn:identity:baltmzbu1uypqajj1n9dv87m6v');
CALL sp_GetIdentity('urn:identity:bb7m2ss1hi858bwgc111h3zk1o');
CALL sp_GetIdentity('urn:identity:bcw1qpn09prjmdnvnwdht1hcge');
CALL sp_GetIdentity('urn:identity:bcxc0ermlshfxa3tmstwyyzvbh');
CALL sp_GetIdentity('annonymous@domain');
CALL sp_GetIdentity('urn:identity:bhsmp4h51ha8bcywxqhba1rvn6');

CALL sp_ChangeIdentityGroup('urn:identity:bcxc0ermlshfxa3tmstwyyzvbh', NULL);
CALL sp_GetIdentity('urn:identity:bcxc0ermlshfxa3tmstwyyzvbh');
CALL sp_ChangeIdentityGroup('urn:identity:bcxc0ermlshfxa3tmstwyyzvbh', 1);


SELECT * FROM tbl_identity_groups;

/************************************************************/

/*

CALL sp_DeletePermission(2);

*/