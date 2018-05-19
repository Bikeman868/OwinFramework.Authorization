import '../../MVVM/Mvvm.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Groups/GroupEditFormView.dart';
import '../../Views/Groups/AssignGroupRolesView.dart';

class GroupEditView extends EditView
{
	BoundTextInput<String> _displayNameBinding;
	BoundTextArea<String> _descriptionBinding;
	BoundTextInput<String> _codeNameBinding;

  AuthorizationViewModel _authorizationViewModel;
  AssignGroupRolesView _selectGroupRoles;

	GroupEditView([GroupViewModel groupViewModel])
	{
		// This form is shared between the New and Edit pages
		var formView = merge(new GroupEditFormView()) as GroupEditFormView;

    // This view allows the user to add and remove permissions from the role
    _selectGroupRoles = merge(new AssignGroupRolesView(groupViewModel)) as AssignGroupRolesView;

		// Bind the merged formView view with the view model
		_displayNameBinding = new BoundTextInput<String>(formView.displayName);
		_descriptionBinding = new BoundTextArea<String>(formView.description);
		_codeNameBinding = new BoundTextInput<String>(formView.codeName);

		this.viewModel = groupViewModel;
	}

	GroupViewModel _viewModel;
	GroupViewModel get viewModel => _viewModel;

	void set viewModel(GroupViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
			_codeNameBinding.binding = null;
      _selectGroupRoles.viewModel = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;
      _selectGroupRoles.viewModel = value;
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