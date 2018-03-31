import 'dart:html';

import '../../MVVM/Mvvm.dart';

class IdentityEditFormView extends View
{
	IdentityEditFormView()
	{
		addBlockText(
			'<p>Identities normally get created automatically when users create and account on the website. ' +
			'You should only need this editor for creating special use identities, for example server identities.</p>', 
			className: 'help-note');
	}
}