import 'dart:async';
import 'dart:html';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';
import '../MVVM/ModelList.dart';

import '../ViewModels/PermissionViewModel.dart';

import '../Models/PermissionModel.dart';

import '../Server.dart';

class PermissionListViewModel extends ViewModel
{
    ModelList<PermissionModel, PermissionViewModel> permissions;

	PermissionListViewModel([List<PermissionModel> permissionModels]): super(false)
	{
		permissions = new ModelList<PermissionModel, PermissionViewModel>(
			(Map json) => new PermissionModel(
				new Map()
					..['codeName']='[unique_code_name]'
					..['displayName']='[display_name]'
					..['description']='[description]'),
			(PermissionModel m) => new PermissionViewModel(m));

		if (permissionModels == null)
			reload();
		else
			models = permissionModels;
	}

	dispose()
	{
		models = null;
	}

	List<PermissionModel> get models
	{
		return permissions.models;
	}

	void set models(List<PermissionModel> value)
	{
		permissions.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [permissions];
	}

	void reload()
	{
		Server.getPermissionList()
			.then((List<PermissionModel> m) => models = m)
			.catchError((Error error) => window.alert(error.toString()));
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		List<PermissionViewModel> viewModels = permissions.viewModels
			.where((PermissionViewModel vm) => vm != null && vm.getState() != ChangeState.deleted)
			.toList();

		viewModels.forEach((PermissionViewModel vm) => vm.removeDeleted());

		List<PermissionModel> permissionModels = permissions.viewModels
			.map((PermissionViewModel vm) => vm.model)
			.toList();

		// PostResponseModel response = await Server.replaceEnvironments(environmentModels);

		// if (response.success)
		// {
			viewModels.forEach((PermissionViewModel vm) => vm.saved());
		//	if (alert) window.alert('Environments saved succesfully');
			return SaveResult.saved;
		//}

		//window.alert('Environments were not saved. ' + response.error);
		//return SaveResult.failed;
	}

	String toString() => 'permission list view model';
}

