﻿part of mvvm;

// Abstract base class for components that bind to a list of view models.
// * Subscribes to events from add/remove actions when bound to a list
// * Refreshes the list UI when items are added or removed from the list
// * Unsubscribes from add/remove events when unbound 
// * When items in the list are selected, identifies the element and calls the selection method

abstract class BoundViewModelListBase<TVM extends ViewModel, TV extends View>
{
  BoundViewModelListBase(
    this.viewFactory,
    Element container, 
    {
      this.selectionMethod : null
    })
  {
      this.container = container;
  }
  
  List<TVM> getViewModels();
  void initializeContainer(Element value);
  void refresh();
  
  StreamSubscription<ListEvent> _addSubscription;
  StreamSubscription<ListEvent> _deleteSubscription;
  StreamSubscription<ListEvent> _listChangedSubscription;

  void _unsubscribeFromEvents()
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
  }

  ViewFactory<TVM, TV> viewFactory;
	ViewModelMethod<TVM> selectionMethod;

  Element _container;
  Element get container => _container;
	void set container(Element value) 
	{
		_container = value;
		initializeContainer(value);
		refresh();
	}

	void itemClicked(MouseEvent e)
	{
		if (selectionMethod == null) return;
    var viewModels = getViewModels();
    if (viewModels == null) return;

		Element element = e.target;
		while (element != null)
		{
			var indexAttribute = element.attributes['index'];
			if (indexAttribute != null)
			{
				int index = int.parse(indexAttribute);
				var viewModel = viewModels[index];
				if (viewModel != null)
					selectionMethod(viewModel);
				return;
			}
			element = element.parent;
		}
	}

  void _onAdd(ListEvent e)
  {
		refresh();

		if (selectionMethod == null) return;

    var viewModels = getViewModels();
    if (viewModels == null) return;

		var viewModel = viewModels[e.index];
		if (viewModel != null)
			selectionMethod(viewModel);
  }
  
  void _onDelete(ListEvent e)
  {
		refresh();
  }

	void _onListChanged(ListEvent e)
  {
		refresh();
  }
}
