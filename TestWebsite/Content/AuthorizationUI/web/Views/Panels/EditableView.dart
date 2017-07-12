import 'dart:html';

import '../../MVVM/ViewModel.dart';
import '../../MVVM/View.dart';
import '../../Views/Base/EditView.dart';

class EditableView extends View
{
	Element _viewPanel;

	ViewModel _viewModel;

	View _displayView;
	EditView _editView;

	Element _refreshButton;
	Element _editButton;
	Element _saveButton;
	Element _cancelButton;

	EditableView(String title, this._viewModel, this._displayView, this._editView)
	{
		var panel = addContainer(classNames: ['panel', 'editable-view']);

		var header = addContainer(parent: panel);
		addHeading(3, title, parent: header);

		var toolbar = addContainer(className: 'tool-bar', parent: header);
		_refreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: toolbar);
		_editButton = addButton('Edit', (MouseEvent e) => edit(), parent: toolbar);
		_saveButton = addButton('Save', (MouseEvent e) => save(), parent: toolbar);
		_cancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: toolbar);

		_viewPanel = addContainer(parent: panel);

		display();
	}

	void display()
	{
		_refreshButton.hidden = false;
		_editButton.hidden = false;
		_saveButton.hidden = true;
		_cancelButton.hidden = true;

		_changeView(_displayView);
	}

	void edit()
	{
		_refreshButton.hidden = true;
		_editButton.hidden = true;
		_saveButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(_editView);
	}

	void refresh()
	{
		_viewModel.reload();
	}

	void save()
	{
		_editView.saveEdits(display);
	}

	void cancel()
	{
		_editView.cancelEdits(display);
	}

	_changeView(View view)
	{
		view.displayIn(_viewPanel);
	}
}
