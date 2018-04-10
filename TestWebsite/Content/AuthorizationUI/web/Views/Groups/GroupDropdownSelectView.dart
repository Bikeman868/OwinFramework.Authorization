import 'dart:async';
import '../../MVVM/Mvvm.dart';
import '../../Models/GroupModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import 'GroupNameView.dart';

// This is a drop down list control that allows the user to choose a group

class GroupDropdownSelectView extends View
{
	BoundSelect<GroupModel, GroupViewModel, GroupNameView> _groupSelector;

	GroupDropdownSelectView(
		[
			GroupListViewModel groupList,
			IntBinding groupIdBinding
		])
	{
		_groupSelector = new BoundSelect<GroupModel, GroupViewModel, GroupNameView>(
			(vm) => new GroupNameView(vm), 
			addDropdownList(),
			(vm) => selectedGroup = vm,
			staticListItems: [new View()]);

		this.groupList = groupList;
		this.groupIdBinding = groupIdBinding;
	}

	ViewModelMethod<GroupViewModel> onGroupChanged;

	GroupListViewModel _groupList;
	GroupListViewModel get groupList => _groupList;

	void set groupList(GroupListViewModel value)
	{
		_groupList = value;
		
		if (value == null)
		{
			_groupSelector.listBbinding = null;
		}
		else
		{
			_groupSelector.listBbinding = value.groups;
		}
	}

	IntBinding _groupIdBinding;
	IntBinding get groupIdBinding => _groupIdBinding;
	StreamSubscription<String> _groupIdSubscription;

	void set groupIdBinding(IntBinding intBinding)
	{
		if (_groupIdSubscription != null)
		{
			_groupIdSubscription.cancel();
			_groupIdSubscription = null;
		}

		_groupIdBinding = intBinding;

		// if (intBinding != null)
		// {
		// 	_groupIdSubscription = intBinding.onChange.listen((s)
		// 	{
		// 		var index = int.parse(s);
		// 		_groupSelector.selectedIndex = index;
		// 	});
		// }
	}

	GroupViewModel _selectedGroup;
	GroupViewModel get selectedGroup => _selectedGroup;
	
	void set selectedGroup(GroupViewModel groupViewModel)
	{
		_selectedGroup = groupViewModel;

		if (_groupIdBinding != null && _groupIdBinding.setter != null)
		{
			int groupId = 0;
			if (groupViewModel != null)
				groupId = groupViewModel.id;

			_groupIdBinding.setPropertyValue(groupId);
		}

		if (onGroupChanged != null)
			onGroupChanged(groupViewModel);
	}
}