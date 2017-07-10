﻿import 'dart:html';

import '../../MVVM/View.dart';

import '../../ViewModels/AuthorizationViewModel.dart';

import '../Panels/EditableListView.dart';
import '../Permissions/PermissionListSelectView.dart';
import '../Permissions/PermissionListEditView.dart';
import '../Permissions/PermissionListNewView.dart';

class ManageAuthorizationView extends View
{

	Element _headerRegion;
	Element _menuRegion;
	Element _mainRegion;
	Element _footerRegion;

	Element _navRegion;
	Element _bodyRegion;

	AuthorizationViewModel _viewModel;

	ManageAuthorizationView(this._viewModel)
	{
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

