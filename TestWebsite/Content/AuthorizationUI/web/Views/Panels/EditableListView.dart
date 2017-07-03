import 'dart:html';

import '../../MVVM/View.dart';
import '../../Views/Base/NewModelView.dart';

class EditableListView extends View
{
	Element _viewPanel;

	View _selectView;
	View _editView;
	NewModelView _addView;

	Element _editButton;
	Element _newButton;
	Element _doneButton;
	Element _addButton;
	Element _cancelButton;

	EditableListView(String title, View selectView, View editView, NewModelView addView)
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
		_addButton = addButton('Add', _addClicked, parent: toolbar);
		_cancelButton = addButton('Cancel', _doneClicked, parent: toolbar);

		_viewPanel = addContainer(parent: panel);

		_doneClicked(null);
	}

	void _doneClicked(MouseEvent e)
	{
		_editButton.hidden = false;
		_newButton.hidden = false;
		_doneButton.hidden = true;
		_addButton.hidden = true;
		_cancelButton.hidden = true;

		_changeView(_selectView);
	}

	void _editClicked(MouseEvent e)
	{
		_editButton.hidden = true;
		_newButton.hidden = true;
		_doneButton.hidden = false;
		_addButton.hidden = true;
		_cancelButton.hidden = true;

		_changeView(_editView);
	}

	void _newClicked(MouseEvent e)
	{
		_editButton.hidden = true;
		_newButton.hidden = true;
		_doneButton.hidden = true;
		_addButton.hidden = false;
		_cancelButton.hidden = false;

		_changeView(_addView);

		_addView.clearForm();
	}

	void _addClicked(MouseEvent e)
	{
		if (_addView.addModel())
			_doneClicked(e);
	}

	_changeView(View view)
	{
		view.displayIn(_viewPanel);
	}
}
