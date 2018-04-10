import '../../MVVM/Mvvm.dart';
import '../../Views/Groups/GroupDropdownSelectView.dart';
import '../../Views/Groups/GroupDisplayView.dart';
import '../../ViewModels/GroupListViewModel.dart';
import '../../ViewModels/GroupRoleListViewModel.dart';

class IdentityEditFormView extends View
{
	GroupListViewModel _groupListViewModel;
	GroupRoleListViewModel _groupRoleListViewModel;

	GroupDropdownSelectView groupSelector;
	GroupDisplayView groupView;

	IdentityEditFormView(
		this._groupListViewModel,
		this._groupRoleListViewModel)
	{
		addBlockText(
			'<p>Identities are managed by the Identification System. The Identification System has a UI for ' +
			'managing claims, unlocking blocked accounts, resetting passwords and much more.</p>' +
			'<p>This is the Authorization System which is resposnsible for defining what identities are '+
			'permitted to do within the system. These permissions are granted by assigning each identity '+
			'to a Group.</p>', 
			className: 'help-note');

		var selectDiv = addDiv();
		addInlineText('Assign this identity to ', parent: selectDiv);
		groupSelector = new GroupDropdownSelectView(_groupListViewModel);
		groupSelector.addTo(selectDiv);

		groupView = merge(new GroupDisplayView(_groupRoleListViewModel));
	}
}