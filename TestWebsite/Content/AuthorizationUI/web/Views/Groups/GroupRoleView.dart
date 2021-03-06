﻿import '../../MVVM/Mvvm.dart';
import '../../ViewModels/GroupRoleViewModel.dart';

class GroupRoleView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	GroupRoleView([GroupRoleViewModel viewModel])
	{
		var tableRow = addDiv(className: 'tr');

		_displayNameBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'display-name', 'role'], parent: tableRow));

		_descriptionBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'description', 'role'], parent: tableRow));

		this.viewModel = viewModel;
	}

	GroupRoleViewModel _viewModel;
	GroupRoleViewModel get viewModel => _viewModel;

	void set viewModel(GroupRoleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.roleDisplayName;
			_descriptionBinding.binding = value.roleDescription;
		}
	}
}

