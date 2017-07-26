import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/PermissionModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Permissions/PermissionNameView.dart';
import '../../Views/Permissions/PermissionEditFormView.dart';

class PermissionListNewView extends EditView
{
	PermissionEditFormView _formView;

	PermissionListNewView([PermissionListViewModel viewModel])
	{
		_formView = merge(new PermissionEditFormView()) as PermissionEditFormView;

		this.viewModel = viewModel;
	}

	PermissionListViewModel _viewModel;
	PermissionListViewModel get viewModel => _viewModel;

	void set viewModel(PermissionListViewModel value)
	{
		_viewModel = value;
	}

	void clearForm()
	{
		_formView.codeName.value = '';
		_formView.displayName.value = '';
		_formView.description.value = '';
		_formView.resource.value = '';

		_formView.displayName.focus();
	}

	void saveEdits(void onSuccess())
	{
		var permission = new PermissionModel(null)
			..codeName = _formView.codeName.value
			..displayName = _formView.displayName.value
			..description = _formView.description.value
			..resource = _formView.resource.value;

		Server.validatePermission(permission)
			.then((ApiResponseModel r)
			{
				if (r.isSuccess)
				{
					var vm = _viewModel.permissions.addModel(permission);
					AppEvents.permissionSelected.raise(new PermissionSelectedEvent(vm));

					vm.save()
						.then((SaveResult saveResult) => onSuccess())
						.catchError((Error error) => _formView.fieldValidationError.innerHtml = error.toString());
				}
				else
				{
					_formView.fieldValidationError.innerHtml = r.error;
				}
			})
			.catchError((Error error) => _formView.fieldValidationError.innerHtml = error.toString());
	}
}