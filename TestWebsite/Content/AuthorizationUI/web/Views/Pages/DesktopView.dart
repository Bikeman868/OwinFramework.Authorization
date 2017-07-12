﻿import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Events.dart';

import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/PermissionViewModel.dart';

import '../Base/PageView.dart';

class DesktopView extends PageView
{
	Element _headerRegion;
	Element _menuRegion;
	Element _mainRegion;
	Element _footerRegion;

	Element _navRegion;
	Element _bodyRegion;

	AuthorizationViewModel _viewModel;

	DesktopView(this._viewModel)
	{
		_createLayout();
		_displayPermissions();
	}

	alert(String message)
	{
		// TODO: use hidden panel instead of window.alert
		window.alert(message);
	}

	groupSelected(GroupViewModel groupViewModel)
	{
		displayGroup(groupViewModel, _bodyRegion);
	}

	roleSelected(RoleViewModel roleViewModel)
	{
		displayRole(roleViewModel, _bodyRegion);
	}

	permissionSelected(PermissionViewModel permissionViewModel)
	{
		displayPermission(permissionViewModel, _bodyRegion);
	}

	_createLayout()
	{
		_headerRegion = addContainer(classNames:['page-region', 'header-region']);
		_menuRegion = addContainer(classNames:['page-region', 'menu-region']);
		_mainRegion = addContainer(classNames:['page-region', 'main-region']);
		_footerRegion = addContainer(classNames:['page-region', 'footer-region']);

		_navRegion = addContainer(classNames:['page-region', 'nav-region'], parent: _mainRegion);
		_bodyRegion = addContainer(classNames:['page-region', 'body-region'], parent: _mainRegion);

		addHeading(2, 'Authorization', parent: _headerRegion);

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

