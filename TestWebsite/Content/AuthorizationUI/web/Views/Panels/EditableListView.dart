import 'dart:html';

import '../../MVVM/Mvvm.dart';
import '../../Views/Base/EditView.dart';

class EditableListView extends View
{
	ViewModel viewModel;

	View selectView;
	EditView editView;
	EditView addView;

	Element _viewPanel;
	EditView _currentEditView;

	Element _topRefreshButton;
	Element _topEditButton;
	Element _topNewButton;
	Element _topSaveButton;
	Element _topCancelButton;

	Element _bottomRefreshButton;
	Element _bottomEditButton;
	Element _bottomNewButton;
	Element _bottomSaveButton;
	Element _bottomCancelButton;

	EditableListView(String title, this.viewModel, this.selectView, this.editView, this.addView)
	{
		var panel = addContainer(classNames: ['panel', 'editable-list-view']);

		var header = addContainer(parent: panel);
		addHeading(3, title, parent: header);

		var topToolbar = addContainer(className: 'tool-bar', parent: header);
		_topRefreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: topToolbar);
		_topEditButton = addButton('Edit', (MouseEvent e) => edit(), parent: topToolbar);
		_topNewButton = addButton('New', (MouseEvent e) => addNew(), parent: topToolbar);
		_topSaveButton = addButton('Save', (MouseEvent e) => save(), parent: topToolbar);
		_topCancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: topToolbar);

		_viewPanel = addContainer(parent: panel);

		var footer = addContainer(parent: panel);
		addHR(parent: footer);
		addHeading(3, '&nbsp;', parent: footer);

		var bottomToolbar = addContainer(className: 'tool-bar', parent: footer);
		_bottomRefreshButton = addButton('Refresh', (MouseEvent e) => refresh(), parent: bottomToolbar);
		_bottomEditButton = addButton('Edit', (MouseEvent e) => edit(), parent: bottomToolbar);
		_bottomNewButton = addButton('New', (MouseEvent e) => addNew(), parent: bottomToolbar);
		_bottomSaveButton = addButton('Save', (MouseEvent e) => save(), parent: bottomToolbar);
		_bottomCancelButton = addButton('Cancel', (MouseEvent e) => cancel(), parent: bottomToolbar);

		done();
	}

	void done()
	{
		_topRefreshButton.hidden = false;
		_topEditButton.hidden = editView == null;
		_topNewButton.hidden = addView == null;
		_topSaveButton.hidden = true;
		_topCancelButton.hidden = true;

		_bottomRefreshButton.hidden = false;
		_bottomEditButton.hidden = editView == null;
		_bottomNewButton.hidden = addView == null;
		_bottomSaveButton.hidden = true;
		_bottomCancelButton.hidden = true;

		_changeView(selectView);
	}

	void edit()
	{
		_topRefreshButton.hidden = true;
		_topEditButton.hidden = true;
		_topNewButton.hidden = true;
		_topSaveButton.hidden = false;
		_topCancelButton.hidden = false;

		_bottomRefreshButton.hidden = true;
		_bottomEditButton.hidden = true;
		_bottomNewButton.hidden = true;
		_bottomSaveButton.hidden = false;
		_bottomCancelButton.hidden = false;

		_changeView(editView);
		_currentEditView = editView;
	}

	void addNew()
	{
		_topRefreshButton.hidden = true;
		_topEditButton.hidden = true;
		_topNewButton.hidden = true;
		_topSaveButton.hidden = false;
		_topCancelButton.hidden = false;

		_bottomRefreshButton.hidden = true;
		_bottomEditButton.hidden = true;
		_bottomNewButton.hidden = true;
		_bottomSaveButton.hidden = false;
		_bottomCancelButton.hidden = false;

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
