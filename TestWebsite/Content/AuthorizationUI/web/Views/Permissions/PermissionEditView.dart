import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/Enums.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/PermissionModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/PermissionViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Permissions/EditPermissionFormView.dart';

class PermissionEditView extends EditView
{
	EditPermissionFormView _formView;

	PermissionEditView([PermissionViewModel viewModel])
	{
		_formView = new EditPermissionFormView();
		merge(_formView);

		this.viewModel = viewModel;
	}

	PermissionViewModel _viewModel;
	PermissionViewModel get viewModel => _viewModel;

	void set viewModel(PermissionViewModel value)
	{
		_viewModel = value;
	}

	void saveEdits(void onSuccess())
	{
		_viewModel.save();
		onSuccess();
	}

}