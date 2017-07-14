import 'dart:html';
import 'dart:async';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';
import '../MVVM/ModelList.dart';
import '../MVVM/StringBinding.dart';
import '../MVVM/Events.dart';

import '../Server.dart';
import '../Events/AppEvents.dart';

import '../ViewModels/GroupListViewModel.dart';
import '../ViewModels/RoleListViewModel.dart';

import '../Models/ApiResponseModel.dart';
import '../Models/ParentChildModel.dart';

class GroupRoleViewModel extends ViewModel
{
    StringBinding groupCodeName;
    StringBinding groupDisplayName;
    StringBinding groupDescription;

    StringBinding roleCodeName;
    StringBinding roleDisplayName;
    StringBinding roleDescription;

	GroupListViewModel _groupListViewModel;
	RoleListViewModel _roleListViewModel;

	GroupRoleViewModel(
		this._groupListViewModel,
		this._roleListViewModel,
		[
			ParentChildModel model
		])
	{
		groupCodeName = new StringBinding();
		groupDisplayName = new StringBinding();
		groupDescription = new StringBinding();

		roleCodeName = new StringBinding();
		roleDisplayName = new StringBinding();
		roleDescription = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	ParentChildModel _model;
	ParentChildModel get model => _model;

	void set model(ParentChildModel value)
	{
		_model = value;

		if (value == null)
		{
			groupCodeName.getter = null;
			groupDisplayName.getter = null;
			groupDescription.getter = null;
			roleCodeName.getter = null;
			roleDisplayName.getter = null;
			roleDescription.getter = null;
		}
		else
		{
			var groupViewModel = _groupListViewModel.groups.viewModels.firstWhere((vm) => vm.id == value.parentId);

			if (groupViewModel == null)
			{
				groupCodeName.getter = null;
				groupDisplayName.getter = null;
				groupDescription.getter = null;
			}
			else
			{
				groupCodeName.getter = () => groupViewModel.codeName.getter();
				groupDisplayName.getter = () => groupViewModel.displayName.getter();
				groupDescription.getter = () => groupViewModel.description.getter();
			}

			var roleViewModel = _roleListViewModel.roles.viewModels.firstWhere((vm) => vm.id == value.childId);

			if (roleViewModel == null)
			{
				roleCodeName.getter = null;
				roleDisplayName.getter = null;
				roleDescription.getter = null;
			}
			else
			{
				roleCodeName.getter = () => roleViewModel.codeName.getter();
				roleDisplayName.getter = () => roleViewModel.displayName.getter();
				roleDescription.getter = () => roleViewModel.description.getter();
			}
		}

		loaded();
	}

	String toString() => _model.toString();
}

