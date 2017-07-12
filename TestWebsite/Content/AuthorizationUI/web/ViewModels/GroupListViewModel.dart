import 'dart:async';
import 'dart:html';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';
import '../MVVM/Events.dart';
import '../MVVM/ModelList.dart';

import '../ViewModels/GroupViewModel.dart';

import '../Models/GroupModel.dart';

import '../Server.dart';

class GroupListViewModel extends ViewModel
{
    ModelList<GroupModel, GroupViewModel> groups;

	GroupListViewModel([List<GroupModel> groupModels]): super(false)
	{
		groups = new ModelList<GroupModel, GroupViewModel>(
			(Map json) => new GroupModel(null)
				..codeName = '[unique_code_name]'
				..displayName = '[display_name]'
				..description = '[description]',
			(GroupModel m) => new GroupViewModel(m));

		if (groupModels == null)
			reload();
		else
			models = groupModels;
	}

	dispose()
	{
		models = null;
	}

	List<GroupModel> get models
	{
		return groups.models;
	}

	void set models(List<GroupModel> value)
	{
		groups.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [groups];
	}

	void reload()
	{
		Server.getGroupList()
			.then((List<GroupModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

	String toString() => 'group list';
}

