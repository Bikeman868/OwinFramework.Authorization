part of mvvm;

// Provides two-way binding of a list of view models to a drop-down list of views
// * Generates <option> elements and adds them to a <select> container
// * Wraps each view in a container that provides a list selection mechanism

class BoundSelect<TM extends Model, TVM extends ViewModel, TV extends View>
{
    BoundSelect(
		this._viewFactory, 
		this._container,
		this._selectionMethod,
		{
			this.showDeleted : false,
			this.viewModelFilter : null,
			this.staticListItems : null
		}) 
    {
		_container.classes.add('bound-list');
		_container.classes.add('selection-list');
		_container.onChange.listen(_optionSelected);
	}
  
	bool showDeleted;
	Filter<TVM> viewModelFilter;
	List<View> staticListItems;

  	ViewFactory<TVM, TV> _viewFactory;
	SelectElement _container;
	ViewModelMethod<TVM> _selectionMethod;
	
    StreamSubscription<ListEvent> _addSubscription;
    StreamSubscription<ListEvent> _deleteSubscription;
    StreamSubscription<ListEvent> _listChangedSubscription;

    ModelList<TM, TVM> _listBbinding;
    ModelList<TM, TVM> get listBbinding => _listBbinding;

    void set listBbinding(ModelList<TM, TVM> value)
    {
        if (_addSubscription != null)
        {
            _addSubscription.cancel();
            _addSubscription = null;
        }
        if (_deleteSubscription != null)
        {
            _deleteSubscription.cancel();
            _deleteSubscription = null;
        }
		if (_listChangedSubscription != null)
		{
			_listChangedSubscription.cancel();
			_listChangedSubscription = null;
		}

        _listBbinding = value;
		refresh();

        if (value != null)
        {
            _addSubscription = value.onAdd.listen(_onListChanged);      
            _deleteSubscription = value.onDelete.listen(_onListChanged);
			_listChangedSubscription = value.onListChanged.listen(_onListChanged);
        }
    }

	void _onListChanged(ListEvent e)
    {
		refresh();
    }

    void refresh()
    {
        if (_container == null) return;

		var builder = new HtmlBuilder();

		if (staticListItems != null)
		{
			for (var view in staticListItems)
			{
				var option = builder.addDropdownListElement(className: 'bound-list-item');
				view.addTo(option);
			}
		}

        if (_listBbinding != null && _listBbinding.viewModels != null)
        {
            for (var index = 0; index < _listBbinding.viewModels.length; index++)
            {
				var viewModel = _listBbinding.viewModels[index];
				if ((showDeleted || viewModel.getState() != ChangeState.deleted) && 
					(viewModelFilter == null || viewModelFilter(viewModel)))
				{
					var option = builder.addDropdownListElement(className:'bound-list-item');
					option.value = index.toString();

					var view = _viewFactory(_listBbinding.viewModels[index]);
					view.addTo(option);
				}
            }
        }

		builder.displayIn(_container);
    }

	void set selectedIndex(int index)
	{
		_container.value = index.toString();
	}

	void set selectedViewModel(TVM viewModel)
	{
		for (var index = 0; index < _listBbinding.viewModels.length; index++)
		{
			if (_listBbinding.viewModels[index] == viewModel)
			{
				selectedIndex = index;
				return;
			}
		}
	}

	void _optionSelected(MouseEvent e)
	{
		var selectedValue = _container.value;
		if (selectedValue.length == 0)
		{
			_selectionMethod(null);
		}
		else
		{
			int index = int.parse(selectedValue);
			var viewModel = _listBbinding.viewModels[index];
			_selectionMethod(viewModel);
		}
	}

}
