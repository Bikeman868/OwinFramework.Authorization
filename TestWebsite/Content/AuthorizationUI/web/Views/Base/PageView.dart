import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Events/AppEvents.dart';

import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/RoleListViewModel.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';
import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/IdentityListViewModel.dart';
import '../../ViewModels/IdentityViewModel.dart';

import '../Panels/EditableListView.dart';
import '../Panels/EditableView.dart';

import '../Permissions/PermissionListSelectView.dart';
import '../Permissions/PermissionListEditView.dart';
import '../Permissions/PermissionListNewView.dart';
import '../Permissions/PermissionDisplayView.dart';
import '../Permissions/PermissionEditView.dart';
import '../Permissions/PermissionDeleteView.dart';

import '../Groups/GroupListSelectView.dart';
import '../Groups/GroupListNewView.dart';
import '../Groups/GroupDisplayView.dart';
import '../Groups/GroupEditView.dart';
import '../Groups/GroupDeleteView.dart';

import '../Roles/RoleListSelectView.dart';
import '../Roles/RoleListEditView.dart';
import '../Roles/RoleListNewView.dart';
import '../Roles/RoleDisplayView.dart';
import '../Roles/RoleEditView.dart';
import '../Roles/RoleDeleteView.dart';

import '../Identities/IdentityListSelectView.dart';
import '../Identities/IdentityDisplayView.dart';
import '../Identities/IdentityEditView.dart';
import '../Identities/IdentityDeleteView.dart';

class PageView extends View
{
	PageView()
	{
		MvvmEvents.alert.listen((message) => alert(message));

		AppEvents.groupSelected.listen((e) => groupSelected(e.group));
		AppEvents.roleSelected.listen((e) => roleSelected(e.role));
		AppEvents.permissionSelected.listen((e) => permissionSelected(e.permission));
		AppEvents.identitySelected.listen((e) => identitySelected(e.identity));
	}

	alert(String message){}

	permissionSelected(PermissionViewModel permissionViewModel){}
	roleSelected(RoleViewModel roleViewModel){}
	groupSelected(GroupViewModel groupViewModel){}
	identitySelected(IdentityViewModel identityViewModel){}

	EditableListView _permissionListView;

	displayPermissionList(
		PermissionListViewModel permissionListViewModel, 
		Element container)
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

	displayGroupList(
		GroupListViewModel groupListViewModel, 
		Element container)
	{
		if (_groupListView == null)
		{
			_groupListView = new EditableListView(
				'Groups',
				groupListViewModel,
				new GroupListSelectView(groupListViewModel),
				null,
				new GroupListNewView(groupListViewModel));
		}
		else
		{
			_groupListView.viewModel = groupListViewModel;
			(_groupListView.selectView as GroupListSelectView).viewModel = groupListViewModel;
			(_groupListView.addView as GroupListNewView).viewModel = groupListViewModel;
		}

		_groupListView.displayIn(container);
	}

	EditableListView _roleListView;

	displayRoleList(
		RoleListViewModel roleListViewModel, 
		Element container)
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

	IdentityListSelectView _identityListView;

	displayIdentityList(
		AuthorizationViewModel authorizationViewModel, 
		IdentityListViewModel identityListViewModel, 
		Element container)
	{
		if (_identityListView == null)
		{
			_identityListView = new IdentityListSelectView(authorizationViewModel, identityListViewModel);
		}
		else
		{
			_identityListView.viewModel = identityListViewModel;
		}

		_identityListView.displayIn(container);
	}

	EditableView _groupView;

	displayGroup(
		AuthorizationViewModel authorizationViewModel, 
		GroupViewModel groupViewModel, 
		Element container)
	{
		if (_groupView == null)
		{
			_groupView = new EditableView(
				'Group',
				new GroupDisplayView(authorizationViewModel.groupRoleList, groupViewModel),
				new GroupEditView(groupViewModel),
				new GroupDeleteView(authorizationViewModel.groupList, groupViewModel));
		}
		else
		{
			(_groupView.displayView as GroupDisplayView).viewModel = groupViewModel;
			(_groupView.editView as GroupEditView).viewModel = groupViewModel;
			(_groupView.deleteView as GroupDeleteView).viewModel = groupViewModel;
		}

		_groupView.displayIn(container);
	}

	EditableView _roleView;

	displayRole(
		AuthorizationViewModel authorizationViewModel, 
		RoleViewModel roleViewModel, 
		Element container)
	{
		if (_roleView == null)
		{
			_roleView = new EditableView(
				'Role',
				new RoleDisplayView(authorizationViewModel, roleViewModel),
				new RoleEditView(roleViewModel),
				new RoleDeleteView(authorizationViewModel.roleList, roleViewModel));
		}
		else
		{
			(_roleView.displayView as RoleDisplayView).viewModel = roleViewModel;
			(_roleView.editView as RoleEditView).viewModel = roleViewModel;
			(_roleView.deleteView as RoleDeleteView).viewModel = roleViewModel;
		}

		_roleView.displayIn(container);
	}

	EditableView _permissionView;

	displayPermission(
		AuthorizationViewModel authorizationViewModel, 
		PermissionViewModel permissionViewModel, 
		Element container)
	{
		if (_permissionView == null)
		{
			_permissionView = new EditableView(
				'Permission',
				new PermissionDisplayView(authorizationViewModel.rolePermissionList, permissionViewModel),
				new PermissionEditView(permissionViewModel),
				new PermissionDeleteView(authorizationViewModel.permissionList, permissionViewModel));
		}
		else
		{
			(_permissionView.displayView as PermissionDisplayView).viewModel = permissionViewModel;
			(_permissionView.editView as PermissionEditView).viewModel = permissionViewModel;
			(_permissionView.deleteView as PermissionDeleteView).viewModel = permissionViewModel;
		}

		_permissionView.displayIn(container);
	}


	EditableView _identityView;

	displayIdentity(
		AuthorizationViewModel authorizationViewModel, 
		IdentityViewModel identityViewModel, 
		Element container)
	{
		if (_identityView == null)
		{
			_identityView = new EditableView(
				'Identity',
				new IdentityDisplayView(authorizationViewModel, identityViewModel),
				new IdentityEditView(identityViewModel),
				new IdentityDeleteView(identityViewModel));
		}
		else
		{
			(_identityView.displayView as IdentityDisplayView).viewModel = identityViewModel;
			(_identityView.editView as IdentityEditView).viewModel = identityViewModel;
			(_identityView.deleteView as IdentityDeleteView).viewModel = identityViewModel;
		}

		_identityView.displayIn(container);
	}
}

