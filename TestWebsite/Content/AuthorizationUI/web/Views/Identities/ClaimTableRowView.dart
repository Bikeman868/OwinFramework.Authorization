import '../../MVVM/Mvvm.dart';
import '../../ViewModels/ClaimViewModel.dart';

class ClaimTableRowView extends View
{
	BoundLabel<String> _nameBinding;
	BoundLabel<String> _valueBinding;
	BoundLabel<String> _statusBinding;

	ClaimTableRowView([ClaimViewModel viewModel])
	{
		var tableRow = addDiv(className: 'tr');

		_nameBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'display-name', 'claim'], parent: tableRow));

		_valueBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'claim-value', 'claim'], parent: tableRow));

		_statusBinding = new BoundLabel<String>(
			addDiv(classNames: ['td', 'claim-status', 'claim'], parent: tableRow));

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
}

