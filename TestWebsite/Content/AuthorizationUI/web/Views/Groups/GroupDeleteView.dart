﻿import '../../MVVM/Mvvm.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/GroupListViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Groups/GroupDropdownSelectView.dart';

class GroupDeleteView extends EditView
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
	GroupDropdownSelectView _groupSelector;

	GroupDeleteView(this._groupListViewModel, [GroupViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addDiv(),
			formatMethod: (s) => 
				'<p>If there are any users currently assigned to the "' + s + '" group then ' +
				'they need to be assigned to a different group when the "' + s + '" group ' + 
				'is deleted.</p>');

		var descriptionDiv = addDiv();
		addInlineText('This group is for ', parent: descriptionDiv);
		_descriptionBinding = new BoundLabel<String>(
			addSpan(parent: descriptionDiv),
			formatMethod: (s) => s[0].toLowerCase() + s.substring(1));

		var selectDiv = addDiv();
		addInlineText('Reassign these users to ', parent: selectDiv);
		_groupSelector = new GroupDropdownSelectView(_groupListViewModel);
		_groupSelector.addTo(selectDiv);

		addBlockText(
			'<p>Note that when you delete this group, all these users will have all of their ' +
			'permissions changed to the permissions assigned to their new group.</p>',
			className: 'help-note');

		this.viewModel = viewModel;
	}

	GroupViewModel _viewModel;
	GroupViewModel get viewModel => _viewModel;

	GroupListViewModel _groupListViewModel;

	void set viewModel(GroupViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
		}
	}

	void deleteRecord(void onSuccess())
	{
		_groupListViewModel.delete(_viewModel, _groupSelector.selectedGroup)
			.then((bool success)
			{
				if (success) onSuccess();
			});
	}
}