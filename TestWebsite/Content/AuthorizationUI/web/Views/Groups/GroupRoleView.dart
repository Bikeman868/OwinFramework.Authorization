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
		var div = addDiv();

		_codeNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['role', 'code-name'], parent: div), 
			formatMethod: (s) => s + ' ');

		_displayNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['role', 'display-name'], parent: div), 
			formatMethod: (s) => s + ' ');

		_descriptionBinding = new BoundLabel<String>(
			addSpan(classNames: ['role', 'description'], parent: div));

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

