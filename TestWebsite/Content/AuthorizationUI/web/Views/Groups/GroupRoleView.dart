import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/GroupRoleViewModel.dart';

class GroupRoleView extends View
{
	BoundLabel<String> _codeNameBinding;
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	GroupRoleView([GroupRoleViewModel viewModel])
	{
		var tableRow = addDiv(className: 'table-row');

		_codeNameBinding = new BoundLabel<String>(
			addDiv(classNames: ['role', 'code-name', 'table-column'], parent: tableRow));

		_displayNameBinding = new BoundLabel<String>(
			addDiv(classNames: ['role', 'display-name', 'table-column'], parent: tableRow));

		_descriptionBinding = new BoundLabel<String>(
			addDiv(classNames: ['role', 'description', 'table-column'], parent: tableRow));

		this.viewModel = viewModel;
	}

	GroupRoleViewModel _viewModel;
	GroupRoleViewModel get viewModel => _viewModel;

	void set viewModel(GroupRoleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_codeNameBinding.binding = null;
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
		}
		else
		{
			_codeNameBinding.binding = value.roleCodeName;
			_displayNameBinding.binding = value.roleDisplayName;
			_descriptionBinding.binding = value.roleDescription;
		}
	}
}

