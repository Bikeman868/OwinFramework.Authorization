﻿import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/PermissionViewModel.dart';

import '../Base/PageView.dart';

class MobileView extends PageView
{
	Element _menuRegion;
	Element _navRegion;

	AuthorizationViewModel _viewModel;

	MobileView(this._viewModel)
	{
		_createLayout();
		_displayUsers();
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

	_createLayout()
	{
		_menuRegion = addContainer(classNames:['page-region', 'menu-region']);
		_navRegion = addContainer(classNames:['page-region', 'nav-region']);

		addButton('Users', (MouseEvent e) => _displayUsers(), parent: _menuRegion);
		addButton('Groups', (MouseEvent e) => _displayGroups(), parent: _menuRegion);
		addButton('Roles', (MouseEvent e) => _displayRoles(), parent: _menuRegion);
		addButton('Permissions', (MouseEvent e) => _displayPermissions(), parent: _menuRegion);
	}

	_displayUsers()
	{
		_navRegion.children.clear();
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

