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

		AppEvents.permissionSelected.listen((e) => _permissionSelected(e.permission));

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

	EditableListView _permissionListView;

	_permissionsView()
	{
		if (_permissionListView == null)
		{
			var permissions = _viewModel.permissionList;

			_permissionListView = new EditableListView(
				'Permissions',
				permissions,
				new PermissionListSelectView(permissions),
				new PermissionListEditView(permissions),
				new PermissionListNewView(permissions));
		}

		_permissionListView.displayIn(_navRegion);
	}

	EditableView _permissionView;

	_permissionSelected(PermissionViewModel permission)
	{
		if (_permissionView == null)
		{
			_permissionView = new EditableView(
				'Permission',
				permission,
				new PermissionDisplayView(permission),
				new PermissionEditView(permission));
		}
		else
		{
			(_permissionView.displayView as PermissionDisplayView).viewModel = permission;
			(_permissionView.editView as PermissionEditView).viewModel = permission;
		}

		_permissionView.displayIn(_bodyRegion);
	}
}

