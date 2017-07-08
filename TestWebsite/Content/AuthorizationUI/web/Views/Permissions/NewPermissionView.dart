import 'dart:html';

import '../../MVVM/View.dart';
import '../../MVVM/BoundList.dart';

import '../../Server.dart';

import '../../Events/AppEvents.dart';

import '../../Models/PermissionModel.dart';
import '../../Models/ApiResponseModel.dart';

import '../../ViewModels/PermissionViewModel.dart';
import '../../ViewModels/PermissionListViewModel.dart';

import '../Base/NewModelView.dart';

import '../Permissions/PermissionNameView.dart';

class NewPermissionView extends NewModelView
{
	InputElement _displayName;
	InputElement _description;
	InputElement _codeName;
	InputElement _resource;

	Element _fieldValidationError;

	NewPermissionView([PermissionListViewModel viewModel])
	{
		addBlockText(
			'Create a new permission. After creating the permission you must assign it to one or more roles ' +
			'to make it effective. Your application must also be checking for this permission and restricting ' +
			'access to certain features of the software.', 
			className: 'help-note');

		var form = addForm();
		_displayName = addLabeledEdit(form, 'Display name');
		_description = addLabeledEdit(form, 'Description');
		_codeName = addLabeledEdit(form, 'Code name');
		_resource = addLabeledEdit(form, 'Resource filter');

		_fieldValidationError = addBlockText('', className: 'validation-error');
		var fieldHelpNote = addBlockText('', className: 'help-note');

		_displayName.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'The display name is only used by this user interface to allow you to select the permission. ' +
			'If you have a large number of permissions you should use a naming convention that makes it easier ' +
			'to find permissions when they are sorted alphabetically.');

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
			'Provide a detailed description of the features a user will gain access to if this permission is ' +
			'granted to them.');

		_description.onBlur.listen((Event e)
		{
			if (_description.value.length < 20)
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
			'This code name must match exactly with the name that is checked by the application code to determine ' +
			'if a user has this permission assigned. The recommended best practice is to format permission code names ' +
			'with the name of the application or sub-system, followed by a colon, followed by a dot separated path to ' +
			'the feature, for example auth:role.assign defines the permission to assign roles within the authentication system.');

		_codeName.onBlur.listen((Event e)
		{
			_fieldValidationError.innerHtml = '';
		});

		_resource.onFocus.listen((Event e) => fieldHelpNote.innerHtml = 
			'Leave the resource filter blank to assign this permission to all resources. By filling in the resource filter field ' +
			'you are granting this permission but only on specific resources. The resource is defined by ' +
			'a resource type name followed by a colon followed by a resource path. For example ' +
			'<span class="code">group:admins</span>. Resource filters can also include paths using <span class="code">/</span> ' +
			'path separators and wildwards, for example <span class="code">user:*/profile/image</span> means profile images '+
			'for all users.');

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

	void addModel(void onSuccess())
	{
		var permission = new PermissionModel(
			new Map()
				..['codeName'] = _codeName.value
				..['displayName'] = _displayName.value
				..['description'] = _description.value
				..['resource'] = _resource.value);

		Server.validatePermission(permission)
			.then((ApiResponseModel r)
			{
				if (r.isSuccess)
				{
					var vm = _viewModel.permissions.addModel(permission);
					AppEvents.permissionSelected.raise(new PermissionSelectedEvent(vm));
					onSuccess();
				}
				else
				{
					_fieldValidationError.innerHtml = r.error;
				}
			})
			.catchError((Error error) => _fieldValidationError.innerHtml = error.toString());
	}

}