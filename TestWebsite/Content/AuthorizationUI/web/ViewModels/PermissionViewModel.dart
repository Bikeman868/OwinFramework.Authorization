import 'dart:html';
import 'dart:async';

import '../MVVM/ViewModel.dart';
import '../MVVM/Enums.dart';
import '../MVVM/ModelList.dart';
import '../MVVM/StringBinding.dart';

import '../ViewModels/PermissionListViewModel.dart';

import '../Models/PermissionModel.dart';

class PermissionViewModel extends ViewModel
{
    StringBinding codeName;
    StringBinding displayName;
    StringBinding resource;
    StringBinding description;

	PermissionViewModel([PermissionModel model])
	{
		codeName = new StringBinding();
		displayName = new StringBinding();
		resource = new StringBinding();
		description = new StringBinding();

		this.model = model;
	}

	dispose()
	{
		model = null;
	}

	PermissionModel _model;
	PermissionModel get model => _model;

	void set model(PermissionModel value)
	{
		_model = value;

		if (value == null)
		{
			codeName.setter = null;
			codeName.getter = null;
        
			displayName.setter = null;
			displayName.getter = null;

			resource.setter = null;
			resource.getter = null;

			description.setter = null;
			description.getter = null;
		}
		else
		{
			codeName.setter = (String text) 
			{ 
				value.codeName = text;
				modified();
			};
			codeName.getter = () => value.codeName;
        
			displayName.setter = (String text) 
			{ 
				value.displayName = text; 
				modified();
			};
			displayName.getter = () => value.displayName;
        
			resource.setter = (String text) 
			{ 
				value.resource = text; 
				modified();
			};
			resource.getter = () => value.resource;
        
			description.setter = (String text) 
			{ 
				value.description = text; 
				modified();
			};
			description.getter = () => value.description;
		}
		loaded();
	}

	List<ModelList> getModelLists()
	{
		return [];
	}

	Future<SaveResult> saveChanges(ChangeState state, bool alert) async
	{
		return SaveResult.notsaved;
	}

	String toString() => _model.toString() + ' view model';
}

