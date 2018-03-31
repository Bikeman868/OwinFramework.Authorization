import 'dart:html';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/IdentityViewModel.dart';

import '../Base/PageView.dart';

class MobileView extends PageView
{
	Element _menuRegion;
	Element _navRegion;

	AuthorizationViewModel _viewModel;

	MobileView(this._viewModel)
	{
		_createLayout();
		_displayIdentities();
	}

	groupSelected(GroupViewModel groupViewModel)
	{
		displayGroup(_viewModel, groupViewModel, _navRegion);
	}

	roleSelected(RoleViewModel roleViewModel)
	{
		displayRole(_viewModel, roleViewModel, _navRegion);
	}

	permissionSelected(PermissionViewModel permissionViewModel)
	{
		displayPermission(_viewModel, permissionViewModel, _navRegion);
	}

	identitySelected(IdentityViewModel identityViewModel)
	{
		displayIdentity(_viewModel, identityViewModel, _navRegion);
	}

	_createLayout()
	{
		_menuRegion = addContainer(classNames:['page-region', 'menu-region']);
		_navRegion = addContainer(classNames:['page-region', 'nav-region']);

		addButton('Users', (MouseEvent e) => _displayIdentities(), parent: _menuRegion);
		addButton('Groups', (MouseEvent e) => _displayGroups(), parent: _menuRegion);
		addButton('Roles', (MouseEvent e) => _displayRoles(), parent: _menuRegion);
		addButton('Permissions', (MouseEvent e) => _displayPermissions(), parent: _menuRegion);
	}

	_displayIdentities()
	{
		displayIdentityList(null, _navRegion);
	}

	_displayGroups()
	{
		displayGroupList(_viewModel.groupList, _navRegion);
	}

	_displayRoles()
	{
		displayRoleList(_viewModel.roleList, _navRegion);
	}

	_displayPermissions()
	{
		displayPermissionList(_viewModel.permissionList, _navRegion);
	}
}

