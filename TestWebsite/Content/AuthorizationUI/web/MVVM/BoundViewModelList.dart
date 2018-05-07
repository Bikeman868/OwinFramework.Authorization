part of mvvm;

// Abstract base class for components that bind to a list of view models.
// * Subscribes to events from add/remove actions when bound to a list
// * Refreshes the list UI when items are added or removed from the list
// * Unsubscribes from add/remove events when unbound 
// * When items in the list are selected, identifies the element and calls the selection method

abstract class BoundViewModelList<TVM extends ViewModel, TV extends View> extends BoundViewModelListBase<TVM, TV>
{
  BoundViewModelList(
    ViewFactory viewFactory, 
    Element container,
    {
      selectionMethod : null
    })
    : super(viewFactory, container, selectionMethod: selectionMethod);

  ViewModelList<TVM> _binding;
  ViewModelList<TVM> get binding => _binding;

  void set binding(ViewModelList<TVM> value)
  {
    super._unsubscribeFromEvents();

    _binding = value;

    if (value != null)
    {
      refresh();
      _addSubscription = value.onAdd.listen(_onAdd);      
      _deleteSubscription = value.onDelete.listen(_onDelete);
      _listChangedSubscription = value.onListChanged.listen(_onListChanged);
    }
  }

  List<TVM> getViewModels()
  {
    if (_binding == null) return null;
    return binding.viewModels;
  }

}
