import 'dart:html';

import '../../MVVM/Mvvm.dart';

class EditableListView extends View
{
	ViewModel viewModel;

	View selectView;
	EditView editView;
	EditView addView;

	Element _viewPanel;
	EditView _currentEditView;

	Element _refreshButton;
	Element _editButton;
	Element _newButton;
	Element _saveButton;
	Element _cancelButton;

	EditableListView(String title, this.viewModel, this.selectView, this.editView, this.addView)
	{
		var panel = addContainer(classNames: ['panel', 'editable-list-view']);

		var header = addContainer(parent: panel);
		addHeading(3, title, parent: header);

		var toolbar = addContainer(className: 'tool-bar', parent: header);
		_refreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: toolbar);
		_editButton = addButton('Edit', (MouseEvent e) => edit(), parent: toolbar);
		_newButton = addButton('New', (MouseEvent e) => addNew(), parent: toolbar);
		_saveButton = addButton('Save', (MouseEvent e) => save(), parent: toolbar);
		_cancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: toolbar);

		_viewPanel = addContainer(parent: panel);

		done();
	}

	void done()
	{
		_refreshButton.hidden = false;
		_editButton.hidden = editView == null;
		_newButton.hidden = addView == null;
		_saveButton.hidden = true;
		_cancelButton.hidden = true;

		_changeView(selectView);
	}

	void edit()
	{
		_refreshButton.hidden = true;
		_editButton.hidden = true;
		_newButton.hidden = true;
		_saveButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(editView);
		_currentEditView = editView;
	}

	void addNew()
	{
		_refreshButton.hidden = true;
		_editButton.hidden = true;
		_newButton.hidden = true;
		_saveButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(addView);
		addView.clearForm();
		_currentEditView = addView;
	}

	void refresh()
	{
		viewModel.reload();
	}

	void save()
	{
		if (_currentEditView != null)
			_currentEditView.saveEdits(done);
	}

	void cancel()
	{
		if (_currentEditView != null)
			_currentEditView.cancelEdits(done);
	}

	_changeView(View view)
	{
		view.displayIn(_viewPanel);
		_currentEditView = null;
	}
}
