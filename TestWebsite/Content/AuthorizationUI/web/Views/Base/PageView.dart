import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Events.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/RoleListViewModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';
import '../../ViewModels/PermissionViewModel.dart';

import '../Panels/EditableListView.dart';
import '../Panels/EditableView.dart';

import '../Permissions/PermissionListSelectView.dart';
import '../Permissions/PermissionListEditView.dart';
import '../Permissions/PermissionListNewView.dart';
import '../Permissions/PermissionDisplayView.dart';
import '../Permissions/PermissionEditView.dart';

class PageView extends View
{
	PageView()
	{
		MvvmEvents.alert.listen((message) => alert(message));

		AppEvents.permissionSelected.listen((e) => permissionSelected(e.permission));
	}

	alert(String message){}

	permissionSelected(PermissionViewModel permissionViewModel){}
	roleSelected(RoleViewModel roleViewModel){}
	groupSelected(GroupViewModel groupViewModel){}

	EditableListView _permissionListView;

	displayPermissionList(PermissionListViewModel permissionListViewModel, Element container)
	{
		if (_permissionListView == null)
		{
			_permissionListView = new EditableListView(
				'Permissions',
				permissionListViewModel,
				new PermissionListSelectView(permissionListViewModel),
				new PermissionListEditView(permissionListViewModel),
				new PermissionListNewView(permissionListViewModel));
		}
		else
		{
			_permissionListView.viewModel = permissionListViewModel;
			(_permissionListView.selectView as PermissionListSelectView).viewModel = permissionListViewModel;
			(_permissionListView.editView as PermissionListEditView).viewModel = permissionListViewModel;
			(_permissionListView.addView as PermissionListNewView).viewModel = permissionListViewModel;
		}

		_permissionListView.displayIn(container);
	}

	EditableView _permissionView;

	displayPermission(PermissionViewModel permissionViewModel, Element container)
	{
		if (_permissionView == null)
		{
			_permissionView = new EditableView(
				'Permission',
				permissionViewModel,
				new PermissionDisplayView(permissionViewModel),
				new PermissionEditView(permissionViewModel));
		}
		else
		{
			(_permissionView.displayView as PermissionDisplayView).viewModel = permissionViewModel;
			(_permissionView.editView as PermissionEditView).viewModel = permissionViewModel;
		}

		_permissionView.displayIn(container);
	}
}

