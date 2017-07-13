import 'dart:async';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';

import '../ViewModels/GroupListViewModel.dart';
import '../ViewModels/RoleListViewModel.dart';
import '../ViewModels/PermissionListViewModel.dart';
import '../ViewModels/GroupRoleListViewModel.dart';

class AuthorizationViewModel extends ViewModel
{
	PermissionListViewModel _permissionList;
	PermissionListViewModel get permissionList
	{
		if (_permissionList == null)
			_permissionList = new PermissionListViewModel();

		return _permissionList;
	}

	RoleListViewModel _roleList;
	RoleListViewModel get roleList
	{
		if (_roleList == null)
			_roleList = new RoleListViewModel();
	
		return _roleList;
	}
	
	GroupListViewModel _groupList;
	GroupListViewModel get groupList
	{
		if (_groupList == null)
			_groupList = new GroupListViewModel();
	
		return _groupList;
	}

	GroupRoleListViewModel _groupRoleList;
	GroupRoleListViewModel get groupRoleList
	{
		if (_groupRoleList == null)
			_groupRoleList = new GroupRoleListViewModel(groupList, roleList);

		return _groupRoleList;
	}

	dispose()
	{
		if (_permissionList != null)
			_permissionList.dispose();

	 	if (_roleList != null)
	 		_roleList.dispose();
	 
	 	if (_groupList != null)
	 		_groupList.dispose();
	 
	 	if (_groupRoleList != null)
	 		_groupRoleList.dispose();
	}

	List<ViewModel> getChildViewModels()
	{
		return [_permissionList, _roleList, _groupList, _groupRoleList];
	}

	String toString() => 'authorization data';
}

