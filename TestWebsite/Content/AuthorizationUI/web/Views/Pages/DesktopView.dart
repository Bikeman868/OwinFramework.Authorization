import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Events.dart';

import '../../ViewModels/AuthorizationViewModel.dart';

import '../Panels/EditableListView.dart';
import '../Permissions/PermissionListSelectView.dart';
import '../Permissions/PermissionListEditView.dart';
import '../Permissions/PermissionListNewView.dart';

class DesktopView extends View
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
		// TODO: use hidden panel instead of window.alert
		MvvmEvents.alert.listen((message) => window.alert(message));

		_desktopLayout();
		_permissionsView();
	}

	_desktopLayout()
	{
		_headerRegion = addContainer(classNames:['page-region', 'header-region']);
		_menuRegion = addContainer(classNames:['page-region', 'menu-region']);
		_mainRegion = addContainer(classNames:['page-region', 'main-region']);
		_footerRegion = addContainer(classNames:['page-region', 'footer-region']);

		_navRegion = addContainer(classNames:['page-region', 'nav-region'], parent: _mainRegion);
		_bodyRegion = addContainer(classNames:['page-region', 'body-region'], parent: _mainRegion);

		addHeading(2, 'Authorization', parent: _headerRegion);

		addButton('Users', (MouseEvent e) => _usersView(), parent: _menuRegion);
		addButton('Groups', (MouseEvent e) => _groupsView(), parent: _menuRegion);
		addButton('Roles', (MouseEvent e) => _rolesView(), parent: _menuRegion);
		addButton('Permissions', (MouseEvent e) => _permissionsView(), parent: _menuRegion);

		addHeading(3, 'Desktop', parent: _bodyRegion);
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

