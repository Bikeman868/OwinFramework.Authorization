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

import '../Groups/GroupListSelectView.dart';
import '../Groups/GroupListEditView.dart';
import '../Groups/GroupListNewView.dart';
import '../Groups/GroupDisplayView.dart';
import '../Groups/GroupEditView.dart';

import '../Roles/RoleListSelectView.dart';
import '../Roles/RoleListEditView.dart';
import '../Roles/RoleListNewView.dart';
import '../Roles/RoleDisplayView.dart';
import '../Roles/RoleEditView.dart';

class PageView extends View
{
	PageView()
	{
		MvvmEvents.alert.listen((message) => alert(message));

		AppEvents.groupSelected.listen((e) => groupSelected(e.group));
		AppEvents.roleSelected.listen((e) => roleSelected(e.role));
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

	EditableListView _groupListView;

	displayGroupList(GroupListViewModel groupListViewModel, Element container)
	{
		if (_groupListView == null)
		{
			_groupListView = new EditableListView(
				'Groups',
				groupListViewModel,
				new GroupListSelectView(groupListViewModel),
				new GroupListEditView(groupListViewModel),
				new GroupListNewView(groupListViewModel));
		}
		else
		{
			_groupListView.viewModel = groupListViewModel;
			(_groupListView.selectView as GroupListSelectView).viewModel = groupListViewModel;
			(_groupListView.editView as GroupListEditView).viewModel = groupListViewModel;
			(_groupListView.addView as GroupListNewView).viewModel = groupListViewModel;
		}

		_groupListView.displayIn(container);
	}

	EditableListView _roleListView;

	displayRoleList(RoleListViewModel roleListViewModel, Element container)
	{
		if (_roleListView == null)
		{
			_roleListView = new EditableListView(
				'Roles',
				roleListViewModel,
				new RoleListSelectView(roleListViewModel),
				new RoleListEditView(roleListViewModel),
				new RoleListNewView(roleListViewModel));
		}
		else
		{
			_roleListView.viewModel = roleListViewModel;
			(_roleListView.selectView as RoleListSelectView).viewModel = roleListViewModel;
			(_roleListView.editView as RoleListEditView).viewModel = roleListViewModel;
			(_roleListView.addView as RoleListNewView).viewModel = roleListViewModel;
		}

		_roleListView.displayIn(container);
	}

	EditableView _groupView;

	displayGroup(GroupViewModel groupViewModel, Element container)
	{
		if (_groupView == null)
		{
			_groupView = new EditableView(
				'Group',
				groupViewModel,
				new GroupDisplayView(groupViewModel),
				new GroupEditView(groupViewModel));
		}
		else
		{
			(_groupView.displayView as GroupDisplayView).viewModel = groupViewModel;
			(_groupView.editView as GroupEditView).viewModel = groupViewModel;
		}

		_groupView.displayIn(container);
	}

	EditableView _roleView;

	displayRole(RoleViewModel roleViewModel, Element container)
	{
		if (_roleView == null)
		{
			_roleView = new EditableView(
				'Role',
				roleViewModel,
				new RoleDisplayView(roleViewModel),
				new RoleEditView(roleViewModel));
		}
		else
		{
			(_roleView.displayView as RoleDisplayView).viewModel = roleViewModel;
			(_roleView.editView as RoleEditView).viewModel = roleViewModel;
		}

		_roleView.displayIn(container);
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

