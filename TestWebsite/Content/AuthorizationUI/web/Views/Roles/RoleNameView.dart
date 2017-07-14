import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundLabel.dart';

import '../../ViewModels/RoleViewModel.dart';

class RoleNameView extends View
{
	BoundLabel<String> _displayNameBinding;

	RoleNameView([RoleViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['role', 'display-name']), 
			formatMethod: (s) => s + ' ');

		this.viewModel = viewModel;
	}

	RoleViewModel _viewModel;
	RoleViewModel get viewModel => _viewModel;

	void set viewModel(RoleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
		}
	}
}

