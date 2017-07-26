import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Events/AppEvents.dart';

import '../../Models/GroupModel.dart';

import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import 'GroupNameView.dart';

class GroupDropdownSelectView extends View
{
	BoundSelect<GroupModel, GroupViewModel, GroupNameView> _groupsBinding;

	GroupDropdownSelectView([this._viewModel, this.selectedGroup])
	{
		_groupsBinding = new BoundSelect<GroupModel, GroupViewModel, GroupNameView>(
			(vm) => new GroupNameView(vm), 
			addDropdownList(),
			(vm) => selectedGroup = vm,
			staticListItems: [new View()]);

		this.viewModel = viewModel;
	}

	GroupListViewModel _viewModel;
	GroupListViewModel get viewModel => _viewModel;

	GroupViewModel selectedGroup;

	void set viewModel(GroupListViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_groupsBinding.binding = null;
		}
		else
		{
			_groupsBinding.binding = value.groups;
		}
	}
}