import 'dart:async';
import '../MVVM/Mvvm.dart';
import '../ViewModels/GroupRoleViewModel.dart';
import '../ViewModels/AuthorizationViewModel.dart';
import '../Models/ParentChildModel.dart';
import '../Server.dart';

class GroupRoleListViewModel extends ViewModel
{
	ModelList<ParentChildModel, GroupRoleViewModel> groupRoles;

	AuthorizationViewModel _authorizationViewModel;

	GroupRoleListViewModel(
		this._authorizationViewModel,
		[
			List<ParentChildModel> groupRoleModels
		]): super(true)
	{
		groupRoles = new ModelList<ParentChildModel, GroupRoleViewModel>(
			(Map json) => new ParentChildModel(json),
			(ParentChildModel m) => new GroupRoleViewModel(_authorizationViewModel, m));

		if (groupRoleModels == null)
			reload();
		else
			models = groupRoleModels;
	}

	dispose()
	{
		models = null;
	}

	List<ParentChildModel> get models
	{
		return groupRoles.models;
	}

	void set models(List<ParentChildModel> value)
	{
		groupRoles.models = value;
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [groupRoles];
	}

	void reload()
	{
		Server.getGroupRoles()
			.then((List<ParentChildModel> m) => models = m)
			.catchError((Error error) => MvvmEvents.alert.raise(error.toString()));
	}

  Future<SaveResult> saveChanges(ChangeState state, bool alert) async
  {
    removeDeleted();
    var response = await Server.updateGroupRoles(models);
    return response.isSuccess ? SaveResult.saved : SaveResult.failed;
  }

	String toString() => 'group roles';
}

