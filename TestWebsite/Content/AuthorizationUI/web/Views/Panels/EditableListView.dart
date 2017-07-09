import 'dart:html';

import '../../MVVM/View.dart';
import '../../Views/Base/EditView.dart';

class EditableListView extends View
{
	Element _viewPanel;

	View _selectView;
	EditView _editView;
	EditView _addView;

	EditView _currentEditView;

	Element _editButton;
	Element _newButton;
	Element _doneButton;
	Element _saveButton;
	Element _cancelButton;

	EditableListView(String title, View selectView, EditView editView, EditView addView)
	{
		_selectView = selectView;
		_editView = editView;
		_addView = addView;

		var panel = addContainer(classNames: ['panel', 'editable-list-view']);

		var header = addContainer(parent: panel);
		addHeading(3, title, parent: header);

		var toolbar = addContainer(className: 'tool-bar', parent: header);
		_editButton = addButton('Edit', _editClicked, parent: toolbar);
		_newButton = addButton('New', _newClicked, parent: toolbar);
		_doneButton = addButton('Done', _doneClicked, parent: toolbar);
		_saveButton = addButton('Save', _saveClicked, parent: toolbar);
		_cancelButton = addButton('Cancel', _cancelClicked, parent: toolbar);

		_viewPanel = addContainer(parent: panel);

		done();
	}

	void _doneClicked(MouseEvent e)
	{
		done();
	}

	void _editClicked(MouseEvent e)
	{
		edit();
	}

	void _newClicked(MouseEvent e)
	{
		addNew();
	}

	void _saveClicked(MouseEvent e)
	{
		save();
	}

	void _cancelClicked(MouseEvent e)
	{
		cancel();
	}

	void done()
	{
		_editButton.hidden = false;
		_newButton.hidden = false;
		_doneButton.hidden = true;
		_saveButton.hidden = true;
		_cancelButton.hidden = true;

		_changeView(_selectView);
	}

	void edit()
	{
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
		_editButton.hidden = true;
		_newButton.hidden = true;
		_doneButton.hidden = true;
		_saveButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(_addView);
		_addView.clearForm();
		_currentEditView = _addView;
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
