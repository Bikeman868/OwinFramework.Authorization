import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/GroupRoleViewModel.dart';

class RoleGroupView extends View
{
	BoundLabel<String> _codeNameBinding;
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	RoleGroupView([GroupRoleViewModel viewModel])
	{
		var div = addDiv();

		_codeNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['group', 'code-name'], parent: div), 
			formatMethod: (s) => s + ' ');

		_displayNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['group', 'display-name'], parent: div), 
			formatMethod: (s) => s + ' ');

		_descriptionBinding = new BoundLabel<String>(
			addSpan(classNames: ['group', 'description'], parent: div));

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
			_codeNameBinding.binding = value.groupCodeName;
			_displayNameBinding.binding = value.groupDisplayName;
			_descriptionBinding.binding = value.groupDescription;
		}
	}
}

