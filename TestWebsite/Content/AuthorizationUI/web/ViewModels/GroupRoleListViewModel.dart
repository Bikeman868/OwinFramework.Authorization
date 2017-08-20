import '../MVVM/Mvvm.dart';
import '../ViewModels/GroupRoleViewModel.dart';
import '../ViewModels/GroupListViewModel.dart';
import '../ViewModels/RoleListViewModel.dart';
import '../Models/ParentChildModel.dart';
import '../Server.dart';

class GroupRoleListViewModel extends ViewModel
{
    ModelList<ParentChildModel, GroupRoleViewModel> groupRoles;

	GroupListViewModel _groupListViewModel;
	RoleListViewModel _roleListViewModel;

	GroupRoleListViewModel(
		this._groupListViewModel,
		this._roleListViewModel,
		[
			List<ParentChildModel> groupRoleModels
		]): super(false)
	{
		groupRoles = new ModelList<ParentChildModel, GroupRoleViewModel>(
			(Map json) => new ParentChildModel(json),
			(ParentChildModel m) => new GroupRoleViewModel(_groupListViewModel, _roleListViewModel, m));

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

	String toString() => 'group roles';
}

