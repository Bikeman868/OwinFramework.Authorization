import 'dart:html';

import '../../MVVM/View.dart';

class EditGroupFormView extends View
{
	InputElement displayName;
	TextAreaElement description;
	InputElement codeName;

	Element fieldValidationError;

	EditGroupFormView()
	{
		addBlockText(
			'<p>Create a new group. After creating the group you can assign roles to the group ' +
			'and then place users into this group to give them those roles.</p>', 
			className: 'help-note');

		var form = addForm();
		displayName = addLabeledEdit(form, 'Display name');
		description = addLabeledTextArea(form, 'Description');
		codeName = addLabeledEdit(form, 'Code name');

		fieldValidationError = addBlockText('', className: 'validation-error');
		var fieldHelpNote = addBlockText('', className: 'help-note');

		displayName.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>The display name is only used by this user interface to allow you to select the group. ' +
			'If you have a large number of groups you should use a naming convention that makes it easier ' +
			'to find groups when they are sorted alphabetically.</p>');

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
			'<p>Provide a detailed description of the features a user will have access to if they ' +
			'are a member of this group.</p>');

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
			'<p>This is a unique name for the group that can be hard-coded into the software. ' +
			'It is strongly advised that you use group code names that are url friendly and contain '+
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