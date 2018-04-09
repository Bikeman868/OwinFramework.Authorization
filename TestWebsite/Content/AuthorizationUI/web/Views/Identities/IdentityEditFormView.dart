import 'dart:html';

import '../../MVVM/Mvvm.dart';
import '../../Views/Groups/GroupDropdownSelectView.dart';
import '../../ViewModels/GroupListViewModel.dart';

class IdentityEditFormView extends View
{
	GroupListViewModel _groupListViewModel;
	GroupDropdownSelectView groupSelector;

	IdentityEditFormView(this._groupListViewModel)
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
	}
}