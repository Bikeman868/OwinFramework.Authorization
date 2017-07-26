import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../ViewModels/GroupViewModel.dart';

class GroupNameView extends View
{
	BoundLabel<String> _displayNameBinding;

	GroupNameView([GroupViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['group', 'codeName']), 
			formatMethod: (s) => s + ' ');

		this.viewModel = viewModel;
	}

	GroupViewModel _viewModel;
	GroupViewModel get viewModel => _viewModel;

	void set viewModel(GroupViewModel value)
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

