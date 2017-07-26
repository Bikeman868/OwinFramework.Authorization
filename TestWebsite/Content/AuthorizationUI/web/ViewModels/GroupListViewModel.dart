import 'dart:async';
import 'dart:html';

import '../MVVM/Mvvm.dart';

import '../ViewModels/GroupViewModel.dart';

import '../Models/GroupModel.dart';
import '../Models/ApiResponseModel.dart';

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
	
	Future<bool> delete(GroupViewModel groupToDelete, GroupViewModel replacementGroup) async
	{
		if (replacementGroup == null)
		{
			MvvmEvents.alert.raise('You must select a group to reassign the users to');
			return false;
		}

		if (groupToDelete == replacementGroup)
		{
			MvvmEvents.alert.raise('You must choose a different group than the one you are deleting');
			return false;
		}

		try
		{
			ApiResponseModel resp = await Server.deleteGroup(groupToDelete.model.id, replacementGroup.model.id);
			if (resp.isSuccess)
			{
				groups.deleteViewModel(groupToDelete);
				groups.removeDeleted();
				return true;
			}
		}
		catch (e)
		{
			MvvmEvents.alert.raise(e.toString());
			return false;
		}
	}

	String toString() => 'group list';
}

