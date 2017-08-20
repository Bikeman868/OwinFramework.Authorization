import '../../MVVM/Mvvm.dart';
import '../../ViewModels/RolePermissionViewModel.dart';

class PermissionRoleView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	PermissionRoleView([RolePermissionViewModel viewModel])
	{
		var tableRow = addDiv(className: 'tr');

		_displayNameBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'display-name', 'group'], parent: tableRow));

		_descriptionBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'description', 'group'], parent: tableRow));

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
			_displayNameBinding.binding = value.roleDisplayName;
			_descriptionBinding.binding = value.roleDescription;
		}
	}
}

