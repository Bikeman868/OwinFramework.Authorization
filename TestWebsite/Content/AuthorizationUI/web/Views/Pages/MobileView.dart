import 'dart:html';

import '../../MVVM/View.dart';

import '../../ViewModels/AuthorizationViewModel.dart';

import '../Panels/EditableListView.dart';
import '../Permissions/PermissionListSelectView.dart';
import '../Permissions/PermissionListEditView.dart';
import '../Permissions/PermissionListNewView.dart';

class MobileView extends View
{
	Element _menuRegion;
	Element _navRegion;
	Element _bodyRegion;

	AuthorizationViewModel _viewModel;

	MobileView(this._viewModel)
	{
		_mobileLayout();
		_permissionsView();
	}

	_mobileLayout()
	{
		_menuRegion = addContainer(classNames:['page-region', 'menu-region']);

		_navRegion = addContainer(classNames:['page-region', 'nav-region']);
		_bodyRegion = addContainer(classNames:['page-region', 'body-region']);

		addButton('Users', (MouseEvent e) => _usersView(), parent: _menuRegion);
		addButton('Groups', (MouseEvent e) => _groupsView(), parent: _menuRegion);
		addButton('Roles', (MouseEvent e) => _rolesView(), parent: _menuRegion);
		addButton('Permissions', (MouseEvent e) => _permissionsView(), parent: _menuRegion);

		addHeading(3, 'Mobile', parent: _bodyRegion);
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
}

