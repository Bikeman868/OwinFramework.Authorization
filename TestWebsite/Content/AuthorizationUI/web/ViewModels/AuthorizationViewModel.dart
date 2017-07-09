import 'dart:async';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';

import '../ViewModels/PermissionListViewModel.dart';

class AuthorizationViewModel extends ViewModel
{
	PermissionListViewModel _permissionList;
	PermissionListViewModel get permissionList
	{
		if (_permissionList == null)
			_permissionList = new PermissionListViewModel();

		return _permissionList;
	}


	// RoleListViewModel _roleList;
	// RoleListViewModel get roleList
	// {
	// 	if (_roleList == null)
	// 		_roleList = new RoleListViewModel();
	// 
	// 	return _roleList;
	// }
	// 
	// GroupListViewModel _groupList;
	// GroupListViewModel get groupList
	// {
	// 	if (_groupList == null)
	// 		_groupList = new GroupListViewModel();
	// 
	// 	return _groupList;
	// }

	dispose()
	{
		if (_permissionList != null)
			_permissionList.dispose();

	//	if (_roleList != null)
	//		_roleList.dispose();
	//
	//	if (_groupList != null)
	//		_groupList.dispose();
	}

	List<ViewModel> getChildViewModels()
	{
		// return [_permissionList, _roleList, _groupList];
		return [_permissionList];
	}

	String toString() => 'authorization data';
}

