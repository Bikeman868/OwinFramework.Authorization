import 'dart:html';
import '../../MVVM/Mvvm.dart';
import '../../ViewModels/RoleViewModel.dart';

class RoleUnassignedView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _descriptionBinding;
  ViewModelMethod<RoleViewModel> _onAdd;

	RoleUnassignedView(
    this._onAdd,
		[
			RoleViewModel viewModel
		])
	{
    var listElement = addDiv(className: 'action-list-element');

    var actionsDiv = addDiv(parent: listElement, className: 'actions');
    addButton('Add', _addButtonClick, parent: actionsDiv);

    var detailsDiv = addDiv(parent: listElement, className: 'details');
		_displayNameBinding = new BoundLabel<String>(addSpan(parent: detailsDiv, className: 'data-field'));
		_descriptionBinding = new BoundLabel<String>(addDiv(parent: detailsDiv));
    
		this.viewModel = viewModel;
	}

	RoleViewModel _viewModel;
	RoleViewModel get viewModel => _viewModel;

  void _addButtonClick(Event event)
  {
    if (_viewModel != null)
      _onAdd(_viewModel);
  }

	void set viewModel(RoleViewModel value)
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