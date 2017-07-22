import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';

import '../../Events/AppEvents.dart';

import '../../Models/GroupModel.dart';

import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import 'GroupNameView.dart';

class GroupListSelectView extends View
{
	BoundList<GroupModel, GroupViewModel, GroupNameView> _groupsBinding;

	GroupListSelectView([GroupListViewModel viewModel])
	{
		addBlockText(
			'These are the currently defined groups in this system. Assigning a group to ' +
			'a user will give that user access to functionallity as defined by the roles ' +
			'associated with that group.', 
			className: 'help-note');

		_groupsBinding = new BoundList<GroupModel, GroupViewModel, GroupNameView>(
			(vm) => new GroupNameView(vm), addList(), allowAdd: false, allowRemove: false,
			selectionMethod: (vm) => AppEvents.groupSelected.raise(new GroupSelectedEvent(vm)));

		this.viewModel = viewModel;
	}

	GroupListViewModel _viewModel;
	GroupListViewModel get viewModel => _viewModel;

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