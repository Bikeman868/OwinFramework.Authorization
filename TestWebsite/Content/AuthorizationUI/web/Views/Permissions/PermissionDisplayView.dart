import 'dart:html';

import '../../MVVM/View.dart';

import '../../ViewModels/PermissionViewModel.dart';

class PermissionDisplayView extends View
{
	PermissionDisplayView([PermissionViewModel viewModel])
	{
		this.viewModel = viewModel;
	}

	PermissionViewModel _viewModel;
	PermissionViewModel get viewModel => _viewModel;

	void set viewModel(PermissionViewModel value)
	{
		_viewModel = value;
	}

}