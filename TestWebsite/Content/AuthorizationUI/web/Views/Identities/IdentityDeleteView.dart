import '../../MVVM/Mvvm.dart';
import '../../Server.dart';
import '../../Models/ApiResponseModel.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../Views/Base/EditView.dart';

class IdentityDeleteView extends EditView
{
	BoundLabel<String> _identityBinding;

	IdentityDeleteView([IdentityViewModel viewModel])
	{
		_identityBinding = new BoundLabel<String>(
			addDiv(),
			formatMethod: (s) => 
				'<p>Are you sure you want to delete the "' + s + '" identity from the authorization system.</p>' +
				'<p>Deleting this identity from this Authorization System will remove any permissions assigned to it, and give it the same level of access as public users.</p>' +
				'<p><i>Note that this will not delete anything from the Identification System; the claims, credentials and other information that is managed by the Identification System will not be deleted</i></p>');

		this.viewModel = viewModel;
	}

	IdentityViewModel _viewModel;
	IdentityViewModel get viewModel => _viewModel;

	void set viewModel(IdentityViewModel value)
	{
		_viewModel = value;
		if (value == null)
		{
			_identityBinding.binding = null;
		}
		else
		{
			_identityBinding.binding = value.identity;
		}
	}

	void deleteRecord(void onSuccess())
	{
		if (_viewModel == null) return;

		Server
			.deleteIdentity(_viewModel.identity.getter())
			.then((ApiResponseModel response)
				{
					if (response.isSuccess)
						onSuccess();
				});
	}
}