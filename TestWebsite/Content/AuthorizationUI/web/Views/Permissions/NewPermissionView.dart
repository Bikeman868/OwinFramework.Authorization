import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';
import '../../MVVM/Enums.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/PermissionModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import '../../Views/Base/EditView.dart';
import '../../Views/Permissions/PermissionNameView.dart';

class NewPermissionView extends EditView
{
	InputElement _displayName;
	InputElement _description;
	InputElement _codeName;
	InputElement _resource;

	Element _fieldValidationError;

	NewPermissionView([PermissionListViewModel viewModel])
	{
		addBlockText(
			'<p>Create a new permission. After creating the permission you must assign it to one or more roles ' +
			'to make it effective. Your application must also be checking for this permission and restricting ' +
			'access to certain features of the software.</p><p>Only software developers should create new ' +
			'permissions, if you are not a software developer you should</p>', 
			className: 'help-note');

		var form = addForm();
		_displayName = addLabeledEdit(form, 'Display name');
		_description = addLabeledEdit(form, 'Description');
		_codeName = addLabeledEdit(form, 'Code name');
		_resource = addLabeledEdit(form, 'Resource expression');

		_fieldValidationError = addBlockText('', className: 'validation-error');
		var fieldHelpNote = addBlockText('', className: 'help-note');

		_displayName.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>The display name is only used by this user interface to allow you to select the permission. ' +
			'If you have a large number of permissions you should use a naming convention that makes it easier ' +
			'to find permissions when they are sorted alphabetically.</p>');

		_displayName.onBlur.listen((Event e) 
		{
			if (_displayName.value.length < 3)
			{
				_fieldValidationError.innerHtml = 'The display name is too short';
				_displayName.focus();
			}
			else
			{
				_fieldValidationError.innerHtml = '';
			}
		});

		_description.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>Provide a detailed description of the features a user will gain access to if this permission is ' +
			'granted to them. When users are assigning permissions to roles it is very important that they understand ' +
			'exactly what they are granting access to.</p>');

		_description.onBlur.listen((Event e)
		{
			if (_description.value.length < 15)
			{
				_fieldValidationError.innerHtml = 'The description is too short';
				_description.focus();
			}
			else
			{
				_fieldValidationError.innerHtml = '';
			}
		});

		_codeName.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>This code name must match exactly with the name that is checked by the application code to determine ' +
			'if a user has this permission assigned. The recommended best practice is to format permission code names ' +
			'with the name of the application or sub-system, followed by a colon, followed by a dot separated path to ' +
			'the feature, for example <span class="code">auth:role.assign</span> defines the permission to assign roles ' +
			'within the authentication system.</p>');

		_codeName.onBlur.listen((Event e)
		{
			if (_codeName.value.length < 3)
			{
				_fieldValidationError.innerHtml = 'The code name is too short';
				_codeName.focus();
			}
			else
			{
				_fieldValidationError.innerHtml = '';
			}
		});

		_resource.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'<p>Leave the resource expression blank to assign this permission to all resources. By filling in the resource ' +
			'expression here, you are granting this permission but only on the resources that match this expression.</p>' +
			'<p>Resources are defined by a resource type name followed by a colon followed by a resource path. For example ' +
			'<span class="code">user:123/profile/image</span> identifies the profile image for user 123. Resource expressions ' +
			'can match a resource name exactly or they can match multiple resources using partial paths and wildcards.</p>'+
			'<p>For example the resource expression <span class="code">user:123/profile</span> will match the profile of user 123 and all ' +
			'sub-paths like <span class="code">user:123/profile/image</span>, <span class="code">user:123/profile/preferences</span> etc.</p>' +
			'<p>You can also use wildwards in resource expressions in place of a higer up path element, for example ' +
			'<span class="code">user:*/profile/image</span> matches profile images for all users.</p>');

		_resource.onBlur.listen((Event e)
		{
			_fieldValidationError.innerHtml = '';
		});

		this.viewModel = viewModel;
	}

	PermissionListViewModel _viewModel;
	PermissionListViewModel get viewModel => _viewModel;

	void set viewModel(PermissionListViewModel value)
	{
		_viewModel = value;
	}

	void clearForm()
	{
		_displayName.value = '';
		_description.value = '';
		_codeName.value = '';
		_resource.value = '';

		_displayName.focus();
	}

	void saveEdits(void onSuccess())
	{
		var permission = new PermissionModel(null)
			..codeName = _codeName.value
			..displayName = _displayName.value
			..description = _description.value
			..resource = _resource.value;

		Server.validatePermission(permission)
			.then((ApiResponseModel r)
			{
				if (r.isSuccess)
				{
					var vm = _viewModel.permissions.addModel(permission);
					AppEvents.permissionSelected.raise(new PermissionSelectedEvent(vm));

					vm.save()
						.then((SaveResult saveResult) => onSuccess())
						.catchError((Error error) => _fieldValidationError.innerHtml = error.toString());
				}
				else
				{
					_fieldValidationError.innerHtml = r.error;
				}
			})
			.catchError((Error error) => _fieldValidationError.innerHtml = error.toString());
	}

}