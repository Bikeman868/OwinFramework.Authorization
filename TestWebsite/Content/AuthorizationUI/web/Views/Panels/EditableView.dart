import 'dart:html';

import '../../MVVM/Mvvm.dart';
import '../../Views/Base/EditView.dart';

class EditableView extends View
{
	Element _viewPanel;

	View displayView;
	EditView editView;
	EditView deleteView;

	EditView _currentEditView;

	Element _refreshButton;
	Element _editButton;
	Element _deleteButton;
	Element _saveButton;
	Element _cancelButton;

	EditableView(String title, this.displayView, [this.editView = null, this.deleteView = null])
	{
		var panel = addContainer(classNames: ['panel', 'editable-view']);

		var header = addContainer(parent: panel);
		addHeading(3, title, parent: header);

		var toolbar = addContainer(className: 'tool-bar', parent: header);
		_refreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: toolbar);
		_editButton = addButton('Edit', (MouseEvent e) => edit(), parent: toolbar);
		_deleteButton = addButton('Delete', (MouseEvent e) => delete(), parent: toolbar);
		_saveButton = addButton('Save', (MouseEvent e) => save(), parent: toolbar);
		_cancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: toolbar);

		_viewPanel = addContainer(parent: panel);

		display();
	}

	void display()
	{
		_refreshButton.hidden = false;
		_editButton.hidden = editView == null;
		_deleteButton.hidden = deleteView == null;
		_saveButton.hidden = true;
		_cancelButton.hidden = true;

		_changeView(displayView);
	}

	void edit()
	{
		_refreshButton.hidden = true;
		_editButton.hidden = true;
		_deleteButton.hidden = true;
		_saveButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(editView);
		_currentEditView = editView;
	}

	void delete()
	{
		if (_currentEditView == deleteView)
		{
			deleteView.deleteRecord(display);
		}
		else
		{
			_refreshButton.hidden = true;
			_editButton.hidden = true;
			_deleteButton.hidden = false;
			_saveButton.hidden = true;
			_cancelButton.hidden = false;

			_changeView(deleteView);
			_currentEditView = deleteView;
		}
	}

	void refresh()
	{
		displayView.reload();
	}

	void save()
	{
		if (editView != null)
			editView.saveEdits(display);
	}

	void cancel()
	{
		if (editView != null)
			editView.cancelEdits(display);
	}

	_changeView(View view)
	{
		view.displayIn(_viewPanel);
		_currentEditView = null;
	}
}
