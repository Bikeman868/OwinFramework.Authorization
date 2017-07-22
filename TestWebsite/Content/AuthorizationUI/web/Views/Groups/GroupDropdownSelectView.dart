import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundRepeater.dart';

import '../../Events/AppEvents.dart';

import '../../Models/GroupModel.dart';

import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import 'GroupOptionView.dart';

class GroupDropdownSelectView extends View
{
	BoundRepeater<GroupModel, GroupViewModel, GroupOptionView> _groupsBinding;

	SelectElement _dropdownList;

	GroupDropdownSelectView([this._viewModel, this.selectedGroup])
	{
		_dropdownList = addDropdownList();
		_dropdownList.onChange.listen(_selectionChanged);

		_groupsBinding = new BoundRepeater<GroupModel, GroupViewModel, GroupOptionView>(
			(vm) => new GroupOptionView(vm), _dropdownList);

		this.viewModel = viewModel;
	}

	GroupListViewModel _viewModel;
	GroupListViewModel get viewModel => _viewModel;

	GroupViewModel selectedGroup;

	void _selectionChanged(Event e)
	{

	}

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