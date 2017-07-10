import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/Enums.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/PermissionModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Permissions/PermissionNameView.dart';
import '../../Views/Permissions/EditPermissionFormView.dart';

class PermissionListNewView extends EditView
{
	EditPermissionFormView _formView;

	PermissionListNewView([PermissionListViewModel viewModel])
	{
		_formView = new EditPermissionFormView();
		merge(_formView);

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
		_formView.permissionModel = new PermissionModel(null);
		_formView.displayName.focus();
	}

	void saveEdits(void onSuccess())
	{
		var permission = _formView.permissionModel;

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