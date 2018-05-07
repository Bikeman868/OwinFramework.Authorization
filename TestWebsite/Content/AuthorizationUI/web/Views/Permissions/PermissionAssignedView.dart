import 'dart:html';
import '../../MVVM/Mvvm.dart';
import '../../ViewModels/PermissionViewModel.dart';

class PermissionAssignedView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
  ViewModelMethod<PermissionViewModel> _onRemove;

	PermissionAssignedView(
    this._onRemove,
		[
			PermissionViewModel viewModel
		])
	{
    var listElement = addDiv(className: 'action-list-element');

    var actionsDiv = addDiv(parent: listElement, className: 'actions');
    addButton('Remove', _removeButtonClick, parent: actionsDiv);

    var detailsDiv = addDiv(parent: listElement, className: 'details');
		_displayNameBinding = new BoundLabel<String>(addSpan(parent: detailsDiv, className: 'data-field'));
		_descriptionBinding = new BoundLabel<String>(addDiv(parent: detailsDiv));
    
		this.viewModel = viewModel;
	}

	PermissionViewModel _viewModel;
	PermissionViewModel get viewModel => _viewModel;

  void _removeButtonClick(Event event)
  {
    if (_viewModel != null)
      _onRemove(_viewModel);
  }

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

	reload()
	{
		if (_viewModel != null)
			_viewModel.reload();
	}

}