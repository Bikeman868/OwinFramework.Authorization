import '../../MVVM/Mvvm.dart';
import '../../ViewModels/IdentityViewModel.dart';

class IdentityNameView extends View
{
	BoundLabel<String> _displayNameBinding;

	IdentityNameView([IdentityViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addSpan(classNames: ['identity', 'identity-name']), 
			formatMethod: (s) => s + ' ');

		this.viewModel = viewModel;
	}

	IdentityViewModel _viewModel;
	IdentityViewModel get viewModel => _viewModel;

	void set viewModel(IdentityViewModel viewModel)
	{
		_viewModel = viewModel;
		if (viewModel == null)
		{
			_displayNameBinding.binding = null;
		}
		else
		{
			// TODO: Configure the claim that is used as display name
			// Fall back to Identity URN only when that claim is not made by the identity
			_displayNameBinding.binding = viewModel.identity;
		}
	}
}

