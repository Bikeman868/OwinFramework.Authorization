import '../../MVVM/Mvvm.dart';
import '../../ViewModels/PermissionViewModel.dart';
import '../../Views/Base/EditView.dart';
import '../../Views/Permissions/PermissionEditFormView.dart';

class PermissionEditView extends EditView
{
	BoundTextInput<String> _displayNameBinding;
	BoundTextArea<String> _descriptionBinding;
	BoundTextInput<String> _codeNameBinding;
	BoundTextInput<String> _resourceBinding;

	PermissionEditView([PermissionViewModel viewModel])
	{
		var formView = merge(new PermissionEditFormView()) as PermissionEditFormView;

		_displayNameBinding = new BoundTextInput<String>(formView.displayName);
		_descriptionBinding = new BoundTextArea<String>(formView.description);
		_codeNameBinding = new BoundTextInput<String>(formView.codeName);
		_resourceBinding = new BoundTextInput<String>(formView.resource);

		this.viewModel = viewModel;
	}

	PermissionViewModel _viewModel;
	PermissionViewModel get viewModel => _viewModel;

	void set viewModel(PermissionViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
			_codeNameBinding.binding = null;
			_resourceBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
			_codeNameBinding.binding = value.codeName;
			_resourceBinding.binding = value.resource;
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