﻿import 'dart:html';

import '../../MVVM/Mvvm.dart';

class PermissionEditFormView extends View
{
	InputElement displayName;
	TextAreaElement description;
	InputElement codeName;
	InputElement resource;

	Element fieldValidationError;

	PermissionEditFormView()
	{
		addBlockText(
			'<p>Create a new permission. After creating the permission you must assign it to one or more roles ' +
			'to make it effective. Your application must also be checking for this permission and restricting ' +
			'access to certain features of the software.</p><p>Only software developers should create new ' +
			'permissions, if you are not a software developer you should</p>', 
			className: 'help-note');

		var form = addForm();
		displayName = addLabeledEdit(form, 'Display name');
		description = addLabeledTextArea(form, 'Description');
		codeName = addLabeledEdit(form, 'Code name');
		resource = addLabeledEdit(form, 'Resource expression');

		fieldValidationError = addBlockText('', className: 'validation-error');
		var fieldHelpNote = addBlockText('', className: 'help-note');

		displayName.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>The display name is only used by this user interface to allow you to select the permission. ' +
			'If you have a large number of permissions you should use a naming convention that makes it easier ' +
			'to find permissions when they are sorted alphabetically.</p>');

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
			'<p>Provide a detailed description of the features a user will gain access to if this permission is ' +
			'granted to them. When users are assigning permissions to roles it is very important that they understand ' +
			'exactly what they are granting access to.</p>');

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
			'<p>This code name must match exactly with the name that is checked by the application code to determine ' +
			'if a user has this permission assigned. The recommended best practice is to format permission code names ' +
			'with the name of the application or sub-system, followed by a colon, followed by a dot separated path to ' +
			'the feature, for example <span class="code">auth:role.assign</span> defines the permission to assign roles ' +
			'within the authentication system.</p>');

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

		resource.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>Leave the resource expression blank to assign this permission to all resources. By filling in the resource ' +
			'expression here, you are granting this permission but only on the resources that match this expression.</p>' +
			'<p>Resources are defined by a resource type name followed by a colon followed by a resource path. For example ' +
			'<span class="code">user:123/profile/image</span> identifies the profile image for user 123. Resource expressions ' +
			'can match a resource name exactly or they can match multiple resources using partial paths and wildcards.</p>'+
			'<p>For example the resource expression <span class="code">user:123/profile</span> will match the profile of user 123 and all ' +
			'sub-paths like <span class="code">user:123/profile/image</span>, <span class="code">user:123/profile/preferences</span> etc.</p>' +
			'<p>You can also use wildwards in resource expressions in place of a higer up path element, for example ' +
			'<span class="code">user:*/profile/image</span> matches profile images for all users.</p>' +
			'<p>You can also reference dynamic data in resource expressions in place of path elements by enclosing them in '+
			'<span class="code">{}</span>, for example <span class="code">user:{my.id}/profile</span> matches the profile of the user ' +
			'making the request. See documentation for a full list of supported dynamic data expressions.</p>');

		resource.onBlur.listen((Event e)
		{
			fieldValidationError.innerHtml = '';
		});
	}

}