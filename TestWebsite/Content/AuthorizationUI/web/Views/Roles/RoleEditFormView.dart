import 'dart:html';

import '../../MVVM/Mvvm.dart';

class RoleEditFormView extends View
{
	InputElement displayName;
	TextAreaElement description;
	InputElement codeName;

	Element fieldValidationError;

	RoleEditFormView()
	{
		addBlockText(
			'<p>Create a new role. After creating the role you can assign permissions to it then ' +
			'you can attach it to a group to grant these permissions to all of the users in that group.</p>', 
			className: 'help-note');

		var form = addForm();
		displayName = addLabeledEdit(form, 'Display name');
		description = addLabeledTextArea(form, 'Description');
		codeName = addLabeledEdit(form, 'Code name');

		fieldValidationError = addBlockText('', className: 'validation-error');
		var fieldHelpNote = addBlockText('', className: 'help-note');

		displayName.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>The display name is only used by this user interface to allow you to select the role. ' +
			'If you have a large number of roles you should use a naming convention that makes it easier ' +
			'to find roles when they are sorted alphabetically.</p>');

		displayName.onBlur.listen((Event e) 
		{
			if (displayName.value.length < 3)
			{
				fieldValidationError.innerHtml = 'The display name is too short';
				displayName.focus();
			}
			else
			{
				fieldValidationError.innerHtml = '';
			}
		});

		description.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>Provide a detailed description of the features a group of users will gain access to if this role is ' +
			'assigned to the group. When users are assigning roles to groups it is very important that they understand ' +
			'exactly what they are granting access to, and that id why this description is important.</p>');

		description.onBlur.listen((Event e)
		{
			if (description.value.length < 15)
			{
				fieldValidationError.innerHtml = 'The description is too short';
				description.focus();
			}
			else
			{
				fieldValidationError.innerHtml = '';
			}
		});

		codeName.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>This is a unique name for the role that can be hard-coded into the software. ' +
			'It is strongly advised that you use role code names that are url friendly and contain '+
			'dot separated namespaces.</p>');

		codeName.onBlur.listen((Event e)
		{
			if (codeName.value.length < 3)
			{
				fieldValidationError.innerHtml = 'The code name is too short';
				codeName.focus();
			}
			else
			{
				fieldValidationError.innerHtml = '';
			}
		});
	}

}