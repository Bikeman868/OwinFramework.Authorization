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
	GroupListViewModel _groupListViewModel;
	RoleListViewModel _roleListViewModel;

	GroupRoleViewModel(
		this._groupListViewModel,
		this._roleListViewModel,
		[ParentChildModel model])
	{
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
		loaded();
	}

	String toString() => _model.toString();
}

