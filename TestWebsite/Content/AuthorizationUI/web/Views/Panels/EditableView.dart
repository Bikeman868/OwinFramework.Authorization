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

	Element _topRefreshButton;
	Element _topEditButton;
	Element _topDeleteButton;
	Element _topSaveButton;
	Element _topCancelButton;

	Element _bottomRefreshButton;
	Element _bottomEditButton;
	Element _bottomDeleteButton;
	Element _bottomSaveButton;
	Element _bottomCancelButton;

	EditableView(String title, this.displayView, [this.editView = null, this.deleteView = null])
	{
		var panel = addContainer(classNames: ['panel', 'editable-view']);

		var header = addContainer(parent: panel);
		addHeading(3, title, parent: header);

		var topToolbar = addContainer(className: 'tool-bar', parent: header);
		_topRefreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: topToolbar);
		_topEditButton = addButton('Edit', (MouseEvent e) => edit(), parent: topToolbar);
		_topDeleteButton = addButton('Delete', (MouseEvent e) => delete(), parent: topToolbar);
		_topSaveButton = addButton('Save', (MouseEvent e) => save(), parent: topToolbar);
		_topCancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: topToolbar);

		_viewPanel = addContainer(parent: panel);

		var footer = addContainer(parent: panel);
		addHR(parent: footer);
		addHeading(3, '&nbsp;', parent: footer);

		var bottomToolbar = addContainer(className: 'tool-bar', parent: footer);
		_bottomRefreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: bottomToolbar);
		_bottomEditButton = addButton('Edit', (MouseEvent e) => edit(), parent: bottomToolbar);
		_bottomDeleteButton = addButton('Delete', (MouseEvent e) => delete(), parent: bottomToolbar);
		_bottomSaveButton = addButton('Save', (MouseEvent e) => save(), parent: bottomToolbar);
		_bottomCancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: bottomToolbar);

		display();
	}

	void display()
	{
		_topRefreshButton.hidden = false;
		_topEditButton.hidden = editView == null;
		_topDeleteButton.hidden = deleteView == null;
		_topSaveButton.hidden = true;
		_topCancelButton.hidden = true;

		_bottomRefreshButton.hidden = false;
		_bottomEditButton.hidden = editView == null;
		_bottomDeleteButton.hidden = deleteView == null;
		_bottomSaveButton.hidden = true;
		_bottomCancelButton.hidden = true;

		_changeView(displayView);
	}

	void edit()
	{
		_topRefreshButton.hidden = true;
		_topEditButton.hidden = true;
		_topDeleteButton.hidden = true;
		_topSaveButton.hidden = false;
		_topCancelButton.hidden = false;

		_bottomRefreshButton.hidden = true;
		_bottomEditButton.hidden = true;
		_bottomDeleteButton.hidden = true;
		_bottomSaveButton.hidden = false;
		_bottomCancelButton.hidden = false;

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
			_topRefreshButton.hidden = true;
			_topEditButton.hidden = true;
			_topDeleteButton.hidden = false;
			_topSaveButton.hidden = true;
			_topCancelButton.hidden = false;

			_bottomRefreshButton.hidden = true;
			_bottomEditButton.hidden = true;
			_bottomDeleteButton.hidden = false;
			_bottomSaveButton.hidden = true;
			_bottomCancelButton.hidden = false;

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
