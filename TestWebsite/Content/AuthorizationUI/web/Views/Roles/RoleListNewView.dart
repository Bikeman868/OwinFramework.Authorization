import 'dart:html';

import '../../MVVM/Mvvm.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/RoleModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/RoleListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Roles/RoleNameView.dart';
import '../../Views/Roles/RoleEditFormView.dart';

class RoleListNewView extends EditView
{
	RoleEditFormView _formView;

	RoleListNewView([RoleListViewModel viewModel])
	{
		_formView = merge(new RoleEditFormView()) as RoleEditFormView;

		this.viewModel = viewModel;
	}

	RoleListViewModel _viewModel;
	RoleListViewModel get viewModel => _viewModel;

	void set viewModel(RoleListViewModel value)
	{
		_viewModel = value;
	}

	void clearForm()
	{
		_formView.codeName.value = '';
		_formView.displayName.value = '';
		_formView.description.value = '';

		_formView.displayName.focus();
	}

	void saveEdits(void onSuccess())
	{
		var role = new RoleModel(null)
			..codeName = _formView.codeName.value
			..displayName = _formView.displayName.value
			..description = _formView.description.value;

		Server.validateRole(role)
			.then((ApiResponseModel r)
			{
				if (r.isSuccess)
				{
					var vm = _viewModel.roles.addModel(role);
					AppEvents.roleSelected.raise(new RoleSelectedEvent(vm));

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