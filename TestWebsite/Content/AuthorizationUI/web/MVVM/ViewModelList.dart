part of mvvm;

// Use this in your view models to maintain a list of other view models, for
// example a filtered list.
class ViewModelList<TVM extends ViewModel>
{
	// Raised after a new view model is added to the list
	SubscriptionEvent<ListEvent> onAdd = new SubscriptionEvent<ListEvent>();
	
	// Raised after a view model is deleted from the list
	SubscriptionEvent<ListEvent> onDelete = new SubscriptionEvent<ListEvent>();

	// Raised when the whole list of view models is replaced with a new one
	SubscriptionEvent<ListEvent> onListChanged = new SubscriptionEvent<ListEvent>();
  
	// Contains a list of the view models provided in the construcor with any changes applied
	List<TVM> _viewModels;
	List<TVM> get viewModels => _viewModels;

	ViewModelList(this._viewModels)
	{
	}

	void set viewModels(List<TVM> value)
	{
		_viewModels = value;
		onListChanged.raise(new ListEvent(-1));
	}

  // Call this to add a view model to the end of the list
	TVM addViewModel(TVM viewModel)
	{
		if (_viewModels == null)
			_viewModels = new List<TVM>();

		int index = _viewModels.length;

		_viewModels.add(viewModel);
      
		onAdd.raise(new ListEvent(index));

		return viewModel;
	}

	void deleteViewModel(TVM viewModel)
	{
		delete(findIndex(viewModel));
	}

	// Use this to find the index position of a view model so that you
	// can delete it from the list
	int findIndex(TVM viewModel)
	{
		if (_viewModels != null)
		{
			for (var index = _viewModels.length - 1; index >= 0; index--)
			{
				if (_viewModels[index] == viewModel)
					return index;
			}
		}
		return -1;
	}

	// Finds the first view model that matches the predicate function
	TVM findViewModel(bool predicate(TVM))
	{
		var i = viewModels.iterator;
		while (i.moveNext())
			if (predicate(i.current)) return i.current;
		return null;
	}
  
	// Call this to remove a view model from the list
	void delete(int index)
	{
		if (index < 0) return;

    _viewModels.removeAt(index);
    onListChanged.raise(new ListEvent(-1));
	}

	// Calculates the modification status of this list of view models
	ChangeState getState()
	{
		for (TVM viewModel in _viewModels)
		{
			var state = viewModel.getState();
			if (state != ChangeState.unmodified)
				return ChangeState.modified;
		}
		return ChangeState.unmodified;
	}

}
