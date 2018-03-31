import '../../MVVM/Mvvm.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../ViewModels/IdentityListViewModel.dart';
import '../../Views/Base/EditView.dart';

class IdentityDeleteView extends EditView
{
	BoundLabel<String> _displayNameBinding;

	IdentityDeleteView([IdentityViewModel viewModel])
	{
		_displayNameBinding = new BoundLabel<String>(
			addDiv(),
			formatMethod: (s) => 
				'<p>Are you sure you want to delete the "' + s +
				'" identity.</p><p>Deleting this identity will prevent it from accessing the system.</p>');

		this.viewModel = viewModel;
	}

	IdentityViewModel _viewModel;
	IdentityViewModel get viewModel => _viewModel;

	IdentityListViewModel _identityListViewModel;

	void set viewModel(IdentityViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_displayNameBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = value.displayName;
		}
	}

	void deleteRecord(void onSuccess())
	{
		_identityListViewModel.identities.deleteViewModel(_viewModel);

		_identityListViewModel
			.save()
			.then((SaveResult result)
				{
					if (result == SaveResult.saved)
						onSuccess();
				});
	}
}