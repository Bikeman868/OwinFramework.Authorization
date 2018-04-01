import 'dart:html';

import '../../MVVM/Mvvm.dart';
import '../../Models/ClaimModel.dart';
import '../../ViewModels/AuthorizationViewModel.dart';
import '../../ViewModels/IdentityViewModel.dart';
import '../../ViewModels/ClaimViewModel.dart';
import '../../ViewModels/GroupViewModel.dart';
import '../../Views/Groups/GroupDisplayView.dart';
import '../../Views/Identities/ClaimTableRowView.dart';

class IdentityDisplayView extends View
{
	BoundLabel<String> _displayNameBinding;
	BoundLabel<String> _identityBinding;
	BoundLabel<String> _groupNameBinding;
	GroupDisplayView _groupView;

	BoundRepeater<ClaimModel, ClaimViewModel, ClaimTableRowView> _claimListBinding;

	AuthorizationViewModel _authorizationViewModel;

	Element _groupPanel;

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
		
		addBlockText(
			'<p><b>Claims</b> are additional information about the identity. Some of this information ' +
			'is provided by the identity, some is manually entered into this UI, and some is captured ' +
			'by the system automatically. The status of each claim indicates whether the claim was just ' +
			'made by the identity, or whether is was validated manually, or by some system process.</p>',
			className: 'help-note');

		var claimTableHeading = addDiv(className: 'tr', parent: addDiv(className: 'table'));
		addDiv(html:'Claim', classNames: ['th', 'display-name', 'claim'], parent: claimTableHeading);
		addDiv(html:'Value', classNames: ['th', 'claim-value', 'claim'], parent: claimTableHeading);
		addDiv(html:'Status', classNames: ['th', 'claim-status', 'claim'], parent: claimTableHeading);

		_claimListBinding = new BoundRepeater<ClaimModel, ClaimViewModel, ClaimTableRowView>
			((vm) => new ClaimTableRowView(vm), addDiv(className: 'table'));

		_groupPanel = addContainer();

		addHR(parent: _groupPanel);
		_groupNameBinding = new BoundLabel<String>(
			addHeading(3, 'Identity group membership', parent: _groupPanel), 
			formatMethod: (s) => 'Belongs to the ' + s + ' group');

		_groupView = new GroupDisplayView(_authorizationViewModel.groupRoleList);
		_groupView.addTo(_groupPanel);

		this.viewModel = viewModel;
	}

	IdentityViewModel _viewModel;
	IdentityViewModel get viewModel => _viewModel;

	void set viewModel(IdentityViewModel identity)
	{
		_viewModel = identity;
		if (identity == null)
		{
			_displayNameBinding.binding = null;
			_identityBinding.binding = null;
			_groupView.viewModel = null;
			_claimListBinding.binding = null;
		}
		else
		{
			_displayNameBinding.binding = identity.displayName;
			_identityBinding.binding = identity.identity;
			_claimListBinding.binding = identity.claims;

		}

		displayGroup();
	}

	displayGroup()
	{
		if (_viewModel == null)
		{
			_groupPanel.hidden = true;
		}
		else
		{
			int groupId = _viewModel.groupId.getter();

			var groupViewModel = _authorizationViewModel.groupList.groups.viewModels.firstWhere(
				(GroupViewModel group) => group.id == groupId, 
				orElse: () => null);

			if (groupViewModel == null)
			{
				_groupView.viewModel = null;
				_groupNameBinding.binding = null;
				_groupPanel.hidden = true;
			}
			else
			{
				_groupView.viewModel = groupViewModel;
				_groupNameBinding.binding = groupViewModel.displayName;
				_groupPanel.hidden = false;
			}
		}
	}

	reload()
	{
		if (_viewModel != null)
		{
			_viewModel.reload();
			displayGroup();
		}
	}

}