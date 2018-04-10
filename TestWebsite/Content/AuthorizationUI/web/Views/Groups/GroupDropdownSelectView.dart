import 'dart:async';
import '../../MVVM/Mvvm.dart';
import '../../Models/GroupModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';

import 'GroupNameView.dart';

// This is a drop down list control that allows the user to choose a group
// Can be bound to a ViewModelBinding<GroupViewModel, int> to maintain sync

class GroupDropdownSelectView extends View
{
	BoundSelect<GroupModel, GroupViewModel, GroupNameView> _groupSelector;

	GroupDropdownSelectView(
		[
			GroupListViewModel groupList,
			ViewModelBinding<GroupViewModel, int> groupBinding
		])
	{
		_groupSelector = new BoundSelect<GroupModel, GroupViewModel, GroupNameView>(
			(vm) => new GroupNameView(vm), 
			addDropdownList(),
			(vm) 
			{
				_selectedGroup = vm;

				if (_groupBinding != null)
					_groupBinding.setViewModel(vm);

				if (onGroupChanged != null)
					onGroupChanged(vm);				
			},
			staticListItems: [new View()]);

		this.groupList = groupList;
		this.groupBinding = groupBinding;
	}

	ViewModelMethod<GroupViewModel> onGroupChanged;

	GroupListViewModel _groupList;
	GroupListViewModel get groupList => _groupList;

	void set groupList(GroupListViewModel value)
	{
		_groupList = value;
		
		if (value == null)
		{
			_groupSelector.listBinding = null;
		}
		else
		{
			_groupSelector.listBinding = value.groups;
		}
	}

	// Set groupBinding to keep the selected value in the drop-down
	// list synchronized with the group property of a view model
	ViewModelBinding<GroupViewModel, int> _groupBinding;
	ViewModelBinding<GroupViewModel, int> get groupBinding => _groupBinding;
	StreamSubscription<GroupViewModel> _groupSubscription;
	void set groupBinding(ViewModelBinding<GroupViewModel, int> viewModelBinding)
	{
		if (_groupSubscription != null)
		{
			_groupSubscription.cancel();
			_groupSubscription = null;
		}

		_groupBinding = viewModelBinding;

		if (viewModelBinding == null)
		{
			selectedGroup = null;
		}
		else
		{
			_groupSubscription = viewModelBinding.onChange.listen((vm) => selectedGroup = vm);
			selectedGroup = viewModelBinding.getViewModel();
		}
	}

	// The selectedGroup property is for the use case where there is
	// no binding to a group view model, instead you allow the user to choose
	// a group then read the selectedGroup property to see which one 
	// they selected. You can also set the selectedGroup property to
	// change which group is currently selected in the drop-down list
	GroupViewModel _selectedGroup;
	GroupViewModel get selectedGroup => _selectedGroup;
	void set selectedGroup(GroupViewModel groupViewModel)
	{
		_selectedGroup = groupViewModel;
		_groupSelector.selectedViewModel = groupViewModel;

		if (onGroupChanged != null)
			onGroupChanged(groupViewModel);
	}
}