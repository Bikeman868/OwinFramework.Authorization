import '../../MVVM/Mvvm.dart';
import '../../Models/ClaimModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../ViewModels/ClaimViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../Views/Groups/GroupDisplayView.dart';
import '../../Views/Identities/ClaimDisplayView.dart';

class IdentityDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _identityBinding;
	GroupDisplayView _groupView;

	BoundRepeater<ClaimModel, ClaimViewModel, ClaimDisplayView> _claimListBinding;

	AuthorizationViewModel _authorizationViewModel;

	IdentityDisplayView(
		this._authorizationViewModel,
		[IdentityViewModel viewModel])
	{
		addBlockText(
			'<p>An <b>Identity</b> is someone or something that is allowed access to the system. ' +
			'Identities can have have one or more ways to identify themselves to the system, including logging in with credentials. ' +
			'Identities are assigned to a group, this determines their roles.</p>',
			className: 'help-note');

		var form = addForm();
		_displayNameBinding = new BoundLabel<String>(addLabeledField(form, 'Display name'));
		_identityBinding = new BoundLabel<String>(addLabeledField(form, 'Identity'));

		addHR();
		addHeading(3, 'Identity claims');
		
		_claimListBinding = new BoundRepeater<ClaimModel, ClaimViewModel, ClaimDisplayView>
			((vm) => new ClaimDisplayView(vm), addDiv(className: 'table'));

		addHR();
		addHeading(3, 'Identity group membership');

		_groupView = merge(new GroupDisplayView(_authorizationViewModel.groupRoleList)) as GroupDisplayView;

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
			_identityBinding.binding = null;
			_groupView.viewModel = null;
			_claimListBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = viewModel.displayName;
			_identityBinding.binding = viewModel.identity;
			// _groupView.viewModel = _authorizationViewModel.groupList.groups.viewModels.firstWhere(test);
			_claimListBinding.binding = viewModel.claims;
		}
	}

	reload()
	{
		if (_viewModel != null)
			_viewModel.reload();
	}

}