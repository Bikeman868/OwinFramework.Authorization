﻿import '../../MVVM/Mvvm.dart';

class EditView extends View
{
	// Override in derrived classes to initialize the form
	void clearForm()
	{
	}

	// Override in derrived classes to save changes
	void saveEdits(void onSuccess())
	{
		onSuccess();
	}

	// Override in derrived classes to back out changes
	void cancelEdits(void onSuccess())
	{
		onSuccess();
	}

	// Override in derrived classes to delete the record
	void deleteRecord(void onSuccess())
	{
		onSuccess();
	}
}