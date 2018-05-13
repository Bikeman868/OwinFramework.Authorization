import '../../MVVM/Mvvm.dart';
import '../../ViewModels/RoleViewModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Roles/RoleEditFormView.dart';
import '../../Views/Roles/AssignRolePermissionsView.dart';

class RoleEditView extends EditView
{
	BoundTextInput<String> _displayNameBinding;
	BoundTextArea<String> _descriptionBinding;
	BoundTextInput<String> _codeNameBinding;

    AuthorizationViewModel _authorizationViewModel;
    AssignRolePermissionsView _selectRolePermissions;

	RoleEditView(this._authorizationViewModel, [RoleViewModel roleViewModel])
	{
		// This form is shared between the New and Edit pages
		var formView = merge(new RoleEditFormView()) as RoleEditFormView;

        // This view allows the user to add and remove permissions from the role
        _selectRolePermissions = merge(new AssignRolePermissionsView(roleViewModel)) as AssignRolePermissionsView;

		// Bind the merged formView view with the view model
		_displayNameBinding = new BoundTextInput<String>(formView.displayName);
		_descriptionBinding = new BoundTextArea<String>(formView.description);
		_codeNameBinding = new BoundTextInput<String>(formView.codeName);

		this.viewModel = roleViewModel;
	}

	RoleViewModel _viewModel;
	RoleViewModel get viewModel => _viewModel;

	void set viewModel(RoleViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
			_codeNameBinding.binding = null;
            _selectRolePermissions.viewModel = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;
            _selectRolePermissions.viewModel = value;
		}
	}

	void saveEdits(void onSuccess())
	{
		_viewModel
			.save()
			.then((SaveResult result)
			{
				if (result == SaveResult.saved)
					onSuccess();
			});
	}

	void cancelEdits(void onSuccess())
	{
		_viewModel.reload();
		onSuccess();
	}
}