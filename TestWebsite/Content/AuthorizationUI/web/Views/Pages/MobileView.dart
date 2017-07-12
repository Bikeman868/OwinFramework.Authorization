import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Events.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/PermissionViewModel.dart';

import '../Panels/EditableListView.dart';
import '../Panels/EditableView.dart';

import '../Permissions/PermissionListSelectView.dart';
import '../Permissions/PermissionListEditView.dart';
import '../Permissions/PermissionListNewView.dart';
import '../Permissions/PermissionDisplayView.dart';
import '../Permissions/PermissionEditView.dart';

class MobileView extends View
{
	Element _menuRegion;
	Element _navRegion;

	AuthorizationViewModel _viewModel;

	MobileView(this._viewModel)
	{
		AppEvents.permissionSelected.listen((vm) => _permissionSelected(vm));

		_mobileLayout();
		_permissionsView();
	}

	_mobileLayout()
	{
		_menuRegion = addContainer(classNames:['page-region', 'menu-region']);
		_navRegion = addContainer(classNames:['page-region', 'nav-region']);

		addButton('Users', (MouseEvent e) => _usersView(), parent: _menuRegion);
		addButton('Groups', (MouseEvent e) => _groupsView(), parent: _menuRegion);
		addButton('Roles', (MouseEvent e) => _rolesView(), parent: _menuRegion);
		addButton('Permissions', (MouseEvent e) => _permissionsView(), parent: _menuRegion);
	}

	_usersView()
	{
		_navRegion.children.clear();
	}

	_groupsView()
	{
		_navRegion.children.clear();
	}

	_rolesView()
	{
		_navRegion.children.clear();
	}

	_permissionsView()
	{
		var permissions = _viewModel.permissionList;

		var permissionListView = new EditableListView(
			'Permissions',
			permissions,
			new PermissionListSelectView(permissions),
			new PermissionListEditView(permissions),
			new PermissionListNewView(permissions));

		permissionListView.displayIn(_navRegion);
	}

	_permissionSelected(PermissionViewModel permission)
	{
		var permissionView = new EditableView(
			'Permission',
			permission,
			new PermissionDisplayView(permission),
			new PermissionEditView(permission));

		permissionView.displayIn(_navRegion);
	}
}

