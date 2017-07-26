import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../ViewModels/GroupRoleViewModel.dart';

class RoleGroupView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	RoleGroupView([GroupRoleViewModel viewModel])
	{
		var tableRow = addDiv(className: 'tr');

		_displayNameBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'display-name', 'group'], parent: tableRow));

		_descriptionBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'description', 'group'], parent: tableRow));

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
			_displayNameBinding.binding = value.groupDisplayName;
			_descriptionBinding.binding = value.groupDescription;
		}
	}
}

