import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../Server.dart';
import '../Models/ConfigurationModel.dart';
import '../ViewModels/GroupListViewModel.dart';
import '../ViewModels/RoleListViewModel.dart';
import '../ViewModels/PermissionListViewModel.dart';
import '../ViewModels/GroupRoleListViewModel.dart';
import '../ViewModels/RolePermissionListViewModel.dart';

class AuthorizationViewModel extends ViewModel
{
	ConfigurationModel _configuration;
	Future<ConfigurationModel> get configuration async
	{
		if (_configuration == null)
			_configuration = await Server.getConfiguration();

		return _configuration;
	}

	PermissionListViewModel _permissionList;
	PermissionListViewModel get permissionList
	{
		if (_permissionList == null)
			_permissionList = new PermissionListViewModel(this);

		return _permissionList;
	}

	RoleListViewModel _roleList;
	RoleListViewModel get roleList
	{
		if (_roleList == null)
			_roleList = new RoleListViewModel(this);
	
		return _roleList;
	}
	
	GroupListViewModel _groupList;
	GroupListViewModel get groupList
	{
		if (_groupList == null)
			_groupList = new GroupListViewModel(this);
	
		return _groupList;
	}

	GroupRoleListViewModel _groupRoleList;
	GroupRoleListViewModel get groupRoleList
	{
		if (_groupRoleList == null)
			_groupRoleList = new GroupRoleListViewModel(this);

		return _groupRoleList;
	}

	RolePermissionListViewModel _rolePermissionList;
	RolePermissionListViewModel get rolePermissionList
	{
		if (_rolePermissionList == null)
			_rolePermissionList = new RolePermissionListViewModel(this);

		return _rolePermissionList;
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
	 
	 	if (_rolePermissionList != null)
	 		_rolePermissionList.dispose();
	}

	List<ViewModel> getChildViewModels()
	{
		return [_permissionList, _roleList, _groupList, _groupRoleList, _rolePermissionList];
	}

	String toString() => 'authorization data';
}

