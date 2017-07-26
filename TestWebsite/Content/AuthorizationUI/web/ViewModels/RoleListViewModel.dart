import 'dart:async';
import 'dart:html';

import '../MVVM/Mvvm.dart';

import '../ViewModels/RoleViewModel.dart';

import '../Models/RoleModel.dart';

import '../Server.dart';

class RoleListViewModel extends ViewModel
{
    ModelList<RoleModel, RoleViewModel> roles;

	RoleListViewModel([List<RoleModel> roleModels]): super(false)
	{
		roles = new ModelList<RoleModel, RoleViewModel>(
			(Map json) => new RoleModel(null)
				..codeName = '[unique_code_name]'
				..displayName = '[display_name]'
				..description = '[description]',
			(RoleModel m) => new RoleViewModel(m));

		if (roleModels == null)
			reload();
		else
			models = roleModels;
	}

	dispose()
	{
		models = null;
	}

	List<RoleModel> get models
	{
		return roles.models;
	}

	void set models(List<RoleModel> value)
	{
		roles.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [roles];
	}

	void reload()
	{
		Server.getRoleList()
			.then((List<RoleModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	String toString() => 'role list';
}

