import '../../MVVM/Mvvm.dart';
import '../../ViewModels/PermissionViewModel.dart';

class PermissionTableRowView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;

	PermissionTableRowView([PermissionViewModel viewModel])
	{
		var tableRow = addDiv(className: 'tr');

		_displayNameBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'display-name', 'permission'], parent: tableRow));

		_descriptionBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'description', 'permission'], parent: tableRow));

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
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
			_descriptionBinding.binding = value.description;
		}
	}
}

