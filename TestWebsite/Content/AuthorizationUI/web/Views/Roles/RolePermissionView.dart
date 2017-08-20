import '../../MVVM/Mvvm.dart';
import '../../ViewModels/RolePermissionViewModel.dart';

class RolePermissionView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	RolePermissionView([RolePermissionViewModel viewModel])
	{
		var tableRow = addDiv(className: 'tr');

		_displayNameBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'display-name', 'role'], parent: tableRow));

		_descriptionBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'description', 'role'], parent: tableRow));

		this.viewModel = viewModel;
	}

	RolePermissionViewModel _viewModel;
	RolePermissionViewModel get viewModel => _viewModel;

	void set viewModel(RolePermissionViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
			_descriptionBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.permissionDisplayName;
			_descriptionBinding.binding = value.permissionDescription;
		}
	}
}

