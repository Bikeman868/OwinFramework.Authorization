import 'dart:html';

import '../../MVVM/ViewModel.dart';
import '../../MVVM/View.dart';
import '../../Views/Base/EditView.dart';

class EditableListView extends View
{
	Element _viewPanel;

	ViewModel _viewModel;

	View _selectView;
	EditView _editView;
	EditView _addView;

	EditView _currentEditView;

	Element _refreshButton;
	Element _editButton;
	Element _newButton;
	Element _doneButton;
	Element _saveButton;
	Element _cancelButton;

	EditableListView(String title, this._viewModel, this._selectView, this._editView, this._addView)
	{
		var panel = addContainer(classNames: ['panel', 'editable-list-view']);

		var header = addContainer(parent: panel);
		addHeading(3, title, parent: header);

		var toolbar = addContainer(className: 'tool-bar', parent: header);
		_refreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: toolbar);
		_editButton = addButton('Edit', (MouseEvent e) => edit(), parent: toolbar);
		_newButton = addButton('New', (MouseEvent e) => addNew(), parent: toolbar);
		_doneButton = addButton('Done', (MouseEvent e) => done(), parent: toolbar);
		_saveButton = addButton('Save', (MouseEvent e) => save(), parent: toolbar);
		_cancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: toolbar);

		_viewPanel = addContainer(parent: panel);

		done();
	}

	void done()
	{
		_refreshButton.hidden = false;
		_editButton.hidden = false;
		_newButton.hidden = false;
		_doneButton.hidden = true;
		_saveButton.hidden = true;
		_cancelButton.hidden = true;

		_changeView(_selectView);
	}

	void edit()
	{
		_refreshButton.hidden = true;
		_editButton.hidden = true;
		_newButton.hidden = true;
		_doneButton.hidden = true;
		_saveButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(_editView);
		_currentEditView = _editView;
	}

	void addNew()
	{
		_refreshButton.hidden = true;
		_editButton.hidden = true;
		_newButton.hidden = true;
		_doneButton.hidden = true;
		_saveButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(_addView);
		_addView.clearForm();
		_currentEditView = _addView;
	}

	void refresh()
	{
		_viewModel.reload();
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
