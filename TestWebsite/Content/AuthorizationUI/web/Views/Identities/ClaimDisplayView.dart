import '../../MVVM/Mvvm.dart';
import '../../ViewModels/ClaimViewModel.dart';

class ClaimDisplayView extends View
{
	BoundLabel<String> _nameBinding;
	BoundLabel<String> _valueBinding;
	BoundLabel<String> _statusBinding;

	ClaimDisplayView([ClaimViewModel viewModel])
	{
		var form = addForm();
		_nameBinding = new BoundLabel<String>(addLabeledField(form, 'Claim'));
		_valueBinding = new BoundLabel<String>(addLabeledField(form, 'Value'));
		_statusBinding = new BoundLabel<String>(addLabeledField(form, 'Status'));

		this.viewModel = viewModel;
	}

	ClaimViewModel _viewModel;
	ClaimViewModel get viewModel => _viewModel;

	void set viewModel(ClaimViewModel viewModel)
	{
		_viewModel = viewModel;
		if (viewModel == null)
		{
			_nameBinding.binding = null;
			_valueBinding.binding = null;
			_statusBinding.binding = null;
		}
		else
		{
			_nameBinding.binding = viewModel.name;
			_valueBinding.binding = viewModel.value;
			_statusBinding.binding = viewModel.statusText;
		}
	}

	reload()
	{
		if (_viewModel != null)
			_viewModel.reload();
	}

}